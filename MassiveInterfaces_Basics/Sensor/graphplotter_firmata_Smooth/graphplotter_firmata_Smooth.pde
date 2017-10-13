// Plotter Vars
Plotter plotterA0; 
Plotter plotterA1;


// Vars to store sensordata + smooth out incoming values;
float analogVal0;


// the smaller the lerp factor, the smoother the value. But also more laggy...
float smooth=0.5;

// style
// Höhe der Kurven
float pH=100;

// Arduino Libraries einbinden
// Wir nutzen die standartFirmata Library
import processing.serial.*;
import cc.arduino.*;

// Variable, um den Arduino zu adressieren.
Arduino arduino;

void setup() {

  size(1000, 500);
  // plotter instanzieren
  plotterA0=new Plotter();
  plotterA1=new Plotter();

  frameRate(30);
  colorMode(HSB);

  //Retina Screen  
  pixelDensity(2);


  // setup Arduino
  // Prints out the available serial ports.
  println(Arduino.list());

  // Modify this line, by changing the "0" to the index of the serial
  // port corresponding to your Arduino board (as it appears in the list
  // printed by the line above).
  //arduino = new Arduino(this, Arduino.list()[3], 57600);

  // Alternatively, use the name of the serial port corresponding to your
  // Arduino (in double-quotes), as in the following line.
  arduino = new Arduino(this, "/dev/tty.usbmodem1411", 57600);

  // Set the Arduino digital pins as inputs.
  for (int i = 0; i <= 13; i++)
    arduino.pinMode(i, Arduino.INPUT);
}

void draw() {
  background(200);

// smooth out incoming data. Interpolate between old val and new val
  float val0=arduino.analogRead(0);
 // float val0=random(0,1023);

  analogVal0 = lerp(analogVal0, val0, smooth);
  plotterA0.addValue(analogVal0);
  plotterA0.update();

  plotterA1.addValue(val0);
  plotterA1.update();

  // zeichnen:
  pushMatrix();
  translate(0, 0);
  stroke(0, 255, 255);
  plotterA0.plott(0, 1023, 0, pH);
    // verschieben der Kurve, damit mehrere untereinander gezeichnet werden können
  translate(0, pH);
  stroke(80, 255, 255);
  plotterA1.plott(0, 1023, 0, pH);
  
  popMatrix();
}