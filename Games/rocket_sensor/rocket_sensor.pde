
Player player;
//GravityField asteroid;
ArrayList<GravityField> fields = new ArrayList<GravityField>();


// Arduino 
import processing.serial.*;
Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
String inString="";  // Input string from serial port
int lf = 10;      // ASCII linefeed 
int [] mysensors= new int[2];


void setup() {
  size(1600, 1000);
  frameRate(30);
  //fullScreen(FX2D);

  player=new Player();

  //System 1
  PVector center =new PVector(width/2+200, height/2);
  GravityField planet=new GravityField(200, 800, 0.05, center, color(200, 0, 0));
  fields.add(planet);

  PVector planetpos = center.copy();
  PVector planetdistance = new PVector(400, 0);

  planetpos.add(planetdistance);

  GravityField moon=new GravityField(100, 400, 0.05, planetpos, color(255, 100, 0), true, 0.007, center);
  fields.add(moon);

  planetpos = center.copy();
  planetdistance = new PVector(300, 0);
  planetdistance.rotate(PI/2);
  planetpos.add(planetdistance);
  
  moon=new GravityField(10, 500, 0.03, planetpos, color(255, 200, 100), true, 0.005, center);
  fields.add(moon);
  
  
  //System 2
  center =new PVector(200, height/2-200);
  planet=new GravityField(50, 400, 0.1, center, color(0, 0, 200));
  fields.add(planet);

  planetpos = center.copy();
  planetdistance = new PVector(200, 0);
  planetpos.add(planetdistance);

  moon=new GravityField(30, 350, 0.05, planetpos, color(0, 100, 255), true, 0.01, center);
  fields.add(moon);

  planetpos = center.copy();
  planetdistance = new PVector(250, 0);
  planetdistance.rotate(PI/2);
  planetpos.add(planetdistance);
  
  moon=new GravityField(10, 300, 0.02, planetpos, color(0, 200, 255), true, 0.003, center);
  fields.add(moon);
  

  // Arduino stuff
  println(Serial.list());
  String portName = Serial.list()[3];
  myPort = new Serial(this, "/dev/tty.usbmodem1421", 115200);
  myPort.bufferUntil(lf);
}

void draw() {
  background(0);

  for (int i = 0; i < fields.size(); i++) {
    GravityField m = fields.get(i);
    m.update();
  }
  for (int i = 0; i < fields.size(); i++) {
    GravityField m = fields.get(i);
    m.render();
  }

  for (int i = 0; i < fields.size(); i++) {
    GravityField m = fields.get(i);
    if (m.isInside(player.position.get())) {
      player.applyGravity(m.position, m.gravityForce);
    }
  }
  player.update();
  player.render();
  println(frameRate);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      player.thrust();
    } else if (keyCode == RIGHT) {
      player.turn("right");
    } else if (keyCode == LEFT) {
      player.turn("left");
    } else {
      player.turn("straight");
    }
  }
  if (key==' ') {
    player.thrust=true;
  }
}

void keyReleased() {
  if (key==' ') {
    player.thrust=false;
  }
}



void serialEvent(Serial p) {
  // get message till linefeed;
  String message = myPort.readStringUntil(lf);

  //remove the linefeed
  message = trim(message);

  //split the string at the tabs and convert the sections into integers:
  mysensors = int(split(message, ','));
  float a =map(mysensors[0], -500, 500, 0, 2*PI);
  player.setAngle(a);
}