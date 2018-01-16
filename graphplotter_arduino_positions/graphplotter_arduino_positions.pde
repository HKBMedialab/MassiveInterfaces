// Arduino 
import processing.serial.*;
Serial myPort;  // Create object from Serial class
float val;      // Data received from the serial port

int lf = 10;      // ASCII linefeed 


// Plotter Vars
Plotter plotterA0; 


// style
float pH=500;



void setup() {
  size(1500, 1000);
  plotterA0=new Plotter();
  //plotterA1=new Plotter();
  //plotterA2=new Plotter();
  //plotterA3=new Plotter();

  frameRate(30);
  
    println(Serial.list());
  String portName = Serial.list()[3];
 myPort = new Serial(this, "/dev/tty.usbmodem1411", 9600);
 myPort.bufferUntil(lf);
}

void draw() {
  background(100);
 // float val=random(0, 200);
      plotterA0.addValue(val);

  plotterA0.update();

 /* val=random(0, 200);
  plotterA1.addValue(val);
  plotterA1.update();

  val=random(0, 200);
  plotterA2.addValue(val);
  plotterA2.update();

  val=random(0, 200);
  plotterA3.addValue(val);
  plotterA3.update();
*/
  pushMatrix();
  translate(0, 0);
  plotterA0.plott(0, 255, 0, pH);
/*  translate(0, pH);
  plotterA1.plott(0, 200, 0, pH);
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
   val =float(message);
   
   val=map(val,-16,16,0,255);

  } 
  catch (Exception e) {
    println("Initialization exception");
  }
}