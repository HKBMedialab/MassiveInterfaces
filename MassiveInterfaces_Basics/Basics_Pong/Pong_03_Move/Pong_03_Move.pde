/*
HKB Massive Interfaces Basics
 Created by Michael Flueckiger
 
 */



int posX=100;
int posY=100;

// Funktionen: Wiederverwendbare Programmblöcke
void setup() { 
  size(500, 500);
}


// Funktionen: Drawloop. wird x-mal pro Sekunde wiederholt. 

void draw() {
  rect(posX, posY, 50, 50);
}

void mouseMoved(){
posX=mouseX;
posY=mouseY;
}