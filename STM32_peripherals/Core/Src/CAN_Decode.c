#include "CAN_Decode.h"

static MachineData_t machien_data =
{
		rpm = 0;
		swingR_Press = 0;
		swingL_Press = 0;
		BoomD_Press = 0;
		BoomU_Press = 0;
		ArmDig_Press = 0;
		BucketDump_Press = 0;
		TravelLR_Press = 0;
		TravelLF_Press = 0;
		TravelRR_Press = 0;
		TravelRF_Press = 0;
		//RPump_Press  = 0;
		//LPump_Press = 0;
		//Engine_Temp = 0;
};

void CAN_DecodeMessage(
	uinr32_t id,
	uint8_t *data,
	uint8_t dlc
)
{
	switch(id)
	case 0x100 //Address RPM
	if (dlc >= 2) //Data Byte size
	{
		machine_data.rpm=
				((uint16_t)data[0] << 8) | //Unfinished
				data[1];
	}

	break;

	case 0x101 //address 2 SwingR_Press;

}
