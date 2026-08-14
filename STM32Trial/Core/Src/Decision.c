#include "Decision.h"
#include "CAN_Decode.h"
#include "io_input.h"
#include "Machine_Param.h"

MachineCondition_t Decision_GetMachineCondition(void)
{
	/*
	 * FIX 1: Struct vs Pointer
	 * CAN_GetMachineData() returns the actual struct, not a pointer.
	 * Therefore, we store it in a normal variable, not a pointer (*).
	 */
	MachineData_t machine = CAN_GetMachineData();

	/*
	 * FIX 2: Null Checks on Structs
	 * Because 'machine' is an actual struct and not a pointer, it can
	 * NEVER be NULL. We have to remove the if(machine == NULL) check
	 * because it will cause a compiler error.
	 */

	/*
	 * FIX 3: data_valid does not exist!
	 * In your CAN_Decode.h, you do not have a variable called 'data_valid'.
	 * You only have specific ones like 'rpm_Valid' or 'BoomD_Press_Valid'.
	 * I have commented this out. You must check specific flags or add a
	 * general 'bool data_valid' to your struct in CAN_Decode.h.
	 */
	// if(!machine.data_valid)
	// {
	// 	return MACHINE_UNKNOWN;
	// }

	/*
	 * FIX 4: The Dot Operator
	 * Because 'machine' is no longer a pointer, we must use the dot (.)
	 * operator instead of the arrow (->) operator.
	 */
	if(machine.rpm > RPM_WORK_THRESH)
	{
		return MACHINE_WORKING;
	}

	if(machine.swingL_Press > SWING_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine.swingR_Press > SWING_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine.BoomD_Press > BOOMD_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}

	/* FIX 5: Typo 'BoomU_Press' changed to 'BoomUP_Press' to match your struct */
	if(machine.BoomUP_Press > BOOMUP_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine.ArmDig_Press > ARMDIG_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine.BucketDump_Press > BUCKETDUMP_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine.TravelLR_Press > TRAVEL_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}

	/* FIX 6: Typo 'TRESH' changed to 'THRESH' */
	if(machine.TravelLF_Press > TRAVEL_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine.TravelRR_Press > TRAVEL_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}
	if(machine.TravelRF_Press > TRAVEL_PRESS_THRESH)
	{
		return MACHINE_WORKING;
	}

	return MACHINE_IDLE;
}
