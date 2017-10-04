// Plotter Vars
Plotter plotterA0; 
Plotter plotterA1;
Plotter plotterA2;
Plotter plotterA3;

// style
float pH=100;


import processing.serial.*;
import cc.arduino.*;

Arduino arduino;


void setup() {
  size(1000, 500);
  plotterA0=new Plotter();
  plotterA1=new Plotter();
  plotterA2=new Plotter();
  plotterA3=new Plotter();

  frameRate(30);
  colorMode(HSB);
  pixelDensity(2);


  // setup Arduino
  // Prints out the available serial ports.
  println(Arduino.list());

  // Modify this line, by changing the "0" to the index of the serial
  // port corresponding to your Arduino board (as it appears in the list
  // printed by the line above).
  arduino = new Arduino(this, Arduino.list()[3], 57600);

  // Alternatively, use the name of the serial port corresponding to your
  // Arduino (in double-quotes), as in the following line.
  //arduino = new Arduino(this, "/dev/tty.usbmodem621", 57600);

  // Set the Arduino digital pins as inputs.
  for (int i = 0; i <= 13; i++)
    arduino.pinMode(i, Arduino.INPUT);
}

void draw() {
  background(200);
  
  float val0=arduino.analogRead(0);
  
  plotterA0.addValue(val0);
  plotterA0.update();

  float val1=arduino.analogRead(1);
  plotterA1.addValue(val1);
  plotterA1.update();

  float val2=arduino.analogRead(2);
  plotterA2.addValue(val2);
  plotterA2.update();

  float val3=arduino.analogRead(3);
  plotterA3.addValue(val3);
  plotterA3.update();

println(val0+" "+val1+" "+val2+" "+val3);

  pushMatrix();
  translate(0, 0);
  stroke(0, 255, 255);
  plotterA0.plott(0, 1023, 0, pH);

  translate(0, pH);
  stroke(80, 255, 255);
  plotterA1.plott(0, 1023, 0, pH);

  translate(0, pH);
  stroke(160, 255, 255);
  plotterA2.plott(0, 1023, 0, pH);

  translate(0, pH);
  stroke(240, 255, 255);
  plotterA3.plott(0, 1023, 0, pH);
  popMatrix();
}