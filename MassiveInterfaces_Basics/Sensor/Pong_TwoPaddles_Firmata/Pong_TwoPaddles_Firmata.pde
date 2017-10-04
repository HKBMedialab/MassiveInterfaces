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
int scoreLeft=0;
int scoreRight=0;
int padding=30;


boolean bUseArduino=false;
// sensor min/max to map 
int minVal=0;
int maxVal=1023;


// Arduino Firmata
import processing.serial.*;
import cc.arduino.*;
Arduino arduino;


// Funktionen: Wiederverwendbare Programmblöcke
void setup() { 
  size(700, 500);
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
  backgroundcolor=color(0);

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
  text(scoreLeft, padding, padding);
  text(scoreRight, width-padding, padding);
}


void move() {
  //ball movement
  posX=posX+speedX;
  posY=posY+speedY;
}

void hittest() {
  if (posX+radius>=paddlePosX && posY-radius>paddlePosY && posY-radius<paddlePosY+paddleHeight) {
    speedX=speedX*-1; // right paddle
  } else if (posX-radius<=paddleLeftPosX+paddleWidth && posY-radius>paddleLeftPosY && posY+radius<paddleLeftPosY+paddleHeight) {
    speedX=speedX*-1; // left paddle
  } else if (posX>=paddlePosX) {
    //left score
    scoreLeft++;
    backgroundcolor=color(255, 0, 0);
    reset();
  } else if (posX<paddleLeftPosX+paddleWidth) {
    //right score
    scoreRight++;
    backgroundcolor=color(0, 255, 0);
    reset();
  }

  //top / down bounce
  if (posY+radius>height || posY-radius<0)speedY=speedY*-1;
}





void reset() {
  posX=width/2;
  posY=height/2;
  speedX=random(2, 5);
  speedY=random(2, 5);
  // score+=1;
}

void restart() {
  reset();
  scoreLeft=0;
  scoreRight=0;
}

void paddlePos() {
  //map incoming values to height
  paddlePosY= map(arduino.analogRead(1), minVal, maxVal, -paddleHeight, height);
  paddleLeftPosY= map(arduino.analogRead(0), minVal, maxVal, -paddleHeight, height);
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

  if (key=='w') {
    //move up;
    paddleLeftPosY-=moveAmmount;
  }
  if (key=='s') {
    //move down;
    paddleLeftPosY+=moveAmmount;
  }
}