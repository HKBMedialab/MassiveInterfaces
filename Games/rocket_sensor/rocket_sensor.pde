
Player player;
//GravityField asteroid;
ArrayList<GravityField> fields = new ArrayList<GravityField>();
ArrayList <Laser> lasers;//where our bullets will be stored


// Arduino 
import processing.serial.*;
Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
String inString="";  // Input string from serial port
int lf = 10;      // ASCII linefeed 
int [] mysensors= new int[2];
boolean bUseArduino=true;

void setup() {
  // size(1600, 1000);
  frameRate(30);
  fullScreen();

  player=new Player();
  lasers = new ArrayList();

  //System 1
  PVector center =new PVector(width/2+200, height/2);
  GravityField planet=new GravityField(200, 800, 0.09, center, color(200, 0, 0));
  fields.add(planet);
  
  
    /*//Event horrizon 2 circle
  center =new PVector(width/2+200, height/2);
  planet=new GravityField(200, 500, 0.2, center, color(200, 0, 0));
  fields.add(planet);*/

  PVector planetpos = center.copy();
  PVector planetdistance = new PVector(400, 0);
  planetpos.add(planetdistance);
  GravityField moon=new GravityField(100, 400, 0.09, planetpos, color(255, 100, 0), true, 0.005, center);
  fields.add(moon);

  planetpos = center.copy();
  planetdistance = new PVector(300, 0);
  planetdistance.rotate(PI/2);
  planetpos.add(planetdistance);
  moon=new GravityField(10, 500, 0.03, planetpos, color(255, 200, 100), true, 0.007, center);
  fields.add(moon);

  planetpos = center.copy();
  planetdistance = new PVector(250, 0);
  planetdistance.rotate(PI+PI/3);
  planetpos.add(planetdistance);
  moon=new GravityField(10, 350, 0.03, planetpos, color(255, 220, 0), true, 0.009, center);
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

  moon=new GravityField(10, 550, 0.02, planetpos, color(0, 200, 255), true, 0.007, center);
  fields.add(moon);


  // Arduino stuff
  println(Serial.list());
  String portName = Serial.list()[3];
  if (bUseArduino) myPort = new Serial(this, "/dev/tty.usbmodem1421", 9600);
  if (bUseArduino) myPort.bufferUntil(lf);

  // pixelDensity(2);
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

  for (Laser temp : lasers) {
    temp.update();
  }

  for (Laser temp : lasers) {
    temp.render();
  }

  player.update();
  player.render();


  removeToLimit(100);
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
    } /*else {
     player.turn("straight");
     }*/
  }
  if (key==' ') {
    player.thrust=true;
  }
  if (key=='a') {
  }
}


void removeToLimit(int maxLength)
{
  while (lasers.size() > maxLength)
  {
    lasers.remove(0);
  }
}


void keyReleased() {
  if (key==' ') {
    player.thrust=false;
  }
}

void mousePressed() {
  Laser temp = new Laser(player.getPosition(), player.getDirection());
  lasers.add(temp);
}



void serialEvent(Serial p) {
  try {

    // get message till linefeed;
    String message = myPort.readStringUntil(lf);
    //remove the linefeed
    message = trim(message);
    //split the string at the tabs and convert the sections into integers:
    mysensors = int(split(message, ','));
    float a =map(mysensors[0], -500, 500, 0, 2*PI);
    float thrust =mysensors[1];//map(mysensors[1], 0, 1000, 0, 1);
    player.setAngle(a);
    if (thrust>50) {
      player.thrust=true;
    } else {
      player.thrust=false;
    }
  } 
  catch (Exception e) {
    println("Initialization exception");
  }
}