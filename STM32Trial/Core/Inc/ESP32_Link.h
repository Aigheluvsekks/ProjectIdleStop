/**
  ******************************************************************************
  * @file    ESP32_Link.h
  * @brief   STM32 to ESP32 Communication Link via UART
  ******************************************************************************
  */

#ifndef ESP32_LINK_H
#define ESP32_LINK_H

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"
#include <stdint.h>
#include <stdbool.h>

/* Constants -----------------------------------------------------------------*/
#define ESP32_RX_BUFFER_SIZE  (128U)

/* Exported Types ------------------------------------------------------------*/
typedef struct {
    UART_HandleTypeDef *huart;
    uint8_t            RxBuffer[ESP32_RX_BUFFER_SIZE];
    uint8_t            RxByte;       /* Temporary storage for 1-byte interrupt */
    uint16_t           RxIndex;      /* Current position in the buffer */
    bool               NewDataReady; /* Flag indicating complete message received */
} ESP32_HandleTypeDef;

/* Exported Function Prototypes ----------------------------------------------*/

/**
 * @brief Initializes the link and starts listening for data via interrupt.
 */
void ESP32_Link_Init(ESP32_HandleTypeDef *hesp, UART_HandleTypeDef *huart);

/**
 * @brief Sends a formatted string or data to the ESP32.
 */
void ESP32_Link_Transmit(ESP32_HandleTypeDef *hesp, const char *payload);

/**
 * @brief To be called inside HAL_UART_RxCpltCallback to process incoming bytes.
 */
void ESP32_Link_RxCallback(ESP32_HandleTypeDef *hesp);

/**
 * @brief Reads the completed message if NewDataReady is true.
 */
bool ESP32_Link_ReadMessage(ESP32_HandleTypeDef *hesp, char *outBuffer, uint16_t maxLen);

#ifdef __cplusplus
}
#endif

#endif /* ESP32_LINK_H */
