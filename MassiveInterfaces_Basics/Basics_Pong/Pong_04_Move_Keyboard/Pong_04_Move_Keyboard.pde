/*
HKB Massive Interfaces Basics
 Created by Michael Flueckiger
 
 */



int posX=100;
int posY=100;

int moveAmmount=10;

// Funktionen: Wiederverwendbare Programmblöcke
void setup() { 
  size(500, 500);
}


// Funktionen: Drawloop. wird x-mal pro Sekunde wiederholt. 

void draw() {
  background(50);
  rect(posX, posY, 50, 50);
}

void mouseMoved() {

}


void keyPressed() {
  println("You pressed key "+key);

  if (keyCode==UP) {
    //move up;
    posY-=moveAmmount;
  }
  if (keyCode==DOWN) {
    //move down;
    posY+=moveAmmount;
  }
  if (keyCode==LEFT) {
    //move left;
    posX-=moveAmmount;
  }
  if (keyCode==RIGHT) {
    //move right;
    posX+=moveAmmount;
  }
  
  
    if (key=='w') {
    //move up;
 
  }
  
}