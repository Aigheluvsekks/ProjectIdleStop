#ifndef DATA_LOGGER_H
#define DATA_LOGGER_H

#include "main.h"
#include "ESP32_Link.h"
#include "io_input.h"
#include <stdint.h>

void DataLogger_Init(ESP32_HandleTypeDef *hesp);

void DataLogger_LogModeChange(OperatingMode_t mode);

void DataLogger_LogTimerChange(OperatingTime_t time);

void DataLogger_LogIdleStart(void);

void DataLogger_LogIdleEnd(uint32_t durationMs);

void DataLogger_LogTimerChange(OperatingTime_t time);

uint32_t DataLogger_GetIdleStopCount(void);

uint32_t DataLogger_GetTotalIdleStopTimeMs(void);

#endif
