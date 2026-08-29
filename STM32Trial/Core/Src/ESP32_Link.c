#include "ESP32_Link.h"
#include <string.h>
#include <stddef.h>
#include <stdbool.h>
#include <stdint.h>

/**
  * @brief Initialize ESP32 communication link and arm the UART RX interrupt.
  */
void ESP32_Link_Init(ESP32_HandleTypeDef *hesp, UART_HandleTypeDef *huart)
{
    if (hesp == NULL || huart == NULL)
    {
        return;
    }

    hesp->huart = huart;
    hesp->RxIndex = 0;
    hesp->RxByte = 0;
    hesp->NewDataReady = false;
    memset((void*)hesp->RxBuffer, 0, ESP32_RX_BUFFER_SIZE);

    // Arm UART to receive 1 byte in interrupt mode
    HAL_UART_Receive_IT(hesp->huart, (uint8_t*)&(hesp->RxByte), 1);
}

/**
  * @brief Transmit a null-terminated string to the ESP32.
  */
HAL_StatusTypeDef ESP32_Link_Transmit(ESP32_HandleTypeDef *hesp, const char *payload)
{
    if (hesp == NULL || hesp->huart == NULL || payload == NULL)
    {
        return HAL_ERROR;
    }

    uint16_t len = (uint16_t)strlen(payload);
    if (len == 0)
    {
        return HAL_OK;
    }

    return HAL_UART_Transmit(hesp->huart, (uint8_t*)payload, len, 100);
}

/**
  * @brief Process single byte RX and re-arm the interrupt (Called from HAL_UART_RxCpltCallback).
  */
void ESP32_Link_RxCallback(ESP32_HandleTypeDef *hesp)
{
    if (hesp == NULL || hesp->huart == NULL)
    {
        return;
    }

    // Check for delimiter / end of packet (\n or \r)
    if (hesp->RxByte == '\n' || hesp->RxByte == '\r')
    {
        if (hesp->RxIndex > 0)
        {
            hesp->RxBuffer[hesp->RxIndex] = '\0';
            hesp->NewDataReady = true;
        }
    }
    else
    {
        // Prevent buffer overrun
        if (hesp->RxIndex < (ESP32_RX_BUFFER_SIZE - 1))
        {
            hesp->RxBuffer[hesp->RxIndex++] = hesp->RxByte;
        }
        else
        {
            // Reset on overflow to prevent corrupt un-terminated string
            hesp->RxIndex = 0;
        }
    }

    // Re-arm interrupt for the next byte
    HAL_UART_Receive_IT(hesp->huart, (uint8_t*)&(hesp->RxByte), 1);
}

/**
  * @brief Read a completed message from the buffer if available.
  */
bool ESP32_Link_ReadMessage(ESP32_HandleTypeDef *hesp, char *outBuffer, uint16_t maxLen)
{
    if (hesp == NULL || outBuffer == NULL || maxLen == 0)
    {
        return false;
    }

    if (hesp->NewDataReady)
    {
        strncpy(outBuffer, (const char*)hesp->RxBuffer, maxLen - 1);
        outBuffer[maxLen - 1] = '\0';

        // Clear state and buffer for the next incoming frame
        hesp->RxIndex = 0;
        memset((void*)hesp->RxBuffer, 0, ESP32_RX_BUFFER_SIZE);
        hesp->NewDataReady = false;

        return true;
    }

    return false;
}
