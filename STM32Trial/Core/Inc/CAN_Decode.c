#include "CAN_Decode.h"
#include "CAN_Manager.h"


uint32_t BE;
uint32_t RPMA;
uint32_t RPMB;
uint32_t BE_RPM;



static MachineData_t machine_data =
{
		.rpm = 0,
		.raw_rpm = 0

		// erase the /* */ to connect or decode other var. or systems
	/*.swingR_Press = 0,
		.swingL_Press = 0,
		.BoomD_Press = 0,
		.BoomUP_Press = 0,
		.ArmDig_Press = 0,
		.BucketDump_Press = 0,
		.TravelLR_Press = 0,
		.TravelLF_Press = 0,
		.TravelRR_Press = 0,
		.TravelRF_Press = 0       // No comma needed on the last active item
	  	.RPump_Press  = 0,
      	.LPump_Press = 0,
      	.Engine_Temp = 0
       * */
};

void CAN_DecodeMessage(
	uint32_t id,
	uint8_t *data,
	uint8_t dlc
)
{
	switch(id)
	{
	case 0x11F: //RPM Case
	if (dlc >= 2) //Data Byte size
	{
		RPMA =  CAN_RX_Debug.Data[0];
		RPMB =  CAN_RX_Debug.Data[1];

		// Big Endian Init
		BE_RPM = 256 * RPMA + RPMB;

		machine_data.raw_rpm = BE_RPM;

		machine_data.rpm =
		    (BE_RPM * RPM_FACTOR) + RPM_OFFSET;

		 /* RPM data successfully received and decoded */
		machine_data.rpm_Valid = DATA_VALID;
	}

	break;

 /*
  * Currently only rpm data is read and used since the main
  * hydraulic pump is controlled by / connected to the engine with shaft
  * power derived from the main engine
  * for additional addition please contact at gadingsakti.work@gmail.com or
  * make new function / if loop based on big endian and little endian conversion
  * big endian and little endian need to be looked for based on trial and error
  * and the matlab code provided on the github link below
  *
  * https://github.com/Aigheluvsekks/ProjectIdleStop/tree/main
  *
  */

}
}

MachineData_t CAN_GetMachineData(void)
{
	return machine_data;
}


