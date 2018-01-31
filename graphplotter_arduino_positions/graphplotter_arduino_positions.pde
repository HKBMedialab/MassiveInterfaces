// Arduino 
import processing.serial.*;
Serial myPort;  // Create object from Serial class
float val1=0;
float val2=0;      // Data received from the serial port
float val3=0;      // Data received from the serial port

int lf = 10;      // ASCII linefeed 
float lerpval=0.4;

// Plotter Vars
Plotter plotterA0, plotterA1, plotterA2; 


// style
float pH=100;



void setup() {
  size(1000, 800);
  plotterA0=new Plotter();
  plotterA1=new Plotter();
  plotterA2=new Plotter();
  //plotterA3=new Plotter();

  frameRate(30);

  println(Serial.list());
  String portName = Serial.list()[3];
  myPort = new Serial(this, "/dev/tty.usbmodem1421", 9600);
  myPort.bufferUntil(lf);
}

void draw() {
  background(100);
  // float val=random(0, 200);
  plotterA0.addValue(val1);
  plotterA0.update();

  plotterA1.addValue(val2);
  plotterA1.update();

  plotterA2.addValue(val3);
  plotterA2.update();
  /*
   val=random(0, 200);
   plotterA2.addValue(val);
   plotterA2.update();
   
   val=random(0, 200);
   plotterA3.addValue(val);
   plotterA3.update();
   */
  pushMatrix();
  translate(0, 0);
  fill(255, 0, 0, 100);
  rect(0, 0, width, pH);

  plotterA0.plott(0, 1025, 0, pH);
  translate(0, pH);
  fill(0, 255, 0, 100);
  rect(0, 0, width, pH);
  plotterA1.plott(0, 1025, 0, pH);

  translate(0, pH);
  fill(0, 0, 255, 100);
  rect(0, 0, width, pH);
  plotterA2.plott(0, 1025, 0, pH);

  /*
   translate(0, pH);
   plotterA2.plott(0, 200, 0, pH);
   translate(0, pH);
   plotterA3.plott(0, 200, 0, pH);*/
  popMatrix();
}



void serialEvent(Serial p) {
  try {

    // get message till linefeed;
    String message = myPort.readStringUntil(lf);
    //remove the linefeed
    message = trim(message);
    String[] sensordata = split(message, ',');
    //    println(sensordata);

    float inval1 =float(sensordata[0]);
    float inval2 =float(sensordata[1]);

    if (inval1>0) {
      float mappedinval1=map(inval1, 0, 700, 0, 1025);
      float mappedinvalPow=mapPowInv(2,inval1, 0, 700, 0, 1025);
      val1=lerp(val1, mappedinval1, lerpval);
      val2=lerp(val2, mappedinvalPow, lerpval);
    }

    if (inval2>0) {
      float mappedinval2=map(inval2, 0, 700, 0, 1025);
      val3=lerp(val3, mappedinval2, lerpval);
    }

    //val3=map(inval2, 0, 700, 0, 1025);

    //val3=mapPowInv(3, inval1, 0, 700, 0, 1025);
  } 
  catch (Exception e) {
    println("Initialization exception");
  }
}


float mapPowInv(float pow, float value, float start1, float stop1, float start2, float stop2) {
  float inT = norm(value, start1, stop1);
  float outT = 1-(pow((1-inT), pow));
  return map(outT, 0, 1, start2, stop2);
}


float mapPow(float pow, float value, float start1, float stop1, float start2, float stop2) {
  float inT = norm(value, start1, stop1);
  float outT = pow(inT, pow);
  return map(outT, 0, 1, start2, stop2);
}