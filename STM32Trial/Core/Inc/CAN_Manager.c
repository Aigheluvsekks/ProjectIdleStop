/**
  ******************************************************************************
  * @file    CAN_Manager.c
  * @brief   CAN Bus filtering, reception, and health manager implementation
  ******************************************************************************
  */

#include "CAN_Manager.h"
#include "CAN_Decode.h"
#include <stddef.h>

/* --------------------------------------------------------------------------
 * Private Variables
 * -------------------------------------------------------------------------- */

static CAN_HandleTypeDef *pLocalHcan = NULL;

/*
 * Last time a valid 0x11F RPM frame was received.
 */
static volatile uint32_t lastRpmUpdateTick = 0;


/* --------------------------------------------------------------------------
 * Debug Variables
 * -------------------------------------------------------------------------- */

/* Latest received CAN frame */
volatile CAN_Msg_t CAN_RX_Debug = {0};

/* Total number of received frames */
volatile uint32_t CAN_RX_Count = 0;

/* At least one frame received */
volatile bool CAN_RX_Valid = false;

/* Last RPM message timestamp */
volatile uint32_t CAN_LastRPM_Update = 0;

/* CAN diagnostic state */
volatile uint32_t CAN_State_Debug = 0;
volatile uint32_t CAN_Error_Debug = 0;
volatile bool CAN_Health_Debug = false;

/* Number of times FIFO0 callback has executed */
volatile uint32_t CAN_RX_CallbackCount = 0;


volatile uint32_t debug_rpm_interval = 0;
volatile uint32_t debug_rpm_max_interval = 0;
volatile uint32_t debug_rpm_rx_count = 0;

/* --------------------------------------------------------------------------
 * FROZEN 0x11F DEBUG CAPTURE
 * -------------------------------------------------------------------------- */

volatile CAN_Msg_t CAN_RX_First11F_Debug = {0};
volatile bool CAN_RX_First11F_Captured = false;
volatile uint32_t CAN_RX_First11F_Timestamp = 0;


/* --------------------------------------------------------------------------
 * MANUAL CAPTURE
 * -------------------------------------------------------------------------- */

volatile bool CAN_RX_CaptureArm = false;
volatile bool CAN_RX_CaptureDone = false;
volatile CAN_Msg_t CAN_RX_CapturedFrame = {0};


/* --------------------------------------------------------------------------
 * CAN Manager Initialization
 * -------------------------------------------------------------------------- */

void CAN_Manager_Init(CAN_HandleTypeDef *hcan1)
{
    if (hcan1 == NULL)
    {
        pLocalHcan = NULL;

        CAN_State_Debug = 0;
        CAN_Error_Debug = 0;
        CAN_Health_Debug = false;

        return;
    }

    pLocalHcan = hcan1;

    /*
     * Start CAN
     */
    if (HAL_CAN_Start(hcan1) != HAL_OK)
    {
        CAN_State_Debug =
            (uint32_t)HAL_CAN_GetState(hcan1);

        CAN_Error_Debug =
            HAL_CAN_GetError(hcan1);

        CAN_Health_Debug = false;

        return;
    }


    /*
     * Enable FIFO0 RX interrupt
     */
    if (HAL_CAN_ActivateNotification(
            hcan1,
            CAN_IT_RX_FIFO0_MSG_PENDING) != HAL_OK)
    {
        CAN_State_Debug =
            (uint32_t)HAL_CAN_GetState(hcan1);

        CAN_Error_Debug =
            HAL_CAN_GetError(hcan1);

        CAN_Health_Debug = false;

        return;
    }


    /*
     * Save diagnostic state
     */
    CAN_State_Debug =
        (uint32_t)HAL_CAN_GetState(hcan1);

    CAN_Error_Debug =
        HAL_CAN_GetError(hcan1);

    CAN_Health_Debug =
        (CAN_State_Debug == (uint32_t)HAL_CAN_STATE_LISTENING) &&
        (CAN_Error_Debug == HAL_CAN_ERROR_NONE);
}


/* --------------------------------------------------------------------------
 * CAN Filter Configuration
 * -------------------------------------------------------------------------- */

void CAN_Manager_ConfigFilter_StdID(
    CAN_HandleTypeDef *hcan1,
    uint32_t filterBank,
    uint32_t targetID,
    uint32_t mask
)
{
    CAN_FilterTypeDef filterConfig = {0};

    if (hcan1 == NULL)
    {
        CAN_State_Debug = 0;
        CAN_Error_Debug = 0;
        CAN_Health_Debug = false;

        return;
    }


    /*
     * Standard CAN ID = 11 bits.
     */
    targetID &= 0x7FFU;
    mask &= 0x7FFU;


    /*
     * Standard ID occupies bits [15:5]
     * in the 32-bit bxCAN filter.
     */
    filterConfig.FilterIdHigh =
        (uint16_t)(targetID << 5);

    filterConfig.FilterIdLow =
        0x0000;


    filterConfig.FilterMaskIdHigh =
        (uint16_t)(mask << 5);


    /*
     * Require:
     *
     * IDE = 0 -> Standard frame
     * RTR = 0 -> Data frame
     *
     * bxCAN:
     * bit 3 = IDE
     * bit 4 = RTR
     */
    filterConfig.FilterMaskIdLow =
        0x0018;


    /*
     * Accepted frames go to FIFO0.
     */
    filterConfig.FilterFIFOAssignment =
        CAN_FILTER_FIFO0;

    filterConfig.FilterBank =
        filterBank;

    filterConfig.FilterMode =
        CAN_FILTERMODE_IDMASK;

    filterConfig.FilterScale =
        CAN_FILTERSCALE_32BIT;

    filterConfig.FilterActivation =
        CAN_FILTER_ENABLE;

    filterConfig.SlaveStartFilterBank =
        14;


    if (HAL_CAN_ConfigFilter(
            hcan1,
            &filterConfig) != HAL_OK)
    {
        CAN_State_Debug =
            (uint32_t)HAL_CAN_GetState(hcan1);

        CAN_Error_Debug =
            HAL_CAN_GetError(hcan1);

        CAN_Health_Debug = false;
    }
}


/* --------------------------------------------------------------------------
 * Read CAN Message
 * -------------------------------------------------------------------------- */

bool CAN_Manager_ReadMessage(
    CAN_HandleTypeDef *hcan1,
    uint32_t rxFifo,
    CAN_Msg_t *pMsg
)
{
    CAN_RxHeaderTypeDef rxHeader;

    if ((hcan1 == NULL) ||
        (pMsg == NULL))
    {
        return false;
    }


    /*
     * Read directly from bxCAN FIFO.
     *
     * NO decoding.
     * NO conversion.
     * NO modification of payload.
     */
    if (HAL_CAN_GetRxMessage(
            hcan1,
            rxFifo,
            &rxHeader,
            pMsg->Data) != HAL_OK)
    {
        return false;
    }


    /*
     * Determine ID type.
     */
    pMsg->isExtID =
        (rxHeader.IDE == CAN_ID_EXT);


    /*
     * Store ID.
     */
    if (pMsg->isExtID)
    {
        pMsg->ID =
            rxHeader.ExtId;
    }
    else
    {
        pMsg->ID =
            rxHeader.StdId;
    }


    /*
     * Store DLC.
     */
    pMsg->DLC =
        rxHeader.DLC;


    return true;
}


/* --------------------------------------------------------------------------
 * CAN RX Callback
 * -------------------------------------------------------------------------- */

void CAN_Manager_RxCallback(
    CAN_HandleTypeDef *hcan1
)
{
    CAN_Msg_t incomingMsg;


    if ((hcan1 == NULL) ||
        (hcan1 != pLocalHcan))
    {
        return;
    }


    /*
     * Proves the interrupt callback is executing.
     */
    CAN_RX_CallbackCount++;


    /*
     * Drain FIFO0.
     *
     * Important because several frames can arrive
     * before the CPU gets to the callback.
     */
    while (
        HAL_CAN_GetRxFifoFillLevel(
            hcan1,
            CAN_RX_FIFO0
        ) > 0
    )
    {
        /*
         * Read one complete frame directly from hardware.
         */
        if (!CAN_Manager_ReadMessage(
                hcan1,
                CAN_RX_FIFO0,
                &incomingMsg))
        {
            break;
        }


        /* ------------------------------------------------------------------
         * SAVE LATEST FRAME
         * ------------------------------------------------------------------ */

        CAN_RX_Debug =
            incomingMsg;

        CAN_RX_Count++;

        CAN_RX_Valid = true;


        /* ------------------------------------------------------------------
         * 0x11F FRAME
         * ------------------------------------------------------------------ */

        if ((incomingMsg.ID == 0x11FU) &&
            (incomingMsg.isExtID == false))
        {
            /*
             * --------------------------------------------------------------
             * FIRST 0x11F CAPTURE
             * --------------------------------------------------------------
             */

            if (CAN_RX_First11F_Captured == false)
            {
                CAN_RX_First11F_Debug =
                    incomingMsg;

                CAN_RX_First11F_Timestamp =
                    HAL_GetTick();

                CAN_RX_First11F_Captured =
                    true;
            }


            /*
             * --------------------------------------------------------------
             * MANUAL CAPTURE
             * --------------------------------------------------------------
             */

            if ((CAN_RX_CaptureArm == true) &&
                (CAN_RX_CaptureDone == false))
            {
                CAN_RX_CapturedFrame =
                    incomingMsg;

                CAN_RX_CaptureDone =
                    true;

                CAN_RX_CaptureArm =
                    false;
            }


            /*
             * --------------------------------------------------------------
             * RPM TIMESTAMP
             *
             * IMPORTANT:
             * Only 0x11F updates the RPM timestamp.
             * --------------------------------------------------------------
             */

            uint32_t now = HAL_GetTick();

            if (lastRpmUpdateTick != 0)
            {
                debug_rpm_interval = now - lastRpmUpdateTick;

                if (debug_rpm_interval > debug_rpm_max_interval)
                {
                    debug_rpm_max_interval = debug_rpm_interval;
                }
            }

            debug_rpm_rx_count++;

            lastRpmUpdateTick = now;

            CAN_LastRPM_Update = lastRpmUpdateTick;


            /*
             * --------------------------------------------------------------
             * DECODE 0x11F
             * --------------------------------------------------------------
             */

            CAN_DecodeMessage(
                incomingMsg.ID,
                incomingMsg.Data,
                incomingMsg.DLC
            );
        }
    }


    /*
     * Update FIFO diagnostic level
     */
#ifdef CAN_RX_FIFO0_Level

    CAN_RX_FIFO0_Level =
        HAL_CAN_GetRxFifoFillLevel(
            hcan1,
            CAN_RX_FIFO0
        );

#endif


    /*
     * Update CAN diagnostic state
     */
    CAN_State_Debug =
        (uint32_t)HAL_CAN_GetState(hcan1);

    CAN_Error_Debug =
        HAL_CAN_GetError(hcan1);
}


/* --------------------------------------------------------------------------
 * HAL CAN FIFO0 Callback
 * -------------------------------------------------------------------------- */

void HAL_CAN_RxFifo0MsgPendingCallback(
    CAN_HandleTypeDef *hcan1
)
{
    CAN_Manager_RxCallback(hcan1);
}


/* --------------------------------------------------------------------------
 * Get Last RPM Update
 * -------------------------------------------------------------------------- */

uint32_t CAN_GetLastRPMUpdate(void)
{
    return lastRpmUpdateTick;
}


/* --------------------------------------------------------------------------
 * CAN Health
 * -------------------------------------------------------------------------- */

bool CAN_IsHealthy(void)
{
    if (pLocalHcan == NULL)
    {
        CAN_Health_Debug = false;

        return false;
    }


    HAL_CAN_StateTypeDef state =
        HAL_CAN_GetState(pLocalHcan);

    uint32_t errorCode =
        HAL_CAN_GetError(pLocalHcan);


    CAN_State_Debug =
        (uint32_t)state;

    CAN_Error_Debug =
        errorCode;


    if ((state == HAL_CAN_STATE_LISTENING) &&
        (errorCode == HAL_CAN_ERROR_NONE))
    {
        CAN_Health_Debug = true;

        return true;
    }


    CAN_Health_Debug = false;

    return false;
}
