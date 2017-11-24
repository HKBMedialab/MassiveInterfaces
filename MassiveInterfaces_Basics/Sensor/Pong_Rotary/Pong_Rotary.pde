/*
HKB Massive Interfaces Basics
 Created by Michael Flueckiger
 
 */




//paddle
float paddleWidth=10;
float paddleHeight=100;
float paddlePosX=0;
float paddlePosY=0;
float paddlePosXb=0;
float paddlePosYb=0;
float moveAmmount=20;

//ball
float posX=50;
float posY=50;
float speedX=5;
float speedY=3;
int diameter=20;
int radius=diameter/2;


color backgroundcolor=color(200, 200, 200);


PFont font;
int score=0;
int padding=30;


// Arduino 
import processing.serial.*;

Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
String inString="";  // Input string from serial port
int lf = 10;      // ASCII linefeed 
int [] mysensors= new int[2];

// Funktionen: Wiederverwendbare Programmblöcke
void setup() { 
  size(500, 500);
  paddlePosX=width-paddleWidth-10;

  // Verfügbare Schriften anzeigen
  //String[] fontList = PFont.list();
  //printArray(fontList);

  font = loadFont("PTMono-Bold-48.vlw"); 
  textFont(font);
  textSize(30);

  // Arduino stuff
  println(Serial.list());
  String portName = Serial.list()[3];
  myPort = new Serial(this, "/dev/tty.usbmodem1421", 115200);
  myPort.bufferUntil(lf);
}


// Funktionen: Drawloop. wird x-mal pro Sekunde wiederholt. 
void draw() {
  //revert backgroundcolor to grey
  backgroundcolor=color(200);

  // Update stuff
  paddlePos();
  move();
  hittest();




  //Draw stuff
  // fill background with red or grey
  background(backgroundcolor);
  //paddle
  rect(paddlePosX, paddlePosY, paddleWidth, paddleHeight);
  //ball
  ellipse(posX, posY, diameter, diameter);


  // score
  fill(255);
  textAlign(RIGHT);
  text(score, padding, padding);
}


void move() {
  //ball movement
  posX=posX+speedX;
  posY=posY+speedY;
}

void hittest() {
  //bounce from paddle
  if (posX+radius>=paddlePosX && posY-radius>paddlePosY && posY-radius<paddlePosY+paddleHeight) {
    speedX=speedX*-1;
  } else if (posX+radius>=paddlePosX) {
    // delay(1000);
    // backgroundcolor=color(255, 0, 0);
    //reset();
  }

  //normal bounce
  if (posX+radius>width || posX-radius<0)speedX=speedX*-1;
  if (posY+radius>height || posY-radius<0)speedY=speedY*-1;
}





void reset() {
  posX=width/2;
  posY=height/2;
  speedX=random(2, 5);
  speedY=random(2, 5);
  score+=1;
}

void restart() {
  reset();
  score=0;
}


void paddlePos() {
  paddlePosY= map(mysensors[0], 0, 500, 0, height);
  //paddlePosY= map(arduino.analogRead(1),100,800,-paddleHeight,height);
  println(paddlePosY+" "+mysensors[0]);
}


void serialEvent(Serial p) {
  // get message till linefeed;
  String message = myPort.readStringUntil(lf);

  //remove the linefeed
  message = trim(message);

  //split the string at the tabs and convert the sections into integers:
  mysensors = int(split(message, ','));
}


void keyPressed() {
  if (keyCode==UP) {
    //move up;
    paddlePosY-=moveAmmount;
  }
  if (keyCode==DOWN) {
    //move down;
    paddlePosY+=moveAmmount;
  }
  if (keyCode==LEFT) {
    //move left;
    // paddlePosX-=moveAmmount;
  }
  if (keyCode==RIGHT) {
    //move right;
    //paddlePosX+=moveAmmount;
  }
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