#include <Arduino.h>
#include "driver/twai.h"

#define TX_PIN GPIO_NUM_21
#define RX_PIN GPIO_NUM_22

void setup() {

  Serial.begin(115200);

  twai_general_config_t g_config =
      TWAI_GENERAL_CONFIG_DEFAULT(
          TX_PIN,
          RX_PIN,
          TWAI_MODE_NORMAL);

  twai_timing_config_t t_config =
      TWAI_TIMING_CONFIG_500KBITS();

  twai_filter_config_t f_config =
      TWAI_FILTER_CONFIG_ACCEPT_ALL();

  twai_driver_install(&g_config,&t_config,&f_config);
  twai_start();

  Serial.println("================");
  Serial.println("CAN Receiver Started");
  Serial.println("================");
}

void loop()
{
    twai_message_t msg;

    if(twai_receive(&msg,pdMS_TO_TICKS(1000))==ESP_OK)
    {
        Serial.println("----------------");
        Serial.println("Frame Received");

        Serial.print("ID : 0x");
        Serial.println(msg.identifier,HEX);

        Serial.print("DLC : ");
        Serial.println(msg.data_length_code);

        Serial.print("Data : ");

        for(int i=0;i<msg.data_length_code;i++)
        {
            if(msg.data[i]<16)
                Serial.print("0");

            Serial.print(msg.data[i],HEX);
            Serial.print(" ");
        }

        Serial.println();
        Serial.println("----------------");
    }
}