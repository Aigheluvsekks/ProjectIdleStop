	/**
	  ******************************************************************************
	  * @file    Timer_Manager.c
	  * @brief   RTC Time and Date manager implementation
	  ******************************************************************************
	  */

	#include "Timer_Manager.h"
	#include <stddef.h> // For NULL

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

	/**
	 * @brief Captures the current RTC time and saves it as the last idle stop time.
	 * @param hrtc Pointer to the RTC handle.
	 * @retval true if successfully recorded, false if RTC read failed.
	 */
	bool Timer_Manager_RecordIdleStop(RTC_HandleTypeDef *hrtc) {
		/* Get the current time and immediately save it into our private variable */
		if (Timer_Manager_GetDateTime(hrtc, &lastIdleStop_DateTime)) {
			hasIdleStopOccurred = true;
			return true;
		}
		return false;
	}

	/**
	 * @brief Retrieves the timestamp of the last recorded idle stop.
	 * @param pDateTime Pointer to the structure where the time will be copied.
	 * @retval true if a record exists, false if idle stop hasn't happened yet.
	 */
	bool Timer_Manager_GetLastIdleStop(DateTime_t *pDateTime) {
		if (!hasIdleStopOccurred || pDateTime == NULL) {
			return false; /* No idle stop has happened yet, or invalid pointer */
		}

		/* Copy our saved timestamp into the pointer provided by the user */
		*pDateTime = lastIdleStop_DateTime;
		return true;
	}
