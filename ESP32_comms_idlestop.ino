#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <UniversalTelegramBot.h>
#include <ArduinoJson.h>
#include <time.h>

// ==========================================
// 1. CONFIGURATION & PIN DEFINITIONS
// ==========================================

const char* ssid = "seblak bloom";
const char* password = "tanyasendiri";
const char* BOT_TOKEN = "8808096291:AAHVFGRfhLJh9XcteVCiuDat24qTbBa94Zc";
const String CHAT_ID = "5213807799";

// UART2 Pins for STM32 Link
#define RXD2 16      // ESP32 RX <- STM32 TX (PA9)
#define TXD2 17      // ESP32 TX -> STM32 RX (PA10)

// ============================================================
// 2. OBJECTS
// ============================================================

WiFiClientSecure client;
UniversalTelegramBot bot(BOT_TOKEN, client);


// ============================================================
// 3. SERIAL CONFIGURATION
// ============================================================

// UART connected to STM32
// Change these pins to match your actual wiring.

#define STM32_RX_PIN 16
#define STM32_TX_PIN 17

HardwareSerial STM32Serial(2);


// ============================================================
// 4. STM32 COMMUNICATION
// ============================================================

#define STM32_HEARTBEAT_INTERVAL_MS 10000UL
#define STM32_TIMEOUT_MS             30000UL

unsigned long lastHeartbeatSent = 0;
unsigned long lastAckReceivedTime = 0;

bool isStm32Faulty = true;


// ============================================================
// 5. INTERNET STATUS
// ============================================================

bool isInternetConnected = false;


// ============================================================
// 6. IDLE STOP COUNTER
// ============================================================

unsigned long idleStopCount = 0;


// ============================================================
// 7. SERIAL RECEIVE BUFFER
// ============================================================

String stm32RxBuffer = "";


// ============================================================
// 8. TELEGRAM
// ============================================================

unsigned long lastTelegramCheck = 0;

const unsigned long TELEGRAM_CHECK_INTERVAL_MS = 1000;


// ============================================================
// 9. WIFI CONNECTION
// ============================================================

void connectWiFi()
{
    Serial.println();
    Serial.println("Connecting to WiFi...");

    WiFi.begin(ssid, password);

    unsigned long startTime = millis();

    while (WiFi.status() != WL_CONNECTED &&
           millis() - startTime < 15000UL)
    {
        delay(500);
        Serial.print(".");
    }

    Serial.println();

    if (WiFi.status() == WL_CONNECTED)
    {
        isInternetConnected = true;

        Serial.println("WiFi connected.");
        Serial.print("IP address: ");
        Serial.println(WiFi.localIP());
    }
    else
    {
        isInternetConnected = false;

        Serial.println("WiFi connection failed.");
    }
}


// ============================================================
// 10. CHECK WIFI STATUS
// ============================================================

void updateInternetStatus()
{
    bool connected =
        (WiFi.status() == WL_CONNECTED);

    if (connected != isInternetConnected)
    {
        isInternetConnected = connected;

        if (isInternetConnected)
        {
            Serial.println("Internet connection restored.");
        }
        else
        {
            Serial.println("Internet connection lost.");
        }
    }
}


// ============================================================
// 11. SEND MESSAGE TO STM32
// ============================================================

void sendToSTM32(const char* message)
{
    STM32Serial.print(message);
    STM32Serial.print('\n');

    Serial.print("ESP32 -> STM32: ");
    Serial.println(message);
}


// ============================================================
// 12. PROCESS ONE COMPLETE STM32 MESSAGE
// ============================================================

void processSTM32Message(String msg)
{
    msg.trim();

    if (msg.length() == 0)
    {
        return;
    }

    Serial.print("STM32 -> ESP32: ");
    Serial.println(msg);


    // ========================================================
    // HEARTBEAT ACK
    // ========================================================

    if (msg == "EVENT:ACK")
    {
        lastAckReceivedTime = millis();

        if (isStm32Faulty)
        {
            isStm32Faulty = false;

            Serial.println(
                "STM32 communication restored."
            );

            if (isInternetConnected)
            {
                bot.sendMessage(
                    CHAT_ID,
                    "STM32 communication restored.",
                    ""
                );
            }
        }

        return;
    }


    // ========================================================
    // IDLE STOP EVENT
    // ========================================================

    if (msg == "EVENT:IDLE_STOP")
    {
        idleStopCount++;

        Serial.println(
            "Idle Stop event received."
        );

        if (isInternetConnected)
        {
            String reply =
                "IDLE STOP EVENT\n\n";

            reply +=
                "Idle-stop activation detected.\n";

            reply +=
                "Total stop events: " +
                String(idleStopCount);

            bot.sendMessage(
                CHAT_ID,
                reply,
                ""
            );
        }

        return;
    }


    // ========================================================
    // STATUS RESPONSE
    // ========================================================
    //
    // STM32 sends:
    //
    // STATUS:1800
    //
    // RPM only.
    // ========================================================

    if (msg.startsWith("STATUS:"))
    {
        String rpm =
            msg.substring(7);

        if (isInternetConnected)
        {
            String reply =
                "ENGINE STATUS\n\n";

            reply +=
                "RPM: " +
                rpm +
                " rev/min";

            bot.sendMessage(
                CHAT_ID,
                reply,
                ""
            );
        }

        return;
    }


    // ========================================================
    // IDLE STATISTICS
    // ========================================================
    //
    // STM32 sends:
    //
    // IDLESTAT:work,current_idle,total_idle,idle_saved
    //
    // Example:
    //
    // IDLESTAT:3720,15,1280,0
    // ========================================================

    if (msg.startsWith("IDLESTAT:"))
    {
        String data =
            msg.substring(9);

        int idx1 =
            data.indexOf(',');

        int idx2 =
            data.indexOf(',', idx1 + 1);

        int idx3 =
            data.indexOf(',', idx2 + 1);

        if (idx1 != -1 &&
            idx2 != -1 &&
            idx3 != -1)
        {
            String timeWork =
                data.substring(0, idx1);

            String timeIdle =
                data.substring(
                    idx1 + 1,
                    idx2
                );

            String totalIdle =
                data.substring(
                    idx2 + 1,
                    idx3
                );

            String idleSaved =
                data.substring(
                    idx3 + 1
                );

            String reply =
                "ENGINE METRICS\n\n";

            reply +=
                "Total Work Time: " +
                timeWork +
                " seconds\n";

            reply +=
                "Current Idle Time: " +
                timeIdle +
                " seconds\n";

            reply +=
                "Total Idle Time: " +
                totalIdle +
                " seconds\n";

            reply +=
                "Idle Time Saved: " +
                idleSaved +
                " seconds\n";

            reply +=
                "Idle Stop Activations: " +
                String(idleStopCount);

            if (isInternetConnected)
            {
                bot.sendMessage(
                    CHAT_ID,
                    reply,
                    ""
                );
            }
        }
        else
        {
            Serial.println(
                "Invalid IDLESTAT format."
            );
        }

        return;
    }


    // ========================================================
    // HISTORY EMPTY
    // ========================================================

    if (msg == "LOG_EMPTY")
    {
        if (isInternetConnected)
        {
            bot.sendMessage(
                CHAT_ID,
                "IDLE STOP HISTORY\n\n"
                "No history recorded yet.",
                ""
            );
        }

        return;
    }


    // ========================================================
    // HISTORY START
    // ========================================================

    if (msg == "LOG_START")
    {
        if (isInternetConnected)
        {
            bot.sendMessage(
                CHAT_ID,
                "IDLE STOP HISTORY\n",
                ""
            );
        }

        return;
    }


    // ========================================================
    // HISTORY ENTRY
    // ========================================================

    if (msg.startsWith("LOG:"))
    {
        String logEntry =
            msg.substring(4);

        if (isInternetConnected)
        {
            bot.sendMessage(
                CHAT_ID,
                "LOG: " + logEntry,
                ""
            );
        }

        return;
    }


    // ========================================================
    // HISTORY END
    // ========================================================

    if (msg == "LOG_END")
    {
        if (isInternetConnected)
        {
            bot.sendMessage(
                CHAT_ID,
                "End of history.",
                ""
            );
        }

        return;
    }


    // ========================================================
    // UNKNOWN MESSAGE
    // ========================================================

    Serial.print(
        "Unknown STM32 message: "
    );

    Serial.println(msg);
}


// ============================================================
// 13. READ STM32 UART
// ============================================================

void readSTM32Serial()
{
    while (STM32Serial.available())
    {
        char c =
            STM32Serial.read();

        if (c == '\n' || c == '\r')
        {
            if (stm32RxBuffer.length() > 0)
            {
                processSTM32Message(
                    stm32RxBuffer
                );

                stm32RxBuffer = "";
            }
        }
        else
        {
            if (stm32RxBuffer.length() < 255)
            {
                stm32RxBuffer += c;
            }
            else
            {
                Serial.println(
                    "STM32 RX buffer overflow."
                );

                stm32RxBuffer = "";
            }
        }
    }
}


// ============================================================
// 14. STM32 HEARTBEAT
// ============================================================

void handleSTM32Heartbeat()
{
    unsigned long now = millis();


    // --------------------------------------------------------
    // Send heartbeat request
    // --------------------------------------------------------

    if (now - lastHeartbeatSent >=
        STM32_HEARTBEAT_INTERVAL_MS)
    {
        lastHeartbeatSent = now;

        sendToSTM32("!");
    }


    // --------------------------------------------------------
    // Check STM32 timeout
    // --------------------------------------------------------

    if (now - lastAckReceivedTime >=
        STM32_TIMEOUT_MS)
    {
        if (!isStm32Faulty)
        {
            isStm32Faulty = true;

            Serial.println(
                "STM32 communication timeout."
            );

            if (isInternetConnected)
            {
                bot.sendMessage(
                    CHAT_ID,
                    "STM32 communication FAULT.\n"
                    "No heartbeat response received.",
                    ""
                );
            }
        }
    }
}


// ============================================================
// 15. TELEGRAM COMMAND HANDLER
// ============================================================

void handleTelegramCommands(
    int numNewMessages
)
{
    for (int i = 0;
         i < numNewMessages;
         i++)
    {
        String chat_id =
            bot.messages[i].chat_id;

        String text =
            bot.messages[i].text;


        // ====================================================
        // SECURITY
        // ====================================================

        if (chat_id != CHAT_ID)
        {
            bot.sendMessage(
                chat_id,
                "Unauthorized user.",
                ""
            );

            continue;
        }


        // ====================================================
        // /start
        // ====================================================

        if (text == "/start")
        {
            String welcome =
                "Idle Stop Monitor\n\n";

            welcome +=
                "/status - View engine RPM\n";

            welcome +=
                "/idlestate - View idle metrics\n";

            welcome +=
                "/history - View idle-stop history\n";

            welcome +=
                "/stopcount - View idle-stop count\n";

            welcome +=
                "/stmcond - View STM32 communication status\n";

            bot.sendMessage(
                chat_id,
                welcome,
                ""
            );

            continue;
        }


        // ====================================================
        // /stmcond
        // ====================================================

        if (text == "/stmcond")
        {
            if (isStm32Faulty)
            {
                bot.sendMessage(
                    chat_id,
                    "STM32 STATUS\n\n"
                    "FAULT\n"
                    "No recent heartbeat response.",
                    ""
                );
            }
            else
            {
                bot.sendMessage(
                    chat_id,
                    "STM32 STATUS\n\n"
                    "OK\n"
                    "Communication active.",
                    ""
                );
            }

            continue;
        }


        // ====================================================
        // /stopcount
        // ====================================================

        if (text == "/stopcount")
        {
            String reply =
                "IDLE STOP COUNT\n\n";

            reply +=
                "Activations: " +
                String(idleStopCount);

            bot.sendMessage(
                chat_id,
                reply,
                ""
            );

            continue;
        }


        // ====================================================
        // /status
        // ====================================================

        if (text == "/status")
        {
            if (isStm32Faulty)
            {
                bot.sendMessage(
                    chat_id,
                    "Command rejected.\n"
                    "STM32 is in FAULT state.",
                    ""
                );
            }
            else
            {
                sendToSTM32("?");
            }

            continue;
        }


        // ====================================================
        // /idlestate
        // ====================================================

        if (text == "/idlestate")
        {
            if (isStm32Faulty)
            {
                bot.sendMessage(
                    chat_id,
                    "Command rejected.\n"
                    "STM32 is in FAULT state.",
                    ""
                );
            }
            else
            {
                sendToSTM32("#");
            }

            continue;
        }


        // ====================================================
        // /history
        // ========================================================

        if (text == "/history")
        {
            if (isStm32Faulty)
            {
                bot.sendMessage(
                    chat_id,
                    "Command rejected.\n"
                    "STM32 is in FAULT state.",
                    ""
                );
            }
            else
            {
                sendToSTM32("*");
            }

            continue;
        }


        // ====================================================
        // UNKNOWN COMMAND
        // ====================================================

        bot.sendMessage(
            chat_id,
            "Unknown command.\n\n"
            "Use /start to see available commands.",
            ""
        );
    }
}


// ============================================================
// 16. CHECK TELEGRAM
// ============================================================

void checkTelegram()
{
    if (!isInternetConnected)
    {
        return;
    }

    unsigned long now =
        millis();

    if (now - lastTelegramCheck <
        TELEGRAM_CHECK_INTERVAL_MS)
    {
        return;
    }

    lastTelegramCheck = now;

    int numNewMessages =
        bot.getUpdates(
            bot.last_message_received + 1
        );

    while (numNewMessages)
    {
        Serial.print(
            "Telegram messages received: "
        );

        Serial.println(
            numNewMessages
        );

        handleTelegramCommands(
            numNewMessages
        );

        numNewMessages =
            bot.getUpdates(
                bot.last_message_received + 1
            );
    }
}


// ============================================================
// 17. SETUP
// ============================================================

void setup()
{
    Serial.begin(115200);

    delay(1000);

    Serial.println();
    Serial.println(
        "================================"
    );

    Serial.println(
        "ESP32 Idle Stop Monitor"
    );

    Serial.println(
        "================================"
    );


    // --------------------------------------------------------
    // STM32 UART
    // --------------------------------------------------------

    STM32Serial.begin(
        115200,
        SERIAL_8N1,
        STM32_RX_PIN,
        STM32_TX_PIN
    );

    Serial.println(
        "STM32 UART initialized."
    );


    // --------------------------------------------------------
    // WiFi
    // --------------------------------------------------------

    connectWiFi();


    // --------------------------------------------------------
    // Telegram TLS
    // --------------------------------------------------------

    client.setInsecure();

    if (isInternetConnected)
    {
        Serial.println(
            "Telegram client ready."
        );
    }


    // --------------------------------------------------------
    // STM32 health initialization
    // --------------------------------------------------------

    lastAckReceivedTime =
        millis();

    lastHeartbeatSent =
        millis();

    Serial.println(
        "STM32 communication monitor started."
    );
}


// ============================================================
// 18. MAIN LOOP
// ============================================================

void loop()
{
    // --------------------------------------------------------
    // Update Internet status
    // --------------------------------------------------------

    updateInternetStatus();


    // --------------------------------------------------------
    // Read STM32 UART
    // --------------------------------------------------------

    readSTM32Serial();


    // --------------------------------------------------------
    // STM32 heartbeat
    // --------------------------------------------------------

    handleSTM32Heartbeat();


    // --------------------------------------------------------
    // Telegram
    // --------------------------------------------------------

    checkTelegram();


    // --------------------------------------------------------
    // Keep ESP32 responsive
    // --------------------------------------------------------

    delay(5);
}