#include "io_output.h"

void IO_Output_Init(void)
{
    // Nothing required here for now.
    // GPIO initialization is handled by CubeMX-generated MX_GPIO_Init().
}

void IO_CutoffRelay_On(uint8_t state) //Cutoff On (Engine off)
{
        HAL_GPIO_WritePin(
            GPIOE,
            GPIO_PIN_7,
            GPIO_PIN_SET
        );
    }

void IO_CutoffRelay_Off(uint8_t state) // Cutoff Off (Engine On)
{
        HAL_GPIO_WritePin(
            GPIOE,
            GPIO_PIN_7,
            GPIO_PIN_RESET
        );
    }
}

void IO_PilotGreen_On(uint8_t state) //Pilot Green LED ON
{
        HAL_GPIO_WritePin(
            GPIOE,
            GPIO_PIN_3,
            GPIO_PIN_SET
        );
}

void IO_PilotGreen_Off(uint8_t state) //Pilot Green LED OFF
{
        HAL_GPIO_WritePin(
            GPIOE,
            GPIO_PIN_3,
            GPIO_PIN_RESET
        );
}

void IO_PilotYellow_On(uint8_t state) //Pilot Yellow LED ON
{

        HAL_GPIO_WritePin(
            GPIOE,
            GPIO_PIN_4,
            GPIO_PIN_SET
        );
}

void IO_PilotYellow_Off(uint8_t state) //Pilot LED Yellow Off
{
        HAL_GPIO_WritePin(
            GPIOE,
            GPIO_PIN_4,
            GPIO_PIN_RESET
        );
}


void IO_PilotRed_On(uint8_t state) //Alarm Pilot Red ON
{
        HAL_GPIO_WritePin(
            GPIOE,
            GPIO_PIN_5,
            GPIO_PIN_SET
        );
    }

void IO_PilotRed_Off(uint8_t state) //Alarm Pilot Red OFF
{
        HAL_GPIO_WritePin(
            GPIOE,
            GPIO_PIN_5,
            GPIO_PIN_RESET
        );
}
