#define HEADERSIZE 3
#define VALUESIZE 1
#define CHECKSUMSIZE 1

#define PACKETSIZE (HEADERSIZE+VALUESIZE+CHECKSUMSIZE)

#define CWORD 0x56


const uint8_t header[3] = {0x46,0x67,0x50};

uint8_t led = 0;


#define leftE 3
#define leftA 4
#define leftB 5

#define rightE 6
#define rightA 7
#define rightB 8

#define servopin 9

#include <Servo.h> 

Servo myservo;  // create servo object to control a servo 



void setup() {
  pinMode(leftE,OUTPUT);
  pinMode(rightE,OUTPUT);
  pinMode(leftA,OUTPUT);
  pinMode(leftB,OUTPUT);
  pinMode(rightA,OUTPUT);
  pinMode(rightB,OUTPUT);
  
  digitalWrite (leftE,LOW);
  digitalWrite (rightE,LOW);
  
  myservo.attach(servopin);
  
  Serial.begin(1200); 
}



void loop() {
  uint8_t incomingByte=0; 
  incomingByte = readValue();
  
      //direction
    if (incomingByte & (0x1 << 2) || incomingByte & (0x1 << 3))
       if (incomingByte & (0x1 << 2))
           myservo.write(68);
       else
           myservo.write(112);     
    else
      myservo.write(90);
   
     //motor
   if (incomingByte & (0x1) || incomingByte & (0x1 << 1)){
       digitalWrite(leftE,HIGH);
       digitalWrite(rightE,HIGH);
       if (incomingByte & (0x1)){
           digitalWrite(leftA, LOW);   // set leg 1 of the H-bridge low
           digitalWrite(leftB, HIGH);  // set leg 2 of the H-bridge high 
           digitalWrite(rightA, LOW);   // set leg 1 of the H-bridge low
           digitalWrite(rightB, HIGH);  // set leg 2 of the H-bridge high     
       }
       else{
           digitalWrite(leftB, LOW);   // set leg 1 of the H-bridge low
           digitalWrite(leftA, HIGH);  // set leg 2 of the H-bridge high 
           digitalWrite(rightB, LOW);   // set leg 1 of the H-bridge low
           digitalWrite(rightA, HIGH);  // set leg 2 of the H-bridge high    
       }
    }else{
       digitalWrite(leftE,LOW);
       digitalWrite(rightE,LOW);
    }    
}


uint8_t readValue(){
  
  uint8_t c = 0;
  int pos = 0;
  uint8_t value=0;
  uint8_t checksum=0;
  
  for(;;){


    while(Serial.available() > 0){
    
      c = Serial.read();
      switch(pos) {
         case 0: case 1: case 2: 
            if (header[pos]==c){
            //Serial.write(c);
            //Serial.println();
            //Serial.println(pos);
                pos++;
            }
            else{
               //Serial.println("NOT:");
               //Serial.write(c);
               //Serial.println();
               //Serial.println(pos);
               
                pos = 0;
            }
            break;
        case 3:
            value = c;
            pos++;
            break;
        case 4:
          checksum = c;
          pos=0;
          
          if ((checksum ^ CWORD) == value)
              return value;
          break;  
             
    }
}

}
}
