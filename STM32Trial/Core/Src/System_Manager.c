#include "system_manager.h"
#include "decision.h"
#include "system_health.h"
#include "timer_manager.h"
#include "io_output.h"

/*
 * This tells the compiler that the variable 'system_state'
 * exists and is defined somewhere else (like in your main.c)
 */
extern SystemState_t system_state;

void SystemManager_Process(void)
{
    SystemHealth_t health = SystemHealth_Get();
    MachineCondition_t condition = Decision_GetMachineCondition();

    /*
     * Safety first:
     * If our information isn't trustworthy,
     * don't proceed with auto shutdown.
     */
    if (health != SYSTEM_HEALTH_OK)
    {
        /* FIX: Added underscore to match your timer_manager naming convention */
        Timer_Manager_Stop();

        /* FIX: Changed SystemState_t to system_state */
        system_state = SYSTEM_FAULT;

        return;
    }

    switch (system_state)
    {
        case SYSTEM_MONITORING:
            if (condition == MACHINE_IDLE)
            {
                system_state = SYSTEM_IDLE;
            }
            break;

        case SYSTEM_IDLE:
            /* FIX: Added underscore */
            Timer_Manager_Start();
            system_state = SYSTEM_TIMER_RUNNING;
            break;

        case SYSTEM_TIMER_RUNNING:
            if (condition == MACHINE_WORKING)
            {
                /* FIX: Added underscore */
                Timer_Manager_Stop();
                system_state = SYSTEM_MONITORING;
            }
            else if (condition == MACHINE_UNKNOWN)
            {
                /* FIX: Added underscore */
                Timer_Manager_Stop();
                system_state = SYSTEM_MONITORING;
            }
            else if (Timer_Manager_Expired()) /* FIX: Added underscore */
            {
                system_state = SYSTEM_SHUTDOWN_REQUESTED;
            }
            break;

        case SYSTEM_SHUTDOWN_REQUESTED:
            /*
             * Before actually shutting down,
             * verify everything one more time.
             */
            if (condition == MACHINE_IDLE && health == SYSTEM_HEALTH_OK)
            {
                /* FIX: Added the '1' argument to satisfy uint8_t state */
                IO_CutoffRelay_On(1);
                system_state = SYSTEM_SHUTDOWN_ACTIVE;
            }
            else
            {
                system_state = SYSTEM_MONITORING;
            }
            break;

        case SYSTEM_SHUTDOWN_ACTIVE:
            /* State handled elsewhere or awaits reset */
            break;

        default:
            system_state = SYSTEM_FAULT;
            break;
    }
}
