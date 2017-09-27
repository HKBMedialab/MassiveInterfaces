/*
HKB Massive Interfaces Basics
 Created by Michael Flueckiger
 
 */



int posX;
int posY;

// Funktionen: Wiederverwendbare Programmblöcke
void setup() { 
  size(500, 500);
}


// Funktionen: Drawloop. wird x-mal pro Sekunde wiederholt. 

void draw() {
  ellipse(posX, posY, 20, 20);
  /*
pushMatrix();
   translate(mouseX,mouseY);
   ellipse(0,0,20,20);
   popMatrix();
   */
}