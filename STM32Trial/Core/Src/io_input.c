#include "io_input.h"
#include "main.h"

OperatingMode_t IO_GetOperatingMode(void)
{
	bool IdleStop_On_Signal =
			HAL_GPIO_ReadPin(GPIOE, GPIO_PIN_1) == GPIO_PIN_SET;

	bool Service_On_Signal =
			HAL_GPIO_ReadPin(GPIOE, GPIO_PIN_0) == GPIO_PIN_SET;

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
	bool Time1_Signal =
			HAL_GPIO_ReadPin(GPIOD, GPIO_PIN_7) == GPIO_PIN_SET; // baca Signal untuk keadaan tim1

	bool Time3_Signal =
			HAL_GPIO_ReadPin(GPIOD, GPIO_PIN_6) == GPIO_PIN_SET; // baca signal keadaaan time3

	if(Time1_Signal && !Time3_Signal) //Posisi Knob Preset Time 1
	{
		return time1;
	}

	if(!Time1_Signal && !Time3_Signal) //Posisi Knob Preset Time 2
	{
		return time2;
	}

	if(!Time1_Signal && Time3_Signal) //Posisi Knob Preset Time 3
	{
		return time3;
	}
	return OpTime_Invalid;
}
