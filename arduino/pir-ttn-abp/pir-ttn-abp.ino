
#include <lmic.h>
#include <hal/hal.h>

static u1_t NWKSKEY[16] = { 0x47, 0xE6, 0xD6, 0x36, 0xB8, 0xCE, 0x8E, 0xC3, 0x7C, 0x85, 0x53, 0x7D, 0xAD, 0xCA, 0xA5, 0x9A };
static u1_t APPSKEY[16] = { 0x0B, 0x8E, 0x6F, 0x40, 0x37, 0x85, 0xF1, 0x21, 0x45, 0x40, 0xC5, 0x53, 0xC5, 0x68, 0x87, 0x6E };
static u4_t DEVADDR = 0x260119FC;

// These callbacks are only used in over-the-air activation, so they are left empty here
void os_getArtEui (u1_t* buf) { }
void os_getDevEui (u1_t* buf) { }
void os_getDevKey (u1_t* buf) { }

static osjob_t sendjob;

// Schedule TX every 900 seconds (15 minutes)
const unsigned TX_INTERVAL = 900;

// Sensor reset interval = 6000ms (6 secs)
const unsigned RESET_INTERVAL = 6000;

// Pin mapping for Dragino Lora Shield
const lmic_pinmap lmic_pins = {
    .nss = 10,
    .rxtx = LMIC_UNUSED_PIN,
    .rst = 9,
    .dio = {2, 6, 7},
};

// Inputs and outputs
const int batteryCheckPin = A4;
const int inputPin = 3;
const int ledPin = 5;

// Variables
unsigned int count = 0;
unsigned int lastTriggeredAt = 0;


//
// Gets a rough idea of the battery status based on voltage
//
byte battery_percentage() {
    float voltage = analogRead(batteryCheckPin);
    byte percent = (voltage * 100.0) / 1024.0;
    return percent;
}

//
// Event handler
//
void onEvent (ev_t ev) {
    switch(ev) {
        case EV_TXCOMPLETE:
            Serial.println(F("EV_TXCOMPLETE"));
            os_setTimedCallback(&sendjob, os_getTime() + sec2osticks(TX_INTERVAL), do_send);
            break;
        default:
            Serial.print(F("Unhandled event: "));
            Serial.println(ev);
            break;
    }
}

//
// Send data
//
void do_send(osjob_t* j) {
    byte battery = battery_percentage();

    byte message[4];
    message[3] = (byte) battery;
    message[2] = (byte) (battery >> 8);
    message[1] = (byte) count;
    message[0] = (byte) (count >> 8);

    // Check that there is not a current TX/RX job running
    if (LMIC.opmode & OP_TXRXPEND) {
        Serial.println(F("OP_TXRXPEND, not sending"));
    } else {
        // Prepare upstream data transmission at the next possible time.
        LMIC_setTxData2(1, message, 4, 0);

        Serial.print(F("Packet queued at frequency: "));
        Serial.println(LMIC.freq);

        Serial.println(F("Counter reset"));
        count = 0;
    }
    // Next TX is scheduled after TX_COMPLETE event.
}


//
// Device setup routine
//
void setup() {
    pinMode(batteryCheckPin, INPUT);
    pinMode(inputPin, INPUT);
    pinMode(ledPin, OUTPUT);

    Serial.begin(9600);

    Serial.println(F("Initialising... "));

    os_init();

    LMIC_reset();
    LMIC_setSession(0x1, DEVADDR, NWKSKEY, APPSKEY);
    LMIC_setLinkCheckMode(0);
    LMIC.dn2Dr = DR_SF9;
    LMIC_setDrTxpow(DR_SF7, 14);

    // Use channel 0 only to align with my test gateway
    for (int i=1; i<=8; i++) LMIC_disableChannel(i);

    // Wait for PIR to stabilize...
    digitalWrite(ledPin, HIGH);
    delay(60000);
    digitalWrite(ledPin, LOW);

    lastTriggeredAt = millis();

    // Start job
    do_send(&sendjob);

    Serial.println(F("Running... "));
}


//
// The mighty loop...
//
void loop() {
    unsigned int now = millis();

    if ((now - lastTriggeredAt) > RESET_INTERVAL) {

        byte value = digitalRead(inputPin);

        if (value == HIGH) {

          lastTriggeredAt = millis();

          digitalWrite(ledPin, HIGH);

          Serial.println(F("Motion detected!"));

          count = count + 1;

          Serial.print(F("Count: "));
          Serial.println(count);

          Serial.println(F("Resetting...    "));

        } else {
          digitalWrite(ledPin, LOW);
        }
    }

    os_runloop_once();
}