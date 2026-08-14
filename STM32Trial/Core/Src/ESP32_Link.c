/**
  ******************************************************************************
  * @file    ESP32_Link.c
  * @brief   STM32 to ESP32 Communication Link implementation
  ******************************************************************************
  */

#include "ESP32_Link.h"
#include <string.h>

void ESP32_Link_Init(ESP32_HandleTypeDef *hesp, UART_HandleTypeDef *huart) {
    hesp->huart = huart;
    hesp->RxIndex = 0;
    hesp->NewDataReady = false;
    memset(hesp->RxBuffer, 0, ESP32_RX_BUFFER_SIZE);

    /* Start listening for the first byte via Interrupt */
    HAL_UART_Receive_IT(hesp->huart, &hesp->RxByte, 1);
}

void ESP32_Link_Transmit(ESP32_HandleTypeDef *hesp, const char *payload) {
    uint16_t len = strlen(payload);
    /* Blocking transmit. For high-speed applications, consider HAL_UART_Transmit_DMA */
    HAL_UART_Transmit(hesp->huart, (uint8_t*)payload, len, 100);
}

void ESP32_Link_RxCallback(ESP32_HandleTypeDef *hesp) {
    /* Check for end-of-line characters (Newline \n or Carriage Return \r) */
    if (hesp->RxByte == '\n' || hesp->RxByte == '\r') {
        if (hesp->RxIndex > 0) {
            hesp->RxBuffer[hesp->RxIndex] = '\0'; /* Null-terminate the string */
            hesp->NewDataReady = true;            /* Flag that a message is ready */
        }
    }
    else {
        /* Store the byte if there is room in the buffer */
        if (hesp->RxIndex < (ESP32_RX_BUFFER_SIZE - 1)) {
            hesp->RxBuffer[hesp->RxIndex++] = hesp->RxByte;
        }
    }

    /* Restart the interrupt to listen for the next byte */
    HAL_UART_Receive_IT(hesp->huart, &hesp->RxByte, 1);
}

bool ESP32_Link_ReadMessage(ESP32_HandleTypeDef *hesp, char *outBuffer, uint16_t maxLen) {
    if (hesp->NewDataReady) {
        strncpy(outBuffer, (char*)hesp->RxBuffer, maxLen);

        /* Reset state for the next message */
        hesp->RxIndex = 0;
        hesp->NewDataReady = false;
        memset(hesp->RxBuffer, 0, ESP32_RX_BUFFER_SIZE);
        return true;
    }
    return false;
}
