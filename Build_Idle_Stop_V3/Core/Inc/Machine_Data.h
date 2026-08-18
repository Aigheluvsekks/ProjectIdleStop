#ifndef MACHINE_DATA_H
#define MACHINE_DATA_H


typedef struct
{
	uint16_t raw_rpm;
	uint16_t rpm;
	uint16_t rpm_Valid;

/*
 *
 * DISCLAIMER: NEED TO ADD RAW_(VARIABLE NAME FIRST) FOR DECODING PURPOSES
	uint16_t swingR_Press;
	uint16_t swingL_Press;
	dataValidity_t swingL_Press_Valid;
	dataValidity_t swingR_Press_Valid;

	uint16_t BoomD_Press;
	uint16_t BoomUP_Press;
	dataValidity_t BoomD_Press_Valid;
	dataValidity_t BoomUP_Press_Valid;

	uint16_t ArmDig_Press;
	dataValidity_t ArmDig_Press_Valid;

	uint16_t BucketDump_Press;
	dataValidity_t BucketDump_Press_Valid;

	uint16_t TravelLR_Press;
	uint16_t TravelLF_Press;
	uint16_t TravelRR_Press;
	uint16_t TravelRF_Press;
	dataValidity_t TravelLR_Press_Valid;
	dataValidity_t TravelLF_Press_Valid;
	dataValidity_t TravelRR_Press_Valid;
	dataValidity_t TravelRF_Press_Valid;

	// uint16_t RPump_Press;
	// uint16_t LPump_Press;
	// uint16_t Engine_Temp;
	 *
	 */
} MachineData_t;

#endif
