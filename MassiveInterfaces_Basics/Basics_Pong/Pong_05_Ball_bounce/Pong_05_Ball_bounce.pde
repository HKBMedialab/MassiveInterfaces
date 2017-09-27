/*
HKB Massive Interfaces Basics
 Created by Michael Flueckiger
 
 */



float posX=50;
float posY=50;

//Geschwindigkeit besteht aus 2 Komponenten: 
float speedX=5;
float speedY=3;
// -> eigentlich ein Vektor
PVector speed=new PVector(5, 5);

// Funktionen: Wiederverwendbare Programmblöcke
void setup() { 
  size(500, 500);
}


// Funktionen: Drawloop. wird x-mal pro Sekunde wiederholt. 

void draw() {
  posX=posX+speedX;
  posY=posY+speedY;

  if (posX>width || posX<0)speedX=speedX*-1;
  if (posY>height || posY<0)speedY=speedY*-1;


  ellipse(posX, posY, 20, 20);
}