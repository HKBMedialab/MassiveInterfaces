// definitions
// FORCES
float VERTICAL_THRUST=0.6;
float HORIZONTAL_THRUST=0.1;
float GRAVITY = 0.1;
// Constants
float DRAG=0.99;
float MAXSPEED=5;
float MAXFUEL=1000;


final int MAXLANDSPEED=3;

final int PLAYING = 100;
final int LANDED = 101;
final int CRASHED = 102;


float incomingThrustBefore=0;


Player player;
Player player2;

Player [] players = new Player[2];

ArrayList <Laser> lasers;//where our bullets will be stored
ArrayList <Ground> grounds;//where our bullets will be stored


Plattform plattform;


// Arduino 
import processing.serial.*;
Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
String inString="";  // Input string from serial port
int lf = 10;      // ASCII linefeed 
int [] mysensors= new int[2];
boolean bUseArduino=false;

void setup() {
  //size(1920, 1080);
    size(1500, 1080);

  frameRate(30);
  //fullScreen();
  colorMode(HSB);



  players[0]=new Player(new PVector(width-50, 50));
  players[1]=new Player(new PVector(50, 50));

  lasers = new ArrayList();
  grounds = new ArrayList();

  // make grounds

  float xoff = 0;
  PVector pos=new PVector(0, 0);
  while (pos.x<width) {
    float w=random(50, 150);
    //float h=random(10, height-200);
    float h = (noise(xoff) * height)-100;

    pos.y=height-h;
    Ground ground = new Ground(pos, w, h);
    grounds.add(ground);
    pos.x+=w;
    xoff = xoff + .3;
  }

  int num=grounds.size()/2;

  PVector p= grounds.get(num).getPosition();

  plattform=new Plattform(p);




  // Arduino stuff
  println(Serial.list());
  String portName = Serial.list()[3];
  if (bUseArduino) myPort = new Serial(this, "/dev/tty.usbmodem1411", 9600);
  if (bUseArduino) myPort.bufferUntil(lf);

  // pixelDensity(2);
}

void draw() {
  background(0);
checkGroundCollision();

  for (Laser temp : lasers) {
    temp.update();
  }

  for (Laser temp : lasers) {
    temp.render();
  }

  for (Ground temp : grounds) {
    temp.update();
  }

  for (Ground temp : grounds) {
    temp.render();
  }

  plattform.update();
  plattform.render();

  for (int i=0; i<players.length; i++) {
    players[i].update();
  }
  //  player.update();
  // player2.update();

  //checkPlattform();
  checkPlattformCollision();


  for (int i=0; i<players.length; i++) {
    players[i].render();
  }
  //player.render();
  //player2.render();



  removeToLimit(100);
  //println(frameRate);
}

void checkGroundCollision() {
  for (int i=0; i<players.length; i++) {
    for (int k=0; k<grounds.size(); k++) {
      Ground ground=grounds.get(k);
      PVector gPos=ground.getPosition().copy();

      float [] playerBoundingbox = players[i].getBoundingbox();
      if (playerBoundingbox[2]>gPos.x && playerBoundingbox[0]<(gPos.x+ground.getWidth())&&playerBoundingbox[3]>gPos.y) {
        println("col" + i +" "+playerBoundingbox[0]+" "+gPos.x);
        players[i].position.y=gPos.y-45;
      players[i].velocity.mult(-1);
      }
    }
  }
}



// Vereinfachen? Fühlt sich noch etwas umständlich an...
void checkPlattformCollision() {
  for (int i=0; i<players.length; i++) {
    float [] playerBoundingbox = players[i].getBoundingbox();
    float [] plattformBoundingbox = plattform.getBoundingbox();
    color c=color(0, 255, 255);
    int collisionstate = 0;
    PVector v=players[i].getVelocity();

    if (playerBoundingbox[2]>plattformBoundingbox[0] && playerBoundingbox[0]<plattformBoundingbox[2]) {
      // inside traktorstrahl
      collisionstate=1;
      c=color(0, 255, 255);
      // Landen
      if (playerBoundingbox[0]>plattformBoundingbox[0] && playerBoundingbox[2]<plattformBoundingbox[2]) {
        // full inside -> check height  & speed
        collisionstate=2;
        c=color(100, 255, 255);
      }
    }
    if (v.mag()>MAXLANDSPEED) {
      c=color(0, 255, 255);
    }


    if (playerBoundingbox[3]>plattformBoundingbox[1] && collisionstate != 0) {
      if (v.mag()<3 && collisionstate==2) {
        players[i].setState(LANDED);
      } else {
        players[i].setState(CRASHED);
      }
    }

    if (collisionstate!=0) {
      // inside traktorstrahl
      pushStyle();
      fill(c, 100);
      rect(plattformBoundingbox[0], plattformBoundingbox[1]-height, plattform.pWidth, height);
      popStyle();
    }
  }
}



void keyPressed() {
  println(key);
  /*if (key == CODED) {
   if (keyCode == UP) {
   players[0].thrust=true;
   } else if (keyCode == RIGHT) {
   // player.turn("right");
   players[0].rightthrust=true;
   } else if (keyCode == LEFT) {
   //player.turn("left");
   players[0].leftthrust=true;
   } /*else {
   player.turn("straight");
   }*/
  //}*/


  if (key==' ') {
    //player.thrust=true;
  }
  if (key=='a') {
  }


  if (key=='s') {
    players[0].setShieldActive(true);
  }


  if (key=='w') {
    players[1].thrust=true;
  }
  if (key=='a') {
    players[1].leftthrust=true;
  }
  if (key=='d') {
    players[1].rightthrust=true;
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
  /* if (key == CODED) {
   if (keyCode == UP) {
   players[0].thrust=false;
   }
   if (keyCode == RIGHT) {
   players[0].rightthrust=false;
   }
   if (keyCode == LEFT) {
   players[0].leftthrust=false;
   }
   }*/

  if (key=='s') {
    players[0].setShieldActive(false);
  }




  if (key=='w') {
    players[1].thrust=false;
  }
  if (key=='a') {
  }
  players[1].leftthrust=false;
  if (key=='d') {
    players[1].rightthrust=false;
  }


  if (key==' ') {
    players[1].thrust=false;
  }
}

void mousePressed() {
  //Laser temp = new Laser(player.getPosition(), player.getDirection());
  //lasers.add(temp);
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
    float verticalthrust=mysensors[0];
    float deltathrust= thrust-incomingThrustBefore;
    // println(thrust);
    println(verticalthrust);

    if (deltathrust>300) {
      players[0].thrust=true;
    } else {
      //players[0].thrust=false;
    }

    if (verticalthrust>10) {
      players[0].rightthrust=true;
    } else {
      players[0].rightthrust=false;
    }
    if (verticalthrust<-8) {
      players[0].leftthrust=true;
    } else {
      players[0].leftthrust=false;
    }

    incomingThrustBefore=thrust;
  } 
  catch (Exception e) {
    println("Initialization exception");
  }
}