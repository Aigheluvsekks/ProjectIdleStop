#ifndef DATA_VALIDITY_H
#define DATA_VALIDITY_H

#include "CAN_Manager.h"
#include "CAN_Decode.h"
#include "Machine_Data.h"

typedef enum
{
	DATA_VALID = 1,
	DATA_INVALID = 0
}DataValidity_t;

uint16_t rpm_valid;

DataValidity_t DataValidity_Check(MachineData_t *data);

#endif
