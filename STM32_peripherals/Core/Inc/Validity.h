#ifndef DATA_VALIDITY_H
#define DATA_VALIDITY_H

#include "CAN_Manager.h"

typedef enum
{
	DATA_VALID,
	DATA_INVALID
}DataValidity_t;

DataValidity_t DataValidity_Check(
	const MachineData_t *data
);

#endif
