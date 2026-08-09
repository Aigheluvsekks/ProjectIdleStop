#include "System_manager.h"
#include "Decision.h"
#include "System_Health.h"
#include "Timer_Manager.h"
#include "io_output.h"


void SystemManager_Process(void)
{
    SystemHealth_t health =
        SystemHealth_Get();
    /* Inisiasi variabel "health" yang memiliki tipe "SystemHealth_t" refer to
     * System_Health.h and System_Health.c
     */

    MachineCondition_t condition =
        Decision_GetMachineCondition(
            CAN_GetMachineData()
        );

    /* Inisiasi variabel "condition" yang memiliki tipe "MachineCondition_t" refer to
         * Refer to Decision.h and Decision.c
         */

    /*
     * Cek Health / kesehatan sistem
     * Cek pembacaan CAN apakah valid dan sesuai dengan kriteria yang ditentukan
     * Jika pembacaan CAN gagal/ tidak memenuhi kriteria maka idle-stop akan
     * berhenti  (TimerManager_Stop)
     * Sehingga waktu countdown untuk menuju mati mesin akan direset/distop
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

            /*Jika Exca (data CAN <--- Decision dan CAN DECODER)
             * Dinilai OFF/ sedang dalam posisi Idle/ off
             * Maka System akan diubah state ke idle (System State = IDLE)
             */

            break;


        case SYSTEM_IDLE: //Inisiasi jika system terbaca Idle

            TimerManager_Start();// Jika terindikasi Idle, maka timer akan start

            system_state = SYSTEM_TIMER_RUNNING; //System State shift ke Timer Run

            break;


        case SYSTEM_TIMER_RUNNING:

        	/*
        	 * Jika terindikasi bahwa
        	 * 1. Exca melakukan pekerjaan pada saat timer running
        	 * 2. Sinyal CAN hilang/ tidak valid
        	 * Maka Timer Manager akan stop dan timer reset
        	 * Reset timer dilakukan di Timer_Manager.c
        	 *
        	 * Jika Timer sudah habis / expired, maka
        	 * akan dilakukan request untuk shutdown (IO Out)
        	 */

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
             * Jika terindikasi perlu shutdown, pastikan bahwa
             * Mesin dalam keadaan IDLE dan sinyal CAN Valid dan Sehat
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
