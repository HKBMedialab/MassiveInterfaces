import processing.sound.*;
Amplitude amp;
AudioIn in;

// Position
float yPos;
// smoothing factor. 
float lerpfact=0.25;

void setup() {
  size(640, 360);
  background(255);
    
  // Create an Input stream which is routed into the Amplitude analyzer
  amp = new Amplitude(this);
  in = new AudioIn(this, 0);
  in.start();
  amp.input(in);
}      

void draw() {
  background(255);
  // map volume (0-1) to height (0-height)
  float mappedPos=map(amp.analyze(),0,1,0,height);
  // smooth out transition between values
   yPos=lerp(yPos,mappedPos,lerpfact);
  fill(255,0,0);
  rect(50,yPos,50,50);
}