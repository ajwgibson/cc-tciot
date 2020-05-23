
// Sensor reset interval = 6000ms (6 secs)
const unsigned RESET_INTERVAL = 6000;

// Inputs and outputs
const int inputPin = 3;
const int ledPin = 5;

//
// Device setup routine
//
void setup() {
    pinMode(inputPin, INPUT);
    pinMode(ledPin, OUTPUT);

    Serial.begin(9600);

    Serial.println(F("Initialising... "));

    // Wait for sensor to stabilize...
    digitalWrite(ledPin, HIGH);
    delay(60000);
    digitalWrite(ledPin, LOW);

    Serial.println(F("Running... "));
}

//
// The mighty loop...
//
void loop() {
    byte value = digitalRead(inputPin);

    if (value == HIGH) {
        Serial.println(F("Motion detected!"));
        digitalWrite(ledPin, HIGH);

        delay(RESET_INTERVAL);

        Serial.println(F("Reset"));
        digitalWrite(ledPin, LOW);
    }
}
