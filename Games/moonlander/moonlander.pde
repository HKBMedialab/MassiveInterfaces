//defaults write -g ApplePressAndHoldEnabled -bool false
//defaults write -g ApplePressAndHoldEnabled -bool true



import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.dynamics.Body;
import org.jbox2d.dynamics.BodyDef;
import org.jbox2d.dynamics.BodyType;

import org.jbox2d.callbacks.ContactImpulse;
import org.jbox2d.callbacks.ContactListener;
import org.jbox2d.collision.Manifold;
import org.jbox2d.dynamics.contacts.Contact;


import geomerative.*;


import ddf.minim.*;
import ddf.minim.effects.*;



// A reference to our box2d world
Box2DProcessing box2d;


// definitions
// FORCES
//float VERTICAL_THRUST=0.6;
//float HORIZONTAL_THRUST=0.1;

// WORLD
float GRAVITY = 40;
float RESTITUTION=1.7;
float DAMPING = 1;


// SPACESHIP
float DENSITY = 0.25;
float MAXSPEED=200;
float IMPULSE=10;
float MAXTHRUSTFORCE=8;

//PLATTFORM
final int PLATTFORMWIDTH=130;

final int MAXLANDSPEED=20;




final int PLAYING = 100;
final int LANDED = 101;
final int CRASHED = 102;
final int STARTSCREEN = 99;


int gamestate=STARTSCREEN;


// SENSORVALUES
public float trampolinval = 0;
public float steerval = 0;
public float rightSteer=235;
public float leftSteer=270;

public  float scaledInval=0;
public float trampolinscalemin = 1;//7;
public float trampolinscalemax = 12;//198;

float minVal=400;
float maxVal=0;

float incomingThrustBefore=0;


Plattform plattform;

// An object to store information about the uneven surface
Surface surface;



// A list for all of our rectangles
ArrayList<CustomShape> polygons;





// Plotter Vars
Plotter plotterA0; 
Plotter plotterA1; 
Plotter plotterA2; 
boolean renderPlotter=false;

// style
float pH=255;



// Arduino 
import processing.serial.*;
Serial myPort;  // Create object from Serial class
float val;      // Data received from the serial port
String inString="";  // Input string from serial port
int lf = 10;      // ASCII linefeed 
int [] mysensors= new int[2];
boolean bUseArduino=false;


float val1=0;
float val2=0;      // Data received from the serial port
float val3=0;      // Data received from the serial port
float lerpval=0.3;

float lerpdval1=0;
float lerpdval2=0;      // Data received from the serial port
float lerpdval3=0;      // Data received from the serial port

float leftTriggerVal=200;
float rightTriggerVal=500;


// design
PImage background_0;
PImage background_1_planet1;
PImage background_2_planet2;
PImage background_3_planet3;
PImage background_4;

PImage test_landscape;


PImage background;
PImage background_back;


PVector planet1=new PVector(0, 0);
PVector planet2=new PVector(0, 0);
PVector planet3=new PVector(0, 0);
PVector planet1_speed=new PVector(0, 0);
PVector planet2_speed=new PVector(0, 0);
PVector planet3_speed=new PVector(0, 0);

import oscP5.*;
import netP5.*;
OscP5 oscP5;

// GUI
NetAddress myRemoteLocation;


// gui settings 
JSONObject settings;


// sound
Minim minim;
AudioPlayer ambisound;
AudioSample boostsound;
AudioSample hitsound;

CustomShape player1;
CustomShape player2; 



PGraphics combinedbackground;








void setup() {
  size(1920, 1080);
  // size(1500, 1080);

  frameRate(30);
  //fullScreen();





  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // We are setting a custom gravity
  box2d.setGravity(0, -GRAVITY);

  // Turn on collision listening!
  box2d.listenForCollisions();


  polygons = new ArrayList<CustomShape>();
  CustomShape cs = new CustomShape(this, 20, 500, 1);
  cs.setColor(color(0));
  cs.setGlowColor(color(255, 0, 0));
  
  polygons.add(cs);

  cs = new CustomShape(this, 200, 100, 2);
  cs.setColor(color(0));
  cs.setGlowColor(color(255, 255, 255));

  polygons.add(cs);

  RG.init(this);

  player1 = polygons.get(0);
  player2 = polygons.get(1);


  // Create the surface
  surface = new Surface();


  plattform=new Plattform(new PVector(width/2,590));

  // Arduino stuff
  println(Serial.list());
  String portName = Serial.list()[3];
  if (bUseArduino) myPort = new Serial(this, "/dev/tty.usbmodem1411", 9600 );
  if (bUseArduino) myPort.bufferUntil(lf);

  // pixelDensity(2);


  plotterA0=new Plotter();
  plotterA1=new Plotter();
  plotterA2=new Plotter();

  //leftTriggerVal=map(leftTriggerVal, 0, 1025, 0, pH);
  //rightTriggerVal=map(rightTriggerVal, 0, 1025, 0, pH);

  println("+++++++++rightTriggerVal++++++++++++"+rightTriggerVal);
  println("+++++++++++leftTriggerVal++++++++++"+leftTriggerVal);



  background_back = loadImage("backgrounds/test_bg.png");
  background = loadImage("backgrounds/test_landscape.png");
  println("bWidth "+background.width);


  background_0= loadImage("backgrounds/background_0.png");
  background_1_planet1= loadImage("backgrounds/background_1_planet1.png");
  background_2_planet2= loadImage("backgrounds/background_2_planet2.png");
  background_3_planet3= loadImage("backgrounds/background_3_planet3.png");
  background_4= loadImage("backgrounds/background_4.png");

  test_landscape= loadImage("backgrounds/test_landscape.png");

  combinedbackground=createGraphics(width, height);
  combinedbackground.beginDraw();
  combinedbackground.image(background_0, 0, 0);
  combinedbackground.image(background_1_planet1, 0, 0);
  combinedbackground.image(background_2_planet2, 0, 0);
  combinedbackground.image(background_3_planet3, 0, 0);
  combinedbackground.image(background_4, 0, 0);
  combinedbackground.endDraw();


  /* start oscP5, listening for incoming messages at port 8000 */
  oscP5 = new OscP5(this, 8000);
  // myRemoteLocation = new NetAddress("127.0.0.1 ", 8000);
  myRemoteLocation = new NetAddress("127.0.0.1 ", 8000);

  //loadSettings(myRemoteLocation);

  // Sound
  minim = new Minim(this);
  ambisound = minim.loadFile("sounds/Game Ambient.mp3");
  //ambisound.loop();  
  boostsound = minim.loadSample("sounds/boost.mp3", 512);
  hitsound = minim.loadSample("sounds/Hit.mp3", 512);
}






void setTocuosc(NetAddress _remoteLocation, String adress, float value) {
  OscMessage myMessage = new OscMessage("/1/gravlabel");
  myMessage.add(GRAVITY); /* add an int to the osc message */
  /* send the message */
  oscP5.send(myMessage, myRemoteLocation);
}

float debugval;
void draw() {
  background(0);
    rectMode(CENTER);


  /*image(background_0, 0, 0);
   pushMatrix();
   translate(planet1.x, planet1.y);
   image(background_1_planet1, 0, 0);  
   popMatrix();
   pushMatrix();
   translate(planet2.x, planet2.y);
   image(background_2_planet2, 0, 0);
   popMatrix();
   pushMatrix();
   translate(planet3.x, planet3.y);
   image(background_3_planet3, 0, 0);
   popMatrix();
   image(background_4, 0, 0);*/
  image(combinedbackground, 0, 0);
  image(test_landscape, 0, 0);
  
  plattform.render();

  /*planet1.add(planet1_speed);
   if (planet1.x>width)planet1.x=-background_1_planet1.width;
   planet2.add(planet2_speed);
   if (planet2.x>width)planet1.x=-background_2_planet2.width;
   planet3.add(planet3_speed);
   if (planet3.x>width)planet1.x=-background_3_planet3.width;
   
   */

  switch(gamestate) {

  case PLAYING:

    // We must always step through time!
    box2d.step();

    // Draw the surface
    surface.display();

    // Display all the people
    for (CustomShape cs : polygons) {
      cs.display();
    }

    // people that leave the screen, we delete them
    // (note they have to be deleted from both the box2d world and our list
    for (int i = polygons.size()-1; i >= 0; i--) {
      CustomShape cs = polygons.get(i);
      if (cs.done()) {
        polygons.remove(i);
      }
    }
    break;

  case LANDED:
    text("YOU WIN", width/2, height/2);
    break;

  case CRASHED:
    text("YOU LOOSE", width/2, height/2);

    break;




  case STARTSCREEN:
    text("START", width/2, height/2);
    break;
  }


  /*
  pushMatrix();
   translate(0, 0);
   stroke(255, 255, 255);
   strokeWeight(1);
   //plotterA0.plott(0, 200, 0, pH);
   
   plotterA0.plottScale();
   stroke(200, 255, 255);
   line(0, 0, width, 0);
   stroke(100, 255, 255);
   popMatrix();
   */


  plotterA0.addValue(val1);
  plotterA0.update();

  plotterA1.addValue(val2);
  plotterA1.update();

  plotterA2.addValue(val3);
  plotterA2.update();



  if (renderPlotter) {
    float mleftTriggerVal=map(leftTriggerVal, 0, 1025, 0, pH);
    float mrightTriggerVal=map(rightTriggerVal, 0, 1025, 0, pH);


    colorMode(RGB);
    rectMode(CORNER);
    blendMode(BLEND);
    pushMatrix();
    translate(0, 0);
    fill(255, 0, 0, 100);
    rect(0, 0, width, pH);
    stroke(255, 0, 0, 200);
    line(0, mleftTriggerVal, width, mleftTriggerVal);
    stroke(0, 0, 255, 200);
    line(0, mrightTriggerVal, width, mrightTriggerVal);
    plotterA0.plott(0, 600, 0, pH);
    translate(0, pH);
    fill(0, 255, 0, 100);
    rect(0, 0, width, pH);
    stroke(255, 0, 0, 200);
    line(0, mleftTriggerVal, width, mleftTriggerVal);
    stroke(0, 0, 255, 200);
    line(0, mrightTriggerVal, width, mrightTriggerVal);
    plotterA1.plott(0, 600, 0, pH);

    translate(0, pH);
    fill(0, 0, 255, 100);
    rect(0, 0, width, pH);
    stroke(255, 0, 0, 100);
    line(0, mleftTriggerVal, width, mleftTriggerVal);
    stroke(0, 0, 255, 100);
    line(0, mrightTriggerVal, width, mrightTriggerVal);
    plotterA2.plott(0, 600, 0, pH);
    popMatrix();
    //colorMode(HSB);
    rectMode(CENTER);
  }

  /*
  plotterA0.addValue(trampolinval);
   plotterA0.update();
   
   plotterA1.addValue(scaledInval);
   plotterA1.update();
   
   plotterA2.addValue(steerval);
   plotterA2.update();
   
   
   
   
   
   
   pushMatrix();
   translate(0, 0);
   stroke(255, 255, 255);
   strokeWeight(1);
   //plotterA0.plott(0, 50, 0, pH);
   stroke(100, 255, 255);
   
   translate(0, pH);
   //plotterA1.plott(0, MAXTHRUSTFORCE, 0, pH);
   
   stroke(200, 255, 255);
   
   translate(0, pH);
   //plotterA2.plott(0, 500, 0, pH);
   
   popMatrix();
   
   text(trampolinval, 0, 200);*/

  text(frameRate, 200, 200);
}



void keyTyped() {
  println(key);
  switch(key) {

  case 'q':
    boostsound.trigger();
    break;

  case 's':
    player1.setShieldActive(true);
    break;


  case 'y':
    player1.loadShield(5);
    break;


  case 'p':
    changeGameState(PLAYING);
    break;


  case 'w':
    boostsound.trigger();

    player1.setThrust(true, 2000);
    /* if (!boostsound.isPlaying()) {
     boostsound.play(0);
     
     }*/
    break;

  case 'a':
    player1.leftthrust=true;
    break;

  case 'd':
    player1.rightthrust=true;
    break;




  case 'k':
    player2.setShieldActive(true);
    break;

  case 'i':
    boostsound.trigger();

    //  boostsound.play(0);
    player2.setThrust(true, 2000);

    //if (!boostsound.isPlaying()) {
    // }
    break;

  case 'j':
    player2.leftthrust=true;
    break;

  case 'l':
    player2.rightthrust=true;
    break;




  case '1':
    for (CustomShape cs : polygons) {
      cs.setThrustForce(100);
    }
    break;


  case '2':
    for (CustomShape cs : polygons) {
      cs.setThrustForce(1000);
    }
    break;


  case '3':
    for (CustomShape cs : polygons) {
      //cs.setThrustForce(MAXTHRUSTFORCE);
    }
    break;

  case 'r':
    changeGameState(PLAYING);
    break;
  }
}





void keyReleased() {

  switch(key) {
  case 's':
    //players[0].setShieldActive(false);
    break;

  case 'w':
    for (CustomShape cs : polygons) {
      // cs.thrust=false;
    }
    break;

  case 'a':
    player1.leftthrust=false;

    break;

  case 'd':
    player1.rightthrust=false;
    break;






  case 'k':
    // player2.setShieldActive(true);
    break;

  case 'i':
    //boostsound.play(0);
    // player2.setThrust(true, 2000);

    //if (!boostsound.isPlaying()) {
    // }
    break;

  case 'j':
    player2.leftthrust=false;
    break;

  case 'l':
    player2.rightthrust=false;
    break;
  }
}





void mousePressed() {
  // CustomShape cs = new CustomShape(mouseX, mouseY);
  // polygons.add(cs);
}




/*
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
 }*/




void serialEvent(Serial p) {
  try {

    // get message till linefeed;
    String message = myPort.readStringUntil(lf);
    //remove the linefeed
    message = trim(message);

    String[] sensordata = split(message, ',');

    //val=float(sensordata[0]);

    float inval1 =float(sensordata[0]);
    float inval2 =float(sensordata[1]);


    lerpval=0.05;

    lerpdval1=lerp(lerpdval1, inval1, lerpval);
    lerpdval2=lerp(lerpdval2, inval1, lerpval);



    if (inval1>0) {
      float mappedinval1=map(lerpdval1, 200, 700, 0, 600);
      float mappedinvalPowInv=mapPowInv(3, lerpdval1, 200, 700, 0, 600);
      float mappedinvalPow=mapPow(0.1, lerpdval1, 200, 700, 0, 600);

      println(lerpdval1+" "+mappedinval1);

      val1=mappedinval1;
      val2=mappedinvalPowInv;
      val3=mappedinvalPow;

      //val1=lerp(val1, mappedinval1, lerpval);
      //val2=lerp(val2, mappedinvalPowInv, lerpval);
      //val3=lerp(val3, mappedinvalPow, lerpval);
    }

    if (inval2>0) {
      // float mappedinval2=map(inval2, 0, 300, 0, 1025);
      // val3=lerp(val3, mappedinval2, lerpval);
    }



    // CustomShape player0 =polygons.get(0);

    if (val1<leftTriggerVal) {
      player1.leftthrust=true;
    } else {
      player1.leftthrust=false;
    }

    if (val1>rightTriggerVal) {
      player1.rightthrust=true;
    } else {
      player1.rightthrust=false;
    }
  } 
  catch (Exception e) {
    println("Initialization exception");
  }
}

void preSolve(Contact cp, Manifold oldManifold) {
  // TODO Auto-generated method stub

  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();


  if (o1.getClass() == CustomShape.class && o2.getClass() == CustomShape.class) {
    CustomShape cs1 = (CustomShape) o1;
    CustomShape cs2 = (CustomShape) o2;
    // println("PRESOLVE");

    cs1.hitShipPresolve();
    cs2.hitShipPresolve();
  }
}


void postSolve(Contact cp, ContactImpulse impulse) {
  // TODO Auto-generated method stub
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();


  if (o1.getClass() == CustomShape.class && o2.getClass() == CustomShape.class) {
    CustomShape cs1 = (CustomShape) o1;
    CustomShape cs2 = (CustomShape) o2;
    // println("POSTSOLVE");

    cs1.hitShipPostsolve();
    cs2.hitShipPostsolve();
  }
}

// Collision event functions!
void beginContact(Contact cp) {


  //hitsound.trigger(); 

  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();


  // println(o2.getClass());
  // println(o1.getClass());
  /* if (o2.getClass() == CustomShape.class ) {
   CustomShape cs = (CustomShape) o2;
   cs.change();
   }*/




  if (o1.getClass() == CustomShape.class && o2.getClass() == CustomShape.class) {
    CustomShape cs1 = (CustomShape) o1;
    CustomShape cs2 = (CustomShape) o2;
    println("contact");

    hitsound.trigger();

    cs1.hitShip();
    cs2.hitShip();
  }

  if (o1.getClass() == Surface.class) {
    CustomShape cs = (CustomShape) o2;
    cs.hitSurface();
  }
  if (o2.getClass() == Surface.class) {
    CustomShape cs = (CustomShape) o1;
    cs.hitSurface();
  }
}

// Collision event functions!
void endContact(Contact cp) {
  //println("contact");
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  // println(o2.getClass());
  // println(o1.getClass());
  if (o2.getClass() == CustomShape.class ) {
    CustomShape cs = (CustomShape) o2;
    cs.endContact();
  }


  if (o1.getClass() == CustomShape.class && o2.getClass() == CustomShape.class) {
    CustomShape cs1 = (CustomShape) o1;
    CustomShape cs2 = (CustomShape) o2;

    cs1.hitShipEnd();
    cs2.hitShipEnd();
  }
}

void changeGameState(int _state) {
  gamestate=_state;
}


void oscEvent(OscMessage theOscMessage) {

  String address = theOscMessage.netAddress().address();
  myRemoteLocation = new NetAddress(address, 9000);

  String addr = theOscMessage.addrPattern();
  float  val  = theOscMessage.get(0).floatValue();

  if (addr.equals("/1/gravity")) { 
    GRAVITY = val;
    box2d.setGravity(0, -GRAVITY);
    OscMessage myMessage = new OscMessage("/1/gravitylabel");
    myMessage.add(val); /* add an int to the osc message */
    /* send the message */
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/1/restitution")) { 
    RESTITUTION = val;
    OscMessage myMessage = new OscMessage("/1/restitutionlabel");
    myMessage.add(val); /* add an int to the osc message */
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/1/damping")) { 
    DAMPING = val;
    OscMessage myMessage = new OscMessage("/1/dampinglabel");
    myMessage.add(val); /* add an int to the osc message */
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/1/density")) { 
    DENSITY = val;
    OscMessage myMessage = new OscMessage("/1/densitylabel");
    myMessage.add(val); /* add an int to the osc message */
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/1/maxspeed")) { 
    MAXSPEED = val;
    OscMessage myMessage = new OscMessage("/1/maxspeedlabel");
    myMessage.add(val); /* add an int to the osc message */
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/1/impulse")) { 
    IMPULSE = val;
    OscMessage myMessage = new OscMessage("/1/impulselabel");
    myMessage.add(val); /* add an int to the osc message */
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/1/maxthrustforce")) { 
    MAXSPEED = val;
    OscMessage myMessage = new OscMessage("/1/maxthrustforcelabel");
    myMessage.add(val); /* add an int to the osc message */
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/1/load")) { 
    println("LOAD SETTINGS");
    loadSettings(myRemoteLocation);
  } else if (addr.equals("/1/save")) { 
    saveSettings();
  }
}

void loadSettings(NetAddress _myRemoteLocation) {

  settings = loadJSONObject("settings.json");

  println("here");


  delay(10);

  //world
  GRAVITY = settings.getFloat("Gravity");
  RESTITUTION = settings.getFloat("Restitution");
  DAMPING = settings.getFloat("Damping");

  //vessel
  DENSITY = settings.getFloat("Density");
  MAXSPEED = settings.getFloat("Maxspeed");
  IMPULSE = settings.getFloat("Impulse");
  MAXTHRUSTFORCE = settings.getFloat("Maxthrustforce");


  for (CustomShape cs : polygons) {
    cs.setRestitution(RESTITUTION);
  }


  OscMessage myMessage = new OscMessage("/1/gravitylabel");
  myMessage.add(GRAVITY); /* add an int to the osc message */
  /* send the message */

  oscP5.send(myMessage, _myRemoteLocation);

  myMessage = new OscMessage("/1/gravity");
  myMessage.add(GRAVITY); 
  oscP5.send(myMessage, _myRemoteLocation);

  myMessage = new OscMessage("/1/restitutionlabel");
  myMessage.add(RESTITUTION); 
  oscP5.send(myMessage, _myRemoteLocation);

  myMessage = new OscMessage("/1/restitution");
  myMessage.add(RESTITUTION); 
  oscP5.send(myMessage, _myRemoteLocation);

  myMessage = new OscMessage("/1/dampinglabel");
  myMessage.add(DAMPING); 
  oscP5.send(myMessage, _myRemoteLocation);

  myMessage = new OscMessage("/1/damping");
  myMessage.add(DAMPING); 
  oscP5.send(myMessage, _myRemoteLocation);

  myMessage = new OscMessage("/1/densitylabel");
  myMessage.add(DENSITY); 
  oscP5.send(myMessage, _myRemoteLocation);

  myMessage = new OscMessage("/1/density");
  myMessage.add(DENSITY); 
  oscP5.send(myMessage, _myRemoteLocation);

  myMessage = new OscMessage("/1/maxspeedlabel");
  myMessage.add(MAXSPEED); 
  oscP5.send(myMessage, _myRemoteLocation);

  myMessage = new OscMessage("/1/maxspeed");
  myMessage.add(MAXSPEED); 
  oscP5.send(myMessage, _myRemoteLocation);

  myMessage = new OscMessage("/1/impulselabel");
  myMessage.add(IMPULSE); 
  oscP5.send(myMessage, _myRemoteLocation);

  myMessage = new OscMessage("/1/impulse");
  myMessage.add(IMPULSE); 
  oscP5.send(myMessage, _myRemoteLocation);


  myMessage = new OscMessage("/1/maxthrustforcelabel");
  myMessage.add(MAXTHRUSTFORCE); 
  oscP5.send(myMessage, _myRemoteLocation);

  myMessage = new OscMessage("/1/maxthrustforce");
  myMessage.add(MAXTHRUSTFORCE); 
  oscP5.send(myMessage, _myRemoteLocation);
}


void saveSettings() {
  JSONObject parameters = new JSONObject();
  parameters.setFloat("Gravity", GRAVITY);
  parameters.setFloat("Restitution", RESTITUTION);
  parameters.setFloat("Damping", DAMPING);
  parameters.setFloat("Density", DENSITY);
  parameters.setFloat("Maxspeed", MAXSPEED);
  parameters.setFloat("Impulse", IMPULSE);
  parameters.setFloat("Maxthrustforce", MAXTHRUSTFORCE);
  saveJSONObject(parameters, "data/settings.json");
}


float mapPowInv(float pow, float value, float start1, float stop1, float start2, float stop2) {
  float inT = norm(value, start1, stop1);
  float outT = 1-(pow((1-inT), pow));
  return map(outT, 0, 1, start2, stop2);
}


float mapPow(float pow, float value, float start1, float stop1, float start2, float stop2) {
  float inT = norm(value, start1, stop1);
  float outT = pow(inT, pow);
  return map(outT, 0, 1, start2, stop2);
}