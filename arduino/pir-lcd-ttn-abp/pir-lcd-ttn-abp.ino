/*******************************************************************************
 * Copyright (c) 2015 Thomas Telkamp and Matthijs Kooijman
 *
 * Permission is hereby granted, free of charge, to anyone
 * obtaining a copy of this document and accompanying files,
 * to do whatever they want with them without any restriction,
 * including, but not limited to, copying, modification and redistribution.
 * NO WARRANTY OF ANY KIND IS PROVIDED.
 *
 * Do not forget to define the radio type correctly in config.h.
 *
 *******************************************************************************/

#include <lmic.h>
#include <hal/hal.h>

#include <LiquidCrystal.h>

// LoRaWAN network session key
static u1_t NWKSKEY[16] = { 0x47, 0xE6, 0xD6, 0x36, 0xB8, 0xCE, 0x8E, 0xC3, 0x7C, 0x85, 0x53, 0x7D, 0xAD, 0xCA, 0xA5, 0x9A };

// LoRaWAN application session key
static u1_t APPSKEY[16] = { 0x0B, 0x8E, 0x6F, 0x40, 0x37, 0x85, 0xF1, 0x21, 0x45, 0x40, 0xC5, 0x53, 0xC5, 0x68, 0x87, 0x6E };

// LoRaWAN device address
static u4_t DEVADDR = 0x260119FC; // <-- Change this address for every node!

// These callbacks are only used in over-the-air activation, so they are
// left empty here (we cannot leave them out completely unless
// DISABLE_JOIN is set in config.h, otherwise the linker will complain).
void os_getArtEui (u1_t* buf) { }
void os_getDevEui (u1_t* buf) { }
void os_getDevKey (u1_t* buf) { }

static osjob_t sendjob;

// Schedule TX every 'this many' seconds
const unsigned TX_INTERVAL = 60; // 900 = 15 minutes

// Pin mapping for Dragino Lora Shield
const lmic_pinmap lmic_pins = {
    .nss = 10,
    .rxtx = LMIC_UNUSED_PIN,
    .rst = 9,
    .dio = {2, 6, 7},
};


const int pirInputPin = 8;   
//const int ledPin = 13;         
       
byte val = 0;                    
byte count = 0;

//const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 13;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);


//
// Event handler
//
void onEvent (ev_t ev) {

    Serial.print(os_getTime());
    Serial.print(": ");

    switch(ev) {
        case EV_SCAN_TIMEOUT:
            Serial.println(F("EV_SCAN_TIMEOUT"));
            break;
        case EV_BEACON_FOUND:
            Serial.println(F("EV_BEACON_FOUND"));
            break;
        case EV_BEACON_MISSED:
            Serial.println(F("EV_BEACON_MISSED"));
            break;
        case EV_BEACON_TRACKED:
            Serial.println(F("EV_BEACON_TRACKED"));
            break;
        case EV_JOINING:
            Serial.println(F("EV_JOINING"));
            break;
        case EV_JOINED:
            Serial.println(F("EV_JOINED"));
            break;
        case EV_RFU1:
            Serial.println(F("EV_RFU1"));
            break;
        case EV_JOIN_FAILED:
            Serial.println(F("EV_JOIN_FAILED"));
            break;
        case EV_REJOIN_FAILED:
            Serial.println(F("EV_REJOIN_FAILED"));
            break;
        case EV_TXSTART:
            Serial.println(F("EV_TXSTART"));
            break;
        case EV_TXCOMPLETE:
            Serial.println(F("EV_TXCOMPLETE (includes waiting for RX windows)"));
            // Schedule next transmission
            os_setTimedCallback(&sendjob, os_getTime() + sec2osticks(TX_INTERVAL), do_send);
            break;
        case EV_LOST_TSYNC:
            Serial.println(F("EV_LOST_TSYNC"));
            break;
        case EV_RESET:
            Serial.println(F("EV_RESET"));
            break;
        case EV_RXCOMPLETE:
            Serial.println(F("EV_RXCOMPLETE"));
            break;
        case EV_LINK_DEAD:
            Serial.println(F("EV_LINK_DEAD"));
            break;
        case EV_LINK_ALIVE:
            Serial.println(F("EV_LINK_ALIVE"));
            break;
         default:
            Serial.print(F("Unknown event"));
            break;
    }
}

//
// Send some data...
//
void do_send(osjob_t* j) {

    // Check that there is not a current TX/RX job running
    if (LMIC.opmode & OP_TXRXPEND) {
        Serial.println(F("OP_TXRXPEND, not sending"));
    } else {
        // Prepare upstream data transmission at the next possible time.
        LMIC_setTxData2(1, &count, 1, 0);
        Serial.println(F("Packet queued"));
        Serial.println(LMIC.freq);
    }
    // Next TX is scheduled after TX_COMPLETE event.
}


//
// Device setup routine
//
void setup() {

    Serial.begin(115200);
    Serial.println(F("Starting"));

    os_init();
    LMIC_reset();
    LMIC_setSession(0x1, DEVADDR, NWKSKEY, APPSKEY);
    LMIC_setLinkCheckMode(0);
    LMIC.dn2Dr = DR_SF9;
    LMIC_setDrTxpow(DR_SF7, 14);

    // Use channel 0 only to align with my test gateway
    for (int i=1; i<=8; i++) LMIC_disableChannel(i);

    pinMode(pirInputPin, INPUT);
    //pinMode(ledPin, OUTPUT);

    lcd.begin(16, 2);
  
    lcd.print("Initialising... ");
    delay(60000);

    lcd.setCursor(0, 0);
    lcd.print("Detecting...    ");

    // Start job
    do_send(&sendjob);
}


//
// The mighty loop...
//
void loop() {

    val = digitalRead(pirInputPin);  
    
    if (val == HIGH) {            
      
      //digitalWrite(ledPin, HIGH);
  
      lcd.clear();
      lcd.print("Motion detected!");
      
      count = count + 1;
  
      lcd.setCursor(0, 1);
      lcd.print(count);
  
      delay(3000);
  
      lcd.setCursor(0, 0);
      lcd.print("Resetting...    ");
  
      delay(6000);
  
      lcd.setCursor(0, 0);
      lcd.print("Detecting...    ");
      
    } else {
      //digitalWrite(ledPin, LOW); 
      delay(500);
    }
    
    os_runloop_once();
}
