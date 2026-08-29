#include "Data_Logger.h"
#include <stdio.h>

/* ============================================================
 * PRIVATE VARIABLES
 * ============================================================ */

static ESP32_HandleTypeDef *pEsp32 = NULL;

static uint32_t idleStopCount = 0;
static uint32_t totalIdleStopTimeMs = 0;


/* ============================================================
 * INITIALIZATION
 * ============================================================ */

void DataLogger_Init(ESP32_HandleTypeDef *hesp)
{
    pEsp32 = hesp;

    idleStopCount = 0;
    totalIdleStopTimeMs = 0;
}


/* ============================================================
 * KNOB / OPERATING MODE CHANGE
 * ============================================================ */

void DataLogger_LogModeChange(OperatingMode_t mode)
{
    if (pEsp32 == NULL)
        return;

    char msg[64];

    switch (mode)
    {
        case IdleStop_On:

            snprintf(
                msg,
                sizeof(msg),
                "EVENT:MODE_IDLE_STOP\n"
            );

            break;


        case IdleStop_Off:

            snprintf(
                msg,
                sizeof(msg),
                "EVENT:MODE_IDLE_OFF\n"
            );

            break;


        case Service_On:

            snprintf(
                msg,
                sizeof(msg),
                "EVENT:MODE_SERVICE\n"
            );

            break;


        case OpMode_Invalid:

        default:

            snprintf(
                msg,
                sizeof(msg),
                "EVENT:MODE_INVALID\n"
            );

            break;
    }

    ESP32_Link_Transmit(
        pEsp32,
        msg
    );
}


/* ============================================================
 * TIMER SELECTION CHANGE
 * ============================================================ */

void DataLogger_LogTimerChange(OperatingTime_t time)
{
    if (pEsp32 == NULL)
        return;

    char msg[64];

    switch (time)
    {
        case TIME_INTERVAL_1:

            snprintf(
                msg,
                sizeof(msg),
                "EVENT:TIMER_CHANGE,1_MIN\n"
            );

            break;


        case TIME_INTERVAL_2:

            snprintf(
                msg,
                sizeof(msg),
                "EVENT:TIMER_CHANGE,5_MIN\n"
            );

            break;


        case TIME_INTERVAL_3:

            snprintf(
                msg,
                sizeof(msg),
                "EVENT:TIMER_CHANGE,10_MIN\n"
            );

            break;


        default:

            snprintf(
                msg,
                sizeof(msg),
                "EVENT:TIMER_CHANGE,INVALID\n"
            );

            break;
    }

    ESP32_Link_Transmit(
        pEsp32,
        msg
    );
}


/* ============================================================
 * IDLE STOP START
 *
 * Called when the STM32 actually commands the cutoff relay.
 * ============================================================ */

void DataLogger_LogIdleStart(void)
{
    if (pEsp32 == NULL)
        return;

    idleStopCount++;

    ESP32_Link_Transmit(
        pEsp32,
        "EVENT:IDLE_STOP\n"
    );
}


/* ============================================================
 * IDLE STOP END
 *
 * Optional.
 *
 * This can be called when the Idle Stop event has actually
 * finished, with the duration in milliseconds.
 * ============================================================ */

void DataLogger_LogIdleEnd(uint32_t durationMs)
{
    if (pEsp32 == NULL)
        return;

    totalIdleStopTimeMs += durationMs;

    char msg[64];

    snprintf(
        msg,
        sizeof(msg),
        "EVENT:IDLE_STOP_END,DURATION_MS=%lu\n",
        (unsigned long)durationMs
    );

    ESP32_Link_Transmit(
        pEsp32,
        msg
    );
}


/* ============================================================
 * STATISTICS
 * ============================================================ */

uint32_t DataLogger_GetIdleStopCount(void)
{
    return idleStopCount;
}


uint32_t DataLogger_GetTotalIdleStopTimeMs(void)
{
    return totalIdleStopTimeMs;
}
