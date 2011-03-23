#define maskD B11100000
#define shiftD 5
#define maskB B00011111
#define shiftB 3

#define unpress_time 200

void setup() {
  Serial.begin(9600);
  DDRD ^= maskD;
  DDRB ^= maskB;
  PORTD ^= maskD;
  PORTB ^= maskB;
}

void loop() {
  static byte keysdown = 0;
  static byte prevFull = 0;
  static byte prevFull_release = 0;
  
  static unsigned long tlpress = 0;
  static unsigned long tlunpress = 0;
  
  byte full = ~(((PIND & maskD) >> shiftD)|((PINB & maskB) << shiftB));

  if(full && !keysdown) {
    keysdown = 1;
    tlpress = micros();
    tlunpress = 0;
  }
  else if(!full && keysdown) {
    keysdown = 0;
    Serial.println(prevFull_release, BIN);
    
    tlunpress = 0;
    prevFull = 0;
    prevFull_release = 0;
  }
  
  if(keysdown) {
    if(full < prevFull) {
      tlunpress = millis();
      if((millis() - tlunpress) > unpress_time) {
        prevFull_release = prevFull;
      }
      prevFull = full;
    }
    else if(full > prevFull) {
      prevFull = full;
      prevFull_release = prevFull;
      tlunpress = 0;
      tlpress = millis();
    }
    else {
      //full == prevFull
      if(tlunpress != 0 && (millis() - tlunpress) > unpress_time) {
        prevFull_release = prevFull;
        tlunpress = 0;
      }
    }
  }
  delay(5);
}
