#include <LiquidCrystal.h>

// Initialize LCD interface pins
const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

void setup() {
  pinMode(A4,INPUT);

  // set up the LCD's number of columns and rows:
  lcd.begin(16, 2);

  // Print a message to the LCD.
  lcd.print("Voltage:");
}

void loop() {
  float val = analogRead(A4);

  delay(1000);

  float voltage = (val * 5.0) / 1024.0;

  lcd.setCursor(0, 1);
  lcd.print(voltage);

  delay(1000);
}
