/*
HKB Massive Interfaces Basics
Created by Michael Flueckiger
 
 */

size(400,400);

pushMatrix();
translate(150,150);
/*
rotate(PI/2);
translate(-150,-150);
*/
// Head
fill(0,0,180);
triangle(100,100,150,30,200,100);
fill(100,100,100);
rect(100,100,100,100);
fill(255);
ellipse(130,130,20,20);
ellipse(170,130,20,20);

//Arms
line(100,150,50,50);
line(200,150,250,50);

//Legs
line(120,200,100,300);
line(180,200,200,300);
popMatrix();