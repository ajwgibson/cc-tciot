
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

// Schedule TX every 'this many' seconds
const unsigned TX_INTERVAL = 900; // 900 = 15 minutes

// Pin mapping for Dragino Lora Shield
const lmic_pinmap lmic_pins = {
    .nss = 10,
    .rxtx = LMIC_UNUSED_PIN,
    .rst = 9,
    .dio = {2, 6, 7},
};

const int inputPin = 3;
const int ledPin = 5;

int          val   = 0;
unsigned int count = 0;
unsigned int battery = 100;


//
// Event handler
//
void onEvent (ev_t ev) {

    Serial.print(os_getTime());
    Serial.print(": ");

    switch(ev) {
        case EV_TXCOMPLETE:
            Serial.println("EV_TXCOMPLETE");
            os_setTimedCallback(&sendjob, os_getTime() + sec2osticks(TX_INTERVAL), do_send);
            break;
        default:
            Serial.print("Unhandled event: ");
            Serial.println(ev);
            break;
    }
}

//
// Send some data...
//
void do_send(osjob_t* j) {
    byte message[4];

    message[3] = (byte) battery;
    message[2] = (byte) (battery >> 8);
    message[1] = (byte) count;
    message[0] = (byte) count >> 8;

    // Check that there is not a current TX/RX job running
    if (LMIC.opmode & OP_TXRXPEND) {
        Serial.println("OP_TXRXPEND, not sending");
    } else {
        // Prepare upstream data transmission at the next possible time.
        LMIC_setTxData2(1, message, 4, 0);

        Serial.print("Packet queued at frequency: ");
        Serial.println(LMIC.freq);

        Serial.println("Counter reset");
        count = 0;
    }
    // Next TX is scheduled after TX_COMPLETE event.
}


//
// Device setup routine
//
void setup() {

    pinMode(inputPin, INPUT);
    pinMode(ledPin,   OUTPUT);

    Serial.begin(9600);

    Serial.println("Initialising... ");

    os_init();
    LMIC_reset();
    LMIC_setSession(0x1, DEVADDR, NWKSKEY, APPSKEY);
    LMIC_setLinkCheckMode(0);
    LMIC.dn2Dr = DR_SF9;
    LMIC_setDrTxpow(DR_SF7, 14);

    // Use channel 0 only to align with my test gateway
    for (int i=1; i<=8; i++) LMIC_disableChannel(i);

    // Wait for seonsor to stabilize...
    digitalWrite(ledPin, HIGH);
    delay(10000);
    digitalWrite(ledPin, LOW);

    Serial.println("Running... ");

    // Start job
    do_send(&sendjob);
}


unsigned int now       = millis();
unsigned int triggered = millis();
unsigned int since     = 0;


//
// The mighty loop...
//
void loop() {

    now = millis();

    since = now - triggered;

    if (since > 5000) {

        val = digitalRead(inputPin);

        if (val == HIGH) {

          triggered = millis();

          digitalWrite(ledPin, HIGH);

          Serial.println("Motion detected!");

          count = count + 1;

          Serial.print("Count: ");
          Serial.println(count);

          Serial.println("Resetting...    ");

        } else {

          digitalWrite(ledPin, LOW);

        }
    }

    os_runloop_once();
}
