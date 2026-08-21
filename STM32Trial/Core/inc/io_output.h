#ifndef IO_OUTPUT_H
#define IO_OUTPUT_H

#include "main.h"

void IO_Output_Init(void);

void IO_CutoffRelay_On(uint8_t state);
void IO_CutoffRelay_Off(uint8_t state);

void IO_PilotGreen_On(uint8_t state);
void IO_PilotGreen_Off(uint8_t state);

void IO_PilotYellow_On(uint8_t state);
void IO_PilotYellow_Off(uint8_t state);

void IO_PilotRed_On(uint8_t state);
void IO_PilotRed_Off(uint8_t state);

#endif
