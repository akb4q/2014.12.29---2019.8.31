#include <Keyboard.h>

// use this option for OSX:

// use this option for Windows and Linux:
//  char ctrlKey = KEY_LEFT_CTRL;

void setup() {
  // make pin 2  input and turn on the
  // pullup resistor so it goes high unless
  // connected to ground:
  pinMode(2, INPUT);
  Keyboard.begin();
}

void loop() {
  if (digitalRead(2) == HIGH) {
    Keyboard.press(' ');
    delay(100);
  } else {
    Keyboard.releaseAll();
  }
}
