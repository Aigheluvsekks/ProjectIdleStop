#ifndef SYSTEM_MANAGER_H
#define SYSTEM_MANAGER_H

#include <stdbool.h>

typedef enum
{
	SYSTEM_DISABLED,
	SYSTEM_MONITORING,
	SYSTEM_IDLE,
	SYSTEM_TIMER_RUNNING,
	SYSTEM_SHUTDOWN_REQUESTED,
	SYSTEM_SHUTDOWN_ACTIVE,
	SYSTEM_FAULT
}SystemState_t;

void SystemManager_Init(void);

void SystemManager_Process(void);

SystemState_t SystemManager_GetState(void);

void SystemManager_SetState(SystemState_t state);

#endif
