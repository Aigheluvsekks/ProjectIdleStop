/**
  ******************************************************************************
  * @file    CAN_Manager.c
  * @brief   CAN Bus filtering, reception, and health manager implementation
  ******************************************************************************
  */

#include "CAN_Manager.h"
#include "CAN_Decode.h"
#include <stddef.h>

/* --- Private Variables --- */
static CAN_HandleTypeDef *pLocalHcan = NULL;
static volatile uint32_t lastRpmUpdateTick = 0;

/* --- Function Implementations --- */

void CAN_Manager_Init(CAN_HandleTypeDef *hcan1) {
    pLocalHcan = hcan1;

    /* 1. Start the CAN peripheral */
    HAL_CAN_Start(hcan1);

    /* 2. Activate interrupts for both FIFOs */
    HAL_CAN_ActivateNotification(hcan1, CAN_IT_RX_FIFO0_MSG_PENDING | CAN_IT_RX_FIFO1_MSG_PENDING);
}

void CAN_Manager_ConfigFilter_StdID(CAN_HandleTypeDef *hcan1, uint32_t filterBank, uint32_t targetID, uint32_t mask) {
    CAN_FilterTypeDef filterConfig = {0};

    /*
     * STM32 bxCAN:
     * In 32-bit scale mode, standard 11-bit ID is mapped to bits [31:21].
     * FilterIdHigh holds bits [31:16], so shift the 11-bit ID left by 5 bits (21 - 16).
     */
    filterConfig.FilterIdHigh         = (targetID << 5);
    filterConfig.FilterIdLow          = 0x0000;
    filterConfig.FilterMaskIdHigh     = (mask << 5);
    filterConfig.FilterMaskIdLow      = 0x0000;
    filterConfig.FilterFIFOAssignment = CAN_RX_FIFO0;
    filterConfig.FilterBank           = filterBank;
    filterConfig.FilterMode           = CAN_FILTERMODE_IDMASK;
    filterConfig.FilterScale          = CAN_FILTERSCALE_32BIT;
    filterConfig.FilterActivation     = CAN_FILTER_ENABLE;
    filterConfig.SlaveStartFilterBank = 14;

    HAL_CAN_ConfigFilter(hcan1, &filterConfig);
}

bool CAN_Manager_ReadMessage(CAN_HandleTypeDef *hcan1, uint32_t rxFifo, CAN_Msg_t *pMsg) {
    CAN_RxHeaderTypeDef rxHeader;

    if (HAL_CAN_GetRxMessage(hcan1, rxFifo, &rxHeader, pMsg->Data) == HAL_OK) {
        pMsg->isExtID = (rxHeader.IDE == CAN_ID_EXT);
        pMsg->ID      = pMsg->isExtID ? rxHeader.ExtId : rxHeader.StdId;
        pMsg->DLC     = rxHeader.DLC;
        return true;
    }
    return false;
}

void CAN_Manager_RxCallback(CAN_HandleTypeDef *hcan1) {
    CAN_Msg_t incomingMsg;

    if (CAN_Manager_ReadMessage(hcan1, CAN_RX_FIFO0, &incomingMsg)) {
        /* Record timestamp and decode message when RPM ID (0x11F) is received */
        if (incomingMsg.ID == 0x11F) {
            lastRpmUpdateTick = HAL_GetTick();
            CAN_DecodeMessage(incomingMsg.ID, incomingMsg.Data, incomingMsg.DLC);
        }
    }
}

void HAL_CAN_RxFifo0MsgPendingCallback(CAN_HandleTypeDef *hcan1) {
    CAN_Manager_RxCallback(hcan1);
}

uint32_t CAN_GetLastRPMUpdate(void) {
    return lastRpmUpdateTick;
}

bool CAN_IsHealthy(void) {
    if (pLocalHcan == NULL) {
        return false;
    }

    HAL_CAN_StateTypeDef state = HAL_CAN_GetState(pLocalHcan);
    uint32_t errorCode = HAL_CAN_GetError(pLocalHcan);

    if ((state == HAL_CAN_STATE_LISTENING || state == HAL_CAN_STATE_READY) && (errorCode == HAL_CAN_ERROR_NONE)) {
        return true;
    }

    return false;
}
