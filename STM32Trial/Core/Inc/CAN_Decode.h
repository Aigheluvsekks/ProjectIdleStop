#ifndef CAN_DECODE_H
#define CAN_DECODE_H

#include <stdint.h>
#include <stdbool.h>
#include "Validity.h"
#include "Machine_Data.h"

//Offset for conversion to actual data
#define RPM_FACTOR 0.12350f
#define RPM_OFFSET -39.5f


void CAN_DecodeMessage(
uint32_t id,
uint8_t *data,
uint8_t dlc
);

MachineData_t CAN_GetMachineData(void);

#endif
