//defaults write -g ApplePressAndHoldEnabled -bool false
//defaults write -g ApplePressAndHoldEnabled -bool true



import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;


import geomerative.*;


// A reference to our box2d world
Box2DProcessing box2d;


// definitions
// FORCES
float VERTICAL_THRUST=0.6;
float HORIZONTAL_THRUST=0.1;
float GRAVITY = 0.1;
// Constants
float DRAG=0.9;
float MAXSPEED=5;
float MAXFUEL=1000;


final int MAXLANDSPEED=3;

final int PLAYING = 100;
final int LANDED = 101;
final int CRASHED = 102;

int MAXTHRUSTFORCE=8;
public float trampolinval = 0;
public  float scaledInval=0;
public float trampolinscalemin = 1;//7;
public float trampolinscalemax = 12;//198;
float minVal=400;
float maxVal=0;





float incomingThrustBefore=0;


Player player;
Player player2;

Player [] players = new Player[2];

ArrayList <Laser> lasers;//where our bullets will be stored


Plattform plattform;

// An object to store information about the uneven surface
Surface surface;

// An ArrayList of particles that will fall on the surface
ArrayList<Particle> particles;

// A list for all of our rectangles
ArrayList<CustomShape> polygons;





// Plotter Vars
Plotter plotterA0; 
Plotter plotterA1; 

// style
float pH=500;



// Arduino 
import processing.serial.*;
Serial myPort;  // Create object from Serial class
float val;      // Data received from the serial port
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

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // We are setting a custom gravity
  box2d.setGravity(0, -40);

  // Turn on collision listening!
  box2d.listenForCollisions();



  // Create the empty list
  particles = new ArrayList<Particle>();

  polygons = new ArrayList<CustomShape>();
  CustomShape cs = new CustomShape(20, 500);
  polygons.add(cs);

  RG.init(this);


  // Create the surface
  surface = new Surface();



  //players[0]=new Player(new PVector(width-50, 50));
  //players[1]=new Player(new PVector(50, 50));

  lasers = new ArrayList();




  //plattform=new Plattform(p);




  // Arduino stuff
  println(Serial.list());
  String portName = Serial.list()[3];
  if (bUseArduino) myPort = new Serial(this, "/dev/tty.usbmodem1421", 115200 );
  if (bUseArduino) myPort.bufferUntil(lf);

  // pixelDensity(2);


  plotterA0=new Plotter();
  plotterA1=new Plotter();
}

void draw() {
  background(0);

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







  removeToLimit(100);

  plotterA0.addValue(trampolinval);
  plotterA0.update();

  plotterA1.addValue(scaledInval);
  plotterA1.update();
  pushMatrix();
  translate(0, 0);
  stroke(255, 255, 255);
  strokeWeight(1);
  plotterA0.plott(0, 50, 0, pH);
  stroke(100, 255, 255);

  translate(0, pH);
  plotterA1.plott(0, MAXTHRUSTFORCE, 0, pH);

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
    
    CustomShape cs = polygons.get(0);
    cs.setShieldActive(true);
    
    
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
      cs.setThrustForce(MAXTHRUSTFORCE);
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



void removeToLimit(int maxLength)
{
  while (lasers.size() > maxLength)
  {
    lasers.remove(0);
  }
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
    //message = trim(message);
    trampolinval =float(message);

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

    /*if (trampolinval<trampolinscalemax) {
     for (CustomShape cs : polygons) {
     cs.setThrust(true, int(scaledInval));
     }
     } else {
     for (CustomShape cs : polygons) {
     cs.setThrust(false);
     }*/
    // }
  } 
  catch (Exception e) {
    println("Initialization exception");
  }
}



// Collision event functions!
void beginContact(Contact cp) {
  println("contact");
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  println(o2.getClass());
  println(o1.getClass());
 /* if (o2.getClass() == CustomShape.class ) {
    CustomShape cs = (CustomShape) o2;
    cs.change();
  }*/

  if (o1.getClass() == Surface.class) {
    CustomShape cs = (CustomShape) o2;
    cs.change();
  }
  if (o2.getClass() == Surface.class) {
    CustomShape cs = (CustomShape) o1;
    cs.change();
  }
}

// Collision event functions!
void endContact(Contact cp) {
  println("contact");
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  println(o2.getClass());
  println(o1.getClass());
  if (o2.getClass() == CustomShape.class ) {
    CustomShape cs = (CustomShape) o2;
    cs.endContact();
  }
}