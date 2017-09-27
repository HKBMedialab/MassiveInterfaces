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


color backgroundcolor=color(200, 200, 200);


// Funktionen: Wiederverwendbare Programmblöcke
void setup() { 
  size(500, 500);
  paddlePosX=width-paddleWidth-10;
}


// Funktionen: Drawloop. wird x-mal pro Sekunde wiederholt. 
void draw() {
  //revert backgroundcolor to grey
  backgroundcolor=color(200);

  // Update stuff
  move();
  hittest();




  //Draw stuff
  // fill background with red or grey
 // background(backgroundcolor);
  //paddle
 // rect(paddlePosX, paddlePosY, paddleWidth, paddleHeight);
  //ball
 // ellipse(posX, posY, diameter, diameter);
}


void move() {
  //ball movement
  posX=posX+speedX;
  posY=posY+speedY;
}

void hittest() {
  //bounce from paddle
  if (posX+radius>=paddlePosX && posY>paddlePosY && posY<paddlePosY+paddleHeight) {
    speedX=speedX*-1;
  } else if (posX+radius>=paddlePosX) {
    backgroundcolor=color(255, 0, 0);
    reset();
  }

  //normal bounce
  if (posX+radius>width || posX-radius<0)speedX=speedX*-1;
  if (posY+radius>height || posY-radius<0)speedY=speedY*-1;
}


void reset() {
println("reset");
  posX=width/2;
  posY=height/2;
  speedX=random(2,5);
  speedY=random(2,5);
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