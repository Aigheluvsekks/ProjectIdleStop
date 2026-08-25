#include "Decision.h"
#include "CAN_Decode.h"
#include "io_input.h"
#include "Machine_Param.h"
#include "stm32f4xx_hal.h"


/* ============================================================
 * TRANSIENT QUALIFICATION
 * ============================================================ */

//Diadjust sesuai ketentuan operator
#define IDLE_QUALIFICATION_TIME_MS       300U
#define WORKING_QUALIFICATION_TIME_MS    300U


/* ============================================================
 * PRIVATE VARIABLES
 * ============================================================ */

static MachineCondition_t confirmedCondition = MACHINE_UNKNOWN;

static uint32_t idleStartTick = 0;
static uint32_t workingStartTick = 0;

static bool idleQualificationActive = false;
static bool workingQualificationActive = false;

static bool workDone = false;


/* ============================================================
 * DEBUG VARIABLES
 * ============================================================ */

volatile uint32_t debug_idle_qual_time_ms = 0;
volatile uint32_t debug_working_qual_time_ms = 0;

volatile bool debug_idle_qual_active = false;
volatile bool debug_working_qual_active = false;


/* ============================================================
 * MACHINE CONDITION DECISION
 * ============================================================ */

MachineCondition_t Decision_GetMachineCondition(void)
{
    MachineData_t machine = CAN_GetMachineData();

    /* --------------------------------------------------------
     * Invalid RPM data
     * -------------------------------------------------------- */

    if (machine.rpm_Valid != DATA_VALID)
    {
        /*
         * Do NOT immediately change the confirmed condition.
         *
         * CAN health / timeout is handled separately by
         * System Health.
         */
        return confirmedCondition;
    }


    /* ========================================================
     * CURRENT CONDITION = WORKING
     * ======================================================== */

    if (machine.rpm > RPM_WORK_THRESH)
    {
        /*
         * Working indication detected.
         *
         * Cancel any pending IDLE transition.
         */
        idleQualificationActive = false;
        idleStartTick = 0;
        debug_idle_qual_time_ms = 0;
        debug_idle_qual_active = false;


        /*
         * If we're already working, nothing else to do.
         */
        if (confirmedCondition == MACHINE_WORKING)
        {
            return confirmedCondition;
        }


        /*
         * Start WORKING qualification if necessary.
         */
        if (!workingQualificationActive)
        {
            workingQualificationActive = true;
            workingStartTick = HAL_GetTick();

            debug_working_qual_active = true;
        }


        /*
         * Calculate qualification time.
         */
        debug_working_qual_time_ms =
            HAL_GetTick() - workingStartTick;


        /*
         * Has WORKING persisted long enough?
         */
        if (debug_working_qual_time_ms >=
            WORKING_QUALIFICATION_TIME_MS)
        {
            confirmedCondition = MACHINE_WORKING;

            workDone = true;

            workingQualificationActive = false;
            workingStartTick = 0;

            debug_working_qual_active = false;
        }


        return confirmedCondition;
    }


    /* ========================================================
     * CURRENT CONDITION = IDLE
     * ======================================================== */

    else
    {
        /*
         * Idle indication detected.
         *
         * Cancel any pending WORKING transition.
         */
        workingQualificationActive = false;
        workingStartTick = 0;
        debug_working_qual_time_ms = 0;
        debug_working_qual_active = false;


        /*
         * If we're already idle, nothing else to do.
         */
        if (confirmedCondition == MACHINE_IDLE)
        {
            return confirmedCondition;
        }


        /*
         * Start IDLE qualification if necessary.
         */
        if (!idleQualificationActive)
        {
            idleQualificationActive = true;
            idleStartTick = HAL_GetTick();

            debug_idle_qual_active = true;
        }


        /*
         * Calculate qualification time.
         */
        debug_idle_qual_time_ms =
            HAL_GetTick() - idleStartTick;


        /*
         * Has IDLE persisted long enough?
         */
        if (debug_idle_qual_time_ms >=
            IDLE_QUALIFICATION_TIME_MS)
        {
            confirmedCondition = MACHINE_IDLE;

            idleQualificationActive = false;
            idleStartTick = 0;

            debug_idle_qual_active = false;
        }


        return confirmedCondition;
    }
}

bool Decision_HasWorkBeenDone(void)
{
	return workDone;
}
