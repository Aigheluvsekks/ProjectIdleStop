/**
  ******************************************************************************
  * @file    CAN_Manager.c
  * @brief   CAN Bus filtering and reception manager implementation
  ******************************************************************************
  */

#include "CAN_Manager.h"
#include "CAN_Decode.h"

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
    if (CAN_Manager_ReadMessage(hcan, CAN_RX_FIFO0, &incomingMsg)) {

        /* Example data handling logic: */
        if (incomingMsg.ID == 0x11F) {
        	CAN_DecodeMessage(incomingMsg.ID, incomingMsg.Data, incomingMsg.DLC);
            // Do something with incomingMsg.Data[0] ...
        }

    }
}

void HAL_CAN_RxFifo0MsgPendingCallback(CAN_HandleTypeDef *hcan)
{
    CAN_Manager_RxCallback(hcan);
}
