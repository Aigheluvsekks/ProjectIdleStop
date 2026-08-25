#ifndef TIMER_MANAGER_H
#define TIMER_MANAGER_H

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"
#include "io_input.h"
#include <stdint.h>
#include <stdbool.h>

/* Deklarasi interval timer (menit) */
#define TIMER_MINUTES_TIME1   1   /* Interval Time 1: 3 Menit */
#define TIMER_MINUTES_TIME2   5   /* Interval Time 2: 5 Menit */
#define TIMER_MINUTES_TIME3   10  /* Interval Time 3: 10 Menit */

/* Exported Functions --------------------------------------------------------*/
void Timer_Manager_Start(void);
void Timer_Manager_Stop(void);
uint32_t Timer_Manager_GetElapsedTimeMs(void);
uint32_t Timer_Manager_GetTargetTimeMs(void);
bool Timer_Manager_IsExpired(void);

void Timer_Manager_SetOperatingTime(OperatingTime_t opTime);
OperatingTime_t Timer_Manager_GetOperatingTime(void);

#ifdef __cplusplus
}
#endif

#endif /* TIMER_MANAGER_H */
