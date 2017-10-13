/**
 * Simple Read
 * 
 * Read data from the serial port and change the color of a rectangle
 * when a switch connected to a Wiring or Arduino board is pressed and released.
 * This example works with the Wiring / Arduino program that follows below.
 */


import processing.serial.*;

Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
String inString="";  // Input string from serial port
int lf = 10;      // ASCII linefeed 
int [] mysensors= new int[2];
void setup() 
{
  size(200, 800);
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  println(Serial.list());

  String portName = Serial.list()[3];
  myPort = new Serial(this, "/dev/tty.usbmodem1411", 115200);
  myPort.bufferUntil(lf);
}

void draw()
{
  background(255, 0, 0);
  println(mysensors[0]+" , "+mysensors[1]);
  rect(50, mysensors[0], 100, 100);
}


void serialEvent(Serial p) {
  // get message till linefeed;
  String message = myPort.readStringUntil(lf);

  //remove the linefeed
  message = trim(message);

  //split the string at the tabs and convert the sections into integers:
  mysensors = int(split(message, ','));
}

/* Encoder Library - Basic Example
 * http://www.pjrc.com/teensy/td_libs_Encoder.html
 *
 * This example code is in the public domain.
 */
/*
#include <Encoder.h>

// Change these two numbers to the pins connected to your encoder.
//   Best Performance: both pins have interrupt capability
//   Good Performance: only the first pin has interrupt capability
//   Low Performance:  neither pin has interrupt capability
Encoder myEnc(2, 3);
//   avoid using pins with LEDs attached

void setup() {
  Serial.begin(115200);
  Serial.println("Basic Encoder Test:");
}

long oldPosition  = -999;

void loop() {
  long newPosition = myEnc.read();
  if (newPosition != oldPosition) {
    oldPosition = newPosition;
    Serial.print(newPosition);
    Serial.print(",");
    Serial.println(newPosition);
  }
}
*/