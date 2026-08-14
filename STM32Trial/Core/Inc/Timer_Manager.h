/**
  ******************************************************************************
  * @file    Timer_Manager.h
  * @brief   RTC Time and Date manager
  ******************************************************************************
  */

#ifndef TIMER_MANAGER_H
#define TIMER_MANAGER_H

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"
#include <stdint.h>
#include <stdbool.h>

/* Exported Types ------------------------------------------------------------*/
typedef struct {
    uint8_t Hours;
    uint8_t Minutes;
    uint8_t Seconds;
    uint8_t Date;
    uint8_t Month;
    uint8_t Year;      /* Year since 2000 (e.g., 26 for 2026) */
    uint8_t WeekDay;   /* 1 = Monday, 7 = Sunday */
} DateTime_t;

/* Exported Function Prototypes ----------------------------------------------*/

/**
 * @brief Safely reads the current time and date from the RTC.
 */
bool Timer_Manager_GetDateTime(RTC_HandleTypeDef *hrtc, DateTime_t *pDateTime);

/**
 * @brief Sets a new time and date to the RTC.
 */
bool Timer_Manager_SetDateTime(RTC_HandleTypeDef *hrtc, DateTime_t *pDateTime);

#ifdef __cplusplus
}
#endif

void Timer_Manager_Start(void);
void Timer_Manager_Stop(void);
uint8_t Timer_Manager_Expired(void);

#endif /* TIMER_MANAGER_H */
