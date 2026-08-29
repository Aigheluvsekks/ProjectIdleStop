#include "System_manager.h"
#include "Decision.h"
#include "System_Health.h"
#include "Timer_Manager.h"
#include "io_output.h"
#include "Data_Logger.h"


/* ============================================================
 * SYSTEM MANAGER VARIABLES
 * ============================================================ */

static SystemState_t system_state;
static SystemState_t system_state_health;
static uint32_t shutdown_time;


/* ============================================================
 * DEBUG VARIABLES
 *
 * These are intentionally global + volatile so they can be
 * monitored using CubeIDE Live Expressions.
 *
 * debug_health:
 *     Shows what SystemHealth_Get() is returning.
 *
 * debug_condition:
 *     Shows what Decision_GetMachineCondition() is returning.
 * ============================================================ */

volatile SystemHealth_t debug_health;
volatile MachineCondition_t debug_condition;

uint32_t lastBlink = 0;

/* ============================================================
 * SET SYSTEM STATE
 * ============================================================ */

void SystemManager_SetState(SystemState_t state)
{
    system_state = state;
}


/* ============================================================
 * SYSTEM MANAGER INITIALIZATION
 * ============================================================ */

void SystemManager_Init(void)
{
    system_state = SYSTEM_MONITORING;
    system_state_health = SYSTEM_MONITORING;

    shutdown_time = 0;

    /* Initialize debug variables */
    debug_health = SYSTEM_HEALTH_OK;
    debug_condition = MACHINE_UNKNOWN;
}


/* ============================================================
 * GET SYSTEM STATE
 * ============================================================ */

SystemState_t SystemManager_GetState(void)
{
    return system_state;
}


/* ============================================================
 * MAIN SYSTEM MANAGER PROCESS
 * ============================================================ */

void SystemManager_Process(void)
{
    /*
     * Get system health.
     *
     * Stored into debug_health so it can be observed
     * permanently through CubeIDE Live Expressions.
     */
    debug_health = SystemHealth_Get(system_state_health);


    /*
     * Get machine condition.
     *
     * Stored into debug_condition so it can be observed
     * permanently through CubeIDE Live Expressions.
     */
    debug_condition = Decision_GetMachineCondition();


    /*
     * Local aliases.
     *
     * The actual state-machine logic still uses these
     * variables exactly as before.
     */
    SystemHealth_t health = debug_health;
    MachineCondition_t condition = debug_condition;


    /* ========================================================
     * CAN / SYSTEM HEALTH SAFETY GATE
     * ========================================================
     *
     * If CAN communication has an error or timeout:
     *
     * 1. Stop timer
     * 2. Enter SYSTEM_FAULT
     * 3. Exit immediately
     *
     * NOTE:
     * system_state_health remains SYSTEM_MONITORING.
     * This prevents SYSTEM_FAULT from being fed back into
     * SystemHealth_Get().
     */

    if (health == SYSTEM_HEALTH_CAN_ERROR ||
        health == SYSTEM_HEALTH_CAN_TIMEOUT)
    {
        Timer_Manager_Stop();

        system_state = SYSTEM_FAULT;
        IO_PilotYellow_On(1);
        IO_PilotGreen_Off(1);

        return;
    }


    /* ========================================================
     * SYSTEM STATE MACHINE
     * ======================================================== */

    switch (system_state)
    {

        /* ====================================================
         * SYSTEM MONITORING
         * ==================================================== */

        case SYSTEM_MONITORING:

            if (condition == MACHINE_WORKING)
            {
                /*
                 * Machine is working.
                 */

                HAL_GPIO_WritePin(
                    GPIOA,
                    GPIO_PIN_6,
                    GPIO_PIN_SET
                );

                HAL_GPIO_WritePin(
                    GPIOA,
                    GPIO_PIN_7,
                    GPIO_PIN_SET
                );

                /*
                 * Stop idle timer.
                 */
                Timer_Manager_Stop();

                system_state = SYSTEM_MONITORING;

                /*
                 * Ensure shutdown outputs are OFF.
                 */
                IO_CutoffRelay_Off(1);
                IO_PilotYellow_Off(1);
                IO_PilotRed_Off(1);
                IO_PilotGreen_On(1);

                system_state_health = SYSTEM_MONITORING;
            }

            else if (condition == MACHINE_IDLE)
            {
                /*
                 * Machine detected idle.
                 *
                 *  Idle-stop is only allowed after the machine
                 *  has previously entered MACHINE_WORKING
                 */

            	if (Decision_HasWorkBeenDone())
            	{
            		system_state = SYSTEM_IDLE;
            	}

            	else
            	{
            		/* Engine may be idle due to startup procedure
            		 * Idle stop count down not started yet
            		 */
            		system_state = SYSTEM_MONITORING;
            	}
                system_state_health = SYSTEM_MONITORING;
            }

            break;


        /* ====================================================
         * SYSTEM IDLE
         * ==================================================== */

        case SYSTEM_IDLE:

            /*
             * Start idle countdown.
             */
            Timer_Manager_Start();

            /*
             * Immediately enter timer-running state.
             */
            system_state = SYSTEM_TIMER_RUNNING;

            system_state_health = SYSTEM_MONITORING;

            /*
             * Shutdown relay must remain OFF.
             */
            IO_CutoffRelay_Off(1);

            IO_PilotGreen_Off(1);

            HAL_GPIO_WritePin(
                GPIOA,
                GPIO_PIN_6,
                GPIO_PIN_RESET
            );

            HAL_GPIO_WritePin(
                GPIOA,
                GPIO_PIN_7,
                GPIO_PIN_SET
            );

            break;


        /* ====================================================
         * SYSTEM TIMER RUNNING
         * ==================================================== */

        case SYSTEM_TIMER_RUNNING:

            /*
             * Turn red pilot ON when approximately
             * 500 ms or less remains.
             */
            if ((Timer_Manager_GetTargetTimeMs() -
                 Timer_Manager_GetElapsedTimeMs()) <= 5000)
            {
                IO_PilotRed_On(1);
                IO_PilotYellow_Off(1);
                IO_PilotGreen_Off(1);

                HAL_GPIO_WritePin(
                    GPIOA,
                    GPIO_PIN_6,
                    GPIO_PIN_SET
                );
            }
            else
            {
                IO_PilotRed_Off(1);
                HAL_GPIO_WritePin(
                    GPIOA,
                    GPIO_PIN_7,
                    GPIO_PIN_SET
                );
            }


            /*
             * Machine started working again.
             *
             * Cancel shutdown countdown.
             */
            if (condition == MACHINE_WORKING)
            {
                Timer_Manager_Stop();

                system_state = SYSTEM_MONITORING;
                system_state_health = SYSTEM_MONITORING;

                IO_CutoffRelay_Off(1);

                IO_PilotYellow_Off(1);
                IO_PilotRed_Off(1);
                IO_PilotGreen_Off(1);
            }


            /*
             * Machine condition is unknown.
             *
             * Cancel timer for safety.
             */
            else if (condition == MACHINE_UNKNOWN)
            {
                Timer_Manager_Stop();

                IO_CutoffRelay_Off(1);

                IO_PilotYellow_On(1);
                IO_PilotRed_Off(1);
                IO_PilotGreen_Off(1);

                system_state = SYSTEM_MONITORING;
                system_state_health = SYSTEM_MONITORING;
            }


            /*
             * Timer expired.
             *
             * Move to shutdown-request state.
             */
            else if (Timer_Manager_IsExpired() == 1)
            {
                system_state = SYSTEM_SHUTDOWN_REQUESTED;

                system_state_health = SYSTEM_MONITORING;
            }

            break;


        /* ====================================================
         * SYSTEM SHUTDOWN REQUESTED
         * ==================================================== */

        case SYSTEM_SHUTDOWN_REQUESTED:

            /*
             * Final safety check:
             *
             * Machine must still be IDLE
             * AND
             * System health must be OK.
             */
            if (condition == MACHINE_IDLE &&
                health == SYSTEM_HEALTH_OK)
            {
                /*
                 * Activate cutoff relay.
                 */
                IO_CutoffRelay_On(1);
                IO_PilotRed_Off(1);
                IO_PilotGreen_Off(1);

                /* Log actual Idle Stop activation */
                DataLogger_LogIdleStart();
                /*
                 * Record shutdown activation time.
                 */
                shutdown_time = HAL_GetTick();

                HAL_GPIO_WritePin(
                    GPIOA,
                    GPIO_PIN_6,
                    GPIO_PIN_SET
                );

                HAL_GPIO_WritePin(
                    GPIOA,
                    GPIO_PIN_7,
                    GPIO_PIN_RESET
                );

                /*
                 * Enter shutdown active state.
                 */
                system_state = SYSTEM_SHUTDOWN_ACTIVE;

                /*
                 * Keep System Health evaluation normal.
                 */
                system_state_health = SYSTEM_MONITORING;
            }
            else
            {
                /*
                 * Safety condition failed.
                 *
                 * Cancel shutdown.
                 */
                Timer_Manager_Stop();

                system_state = SYSTEM_MONITORING;
                system_state_health = SYSTEM_MONITORING;
            }

            break;


        /* ====================================================
         * SYSTEM SHUTDOWN ACTIVE
         * ==================================================== */

        case SYSTEM_SHUTDOWN_ACTIVE:

            /*
             * Keep cutoff relay active for 800 ms.
             */
            if ((HAL_GetTick() - shutdown_time) >= 800)
            {
                /*
                 * Turn cutoff relay OFF.
                 */
                IO_CutoffRelay_Off(1);

                /*
                 * Return to normal monitoring.
                 */
                system_state = SYSTEM_MONITORING;
                system_state_health = SYSTEM_MONITORING;

                if (condition == MACHINE_WORKING)
                {
                    /*
                     * Machine has restarted / resumed work.
                     */
                    system_state = SYSTEM_MONITORING;
                    system_state_health = SYSTEM_MONITORING;
                }
            }

            break;


        /* ====================================================
         * SYSTEM FAULT
         * ==================================================== */

        case SYSTEM_FAULT:

            /*
             * Stop timer.
             */
            Timer_Manager_Stop();

            /*
             * Ensure shutdown relay is OFF.
             */
            IO_CutoffRelay_Off(1);

            /*
             * Turn all pilot indicators OFF.
             */
            IO_PilotYellow_On(1);
            IO_PilotRed_Off(1);
            IO_PilotGreen_Off(1);

            system_state = SYSTEM_MONITORING;

            /*
             * Remain in SYSTEM_FAULT.
             */
            break;


        /* ====================================================
         * INVALID STATE
         * ==================================================== */

        default:

            Timer_Manager_Stop();

            system_state = SYSTEM_FAULT;

            break;
    }
}
