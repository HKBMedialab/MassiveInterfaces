/*
HKB Massive Interfaces Basics
 Created by Michael Flueckiger
 
 */




//paddle
float paddleWidth=10;
float paddleHeight=200;
//paddle right
float paddlePosX=0;
float paddlePosY=0;
//paddle left
float paddleLeftPosX=0;
float paddleLeftPosY=0;


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


boolean bUseArduino=false;


// Arduino Firmata
import processing.serial.*;
import cc.arduino.*;
Arduino arduino;


// Funktionen: Wiederverwendbare Programmblöcke
void setup() { 
  size(500, 500);
  paddlePosX=width-paddleWidth-10;
  paddleLeftPosX=10;

  // Verfügbare Schriften anzeigen
  //String[] fontList = PFont.list();
  //printArray(fontList);

  font = loadFont("PTMono-Bold-48.vlw"); 
  textFont(font);
  textSize(30);

  // Arduino stuff
  if (bUseArduino) {
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
    for (int i = 0; i <= 13; i++) {
      arduino.pinMode(i, Arduino.INPUT);
    }
  }
}


// Funktionen: Drawloop. wird x-mal pro Sekunde wiederholt. 
void draw() {
  //revert backgroundcolor to grey
  backgroundcolor=color(200);

  // Update stuff
  if (bUseArduino) {
    paddlePos();
  }
  move();
  hittest();




  //Draw stuff
  // fill background with red or grey
  background(backgroundcolor);
  //paddle
  rect(paddlePosX, paddlePosY, paddleWidth, paddleHeight);
  rect(paddleLeftPosX, paddleLeftPosY, paddleWidth, paddleHeight);



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
  //bounce from right paddle
  if (posX+radius>=paddlePosX && posY-radius>paddlePosY && posY-radius<paddlePosY+paddleHeight) {
    speedX=speedX*-1;
  } else if (posX-radius<=paddleLeftPosX+paddleWidth && posY-radius>paddleLeftPosY && posY+radius<paddleLeftPosY+paddleHeight) {
    speedX=speedX*-1;
  } else if (posX>=paddlePosX) {
    backgroundcolor=color(255, 0, 0);
    reset();
  } else if (posX<paddleLeftPosY+paddleWidth) {
    backgroundcolor=color(255, 0, 0);

    reset();
  }

  //normal bounce
  //if (posX+radius>width || posX-radius<0)speedX=speedX*-1;
  if (posY+radius>height || posY-radius<0)speedY=speedY*-1;
}





void reset() {
  posX=width/2;
  posY=height/2;
  speedX=random(2, 5);
  speedY=random(2, 5);

  speedX=random(0, 1);
  speedY=random(0, 1);
 // score+=1;
}

void restart() {
  reset();
  score=0;
}


void paddlePos() {

  paddlePosY= map(arduino.analogRead(1), 100, 800, -paddleHeight, height);
  println(arduino.analogRead(1)+" "+paddlePosY);
}

void keyPressed() {
  println(key);
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


  if (key=='w') {

    //move up;
    paddleLeftPosY-=moveAmmount;
  }
  if (key=='s') {
    //move down;
    paddleLeftPosY+=moveAmmount;
  }
}