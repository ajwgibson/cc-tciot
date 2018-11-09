/*
 * PIR sensor tester
 */

#include <LiquidCrystal.h>

int pirInputPin = 7;   
int ledPin = 13;         
       
int val = 0;                    

int count = 0;

const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

 
void setup() {
  pinMode(pirInputPin, INPUT);
  pinMode(ledPin, OUTPUT);

  lcd.begin(16, 2);
  
  lcd.print("Initialising... ");
  delay(60000);

  lcd.setCursor(0, 0);
  lcd.print("Detecting...    ");
}
 
void loop(){
  
  val = digitalRead(pirInputPin);  
  
  if (val == HIGH) {            
    
    digitalWrite(ledPin, HIGH);

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
    digitalWrite(ledPin, LOW); 
    delay(500);
  }
  
}
