// IdleMetrics.h

#ifndef IDLE_METRICS_H
#define IDLE_METRICS_H

#include <stdint.h>

void IdleMetrics_Init(void);
void IdleMetrics_Update(void);

uint32_t IdleMetrics_GetWorkTime(void);
uint32_t IdleMetrics_GetIdleTime(void);
uint32_t IdleMetrics_GetTotalIdleTime(void);
uint32_t IdleMetrics_GetIdleSavedTime(void);

#endif
