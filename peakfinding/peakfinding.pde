/*
  Peak Finding graphing sketch
 by Tom Igoe with help from Matt Young
 
 This program takes raw bytes from the serial port at 9600 baud and
 graphs them. It also detects peaks in the changing values as they come in,
 and displays an ellipse when a peak is detected.
 
 Created 20 April 2005
 Updated 23 Oct 2007
 */

import processing.serial.*;

Serial myPort;  // The serial port

// initial variables:
int hPosition = 1;     // the horizontal position on the graph
int threshold = 10;    // minimum threshold for peak finding
int peakValue = 0;     // the current peak value


void setup () {
  size(400, 300);        // window size

  // List all the available serial ports
  println(Serial.list());

  // Open whatever port is the one you're using.
 // myPort = new Serial(this, Serial.list()[0], 9600);
   myPort = new Serial(this, "/dev/tty.usbmodem4013241", 9600);
 myPort.bufferUntil(lf);


  // set inital background:
  background(0);
}

void draw () {
  // all the action is in the serialEvent()
}

void serialEvent (Serial myPort) {
  // read the byte:
  int inByte = myPort.read();

  // draw the line:
  stroke(0,255,0);
  line(hPosition, height, hPosition, height - inByte);

  // if the current value > threshold, we can look for a peak:
  if (inByte >= threshold) {
    // if current value > last peak value, we're going up:
    if (inByte >= peakValue) {
      // save the current value as the highest
      peakValue = inByte;
    }
    // if we're > threshold, but < lastValue, then
    // the last peak value we got is indeed a peak:
    else {
      // this is when we have a peak
      println(" Peak = " + peakValue);
      fill(peakValue);
      ellipse(10, 10, 10, 10);
    }
    // if we're below the threshold, reset the peaK:
  } 
  else {
    peakValue = 0;
    fill(peakValue);
    stroke(0);
    ellipse(10, 10, 10, 10);
  }

  // at the edge of the screen, go back to the beginning:
  if (hPosition >= width) {
    hPosition = 0;
    background(0);
  }
  else {
    hPosition++;
  }
}