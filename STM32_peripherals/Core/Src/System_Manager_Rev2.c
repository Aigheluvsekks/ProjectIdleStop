#include "system_manager.h"
#include "decision.h"
#include "system_health.h"
#include "timer_manager.h"


void SystemManager_Process(void)
{
    SystemHealth_t health =
        SystemHealth_Get();

    MachineCondition_t condition =
        Decision_GetMachineCondition(
            CAN_GetMachineData()
        );


    /*
     * Safety first:
     * If our information isn't trustworthy,
     * don't proceed with auto shutdown.
     */

    if (health != SYSTEM_HEALTH_OK)
    {
        TimerManager_Stop();

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

            TimerManager_Start();

            system_state = SYSTEM_TIMER_RUNNING;

            break;


        case SYSTEM_TIMER_RUNNING:

            if (condition == MACHINE_WORKING)
            {
                TimerManager_Stop();

                system_state = SYSTEM_MONITORING;
            }

            else if (condition == MACHINE_UNKNOWN)
            {
                TimerManager_Stop();

                system_state = SYSTEM_MONITORING;
            }

            else if (TimerManager_Expired())
            {
                system_state = SYSTEM_SHUTDOWN_REQUESTED;
            }

            break;


        case SYSTEM_SHUTDOWN_REQUESTED:

            /*
             * Before actually shutting down,
             * verify everything one more time.
             */

            if (condition == MACHINE_IDLE &&
                health == SYSTEM_HEALTH_OK)
            {
                IO_ShutdownRelay_On();

                system_state = SYSTEM_SHUTDOWN_ACTIVE;
            }
            else
            {
                system_state = SYSTEM_MONITORING;
            }

            break;


        case SYSTEM_SHUTDOWN_ACTIVE:

            break;


        default:

            system_state = SYSTEM_FAULT;

            break;
    }
}
