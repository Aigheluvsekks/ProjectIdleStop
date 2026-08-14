#ifndef CAN_DECODE_H
#define CAN_DECODE_H

#include <stdint.h>
#include <stdbool.h>

typedef struct
{
	uint16_t rpm;
	bool rpm_Valid;

	uint16_t swingR_Press;
	uint16_t swingL_Press;
	bool swingL_Press_Valid;
	bool swingR_Press_Valid;

	uint16_t BoomD_Press;
	uint16_t BoomUP_Press;
	bool BoomD_Press_Valid;
	bool BoomUP_Press_Valid;

	uint16_t ArmDig_Press;
	bool ArmDig_Press_Valid;

	uint16_t BucketDump_Press;
	bool BucketDump_Press_Valid;

	uint16_t TravelLR_Press;
	uint16_t TravelLF_Press;
	uint16_t TravelRR_Press;
	uint16_t TravelRF_Press;
	bool TravelLR_Press_Valid;
	bool TravelLF_Press_Valid;
	bool TravelRR_Press_Valid;
	bool TravelRF_Press_Valid;

	// uint16_t RPump_Press;
	// uint16_t LPump_Press;
	// uint16_t Engine_Temp;
}
MachineData_t;

void CAN_DecodeMessage(
uint32_t id,
uint8_t *data,
uint8_t dlc
);

MachineData_t CAN_GetMachineData(void);

#endif
