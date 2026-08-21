#ifndef IO_INPUT_H
#define IO_INPUT_H

#include <stdbool.h>

typedef enum
{
	IdleStop_On,
	IdleStop_Off,
	Service_On,
	OpMode_Invalid
}OperatingMode_t;

OperatingMode_t IO_GetOperatingMode(void);

typedef enum
{
	TIME_INTERVAL_1,
	TIME_INTERVAL_2,
	TIME_INTERVAL_3,
	OpTime_Invalid
}OperatingTime_t;

OperatingTime_t IO_GetOperatingTime(void);

#endif
