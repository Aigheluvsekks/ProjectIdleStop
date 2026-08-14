/**
  ******************************************************************************
  * @file    CAN_Manager.h
  * @brief   CAN Bus filtering and reception manager
  ******************************************************************************
  */

#ifndef CAN_MANAGER_H
#define CAN_MANAGER_H

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"
#include <stdint.h>
#include <stdbool.h>

/* Exported Types ------------------------------------------------------------*/

/**
 * @brief Simplified structure to hold a decoded CAN message
 */
typedef struct {
    uint32_t ID;        /* Message ID (Standard or Extended) */
    bool     isExtID;   /* True if Extended ID (29-bit), False if Standard (11-bit) */
    uint8_t  DLC;       /* Data Length Code (0 to 8 bytes) */
    uint8_t  Data[8];   /* Payload buffer */
} CAN_Msg_t;

/* Exported Function Prototypes ----------------------------------------------*/

/**
 * @brief Starts the CAN peripheral and enables RX interrupts.
 */
void CAN_Manager_Init(CAN_HandleTypeDef *hcan);

/**
 * @brief Configures a 32-bit hardware mask filter for Standard IDs (11-bit).
 * @param filterBank The filter bank number (0-13 for single CAN)
 * @param targetID   The specific ID you want to allow (e.g., 0x100)
 * @param mask       The mask (0x7FF requires exact ID match, 0x000 lets all pass)
 */
void CAN_Manager_ConfigFilter_StdID(CAN_HandleTypeDef *hcan, uint32_t filterBank, uint32_t targetID, uint32_t mask);

/**
 * @brief Reads a message directly from the hardware FIFO.
 * @return true if a message was successfully read, false if FIFO is empty.
 */
bool CAN_Manager_ReadMessage(CAN_HandleTypeDef *hcan, uint32_t rxFifo, CAN_Msg_t *pMsg);

/**
 * @brief Callback function to be placed inside HAL_CAN_RxFifo0MsgPendingCallback.
 */
void CAN_Manager_RxCallback(CAN_HandleTypeDef *hcan);

#ifdef __cplusplus
}
#endif

/* Put these inside CAN_Manager.h */
uint32_t CAN_GetLastRPMUpdate(void);
uint32_t CAN_GetLastSwingLUpdate(void);
uint32_t CAN_GetLastSwingRUpdate(void);
uint32_t CAN_GetLastBoomDUpdate(void);
uint32_t CAN_GetLastBoomUUpdate(void);
uint32_t CAN_GetLastArmDigUpdate(void);
uint32_t CAN_GetLastBucketDumpUpdate(void);
uint32_t CAN_GetLastTravelLRUpdate(void);
uint32_t CAN_GetLastTravelLFUpdate(void);
uint32_t CAN_GetLastTravelRRUpdate(void);
uint32_t CAN_GetLastTravelRFUpdate(void);

bool CAN_IsHealthy(void);
#endif /* CAN_MANAGER_H */
