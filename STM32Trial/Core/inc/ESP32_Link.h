#ifndef ESP32_LINK_H
#define ESP32_LINK_H

#include "stm32f4xx_hal.h"
#include <stdint.h>
#include <stdbool.h>

#define ESP32_RX_BUFFER_SIZE    128U

typedef struct
{
    UART_HandleTypeDef *huart;

    uint8_t RxByte;

    volatile uint8_t RxBuffer[ESP32_RX_BUFFER_SIZE];
    volatile uint16_t RxIndex;

    volatile bool NewDataReady;

} ESP32_HandleTypeDef;


/* Initialization */
void ESP32_Link_Init(ESP32_HandleTypeDef *hesp,
                     UART_HandleTypeDef *huart);


/* Transmit string to ESP32 */
HAL_StatusTypeDef ESP32_Link_Transmit(ESP32_HandleTypeDef *hesp,
                                      const char *payload);


/* Called from HAL_UART_RxCpltCallback() */
void ESP32_Link_RxCallback(ESP32_HandleTypeDef *hesp);


/* Check whether a complete message has arrived */
bool ESP32_Link_ReadMessage(ESP32_HandleTypeDef *hesp,
                            char *outBuffer,
                            uint16_t maxLen);

#endif
