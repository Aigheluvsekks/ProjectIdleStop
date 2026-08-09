#include "System_Manager.h"

static SystemState_t system_state;

void SystemManager_Init(void)
{
	system_state = SYSTEM_DISABLED;
}

void SystemManager_Process(void)
{
	switch(system_state)
	{
	case SYSTEM_DISABLED:
		break;

	case SYSTEM_MONITORING:
		break;

	case SYSTEM_IDLE:
		break;

	case SYSTEM_TIMER_RUNNING:
		break;

	case SYSTEM_SHUTDOWN_ACTIVE:
		break;

	case SYSTEM_FAULT:
		break;

	default:
		system_state = SYSTEM_FAULT;
		break;
	}
}

SystemState_t SystemManager_GetState(void)
{
	return system_state;
}

void SystemManager_SetStates(SystemState_t state)
{
	system_state = state;
}
