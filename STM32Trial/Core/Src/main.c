/* USER CODE BEGIN Header */

/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2026 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */

/* USER CODE END Header */


/* Includes ------------------------------------------------------------------*/

#include "main.h"


/* Private includes ----------------------------------------------------------*/

/* USER CODE BEGIN Includes */

#include "CAN_Decode.h"
#include "CAN_Manager.h"
#include "Decision.h"
#include "io_input.h"
#include "io_output.h"
#include "Machine_Config_Max.h"
#include "Machine_Param.h"
#include "System_Health.h"
#include "System_Manager.h"
#include "Timer_Manager.h"

/* USER CODE END Includes */


/* Private typedef -----------------------------------------------------------*/

/* USER CODE BEGIN PTD */

/* USER CODE END PTD */


/* Private define ------------------------------------------------------------*/

/* USER CODE BEGIN PD */

/* USER CODE END PD */


/* Private macro -------------------------------------------------------------*/

/* USER CODE BEGIN PM */

/* USER CODE END PM */


/* Private variables ---------------------------------------------------------*/

CAN_HandleTypeDef hcan1;

RTC_HandleTypeDef hrtc;

UART_HandleTypeDef huart1;


/* USER CODE BEGIN PV */

/* USER CODE END PV */


/* Private function prototypes -----------------------------------------------*/

void SystemClock_Config(void);

static void MX_GPIO_Init(void);

static void MX_CAN1_Init(void);

static void MX_RTC_Init(void);

static void MX_USART1_UART_Init(void);


/* USER CODE BEGIN PFP */

/* USER CODE END PFP */


/* Private user code ---------------------------------------------------------*/

/* USER CODE BEGIN 0 */

/* USER CODE END 0 */


/**
  * @brief  The application entry point.
  * @retval int
  */

int main(void)
{
    /* USER CODE BEGIN 1 */

    /* USER CODE END 1 */


    /* MCU Configuration--------------------------------------------------------*/

    HAL_Init();


    /* USER CODE BEGIN Init */

    /* USER CODE END Init */


    /* Configure the system clock */

    SystemClock_Config();


    /* USER CODE BEGIN SysInit */

    /* USER CODE END SysInit */


    /* Initialize all configured peripherals */

    MX_GPIO_Init();

    MX_CAN1_Init();

    MX_RTC_Init();

    MX_USART1_UART_Init();


    /* USER CODE BEGIN 2 */


    /* ------------------------------------------------------------------------
     * Initialize Application IO
     * ------------------------------------------------------------------------ */

    IO_Output_Init();


    /* ------------------------------------------------------------------------
     * CAN FILTER
     * ------------------------------------------------------------------------
     *
     * CAN bus:
     *
     *     Bitrate = 250 kbps
     *
     * Target CAN message:
     *
     *     Standard ID = 0x11F
     *
     * Mask:
     *
     *     0x7FF
     *
     * This means:
     *
     *     ONLY standard CAN ID 0x11F
     *
     * will enter FIFO0.
     *
     * Filter MUST be configured before
     * CAN_Manager_Init(), because Init() starts CAN.
     * ------------------------------------------------------------------------ */

    CAN_Manager_ConfigFilter_StdID(
        &hcan1,
        0,
        0x11F,
        0x7FF
    );


    /* ------------------------------------------------------------------------
     * Start CAN and enable RX FIFO0 interrupt
     * ------------------------------------------------------------------------ */

    CAN_Manager_Init(&hcan1);


    /* ------------------------------------------------------------------------
     * Startup indication
     * ------------------------------------------------------------------------ */

    uint32_t startTime = HAL_GetTick();

    IO_PilotGreen_On(1);
    IO_PilotYellow_On(1);
    IO_PilotRed_On(1);
    IO_CutoffRelay_On(1);


    while ((HAL_GetTick() - startTime) < 3000)
    {
        /*
         * Startup delay.
         */
    }


    IO_PilotGreen_Off(1);
    IO_PilotYellow_Off(1);
    IO_PilotRed_Off(1);
    IO_CutoffRelay_Off(1);


    /* ------------------------------------------------------------------------
     * Initialize system state machine
     * ------------------------------------------------------------------------ */

    SystemManager_Init();


    /*
     * SystemManager_Init() currently starts in SYSTEM_DISABLED.
     *
     * For the first implementation, enter monitoring mode.
     */

    SystemManager_SetState(SYSTEM_MONITORING);


    /* USER CODE END 2 */


    /* Infinite loop */

    /* USER CODE BEGIN WHILE */

    while (1)
    {

        /* USER CODE END WHILE */


        /* USER CODE BEGIN 3 */


        /* ====================================================================
         * MAIN APPLICATION LOOP
         * ==================================================================== */

        OperatingMode_t operating_mode =
            IO_GetOperatingMode();


        /* --------------------------------------------------------------------
         * Idle Stop System ENABLED
         * -------------------------------------------------------------------- */

        if (operating_mode == IdleStop_On)
        {
            if (SystemManager_GetState() == SYSTEM_DISABLED)
            {
                SystemManager_SetState(SYSTEM_MONITORING);
            }

            SystemManager_Process();

            IO_PilotYellow_Off(1);
        }


        /* --------------------------------------------------------------------
         * Idle Stop System DISABLED
         * -------------------------------------------------------------------- */

        else if (operating_mode == IdleStop_Off)
        {
            Timer_Manager_Stop();

            IO_CutoffRelay_Off(1);

            SystemManager_SetState(SYSTEM_DISABLED);

            IO_PilotYellow_Off(1);

            IO_PilotGreen_Off(1);

            IO_PilotRed_Off(1);
        }


        /* --------------------------------------------------------------------
         * Service Mode
         * -------------------------------------------------------------------- */

        else if (operating_mode == Service_On)
        {
            Timer_Manager_Stop();

            IO_CutoffRelay_Off(1);

            SystemManager_SetState(SYSTEM_DISABLED);

            IO_PilotYellow_On(1);
        }


        /* --------------------------------------------------------------------
         * Invalid / Fault Operating Mode
         * -------------------------------------------------------------------- */

        else
        {
            Timer_Manager_Stop();

            IO_CutoffRelay_Off(1);

            SystemManager_SetState(SYSTEM_FAULT);

            IO_PilotGreen_On(1);

            IO_PilotRed_On(1);

            IO_PilotYellow_On(1);
        }

    }


    /* USER CODE END 3 */
}


/**
  * @brief System Clock Configuration
  * @retval None
  */

void SystemClock_Config(void)
{
    RCC_OscInitTypeDef RCC_OscInitStruct = {0};

    RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};


    /* Configure the main internal regulator output voltage */

    __HAL_RCC_PWR_CLK_ENABLE();

    __HAL_PWR_VOLTAGESCALING_CONFIG(
        PWR_REGULATOR_VOLTAGE_SCALE1
    );


    /* ------------------------------------------------------------------------
     * Oscillator Configuration
     * ------------------------------------------------------------------------ */

    RCC_OscInitStruct.OscillatorType =
        RCC_OSCILLATORTYPE_HSI |
        RCC_OSCILLATORTYPE_LSI;

    RCC_OscInitStruct.HSIState =
        RCC_HSI_ON;

    RCC_OscInitStruct.HSICalibrationValue =
        RCC_HSICALIBRATION_DEFAULT;

    RCC_OscInitStruct.LSIState =
        RCC_LSI_ON;

    RCC_OscInitStruct.PLL.PLLState =
        RCC_PLL_NONE;


    if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
    {
        Error_Handler();
    }


    /* ------------------------------------------------------------------------
     * CPU / AHB / APB Clock Configuration
     * ------------------------------------------------------------------------ */

    RCC_ClkInitStruct.ClockType =
        RCC_CLOCKTYPE_HCLK |
        RCC_CLOCKTYPE_SYSCLK |
        RCC_CLOCKTYPE_PCLK1 |
        RCC_CLOCKTYPE_PCLK2;

    RCC_ClkInitStruct.SYSCLKSource =
        RCC_SYSCLKSOURCE_HSI;

    RCC_ClkInitStruct.AHBCLKDivider =
        RCC_SYSCLK_DIV1;

    RCC_ClkInitStruct.APB1CLKDivider =
        RCC_HCLK_DIV1;

    RCC_ClkInitStruct.APB2CLKDivider =
        RCC_HCLK_DIV1;


    if (HAL_RCC_ClockConfig(
            &RCC_ClkInitStruct,
            FLASH_LATENCY_0) != HAL_OK)
    {
        Error_Handler();
    }
}


/**
  * @brief CAN1 Initialization Function
  * @param None
  * @retval None
  */

static void MX_CAN1_Init(void)
{
    /* USER CODE BEGIN CAN1_Init 0 */

    /* USER CODE END CAN1_Init 0 */


    /* USER CODE BEGIN CAN1_Init 1 */

    /* USER CODE END CAN1_Init 1 */


    hcan1.Instance = CAN1;


    /* ------------------------------------------------------------------------
     * CAN BIT TIMING
     * ------------------------------------------------------------------------
     *
     * CAN clock = APB1 = 16 MHz
     *
     * Prescaler = 4
     *
     * CAN clock / Prescaler = 4 MHz
     *
     * Total TQ:
     *
     *     1 + 13 + 2 = 16 TQ
     *
     * Bitrate:
     *
     *     4 MHz / 16 = 250 kbps
     *
     * KEEP THIS CONFIGURATION.
     * ------------------------------------------------------------------------ */

    hcan1.Init.Prescaler =
        4;

    hcan1.Init.Mode =
        CAN_MODE_NORMAL;

    hcan1.Init.SyncJumpWidth =
        CAN_SJW_1TQ;

    hcan1.Init.TimeSeg1 =
        CAN_BS1_13TQ;

    hcan1.Init.TimeSeg2 =
        CAN_BS2_2TQ;


    /* ------------------------------------------------------------------------
     * CAN Features
     * ------------------------------------------------------------------------ */

    hcan1.Init.TimeTriggeredMode =
        DISABLE;

    hcan1.Init.AutoBusOff =
        DISABLE;

    hcan1.Init.AutoWakeUp =
        DISABLE;

    hcan1.Init.AutoRetransmission =
        DISABLE;

    hcan1.Init.ReceiveFifoLocked =
        DISABLE;

    hcan1.Init.TransmitFifoPriority =
        DISABLE;


    if (HAL_CAN_Init(&hcan1) != HAL_OK)
    {
        Error_Handler();
    }


    /* USER CODE BEGIN CAN1_Init 2 */

    /* USER CODE END CAN1_Init 2 */
}


/**
  * @brief RTC Initialization Function
  * @param None
  * @retval None
  */

static void MX_RTC_Init(void)
{
    /* USER CODE BEGIN RTC_Init 0 */

    /* USER CODE END RTC_Init 0 */


    /* USER CODE BEGIN RTC_Init 1 */

    /* USER CODE END RTC_Init 1 */


    /* Initialize RTC Only */

    hrtc.Instance =
        RTC;

    hrtc.Init.HourFormat =
        RTC_HOURFORMAT_24;

    hrtc.Init.AsynchPrediv =
        127;

    hrtc.Init.SynchPrediv =
        255;

    hrtc.Init.OutPut =
        RTC_OUTPUT_DISABLE;

    hrtc.Init.OutPutPolarity =
        RTC_OUTPUT_POLARITY_HIGH;

    hrtc.Init.OutPutType =
        RTC_OUTPUT_TYPE_OPENDRAIN;


    if (HAL_RTC_Init(&hrtc) != HAL_OK)
    {
        Error_Handler();
    }


    /* USER CODE BEGIN RTC_Init 2 */

    /* USER CODE END RTC_Init 2 */
}


/**
  * @brief USART1 Initialization Function
  * @param None
  * @retval None
  */

static void MX_USART1_UART_Init(void)
{
    /* USER CODE BEGIN USART1_Init 0 */

    /* USER CODE END USART1_Init 0 */


    /* USER CODE BEGIN USART1_Init 1 */

    /* USER CODE END USART1_Init 1 */


    huart1.Instance =
        USART1;

    huart1.Init.BaudRate =
        115200;

    huart1.Init.WordLength =
        UART_WORDLENGTH_8B;

    huart1.Init.StopBits =
        UART_STOPBITS_1;

    huart1.Init.Parity =
        UART_PARITY_NONE;

    huart1.Init.Mode =
        UART_MODE_TX_RX;

    huart1.Init.HwFlowCtl =
        UART_HWCONTROL_NONE;

    huart1.Init.OverSampling =
        UART_OVERSAMPLING_16;


    if (HAL_UART_Init(&huart1) != HAL_OK)
    {
        Error_Handler();
    }


    /* USER CODE BEGIN USART1_Init 2 */

    /* USER CODE END USART1_Init 2 */
}


/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */

static void MX_GPIO_Init(void)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};


    /* USER CODE BEGIN MX_GPIO_Init_1 */

    /* USER CODE END MX_GPIO_Init_1 */


    /* GPIO Ports Clock Enable */

    __HAL_RCC_GPIOE_CLK_ENABLE();

    __HAL_RCC_GPIOH_CLK_ENABLE();

    __HAL_RCC_GPIOA_CLK_ENABLE();

    __HAL_RCC_GPIOD_CLK_ENABLE();

    __HAL_RCC_GPIOB_CLK_ENABLE();


    /* Configure GPIO pin Output Level */

    HAL_GPIO_WritePin(
        GPIOE,
        GPIO_PIN_2 |
        GPIO_PIN_3 |
        GPIO_PIN_4 |
        GPIO_PIN_5 |
        GPIO_PIN_6,
        GPIO_PIN_RESET
    );


    /* Configure GPIO pin Output Level */

    HAL_GPIO_WritePin(
        GPIOA,
        GPIO_PIN_6 |
        GPIO_PIN_7,
        GPIO_PIN_RESET
    );


    /* Configure GPIO pins : PE2 PE3 PE4 PE5 PE6 */

    GPIO_InitStruct.Pin =
        GPIO_PIN_2 |
        GPIO_PIN_3 |
        GPIO_PIN_4 |
        GPIO_PIN_5 |
        GPIO_PIN_6;

    GPIO_InitStruct.Mode =
        GPIO_MODE_OUTPUT_PP;

    GPIO_InitStruct.Pull =
        GPIO_NOPULL;

    GPIO_InitStruct.Speed =
        GPIO_SPEED_FREQ_LOW;

    HAL_GPIO_Init(
        GPIOE,
        &GPIO_InitStruct
    );


    /* Configure GPIO pins : PA6 PA7 */

    GPIO_InitStruct.Pin =
        GPIO_PIN_6 |
        GPIO_PIN_7;

    GPIO_InitStruct.Mode =
        GPIO_MODE_OUTPUT_PP;

    GPIO_InitStruct.Pull =
        GPIO_NOPULL;

    GPIO_InitStruct.Speed =
        GPIO_SPEED_FREQ_LOW;

    HAL_GPIO_Init(
        GPIOA,
        &GPIO_InitStruct
    );


    /* Configure GPIO pins : PD6 PD7 */

    GPIO_InitStruct.Pin =
        GPIO_PIN_6 |
        GPIO_PIN_7;

    GPIO_InitStruct.Mode =
        GPIO_MODE_INPUT;

    GPIO_InitStruct.Pull =
        GPIO_NOPULL;

    HAL_GPIO_Init(
        GPIOD,
        &GPIO_InitStruct
    );


    /* Configure GPIO pins : PE0 PE1 */

    GPIO_InitStruct.Pin =
        GPIO_PIN_0 |
        GPIO_PIN_1;

    GPIO_InitStruct.Mode =
        GPIO_MODE_INPUT;

    GPIO_InitStruct.Pull =
        GPIO_NOPULL;

    HAL_GPIO_Init(
        GPIOE,
        &GPIO_InitStruct
    );


    /* USER CODE BEGIN MX_GPIO_Init_2 */

    /* USER CODE END MX_GPIO_Init_2 */
}


/* USER CODE BEGIN 4 */

/* USER CODE END 4 */


/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */

void Error_Handler(void)
{
    /* USER CODE BEGIN Error_Handler_Debug */

    __disable_irq();

    while (1)
    {
    }

    /* USER CODE END Error_Handler_Debug */
}


#ifdef USE_FULL_ASSERT

/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line number
  * @retval None
  */

void assert_failed(uint8_t *file, uint32_t line)
{
    /* USER CODE BEGIN 6 */

    /*
     * User can add implementation to report the file name
     * and source line number.
     */

    /* USER CODE END 6 */
}

#endif /* USE_FULL_ASSERT */
