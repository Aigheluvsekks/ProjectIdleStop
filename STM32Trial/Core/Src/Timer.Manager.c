/**
  ******************************************************************************
  * @file    Timer_Manager.c
  * @brief   RTC Time and Date manager implementation
  ******************************************************************************
  */

#include "Timer_Manager.h"
#include "main.h"    /* REQUIRED: for HAL_GetTick(), HAL_GPIO_TogglePin, etc. */
#include <stddef.h>  /* REQUIRED: For NULL */
#include <stdbool.h>

/* --- Private Variables --- */
/* This remembers the last time an idle stop occurred */
static DateTime_t lastIdleStop_DateTime = {0};
/* This tells us if an idle stop has actually been recorded yet */
static bool hasIdleStopOccurred = false;

/* --- Existing Functions --- */

bool Timer_Manager_GetDateTime(RTC_HandleTypeDef *hrtc, DateTime_t *pDateTime) {
    RTC_TimeTypeDef sTime = {0};
    RTC_DateTypeDef sDate = {0};

    /*
     * STM32 HARDWARE REQUIREMENT:
     * You MUST read the Time first, and the Date second.
     * Reading the Time locks the values, and reading the Date unlocks them.
     */
    if (HAL_RTC_GetTime(hrtc, &sTime, RTC_FORMAT_BIN) != HAL_OK) return false;
    if (HAL_RTC_GetDate(hrtc, &sDate, RTC_FORMAT_BIN) != HAL_OK) return false;

    pDateTime->Hours   = sTime.Hours;
    pDateTime->Minutes = sTime.Minutes;
    pDateTime->Seconds = sTime.Seconds;

    pDateTime->Date    = sDate.Date;
    pDateTime->Month   = sDate.Month;
    pDateTime->Year    = sDate.Year;
    pDateTime->WeekDay = sDate.WeekDay;

    return true;
}

bool Timer_Manager_SetDateTime(RTC_HandleTypeDef *hrtc, DateTime_t *pDateTime) {
    RTC_TimeTypeDef sTime = {0};
    RTC_DateTypeDef sDate = {0};

    sTime.Hours   = pDateTime->Hours;
    sTime.Minutes = pDateTime->Minutes;
    sTime.Seconds = pDateTime->Seconds;
    sTime.DayLightSaving = RTC_DAYLIGHTSAVING_NONE;
    sTime.StoreOperation = RTC_STOREOPERATION_RESET;

    sDate.Date    = pDateTime->Date;
    sDate.Month   = pDateTime->Month;
    sDate.Year    = pDateTime->Year;
    sDate.WeekDay = pDateTime->WeekDay;

    if (HAL_RTC_SetTime(hrtc, &sTime, RTC_FORMAT_BIN) != HAL_OK) return false;
    if (HAL_RTC_SetDate(hrtc, &sDate, RTC_FORMAT_BIN) != HAL_OK) return false;

    return true;
}

/* --- New Idle Stop Functions --- */

bool Timer_Manager_RecordIdleStop(RTC_HandleTypeDef *hrtc) {
    /* Get the current time and immediately save it into our private variable */
    if (Timer_Manager_GetDateTime(hrtc, &lastIdleStop_DateTime)) {
        hasIdleStopOccurred = true;
        return true;
    }
    return false;
}

bool Timer_Manager_GetLastIdleStop(DateTime_t *pDateTime) {
    if (!hasIdleStopOccurred || pDateTime == NULL) {
        return false; /* No idle stop has happened yet, or invalid pointer */
    }
    /* Copy our saved timestamp into the pointer provided by the user */
    *pDateTime = lastIdleStop_DateTime;
    return true;
}


/* ==============================================================================
 *                     IDLE WARNING STATE MACHINE LOGIC
 * ============================================================================== */

/*
 * FALLBACK PIN DEFINITIONS:
 * If you didn't name your pins "WARNING_LED_Pin" in STM32CubeMX, define them here.
 * CHANGE THESE TO YOUR ACTUAL PORT AND PIN!
 */
#ifndef WARNING_LED_GPIO_Port
#define WARNING_LED_GPIO_Port GPIOD
#define WARNING_LED_Pin       GPIO_PIN_12
#endif

/*
 * PLACEHOLDER FUNCTIONS:
 * These resolve the "implicit declaration" errors. Put your actual logic inside them.
 */
static bool Check_Engine_Idle_Condition(void) {
    /* Example: return (current_RPM == 0 && brake_pressed); */
    return false;
}

static bool Check_Restart_Condition(void) {
    /* Example: return (throttle_pressed); */
    return false;
}

static void Stop_Engine_Actuator(void) {
    /* Insert code to cut fuel/ignition here */
}

static void Start_Engine(void) {
    /* Insert code to restart engine here */
}

/* State Machine Variables */
typedef enum {
    IDLE_STATE_RUNNING,
    IDLE_STATE_WARNING,    /* Blinking LED before shutdown */
    IDLE_STATE_STOPPING,
    IDLE_STATE_STOPPED
} IdleState_t;

#define IDLE_WARNING_DURATION_MS   5000  /* Blink for 5 seconds before cutoff */
#define LED_BLINK_INTERVAL_MS       250  /* Blink toggle speed */

static IdleState_t idleState = IDLE_STATE_RUNNING;
static uint32_t stateEntryTime = 0;
static uint32_t lastBlinkTime  = 0;

void Idle_Manager_Update(RTC_HandleTypeDef *hrtc) {
    uint32_t now = HAL_GetTick();

    switch (idleState) {
        case IDLE_STATE_RUNNING:
            if (Check_Engine_Idle_Condition()) {
                stateEntryTime = now;
                lastBlinkTime  = now;
                idleState = IDLE_STATE_WARNING;
            }
            break;

        case IDLE_STATE_WARNING:
            /* Non-blocking LED toggle */
            if (now - lastBlinkTime >= LED_BLINK_INTERVAL_MS) {
                lastBlinkTime = now;
                HAL_GPIO_TogglePin(WARNING_LED_GPIO_Port, WARNING_LED_Pin);
            }

            /* Abort warning if driver presses the throttle/clutch */
            if (!Check_Engine_Idle_Condition()) {
                HAL_GPIO_WritePin(WARNING_LED_GPIO_Port, WARNING_LED_Pin, GPIO_PIN_RESET);
                idleState = IDLE_STATE_RUNNING;
                break;
            }

            /* Warning duration elapsed -> Proceed to stop engine */
            if (now - stateEntryTime >= IDLE_WARNING_DURATION_MS) {
                HAL_GPIO_WritePin(WARNING_LED_GPIO_Port, WARNING_LED_Pin, GPIO_PIN_RESET);
                idleState = IDLE_STATE_STOPPING;
            }
            break;

        case IDLE_STATE_STOPPING:
            Stop_Engine_Actuator();

            /* Record timestamp using Timer_Manager once engine has stopped */
            Timer_Manager_RecordIdleStop(hrtc);

            idleState = IDLE_STATE_STOPPED;
            break;

        case IDLE_STATE_STOPPED:
            if (Check_Restart_Condition()) {
                Start_Engine();
                idleState = IDLE_STATE_RUNNING;
            }
            break;
    }
}
