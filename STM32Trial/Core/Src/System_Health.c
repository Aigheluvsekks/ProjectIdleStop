#include "System_Health.h"
#include "CAN_Manager.h"
#include "stm32f4xx_hal.h"

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

SystemHealth_t SystemHealth_Get(void)
{
	uint32_t lastRPM = CAN_GetLastRPMUpdate();
	uint32_t lastSWINGL = CAN_GetLastSwingLUpdate();
	uint32_t lastSWINGR = CAN_GetLastSwingRUpdate();
	uint32_t lastBOOMD = CAN_GetLastBoomDUpdate();
	uint32_t lastBOOMU = CAN_GetLastBoomUUpdate();
	uint32_t lastARMDIG = CAN_GetLastArmDigUpdate();
	uint32_t lastBUCKETDUMP = CAN_GetLastBucketDumpUpdate();
	uint32_t lastTRAVELLR   = CAN_GetLastTravelLRUpdate();
	uint32_t lastTRAVELLF   = CAN_GetLastTravelLFUpdate();
	uint32_t lastTRAVELRR   = CAN_GetLastTravelRRUpdate();
	uint32_t lastTRAVELRF   = CAN_GetLastTravelRFUpdate();
	uint32_t now = HAL_GetTick();


	if(!CAN_IsHealthy())
	{
		return SYSTEM_HEALTH_CAN_ERROR;
	}

	if((now-lastRPM)>RPM_TIMEOUT_MS)
	{
		return SYSTEM_HEALTH_CAN_TIMEOUT;
	}
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
	return SYSTEM_HEALTH_OK;
}
