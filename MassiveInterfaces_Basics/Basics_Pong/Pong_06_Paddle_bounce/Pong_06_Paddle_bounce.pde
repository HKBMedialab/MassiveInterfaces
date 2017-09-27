/*
HKB Massive Interfaces Basics
 Created by Michael Flueckiger
 
 */




//paddle
float paddleWidth=10;
float paddleHeight=200;
float paddlePosX=0;
float paddlePosY=0;
float moveAmmount=20;

//ball
float posX=50;
float posY=50;
float speedX=5;
float speedY=3;
int diameter=20;
int radius=diameter/2;


// Funktionen: Wiederverwendbare Programmblöcke
void setup() { 
  size(500, 500);
  paddlePosX=width-paddleWidth-10;
}


// Funktionen: Drawloop. wird x-mal pro Sekunde wiederholt. 
void draw() {
  background(200);
  //paddle
  rect(paddlePosX, paddlePosY, paddleWidth, paddleHeight);

  //ball, movement
  posX=posX+speedX;
  posY=posY+speedY;

  //bounce from paddle
  if (posX+radius>=paddlePosX && posY>paddlePosY && posY<paddlePosY+paddleHeight)speedX=speedX*-1;

  //bounce
  if (posX>width || posX<0)speedX=speedX*-1;
  if (posY>height || posY<0)speedY=speedY*-1;
  ellipse(posX, posY, diameter, diameter);
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
    paddlePosX-=moveAmmount;
  }
  if (keyCode==RIGHT) {
    //move right;
    paddlePosX+=moveAmmount;
  }
}