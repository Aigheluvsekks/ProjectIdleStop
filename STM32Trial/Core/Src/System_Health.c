#include "System_Health.h"
#include "CAN_Manager.h"
#include "stm32f4xx_hal.h"
#include "System_Manager.h"

/*
 * Bagian kode ini digunakan untuk monitoring kesehatan / cacat dari sistem CAN Exca
 * Diagnosis / kesehatan yang dipantau adalah terkait jumlah data yang dikirimkan
 * dalam satu waktu tertentu / keterbaruan data.
 *
 * Jika data yang diterima bersifat update dan baru, maka CAN dan sistem data dapat
 * dikategorikan sebagai sehat.
 *
 * Namun, jika data yang diterima bersifat tidak updata atau sudah 'basi' maka CAN dan sistem
 * data dapat dikategorikan sebagai tidak sehat / faulty/ error
 */

volatile SystemHealth_t debug_last_health;
volatile uint32_t debug_rpm_age;
volatile uint8_t debug_can_healthy;

SystemHealth_t SystemHealth_Get(SystemState_t system_state_health)
{
	uint32_t lastRPM = CAN_GetLastRPMUpdate();
	/* uint32_t lastSWINGL = CAN_GetLastSwingLUpdate();
	uint32_t lastSWINGR = CAN_GetLastSwingRUpdate();
	uint32_t lastBOOMD = CAN_GetLastBoomDUpdate();
	uint32_t lastBOOMU = CAN_GetLastBoomUUpdate();
	uint32_t lastARMDIG = CAN_GetLastArmDigUpdate();
	uint32_t lastBUCKETDUMP = CAN_GetBucketDumpUpdate();
	uint32_t lastTRAVELLR = CAN_GetTravelLRUpdate();
	uint32_t lastTRAVELLF = CAN_GetTravelLFUpdate();
	uint32_t lastTRAVELRR = CAN_GetTravelRRUpdate();
	uint32_t lastTRAVELRF = CAN_GetTravelRFUpdate();

	Remove comment line to add other variables aside from RPM
	*/
	uint32_t now = HAL_GetTick();

	debug_can_healthy = CAN_IsHealthy();
	debug_rpm_age = now - lastRPM;


	if(!debug_can_healthy)
	{
		if (system_state_health == SYSTEM_SHUTDOWN_ACTIVE)
		    {
				debug_last_health = SYSTEM_HEALTH_CAN_OFF_EXPECTED;
		        return SYSTEM_HEALTH_CAN_OFF_EXPECTED;
		    }

		    return SYSTEM_HEALTH_CAN_ERROR;
		}

	if(debug_rpm_age > RPM_TIMEOUT_MS)
	{
		if (system_state_health == SYSTEM_SHUTDOWN_ACTIVE)
		    {
				debug_last_health = SYSTEM_HEALTH_CAN_OFF_EXPECTED;
		        return SYSTEM_HEALTH_CAN_OFF_EXPECTED;
		    }

			debug_last_health = SYSTEM_HEALTH_CAN_TIMEOUT;
		    return SYSTEM_HEALTH_CAN_TIMEOUT;
	}
	debug_last_health = SYSTEM_HEALTH_OK;
	return SYSTEM_HEALTH_OK;
	/*
	if((now-lastSWINGL)>SWINGL_PRESS_TIMEOUT_MS)
	{
		return SYSTEM_HEALTH_CAN_TIMEOUT;
	}
	if((now-lastSWINGR)>SWINGR_PRESS_TIMEOUT_MS)
	{
			return SYSTEM_HEALTH_CAN_TIMEOUT;
	}
	if((now-lastBOOMD)>BOOMD_PRESS_TIMEOUT_MS)
	{
			return SYSTEM_HEALTH_CAN_TIMEOUT;
	}
	if((now-lastBOOMU)>BOOMU_PRESS_TIMEOUT_MS)
	{
			return SYSTEM_HEALTH_CAN_TIMEOUT;
	}
	if((now-lastARMDIG)>ARMDIG_PRESS_TIMEOUT_MS)
	{
			return SYSTEM_HEALTH_CAN_TIMEOUT;
	}
	if((now-lastTRAVELLR)>TRAVELLR_PRESS_TIMEOUT_MS)
	{
			return SYSTEM_HEALTH_CAN_TIMEOUT;
	}
	if((now-lastTRAVELLF)>TRAVELLF_PRESS_TIMEOUT_MS)
	{
			return SYSTEM_HEALTH_CAN_TIMEOUT;
	}
	if((now-lastTRAVELRR)>TRAVELRR_PRESS_TIMEOUT_MS)
	{
			return SYSTEM_HEALTH_CAN_TIMEOUT;
	}
	if((now-lastTRAVELRF)>TRAVELRF_PRESS_TIMEOUT_MS)
	{
			return SYSTEM_HEALTH_CAN_TIMEOUT;
	}
	if((now-lastBUCKETDUMP)>BUCKETDUMP_PRESS_TIMEOUT_MS)
	{
			return SYSTEM_HEALTH_CAN_TIMEOUT;
	}
	*/
	return SYSTEM_HEALTH_OK;
}
