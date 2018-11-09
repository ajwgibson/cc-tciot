

const int pirInputPin = 3;
const int ledPin = 13;

int val   = 0;
int count = 0;


//
// Device setup routine
//
void setup() {
    pinMode(pirInputPin, INPUT);
    pinMode(ledPin, OUTPUT);

    Serial.begin(9600);

    Serial.println("Initialising... ");
    digitalWrite(ledPin, HIGH);

    delay(60000);

    digitalWrite(ledPin, LOW);
    Serial.println("Detecting...    ");
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

    if (since > 6000) {

        val = digitalRead(pirInputPin);

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

}
