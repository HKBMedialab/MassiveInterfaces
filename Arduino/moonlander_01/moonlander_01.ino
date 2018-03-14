
/* Encoder Library - Basic Example
   http://www.pjrc.com/teensy/td_libs_Encoder.html

   This example code is in the public domain.
*/

// PLAYER 1
int shield1Button = 4;
// variables will change:
int shield1ButtonState = 0;         // current state of the button
int lastshield1ButtonState = 0;     // previous state of the button
int steerSensor1 = 0;                 // analog pin used to connect the sharp sensor

const int zInput1 = A1;


int shield2Button = 9;
// variables will change:
int shield2ButtonState = 0;         // current state of the button
int lastshield2ButtonState = 0;     // previous state of the button
int steerSensor2 = 2;                 // analog pin used to connect the sharp sensor

const int zInput2 = A3;


int zRawMin1 = -1000;
int zRawMax1 = 1000;

// Take multiple samples to reduce noise
const int sampleSize = 3;


#include <Encoder.h>

// Change these two numbers to the pins connected to your encoder.
//   Best Performance: both pins have interrupt capability
//   Good Performance: only the first pin has interrupt capability
//   Low Performance:  neither pin has interrupt capability
Encoder myEnc(2, 5);
Encoder myEnc2(3, 8);

//   avoid using pins with LEDs attached



int shieldButtonOut1 = 0;
int energyOut1 = 0;

int shieldButtonOut2 = 0;
int energyOut2 = 0;

void setup() {
  Serial.begin(9600);
  Serial.println("Basic Encoder Test:");
  pinMode(shield1Button, INPUT_PULLUP);
  pinMode(steerSensor1, OUTPUT);

  pinMode(shield2Button, INPUT_PULLUP);
  pinMode(steerSensor2, OUTPUT);



}

long oldPosition  = -999;
long oldPosition2  = -999;


void loop() {
  //  PLAYER 1 SHIELD
  shieldButtonOut1 = 0;
  shield1ButtonState = digitalRead(shield1Button);
  if (shield1ButtonState != lastshield1ButtonState) {
    if (shield1ButtonState == LOW) {
      shieldButtonOut1 = 1;
    }
  }
  lastshield1ButtonState = shield1ButtonState;
  long newPosition = myEnc.read();
  if (newPosition != oldPosition) {
    oldPosition = newPosition;
    energyOut1 = newPosition;
  }

  uint16_t value1 = analogRead (steerSensor1);
  uint16_t range1 = get_gp2d12 (value1);
  float volts = analogRead(steerSensor1) * 0.0048828125; // value from sensor * (5/1024)
  float distance = 13 * pow(volts, -1); // worked out from datasheet graph

  int zRaw1 = ReadAxis(zInput1);




  //  PLAYER 2 SHIELD
  shieldButtonOut2 = 0;
  shield2ButtonState = digitalRead(shield2Button);
  if (shield2ButtonState != lastshield2ButtonState) {
    if (shield2ButtonState == LOW) {
      shieldButtonOut2 = 1;
    }
  }
  lastshield2ButtonState = shield2ButtonState;
  long newPosition2 = myEnc2.read();
  if (newPosition2 != oldPosition2) {
    oldPosition2 = newPosition2;
    energyOut2 = newPosition2;
  }

  uint16_t value2 = analogRead (steerSensor2);
  uint16_t range2 = get_gp2d12 (value2);
  float volts2 = analogRead(steerSensor2) * 0.0048828125; // value from sensor * (5/1024)
  float distance2 = 13 * pow(volts2, -1); // worked out from datasheet graph

  int zRaw2 = ReadAxis(zInput2);



  //float accelValZ1 = accel_value(zRaw1);
  //if(accelValZ1<0)accelValZ1=0;
  //long zScaled1 = map(zRaw1, zRawMin1, zRawMax1, -1000, 1000);


  Serial.print(shieldButtonOut1);
  Serial.print(",");
  Serial.print(energyOut1);
  Serial.print(",");
  Serial.print(distance);
  Serial.print(",");
  Serial.print(zRaw1);
  Serial.print(",");
  Serial.print(shieldButtonOut2);
  Serial.print(",");
  Serial.print(energyOut2);
  Serial.print(",");
  Serial.print(distance2);
  Serial.print(",");
  Serial.println(zRaw2);
 


  delay(10);

}


uint16_t get_gp2d12 (uint16_t value) {
  if (value < 10) value = 10;
  return ((67870.0 / (value - 3.0)) - 40.0);
}



int ReadAxis(int axisPin)
{
  long reading = 0;
  analogRead(axisPin);
  delay(1);
  for (int i = 0; i < sampleSize; i++)
  {
    reading += analogRead(axisPin);
  }
  return reading / sampleSize;
}
//
// Find the extreme raw readings from each axis
//
void AutoCalibrate(int zRaw1)
{
  Serial.println("Calibrate");
  if (zRaw1 < zRawMin1)
  {
    zRawMin1 = zRaw1;
  }
  if (zRaw1 > zRawMax1)
  {
    zRawMax1 = zRaw1;
  }
}

float accel_value(float _input) {
  float val = _input / 65535;
  val -= 0.5;
  return val * 3.0;
}


