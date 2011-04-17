#include <Wire.h>
#include <WiiChuck.h>

WiiChuck wchuck;

#define CWORD 0x56

const uint8_t header[3] = { 0x46, 0x67, 0x50 };
const uint8_t preamble[5] = { 0x00, 0xFF, 0x00,0xFF,0x00 };

void setup ()
{
  
  Serial.begin (1200);
  
  wchuck.setPowerPins();
  wchuck.begin();
  delay(100);
  wchuck.update();
  wchuck.calibrateJoy();  
}

void loop(){
  wchuck.update();
 
  sendPacket();
  
  delay(100);
}

void sendPacket(){
    Serial.write(preamble,5);
    Serial.write(header,3);
    if (wchuck.readJoyY() > 190 || wchuck.readJoyY() < 64){
      Serial.write(wchuck.readJoyY());
      Serial.write(wchuck.readJoyY()^CWORD);
    }
    else{
      Serial.write(127);
      Serial.write(127^CWORD);
    }
    Serial.write(wchuck.readJoyX());
    Serial.write(wchuck.readJoyX()^CWORD);
}



