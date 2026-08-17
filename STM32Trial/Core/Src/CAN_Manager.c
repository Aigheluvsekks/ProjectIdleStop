/**
  ******************************************************************************
  * @file    CAN_Manager.c
  * @brief   CAN Bus filtering and reception manager implementation
  ******************************************************************************
  */

#include "CAN_Manager.h"
#include "CAN_Decode.h" /* Ensure this file exists in your project */

/* Private Variables to hold timestamps --------------------------------------*/
static uint32_t lastRpmUpdate = 0;
static uint32_t lastSwingLUpdate = 0;
static uint32_t lastSwingRUpdate = 0;
static uint32_t lastBoomDUpdate = 0;
static uint32_t lastBoomUUpdate = 0;
static uint32_t lastArmDigUpdate = 0;
static uint32_t lastBucketDumpUpdate = 0;
static uint32_t lastTravelLRUpdate = 0;
static uint32_t lastTravelLFUpdate = 0;
static uint32_t lastTravelRRUpdate = 0;
static uint32_t lastTravelRFUpdate = 0;

/* Function Implementations --------------------------------------------------*/

void CAN_Manager_Init(CAN_HandleTypeDef *hcan1) {
    /* 1. Start the CAN peripheral */
    HAL_CAN_Start(hcan1);

    /* 2. Activate interrupts for both FIFOs so we don't miss messages */
    HAL_CAN_ActivateNotification(hcan1, CAN_IT_RX_FIFO0_MSG_PENDING | CAN_IT_RX_FIFO1_MSG_PENDING);
}

void CAN_Manager_ConfigFilter_StdID(CAN_HandleTypeDef *hcan1, uint32_t filterBank, uint32_t targetID, uint32_t mask) {
    CAN_FilterTypeDef filterConfig = {0};

    /*
     * STM32 bxCAN QUIRK:
     * In 32-bit scale mode, the 11-bit Standard ID must be shifted left by 21 bits.
     * The upper 16 bits of this shifted value go into FilterIdHigh.
     * Therefore, we shift the 11-bit ID left by 5 bits (21 - 16 = 5) to align it.
     */
    filterConfig.FilterIdHigh       = (targetID << 5);
    filterConfig.FilterIdLow        = 0x0000;

    filterConfig.FilterMaskIdHigh   = (mask << 5);
    filterConfig.FilterMaskIdLow    = 0x0000;

    /* General Filter Configuration */
    filterConfig.FilterFIFOAssignment = CAN_RX_FIFO0;          /* Route passing messages to FIFO 0 */
    filterConfig.FilterBank           = filterBank;            /* Filter bank number */
    filterConfig.FilterMode           = CAN_FILTERMODE_IDMASK; /* Mask mode (check bits based on mask) */
    filterConfig.FilterScale          = CAN_FILTERSCALE_32BIT; /* 32-bit single filter mode */
    filterConfig.FilterActivation     = CAN_FILTER_ENABLE;     /* Turn the filter on */
    filterConfig.SlaveStartFilterBank = 14;                    /* Relevant only if using dual CAN (CAN1/CAN2) */

    /* Apply the filter to the hardware */
    HAL_CAN_ConfigFilter(hcan1, &filterConfig);
}

bool CAN_Manager_ReadMessage(CAN_HandleTypeDef *hcan1, uint32_t rxFifo, CAN_Msg_t *pMsg) {
    CAN_RxHeaderTypeDef rxHeader;

    /* Attempt to pull the message out of the hardware FIFO */
    if (HAL_CAN_GetRxMessage(hcan1, rxFifo, &rxHeader, pMsg->Data) == HAL_OK) {

        /* Check if it's a Standard or Extended ID frame */
        pMsg->isExtID = (rxHeader.IDE == CAN_ID_EXT);

        /* Store the correct ID and Length */
        pMsg->ID  = pMsg->isExtID ? rxHeader.ExtId : rxHeader.StdId;
        pMsg->DLC = rxHeader.DLC;

        return true; /* Success */
    }
    return false; /* FIFO was empty or error */
}

void CAN_Manager_RxCallback(CAN_HandleTypeDef *hcan1)
{
    CAN_Msg_t incomingMsg;

    /* Read from FIFO 0 */
    if (CAN_Manager_ReadMessage(hcan1, CAN_RX_FIFO0, &incomingMsg)) {

        /* Example data handling logic: */
        if (incomingMsg.ID == 0x11F) {
            CAN_DecodeMessage(incomingMsg.ID, incomingMsg.Data, incomingMsg.DLC);

            // Example of updating a timestamp variable from HAL_GetTick()
            // lastRpmUpdate = HAL_GetTick();
        }
    }
}

void HAL_CAN_RxFifo0MsgPendingCallback(CAN_HandleTypeDef *hcan1)
{
    CAN_Manager_RxCallback(hcan1);
}

/* Status and Timing Implementations -----------------------------------------*/

uint32_t CAN_GetLastRPMUpdate(void)       { return lastRpmUpdate; }
uint32_t CAN_GetLastSwingLUpdate(void)    { return lastSwingLUpdate; }
uint32_t CAN_GetLastSwingRUpdate(void)    { return lastSwingRUpdate; }
uint32_t CAN_GetLastBoomDUpdate(void)     { return lastBoomDUpdate; }
uint32_t CAN_GetLastBoomUUpdate(void)     { return lastBoomUUpdate; }
uint32_t CAN_GetLastArmDigUpdate(void)    { return lastArmDigUpdate; }
uint32_t CAN_GetLastBucketDumpUpdate(void){ return lastBucketDumpUpdate; }
uint32_t CAN_GetLastTravelLRUpdate(void)  { return lastTravelLRUpdate; }
uint32_t CAN_GetLastTravelLFUpdate(void)  { return lastTravelLFUpdate; }
uint32_t CAN_GetLastTravelRRUpdate(void)  { return lastTravelRRUpdate; }
uint32_t CAN_GetLastTravelRFUpdate(void)  { return lastTravelRFUpdate; }

bool CAN_IsHealthy(void) {
    /*
     * Implement your health logic here.
     * For example, checking if (HAL_GetTick() - lastRpmUpdate) < 500ms
     */
    return true;
}
