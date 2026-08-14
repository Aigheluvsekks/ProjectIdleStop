#ifndef VALIDITY_H
#define VALIDITY_H

/* 1. Pull the ONE true struct definition from CAN_Decode.h */
#include "CAN_Decode.h"

/* 2. The exact function prototype matching your .c file */
void DataValidity_Check(MachineData_t *data);

#endif
