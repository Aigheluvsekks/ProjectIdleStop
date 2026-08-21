#include "io_input.h"
#include "main.h"

OperatingMode_t IO_GetOperatingMode(void)
{
	bool IdleStop_On_Signal = 1;

	bool Service_On_Signal = 0;

	if(IdleStop_On_Signal && !Service_On_Signal) //Posisi Knob Idle
	{
		return IdleStop_On;
	}

	if(!IdleStop_On_Signal && !Service_On_Signal) //Posisi Knob Tengah
	{
		return IdleStop_Off;
	}

	if(!IdleStop_On_Signal && Service_On_Signal) //Posisi Knob Service
	{
		return Service_On;
	}
	return OpMode_Invalid;
}

OperatingTime_t IO_GetOperatingTime(void)
{
	bool Time1_Signal = 1; // baca Signal untuk keadaan tim1

	bool Time3_Signal = 0; // baca signal keadaaan time3

	if(Time1_Signal && !Time3_Signal) //Posisi Knob Preset Time 1
	{
		return TIME_INTERVAL_1;
	}

	if(!Time1_Signal && !Time3_Signal) //Posisi Knob Preset Time 2
	{
		return TIME_INTERVAL_2;
	}

	if(!Time1_Signal && Time3_Signal) //Posisi Knob Preset Time 3
	{
		return TIME_INTERVAL_3;
	}
	return OpTime_Invalid;
}
