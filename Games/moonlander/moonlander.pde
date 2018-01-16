//defaults write -g ApplePressAndHoldEnabled -bool false
//defaults write -g ApplePressAndHoldEnabled -bool true



import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;


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
float RESTITUTION=1;
float DAMPING = 1;


// SPACESHIP
float DENSITY = 0.6;
float MAXSPEED=100;
float IMPULSE=7;
float MAXTHRUSTFORCE=8;


final int MAXLANDSPEED=3;




final int PLAYING = 100;
final int LANDED = 101;
final int CRASHED = 102;


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

// style
float pH=200;



// Arduino 
import processing.serial.*;
Serial myPort;  // Create object from Serial class
float val;      // Data received from the serial port
String inString="";  // Input string from serial port
int lf = 10;      // ASCII linefeed 
int [] mysensors= new int[2];
boolean bUseArduino=false;




// design
PImage background;
PImage background_back;



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
AudioPlayer boostsound;
AudioPlayer hitsound;



void setup() {
  size(1920, 1080);
  // size(1500, 1080);

  frameRate(30);
  //fullScreen();
  colorMode(HSB);





  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // We are setting a custom gravity
  box2d.setGravity(0, -GRAVITY);

  // Turn on collision listening!
  box2d.listenForCollisions();




  polygons = new ArrayList<CustomShape>();
  CustomShape cs = new CustomShape(20, 500);
  polygons.add(cs);

  RG.init(this);


  // Create the surface
  surface = new Surface();

  //plattform=new Plattform(p);

  // Arduino stuff
  println(Serial.list());
  String portName = Serial.list()[3];
  if (bUseArduino) myPort = new Serial(this, "/dev/tty.usbmodem1411", 115200 );
  if (bUseArduino) myPort.bufferUntil(lf);

  // pixelDensity(2);


  plotterA0=new Plotter();
  plotterA1=new Plotter();
  plotterA2=new Plotter();


  background_back = loadImage("backgrounds/test_bg.png");
  background = loadImage("backgrounds/test_landscape.png");


  /* start oscP5, listening for incoming messages at port 8000 */
  oscP5 = new OscP5(this, 8000);
  myRemoteLocation = new NetAddress("127.0.0.1 ", 8000);
  //loadSettings(myRemoteLocation);

  // Sound
  minim = new Minim(this);
  ambisound = minim.loadFile("sounds/Game Ambient.mp3");
  ambisound.loop();  
  // boostsound = minim.loadFile("sounds/Boost.aif",16);
  //  hitsound = minim.loadFile("sounds/Hit.aif",16);
}






void setTocuosc(NetAddress _remoteLocation, String adress, float value) {
  OscMessage myMessage = new OscMessage("/1/gravlabel");
  myMessage.add(GRAVITY); /* add an int to the osc message */
  /* send the message */
  oscP5.send(myMessage, myRemoteLocation);
}


void draw() {
  background(0);
  image(background_back, 0, 0);
  image(background, 0, 0);



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

  text(trampolinval, 0, 200);
  text(frameRate, 200, 200);
}



void keyPressed() {
  println("key "+key);

  switch(key) {
  case 's':
    /* for (CustomShape cs : polygons) {
     cs.setShieldActive(true);
     }*/

    CustomShape s = polygons.get(0);
    s.setShieldActive(true);


    break;

  case 'w':
    for (CustomShape cs : polygons) {
      cs.setThrust(true, 2000);
    }
    break;

  case 'a':
    for (CustomShape cs : polygons) {
      cs.leftthrust=true;
    }

    break;

  case 'd':
    for (CustomShape cs : polygons) {
      cs.rightthrust=true;
    }

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
    trampolinscalemax=trampolinval-2;
    break;
  }
}





void keyReleased() {
  println("release "+key);

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
    for (CustomShape cs : polygons) {
      cs.leftthrust=false;
    }
    break;

  case 'd':
    for (CustomShape cs : polygons) {
      cs.rightthrust=false;
    }
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
    println(sensordata);

    trampolinval =float(sensordata[0]);

    val=constrain(trampolinval, 0, 22);


    //println(trampolinval);
    /* val=inval;
     val=constrain(inval, 0, 250);
     */
    //trampolinval=inval;

    // if (trampolinval<minVal)minVal=trampolinval;
    //if (trampolinval>maxVal)maxVal=trampolinval;


    scaledInval=floor(map(val, 0, 19, MAXTHRUSTFORCE, 0));

    if (scaledInval>4) {
      for (CustomShape cs : polygons) {
        cs.setThrust(true, int(scaledInval*500));
      }
    } 


    steerval=lerp(steerval, float(sensordata[1]), 0.1);
    CustomShape cs = polygons.get(0);

    if (steerval<rightSteer) {
      cs.rightthrust=true;
      println("right", steerval);
    } else {
      cs.rightthrust=false;
    }

    if (steerval>leftSteer) {
      cs.leftthrust=true;
      println("left", steerval);
    } else {
      cs.leftthrust=false;
    }
  } 
  catch (Exception e) {
    println("Initialization exception");
  }
}



// Collision event functions!
void beginContact(Contact cp) {
  // println("contact");
  // Get both fixtures
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
    MAXSPEED = val;
    OscMessage myMessage = new OscMessage("/1/impulselabel");
    myMessage.add(val); /* add an int to the osc message */
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/1/maxthrustforce")) { 
    MAXSPEED = val;
    OscMessage myMessage = new OscMessage("/1/maxthrustforcelabel");
    myMessage.add(val); /* add an int to the osc message */
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/1/load")) { 
    loadSettings(myRemoteLocation);
  }
}

void loadSettings(NetAddress _myRemoteLocation) {
  settings = loadJSONObject("settings.json");

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




  OscMessage myMessage = new OscMessage("/1/gravitylabel");
  myMessage.add(GRAVITY); /* add an int to the osc message */
  /* send the message */
  oscP5.send(myMessage, myRemoteLocation);

  myMessage = new OscMessage("/1/gravity");
  myMessage.add(GRAVITY); 
  oscP5.send(myMessage, myRemoteLocation);

  myMessage = new OscMessage("/1/restitutionlabel");
  myMessage.add(RESTITUTION); 
  oscP5.send(myMessage, myRemoteLocation);

  myMessage = new OscMessage("/1/restitution");
  myMessage.add(RESTITUTION); 
  oscP5.send(myMessage, myRemoteLocation);

  myMessage = new OscMessage("/1/dampinglabel");
  myMessage.add(DAMPING); 
  oscP5.send(myMessage, myRemoteLocation);

  myMessage = new OscMessage("/1/damping");
  myMessage.add(DAMPING); 
  oscP5.send(myMessage, myRemoteLocation);

  myMessage = new OscMessage("/1/densitylabel");
  myMessage.add(DENSITY); 
  oscP5.send(myMessage, myRemoteLocation);

  myMessage = new OscMessage("/1/density");
  myMessage.add(DENSITY); 
  oscP5.send(myMessage, myRemoteLocation);

  myMessage = new OscMessage("/1/maxspeedlabel");
  myMessage.add(MAXSPEED); 
  oscP5.send(myMessage, myRemoteLocation);

  myMessage = new OscMessage("/1/maxspeed");
  myMessage.add(MAXSPEED); 
  oscP5.send(myMessage, myRemoteLocation);

  myMessage = new OscMessage("/1/impulselabel");
  myMessage.add(IMPULSE); 
  oscP5.send(myMessage, myRemoteLocation);

  myMessage = new OscMessage("/1/impulse");
  myMessage.add(IMPULSE); 
  oscP5.send(myMessage, myRemoteLocation);


  myMessage = new OscMessage("/1/maxthrustforcelabel");
  myMessage.add(MAXTHRUSTFORCE); 
  oscP5.send(myMessage, myRemoteLocation);

  myMessage = new OscMessage("/1/maxthrustforce");
  myMessage.add(MAXTHRUSTFORCE); 
  oscP5.send(myMessage, myRemoteLocation);
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