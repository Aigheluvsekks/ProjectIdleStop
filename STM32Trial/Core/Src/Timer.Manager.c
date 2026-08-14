/**
  ******************************************************************************
  * @file    Timer_Manager.c
  * @brief   RTC Time and Date manager implementation
  ******************************************************************************
  */

#include "Timer_Manager.h"

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
