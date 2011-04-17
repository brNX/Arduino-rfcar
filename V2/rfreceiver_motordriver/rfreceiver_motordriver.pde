#include <Servo.h> 
#include "structs.h"

#define HEADERSIZE 3
#define VALUESIZE 2
#define CHECKSUMSIZE 2

#define PACKETSIZE (HEADERSIZE+VALUESIZE+CHECKSUMSIZE)

#define CWORD 0x56

const uint8_t header[3] = { 0x46, 0x67, 0x50 };

#define enablePin 11
#define leftA 4
#define leftB 5
#define rightA 7
#define rightB 8

#define servopin 9

Servo myservo; // create servo object to control a servo 

Packet readValue() {

	int8_t c = 0;
	int pos = 0;
	Packet value;
	uint8_t checksum[CHECKSUMSIZE];

	for (;;) {

		while (Serial.available() > 0) {

			c = Serial.read();
			switch (pos) {
			case 0:
			case 1:
			case 2:
				if (header[pos] == c) {
					pos++;
				} else {
					pos = 0;
				}
				break;
			case 3:
				value.speed = c;
				pos++;
				break;
			case 4:
				checksum[0] = c;
				if ((checksum[0] ^ CWORD) == value.speed)
					pos++;
				else
					pos = 0;
				break;
			case 5:
				value.direction = c;
				pos++;
				break;
			case 6:
				checksum[1] = c;
				if ((checksum[1] ^ CWORD) == value.direction)
					return value;
				else
					pos = 0;
				break;
			}
		}

	}
}

void setup() {
	pinMode(enablePin, OUTPUT);
	pinMode(leftA, OUTPUT);
	pinMode(leftB, OUTPUT);
	pinMode(rightA, OUTPUT);
	pinMode(rightB, OUTPUT);

	digitalWrite(enablePin, LOW);

	myservo.attach(servopin);

	Serial.begin(1200);
}


void loop() {
	Packet incomingPacket;
	incomingPacket = readValue();

	//direction
	if (incomingPacket.direction >= 0 && incomingPacket.direction <= 255){
                uint8_t value = map(incomingPacket.direction,0,255,27,167);
		myservo.write(value);
        }
	else{
		myservo.write(97);
        }

	//motor
        int speed = incomingPacket.speed - 127;
	if (speed < 0) {
		digitalWrite(leftA, LOW); // set leg 1 of the H-bridge low
		digitalWrite(leftB, HIGH); // set leg 2 of the H-bridge high 
		digitalWrite(rightA, LOW); // set leg 1 of the H-bridge low
		digitalWrite(rightB, HIGH); // set leg 2 of the H-bridge high     
	} else {
		digitalWrite(leftB, LOW); // set leg 1 of the H-bridge low
		digitalWrite(leftA, HIGH); // set leg 2 of the H-bridge high 
		digitalWrite(rightB, LOW); // set leg 1 of the H-bridge low
		digitalWrite(rightA, HIGH); // set leg 2 of the H-bridge high    
	}
	int value = abs(speed);
	value = map(value, 0, 128, 0, 255);
	analogWrite(enablePin, value);
}
