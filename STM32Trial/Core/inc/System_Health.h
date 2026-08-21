#ifndef SYSTEM_HEALTH_H
#define SYSTEM_HEALTH_H

#include "System_Manager.h"

//Pendefinisian variabel konstan untuk setiap kondisi
typedef enum
{
	SYSTEM_HEALTH_OK,

	SYSTEM_HEALTH_CAN_TIMEOUT,
	SYSTEM_HEALTH_CAN_ERROR,
	SYSTEM_HEALTH_CAN_OFF_EXPECTED,

	SYSTEM_HEALTH_FAULT
}SystemHealth_t;

/*
 * Pendefinisian variabel konstan untuk waktu timeour/ kapan sebuah variabel dianggap 'basi'
 * Jumlah / besaran timeout untuk masing-masing variabel dapat diatur
 * Nama variabel mohon untuk tidak diatur/ diubah\
 *
 * Satuan dalam milisekon
 */



#define RPM_TIMEOUT_MS 120
#define SWINGL_PRESS_TIMEOUT_MS 50
#define SWINGR_PRESS_TIMEOUT_MS 50
#define BOOMD_PRESS_TIMEOUT_MS 50
#define BOOMU_PRESS_TIMEOUT_MS 50
#define ARMDIG_PRESS_TIMEOUT_MS 50
#define BUCKETDUMP_PRESS_TIMEOUT_MS 50
#define TRAVELLR_PRESS_TIMEOUT_MS 50
#define TRAVELLF_PRESS_TIMEOUT_MS 50
#define TRAVELRR_PRESS_TIMEOUT_MS 50
#define TRAVELRF_PRESS_TIMEOUT_MS 50

SystemHealth_t SystemHealth_Get(SystemState_t system_state_health);

#endif
