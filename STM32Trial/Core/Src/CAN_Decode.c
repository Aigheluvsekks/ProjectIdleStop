#include "CAN_Decode.h"

/* 1. STRUCT INITIALIZATION FIXES */
static MachineData_t machine_data =
{
    .rpm = 0,                 // Use a dot (.) and comma (,) instead of '=' and ';'
    .swingR_Press = 0,
    .swingL_Press = 0,
    .BoomD_Press = 0,
    .BoomUP_Press = 0,
    .ArmDig_Press = 0,
    .BucketDump_Press = 0,
    .TravelLR_Press = 0,
    .TravelLF_Press = 0,
    .TravelRR_Press = 0,
    .TravelRF_Press = 0       // No comma needed on the last active item
    //.RPump_Press  = 0,
    //.LPump_Press = 0,
    //.Engine_Temp = 0
};                            // Add the missing semicolon here

void CAN_DecodeMessage(
    uint32_t id,
    uint8_t *data,
    uint8_t dlc
)
{
    /* 2. SWITCH STATEMENT FIXES */
    switch(id)
    {                         // Add missing opening brace for the switch body
        case 0x100:           // Add missing colon (:) after the case value
            if (dlc >= 2)
            {
                /* Assuming Big-Endian format (MSB in data[0], LSB in data[1]) */
                machine_data.rpm = ((uint16_t)data[0] << 8) | data[1];
            }
            break;

        case 0x101:           // Add missing colon (:)
            // Add parsing logic for SwingR_Press here
            break;            // Always remember the break statement

    }                         // Add missing closing brace for the switch body
}
