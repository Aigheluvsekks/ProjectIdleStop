/**
  ******************************************************************************
  * @file    Timer_Manager.c
  * @brief   Timer & Countdown Manager Implementation
  ******************************************************************************
  */

#include "Timer_Manager.h"
#include "io_input.h"


/* --- Private Variables --- */

static uint32_t currentElapsedTimeMs = 0;
static uint32_t targetCountdownTimeMs = 0;
static uint32_t startTimeTick = 0;
static bool     isTimerRunning = false;

static OperatingTime_t activeOperatingTime = TIME_INTERVAL_1;


/* Debug */
volatile uint32_t debug_timer_remaining_ms = 0;
volatile uint32_t debug_timer_remaining_s = 0;

/* --- Function Implementations --- */
void Timer_Manager_SetOperatingTime(OperatingTime_t opTime)
{
    if (opTime == TIME_INTERVAL_1 ||
        opTime == TIME_INTERVAL_2 ||
        opTime == TIME_INTERVAL_3)
    {
        activeOperatingTime = opTime;
    }
}

OperatingTime_t Timer_Manager_GetOperatingTime(void)
{
    return activeOperatingTime;
}


void Timer_Manager_Start(void) {
    /* 1. Mengetahui waktu countdown yang harus dieksekusi */
	OperatingTime_t opTime = activeOperatingTime;

    /* 2. Menentukan target millisec berdasarkan interval time1, time2, time3 */
    switch ((uint8_t)opTime) {
        case TIME_INTERVAL_1:
            targetCountdownTimeMs = (uint32_t)TIMER_MINUTES_TIME1 * 60 * 1000;
            break;
        case TIME_INTERVAL_2:
            targetCountdownTimeMs = (uint32_t)TIMER_MINUTES_TIME2 * 60 * 1000;
            break;
        case TIME_INTERVAL_3:
            targetCountdownTimeMs = (uint32_t)TIMER_MINUTES_TIME3 * 60 * 1000;
            break;
        default:
            targetCountdownTimeMs = 0;
            break;
    }

    /* 3. Ngestart Timer */
    if (targetCountdownTimeMs > 0) {
        startTimeTick = HAL_GetTick();
        currentElapsedTimeMs = 0;
        isTimerRunning = true;
    }
}

void Timer_Manager_Stop(void) {
    /* 4. Ngestop timer dan reset timer */
    isTimerRunning = false;
    startTimeTick = 0;
    currentElapsedTimeMs = 0;
    targetCountdownTimeMs = 0;
}

uint32_t Timer_Manager_GetElapsedTimeMs(void)
{
    if (isTimerRunning)
    {
        currentElapsedTimeMs = HAL_GetTick() - startTimeTick;

        if (currentElapsedTimeMs < targetCountdownTimeMs)
        {
            debug_timer_remaining_ms =
                targetCountdownTimeMs - currentElapsedTimeMs;
            debug_timer_remaining_s =
                debug_timer_remaining_ms / 1000;
        }
        else
        {
            debug_timer_remaining_ms = 0;
        }
    }
    else
    {
        debug_timer_remaining_ms = 0;
    }

    return currentElapsedTimeMs;
}

uint32_t Timer_Manager_GetTargetTimeMs(void) {
    /* 6. Ngereport target time */
    return targetCountdownTimeMs;
}

bool Timer_Manager_IsExpired(void) {
    if (!isTimerRunning) {
        return false;
    }

    /* Periksa apakah elapsed time sudah mencapai atau melebihi target time */
    if (Timer_Manager_GetElapsedTimeMs() >= targetCountdownTimeMs) {
        isTimerRunning = false;
        return true;
    }

    return false;
}


