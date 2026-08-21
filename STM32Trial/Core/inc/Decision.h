#ifndef DECISION_H
#define DECISION_H

#include <stdbool.h>

typedef enum
{
	MACHINE_WORKING,
	MACHINE_IDLE,
	MACHINE_UNKNOWN
} MachineCondition_t;

MachineCondition_t Decision_GetMachineCondition(void);

#endif
