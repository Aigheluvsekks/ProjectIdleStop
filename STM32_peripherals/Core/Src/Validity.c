#include "Validity.h"
#include "CAN_Manager.h"
#include "Machine_Config_Max.h"
#include "CAN_Decode.h"

void DataValidity_Check(MachineData_t *data)
{
    data->rpm_valid = (data->rpm >= RPM_MIN &&
    		data->rpm <= RPM_MAX);

    data->swingR_Press_Valid = (data->swingR_Press >= SWING_PRESS_MIN &&
    		data->swingR_Press <= SWING_PRESS_MAX);

    data->swingL_Press_Valid = (data->swingL_Press >= SWING_PRESS_MIN &&
    		data->swingL_Press <= SWING_PRESS_MAX);

    data->BoomD_Press_Valid = (data->BoomD_Press >= BOOMD_PRESS_MIN &&
    		data->BoomD_Press <= BOOMD_PRESS_MAX);

    data->BoomUP_Press_Valid = (data->BoomUP_press >= BOOMUP_PRESS_MIN &&
    		data->BoomUP_Press <= BOOMUP_PRESS_MAX);

       data->ArmDig_Press_Valid = (data->ArmDig_Press >= ARMDIG_PRESS_MIN &&
    		data->ArmDig_Press <= ARMDIG_PRESS_MAX);

    data->BucketDump_Press_Valid = (data->BucketDump_Press >= BUCKETDUMP_PRESS_MIN &&
    		data->BucketDump_Press <= BUCKETDUMP_PRESS_MAX);

    data->TravelLR_Press_Valid = (data->TravelLR_Press >= TRAVEL_PRESS_MIN &&
    		data->TravelLR_Press <= TRAVEL_PRESS_MAX);

    data->TravelLF_Press_Valid = (data->TravelLF_Press >= TRAVEL_PRESS_MIN &&
        		data->TravelLF_Press <= TRAVEL_PRESS_MAX);

    data->TravelRR_Press_Valid = (data->TravelRR_Press >= TRAVEL_PRESS_MIN &&
        		data->TravelRR_Press <= TRAVEL_PRESS_MAX);

    data->TravelRF_Press_Valid = (data->TravelRF_Press >= TRAVEL_PRESS_MIN &&
        		data->TravelRF_Press <= TRAVEL_PRESS_MAX);

}
