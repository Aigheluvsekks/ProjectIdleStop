/**
  ******************************************************************************
  * @file    CAN_Manager.h
  * @brief   CAN Bus filtering, reception, and health manager
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


/* Exported Types ------------------------------------------------------------ */

/**
 * @brief Simplified structure to hold a CAN message
 */
typedef struct
{
    uint32_t ID;        /* Message ID (Standard or Extended) */

    bool isExtID;       /* True = Extended ID, False = Standard ID */

    uint8_t DLC;        /* Data Length Code (0 to 8 bytes) */

    uint8_t Data[8];    /* CAN payload buffer */

} CAN_Msg_t;


/* Exported Function Prototypes ---------------------------------------------- */

/**
 * @brief Starts the CAN peripheral and enables RX interrupts.
 */
void CAN_Manager_Init(CAN_HandleTypeDef *hcan1);


/**
 * @brief Configures a 32-bit hardware mask filter for Standard IDs.
 *
 * @param hcan1       CAN peripheral handle
 * @param filterBank  Filter bank number
 * @param targetID    CAN ID to allow
 * @param mask        CAN ID mask
 *
 * Examples:
 *
 *     targetID = 0x11F
 *     mask     = 0x7FF
 *
 *     Allows ONLY 0x11F.
 *
 *
 *     targetID = 0x000
 *     mask     = 0x000
 *
 *     Allows ALL Standard IDs.
 */
void CAN_Manager_ConfigFilter_StdID(
    CAN_HandleTypeDef *hcan1,
    uint32_t filterBank,
    uint32_t targetID,
    uint32_t mask
);


/**
 * @brief Reads a message directly from the hardware FIFO.
 *
 * @return true  if a message was successfully read
 * @return false if FIFO is empty or reception failed
 */
bool CAN_Manager_ReadMessage(
    CAN_HandleTypeDef *hcan1,
    uint32_t rxFifo,
    CAN_Msg_t *pMsg
);


/**
 * @brief CAN RX callback.
 *
 * Called from HAL_CAN_RxFifo0MsgPendingCallback().
 */
void CAN_Manager_RxCallback(
    CAN_HandleTypeDef *hcan1
);


/**
 * @brief Get timestamp of the last RPM message.
 *
 * @return Timestamp from HAL_GetTick(), in milliseconds.
 */
uint32_t CAN_GetLastRPMUpdate(void);


/**
 * @brief Check CAN peripheral health.
 *
 * @return true  if CAN is healthy
 * @return false if CAN is unhealthy
 */
bool CAN_IsHealthy(void);


/* --------------------------------------------------------------------------
 * Live Expression / Debug Variables
 * -------------------------------------------------------------------------- */

/*
 * Latest CAN frame received.
 *
 * Live Expressions:
 *
 *     CAN_RX_Debug.ID
 *     CAN_RX_Debug.DLC
 *     CAN_RX_Debug.Data[0]
 *     CAN_RX_Debug.Data[1]
 *     ...
 *     CAN_RX_Debug.Data[7]
 *     CAN_RX_Debug.isExtID
 */
extern volatile CAN_Msg_t CAN_RX_Debug;


/*
 * Number of CAN messages successfully received.
 *
 * This should continuously increase when CAN traffic is being received.
 */
extern volatile uint32_t CAN_RX_Count;


/*
 * Indicates whether at least one CAN frame has been received.
 *
 *     0 = No CAN frame received
 *     1 = At least one CAN frame received
 */
extern volatile bool CAN_RX_Valid;


/*
 * Timestamp of the most recent RPM message.
 *
 * Unit: milliseconds.
 */
extern volatile uint32_t CAN_LastRPM_Update;


/*
 * Current HAL CAN state.
 *
 * Useful for debugging CAN initialization/state.
 */
extern volatile uint32_t CAN_State_Debug;


/*
 * Current HAL CAN error code.
 *
 * Useful for diagnosing CAN errors.
 */
extern volatile uint32_t CAN_Error_Debug;


/*
 * CAN health status.
 *
 *     0 = CAN unhealthy
 *     1 = CAN healthy
 */
extern volatile bool CAN_Health_Debug;


/* --------------------------------------------------------------------------
 * Other CAN Address Update Functions
 * -------------------------------------------------------------------------- */

/*
 * Other CAN addresses, reserved for development purposes.
 *
 * These can be implemented later when the corresponding
 * CAN messages are identified and decoded.
 */

/*
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
*/


#ifdef __cplusplus
}
#endif

#endif /* CAN_MANAGER_H */
