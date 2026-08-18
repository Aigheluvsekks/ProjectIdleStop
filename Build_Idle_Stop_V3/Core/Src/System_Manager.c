#include "System_manager.h"
#include "Decision.h"
#include "System_Health.h"
#include "Timer_Manager.h"
#include "io_output.h"


static SystemState_t system_state;
static SystemState_t system_state_health;
static uint32_t shutdown_time;

void SystemManager_SetState(SystemState_t state)
{
    system_state = state;
}

void SystemManager_Init(void)
{
    system_state = SYSTEM_MONITORING;
    system_state_health = SYSTEM_MONITORING;
    shutdown_time = 0;
}

SystemState_t SystemManager_GetState(void)
{
    return system_state;
}

void SystemManager_Process(void)
{
    SystemHealth_t health = SystemHealth_Get(system_state_health);
    /* Inisiasi variabel "health" yang memiliki tipe "SystemHealth_t" refer to
     * System_Health.h and System_Health.c
     * Bagian ini juga digunakan untuk menyambungkan ke System_Health, agar System_Health mengetahui
     * Apabila Engine sudah mati / belum
     */
    MachineCondition_t condition = Decision_GetMachineCondition();
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

    if (health == SYSTEM_HEALTH_CAN_ERROR ||
        health == SYSTEM_HEALTH_CAN_TIMEOUT)
    {
        Timer_Manager_Stop();

        system_state = SYSTEM_FAULT;
        system_state_health = SYSTEM_FAULT;

        return;
    }


    switch (system_state)
    {
        case SYSTEM_MONITORING:

        	if (condition == MACHINE_WORKING)
        	    {
        	        // Machine is working
        	        HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, GPIO_PIN_SET); // LED ON
        	        HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, GPIO_PIN_SET);   // LED OFF
        	        Timer_Manager_Stop();
        	        system_state = SYSTEM_MONITORING;
        	        IO_CutoffRelay_Off(1);
        	        IO_PilotYellow_Off(1);
        	        IO_PilotRed_Off(1);
        	        IO_PilotGreen_Off(1);
        	        system_state_health = SYSTEM_MONITORING;
        	    }


            if (condition == MACHINE_IDLE)
            {
                system_state = SYSTEM_IDLE;
                system_state_health = SYSTEM_MONITORING;
            }

            /*Jika Exca (data CAN <--- Decision dan CAN DECODER)
             * Dinilai OFF/ sedang dalam posisi Idle/ off
             * Maka System akan diubah state ke idle (System State = IDLE)
             */

            break;


        case SYSTEM_IDLE: //Inisiasi jika system terbaca Idle

            Timer_Manager_Start();// Jika terindikasi Idle, maka timer akan start

            system_state = SYSTEM_TIMER_RUNNING; //System State shift ke Timer Run
            system_state_health = SYSTEM_MONITORING;
            IO_CutoffRelay_Off(1);
            IO_PilotGreen_On(1);
            HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, GPIO_PIN_RESET);
            HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, GPIO_PIN_SET);

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
        	if((Timer_Manager_GetTargetTimeMs() - Timer_Manager_GetElapsedTimeMs()) <= 500){
        		IO_PilotRed_On(1);
                HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, GPIO_PIN_SET);
                HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, GPIO_PIN_RESET);
        	}
        	else
        	{
        		IO_PilotRed_Off(1);
        		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, GPIO_PIN_SET);
        	}
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

            else if (condition == MACHINE_UNKNOWN)
            {
                Timer_Manager_Stop();
                IO_CutoffRelay_Off(1);
                IO_PilotYellow_Off(1);
                IO_PilotRed_Off(1);
                IO_PilotGreen_Off(1);
                system_state = SYSTEM_MONITORING;
                system_state_health = SYSTEM_MONITORING;
            }

            else if (Timer_Manager_IsExpired() == 1)
            {
                system_state = SYSTEM_SHUTDOWN_REQUESTED;
                system_state_health = SYSTEM_MONITORING;
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
                IO_CutoffRelay_On(1);

                shutdown_time = HAL_GetTick();
                HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, GPIO_PIN_SET);
                HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, GPIO_PIN_RESET);

                system_state = SYSTEM_SHUTDOWN_ACTIVE;
                system_state_health = SYSTEM_SHUTDOWN_ACTIVE;
            }
            else
            {
            	system_state = SYSTEM_MONITORING;
            	system_state_health = SYSTEM_MONITORING;
            }

            break;


        case SYSTEM_SHUTDOWN_ACTIVE:

        	if((HAL_GetTick() - shutdown_time) >= 800)
        	{
        		IO_CutoffRelay_Off(1);
        		system_state = SYSTEM_MONITORING;
        		system_state_health = SYSTEM_SHUTDOWN_ACTIVE;
        	}


            break;


        default:

            system_state = SYSTEM_FAULT;

            break;
    }
}
