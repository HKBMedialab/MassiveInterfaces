/*
HKB Massive Interfaces Basics
 Created by Michael Flueckiger
 
 */




//paddle
float paddleWidth=10;
float paddleHeight=200;
float paddlePosX=0;
float paddlePosY=0;
float paddleSpeed=10;
float rightpaddleSpeed=0;


//ball
float posX=50;
float posY=50;
float speedX=10;
float speedY=0;
int diameter=20;
int radius=diameter/2;


color backgroundcolor=color(200, 200, 200);


PFont font;
int score=0;
int padding=30;

boolean bReset=false;


// Funktionen: Wiederverwendbare Programmblöcke
void setup() { 
  size(500, 500);
  paddlePosX=width-paddleWidth-10;
  paddlePosY=height/2-paddleHeight/2;

  posX=width/2;
  posY=height/2;

  // Verfügbare Schriften anzeigen
  //String[] fontList = PFont.list();
  //printArray(fontList);

  font = loadFont("PTMono-Bold-48.vlw"); 
  textFont(font);
  textSize(30);
}


// Funktionen: Drawloop. wird x-mal pro Sekunde wiederholt. 
void draw() {
  //revert backgroundcolor to grey
  backgroundcolor=color(200);

  // Update stuff
  paddle();
  move();
  hittest();

 


  //Draw stuff
  // fill background with red or grey
  background(backgroundcolor);
  //paddle
  rect(paddlePosX, paddlePosY, paddleWidth, paddleHeight);
  //ball
  ellipse(posX, posY, diameter, diameter);



  ellipse(posX, posY+radius, 5, 5);
  fill(0, 0, 255);
  ellipse(paddlePosX, paddlePosY, 5, 5);


  // score
  fill(255);
  textAlign(RIGHT);
  text(score, padding, padding);
  
  println(bReset+" "+posX);
  // pause if reset
   if (bReset) {
    delay(1000);
    bReset=false;
  }
  
}


void paddle() {
  paddlePosY+=rightpaddleSpeed;
  if (paddlePosY<0)paddlePosY=0;
  if (paddlePosY>height-paddleHeight)paddlePosY=height-paddleHeight;
}


void move() {
  //ball movement
  posX=posX+speedX;
  posY=posY+speedY;
}

void hittest() {
  //bounce from paddle
  if (posX+radius>=paddlePosX && posY+radius>paddlePosY && posY-radius<paddlePosY+paddleHeight) {
    speedX=speedX*-1;
    // change reflection angle
    // where is the hitpoint in respect to the paddle?
    float hit = posY - (paddlePosY+paddleHeight/2);
    // remap this to somewhat arbitrary range of(-2,2)
    float dir=map(hit, -paddleHeight/2, paddleHeight/2, -2, 2);
    // add it to speedY
    speedY+=dir;
  } else if (posX>=paddlePosX) {
    backgroundcolor=color(255, 0, 0);
    reset();
  }

  //normal bounce
  if (posX+radius>width || posX-radius<0)speedX=speedX*-1;
  if (posY+radius>height || posY-radius<0)speedY=speedY*-1;
}


void reset() {
  
  bReset=true;
  println("------------------------Reset" +bReset);
  posX=width/2;
  posY=height/2;
  speedX=random(2, 5);
  speedY=0;//random(2, 5);
  score+=1;
}

void restart() {
  reset();
  score=0;
}


void keyPressed() {
  if (keyCode==UP) {
    //move up;
    rightpaddleSpeed=paddleSpeed * -1;
  }
  if (keyCode==DOWN) {
    //move down;
    rightpaddleSpeed=paddleSpeed;
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


void keyReleased() {
  if (keyCode == UP || keyCode == DOWN) {
    rightpaddleSpeed = 0;
  }
};