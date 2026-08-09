#include "Decision.h"
#include "CAN_Decode.h"
#include "io_input.h"
#include "Machine_Param.h"

MachineCondition_t Decision_GetMachineCondition(void)
{
	const MachineData_t *machine = CAN_GetMachineData();


	if(machine == NULL)
	{
		return MACHINE_UNKNOWN;
	}

	if(!machine->data_valid)
	{
		return MACHINE_UNKNOWN;
	}

	if(machine->rpm > RPM_WORK_THRESH)
	{
		return MACHINE_WORKING;
	}

	if(machine->swingL_Press > SWING_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine->swingR_Press > SWING_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine->BoomD_Press > BOOMD_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine->BoomU_Press > BOOMU_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine->ArmDig_Press > ARMDIG_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine->BucketDump_Press > BUCKETDUMP_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine->TravelLR_Press > TRAVEL_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine->TravelLF_Press > TRAVEL_PRESS_TRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine->TravelRR_Press > TRAVEL_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine->TravelRF_Press > TRAVEL_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	return MACHINE_IDLE;

}
