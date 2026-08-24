#include "IdleMetrics.h"
#include "System_Manager.h"
#include "Decision.h"
#include "main.h"

/* ============================================================
 * INTERNAL VARIABLES
 * ============================================================ */

static uint32_t work_time_seconds = 0;
static uint32_t current_idle_time_seconds = 0;
static uint32_t total_idle_seconds = 0;
static uint32_t idle_saved_seconds = 0;

static uint32_t last_update_tick = 0;


/* ============================================================
 * INITIALIZATION
 * ============================================================ */

void IdleMetrics_Init(void)
{
    work_time_seconds = 0;
    current_idle_time_seconds = 0;
    total_idle_seconds = 0;
    idle_saved_seconds = 0;

    last_update_tick = HAL_GetTick();
}


/* ============================================================
 * UPDATE METRICS
 * ============================================================ */

void IdleMetrics_Update(void)
{
    uint32_t current_tick;
    uint32_t elapsed_ms;
    uint32_t elapsed_seconds;

    current_tick = HAL_GetTick();

    elapsed_ms = current_tick - last_update_tick;

    if (elapsed_ms < 1000U)
    {
        return;
    }

    elapsed_seconds = elapsed_ms / 1000U;

    /*
     * Preserve leftover milliseconds.
     */
    last_update_tick += elapsed_seconds * 1000U;


    /* ========================================================
     * Get confirmed machine condition
     * ======================================================== */

    MachineCondition_t condition =
        Decision_GetMachineCondition();


    /* ========================================================
     * WORKING
     * ======================================================== */

    if (condition == MACHINE_WORKING)
    {
        work_time_seconds += elapsed_seconds;

        /*
         * Machine is no longer idle.
         */
        current_idle_time_seconds = 0;
    }


    /* ========================================================
     * IDLE
     * ======================================================== */

    else if (condition == MACHINE_IDLE)
    {
        current_idle_time_seconds += elapsed_seconds;
        total_idle_seconds += elapsed_seconds;
    }


    /* ========================================================
     * UNKNOWN
     * ======================================================== */

    else
    {
        /*
         * Do not count unknown machine condition
         * as working or idle.
         */
    }
}


/* ============================================================
 * GETTERS
 * ============================================================ */

uint32_t IdleMetrics_GetWorkTime(void)
{
    return work_time_seconds;
}


uint32_t IdleMetrics_GetIdleTime(void)
{
    return current_idle_time_seconds;
}


uint32_t IdleMetrics_GetTotalIdleTime(void)
{
    return total_idle_seconds;
}


uint32_t IdleMetrics_GetIdleSavedTime(void)
{
    return idle_saved_seconds;
}
