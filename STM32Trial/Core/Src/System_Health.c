#include "System_Health.h"
#include "CAN_Manager.h"
#include "stm32f4xx_hal.h"
#include "System_Manager.h"

/* ============================================================
 * DEBUG VARIABLES
 * ============================================================ */

volatile SystemHealth_t debug_last_health;
volatile uint32_t debug_rpm_age;
volatile uint8_t debug_can_healthy;

/* ============================================================
 * RPM HEALTH PARAMETERS
 * ============================================================ */

/*
 * RPM data dianggap stale setelah waktu ini.
 *
 * Contoh:
 * RPM frame normal setiap ~100 ms
 * Timeout = 140 ms
 */
#define RPM_TIMEOUT_MS        140U

/*
 * RPM harus tetap hilang selama waktu ini
 * sebelum benar-benar dianggap FAULT.
 *
 * Jadi transient CAN/RPM loss tidak langsung
 * membuat system fault.
 */
#define RPM_FAULT_CONFIRM_MS  1000U


/* ============================================================
 * INTERNAL RPM FAULT TIMER
 * ============================================================ */

/*
 * Menyimpan waktu ketika RPM pertama kali dianggap stale.
 *
 * 0 = tidak sedang menunggu konfirmasi fault.
 */
static uint32_t rpmFaultStartTick = 0;


/* ============================================================
 * SYSTEM HEALTH
 * ============================================================ */

SystemHealth_t SystemHealth_Get(SystemState_t system_state_health)
{
    uint32_t lastRPM = CAN_GetLastRPMUpdate();
    uint32_t now = HAL_GetTick();

    debug_can_healthy = CAN_IsHealthy();

    /*
     * ========================================================
     * CAN HARDWARE HEALTH
     * ========================================================
     */

    if (!debug_can_healthy)
    {
        /*
         * CAN memang sedang OFF karena shutdown.
         * Jangan dianggap sebagai fault.
         */
        if (system_state_health == SYSTEM_SHUTDOWN_ACTIVE)
        {
            debug_last_health = SYSTEM_HEALTH_CAN_OFF_EXPECTED;

            return SYSTEM_HEALTH_CAN_OFF_EXPECTED;
        }

        /*
         * CAN hardware benar-benar error.
         *
         * Untuk sekarang kita tetap anggap ini hard fault.
         */
        debug_last_health = SYSTEM_HEALTH_CAN_ERROR;

        return SYSTEM_HEALTH_CAN_ERROR;
    }


    /*
     * ========================================================
     * STARTUP / BEFORE FIRST RPM
     * ========================================================
     */

    /*
     * Engine belum pernah mengirim RPM.
     *
     * Ini NORMAL.
     *
     * Excavator:
     *
     * Main Power ON
     *      ↓
     * ECU ON
     *      ↓
     * Engine belum start
     *      ↓
     * RPM belum ada
     *
     * Jangan fault di sini.
     */
    if (!CAN_HasValidRPM())
    {
        /*
         * Tidak ada fault timer yang sedang berjalan.
         */
        rpmFaultStartTick = 0;

        debug_rpm_age = 0;

        debug_last_health = SYSTEM_HEALTH_OK;

        return SYSTEM_HEALTH_OK;
    }


    /*
     * ========================================================
     * RPM HAS BEEN VALID
     * ========================================================
     */

    /*
     * Sekarang RPM memang sudah pernah diterima.
     * Jadi lastRPM valid dan boleh digunakan untuk
     * monitoring freshness.
     */
    debug_rpm_age = now - lastRPM;


    /*
     * ========================================================
     * RPM STILL FRESH
     * ========================================================
     */

    if (debug_rpm_age <= RPM_TIMEOUT_MS)
    {
        /*
         * RPM kembali normal.
         *
         * Kalau sebelumnya sedang menunggu
         * fault confirmation, batalkan.
         */
        rpmFaultStartTick = 0;

        debug_last_health = SYSTEM_HEALTH_OK;

        return SYSTEM_HEALTH_OK;
    }


    /*
     * ========================================================
     * RPM IS STALE
     * ========================================================
     */

    /*
     * RPM sudah melewati RPM_TIMEOUT_MS.
     *
     * JANGAN langsung fault.
     *
     * Mulai fault confirmation timer.
     */
    if (rpmFaultStartTick == 0)
    {
        rpmFaultStartTick = now;
    }


    /*
     * ========================================================
     * FAULT CONFIRMATION / HYSTERESIS
     * ========================================================
     */

    /*
     * RPM harus tetap stale selama
     * RPM_FAULT_CONFIRM_MS sebelum fault.
     */
    if ((now - rpmFaultStartTick) >= RPM_FAULT_CONFIRM_MS)
    {
        debug_last_health = SYSTEM_HEALTH_CAN_TIMEOUT;

        return SYSTEM_HEALTH_CAN_TIMEOUT;
    }


    /*
     * RPM baru sebentar hilang.
     *
     * Belum cukup lama untuk dianggap fault.
     */
    debug_last_health = SYSTEM_HEALTH_OK;

    return SYSTEM_HEALTH_OK;
}
