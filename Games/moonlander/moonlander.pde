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

import oscP5.*;
import netP5.*;

import processing.serial.*;


// GUI
OscP5 oscP5;
NetAddress myRemoteLocation;
// gui settings 
JSONObject settings;

// A reference to our box2d world
Box2DProcessing box2d;
// Landing Plattform
Plattform plattform;
// An object to store information about the uneven surface
Surface surface;

// VESSELS
ArrayList<CustomShape> polygons;
CustomShape player1;
CustomShape player2; 
PVector positionPlayer1=new PVector(20, 500);
PVector positionPlayer2=new PVector(200, 100);


// STARTING UP
Countdown countdown = new Countdown();

// sound
Minim minim;
AudioPlayer ambisound;
AudioSample boostsound;
AudioSample hitsound;
AudioPlayer countdownsound;
AudioPlayer liftoff;
AudioPlayer landed;



//GAMESTATE
int gamestate;

void setup() {
  size(1920, 1080);
  // size(1500, 1080);
  frameRate(30);
  // pixelDensity(2);
  // fullScreen(2);

  //------------------------- INITS ----------------------------------
  RG.init(this); // init geomerative for Landscape generation
  // Arduino stuff
  println(Serial.list());
  String portName = Serial.list()[3];
  if (bUseArduino) myPort = new Serial(this, "/dev/tty.usbmodem1411", 9600 );
  if (bUseArduino) myPort.bufferUntil(lf);
  /* start oscP5, listening for incoming messages at port 8000 */
  oscP5 = new OscP5(this, 8000);
  myRemoteLocation = new NetAddress("127.0.0.1 ", 8000);


  // ------------------------- WORLD ----------------------------------
  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, -GRAVITY);
  // Turn on collision listening!
  box2d.listenForCollisions();

  // Create the surface
  surface = new Surface();

  // Create the Plattform
  plattform=new Plattform(new PVector(width/2, 590));

  // Make the players
  polygons = new ArrayList<CustomShape>();
  CustomShape cs = new CustomShape(this, positionPlayer1.x, positionPlayer1.y, 1);
  cs.setColor(color(0));
  cs.setGlowColor(color(255, 0, 0));
  polygons.add(cs);
  cs = new CustomShape(this, positionPlayer2.x, positionPlayer2.y, 2);
  cs.setColor(color(0));
  cs.setGlowColor(color(255, 255, 255));
  polygons.add(cs);
  // Player var for convenience
  player1 = polygons.get(0);
  player2 = polygons.get(1);
  // Background
  bakeBackground();

  //------------------------- PLOTTER ----------------------------------
  plotterA0=new Plotter();
  plotterA1=new Plotter();
  plotterA2=new Plotter();

  println("+++++++++rightTriggerVal++++++++++++"+rightTriggerVal);
  println("+++++++++++leftTriggerVal++++++++++"+leftTriggerVal);

  //------------------------- SETTINGS ----------------------------------

  //loadSettings(myRemoteLocation);

  //------------------------- SOUND ----------------------------------
  minim = new Minim(this);
  ambisound = minim.loadFile("sounds/Game Ambient.mp3");
  ambisound.setGain(AMBIMUTE);
  ambisound.loop();  
  boostsound = minim.loadSample("sounds/boost.mp3", 512);
  hitsound = minim.loadSample("sounds/Hit.mp3", 512);
  countdownsound = minim.loadFile("sounds/Countdown.mp3");
  liftoff = minim.loadFile("sounds/Startliftoff.mp3");
  landed=minim.loadFile("sounds/Landing Plattform.mp3");


  //------------------------- GAMEHANDLER ----------------------------------
  gamestate=STARTSCREEN;
}

void draw() {
  background(0);
  rectMode(CENTER);
  // renderDynamicBackground();

  // -------------- Render Background ----------
  image(combinedbackground, 0, 0);
  image(test_landscape, 0, 0);
  plattform.render();

  // -------------- Main Render Stuff  ----------
  gameStateRenderHandler();

  plotterHandler();

  textSize(50);
  fill(255);
  text(frameRate, 20, 50);



  lerpdPlayer1Steerval=lerp(lerpdPlayer1Steerval, player1Steerval, player1SteerLerpFact);
  OscMessage myMessage = new OscMessage("/2/lerpdPlayer1Steerval");
  myMessage.add(lerpdPlayer1Steerval); /* add an int to the osc message */
  oscP5.send(myMessage, myRemoteLocation);
  myMessage = new OscMessage("/2/mappedPlayer1Steerval");
  myMessage.add(lerpdPlayer1Steerval); /* add an int to the osc message */
  oscP5.send(myMessage, myRemoteLocation);

  lerpdPlayer1Steerval=lerp(lerpdPlayer1Steerval, player1Steerval, player1SteerLerpFact);
  myMessage = new OscMessage("/2/lerpdPlayer2Steerval");
  myMessage.add(lerpdPlayer2Steerval); /* add an int to the osc message */
  oscP5.send(myMessage, myRemoteLocation);
  myMessage = new OscMessage("/2/mappedPlayer2Steerval");
  myMessage.add(mappedPlayer2Steerval); /* add an int to the osc message */
  oscP5.send(myMessage, myRemoteLocation);
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

    player1Steerval =float(sensordata[0]);
    player1Trampolinval =float(sensordata[1]);
    player1Shieldval =float(sensordata[2]);
    player1Buttonval =float(sensordata[3]);

    player2Steerval =float(sensordata[4]);
    player2Trampolinval =float(sensordata[5]);
    player2Shieldval =float(sensordata[6]);
    player2Buttonval =float(sensordata[7]);






    lerpdPlayer2Steerval=lerp(lerpdPlayer2Steerval, player2Steerval, player2SteerLerpFact);


    /*
    float player1mapInMin= 200;
     float player1mapInMax=700;
     float player1mapOutMin =0;
     float player1mapOutMax=600;
     */

    if (player1Steerval>0) {
      float mappedinval1=map(lerpdPlayer1Steerval, player1mapInMin, player1mapInMax, player1mapOutMin, player1mapOutMax);
      float mappedinvalPowInv=mapPowInv(3, lerpdPlayer1Steerval, player1mapInMin, player1mapInMax, player1mapOutMin, player1mapOutMax);
      float mappedinvalPow=mapPow(0.1, lerpdPlayer1Steerval, player1mapInMin, player1mapInMax, player1mapOutMin, player1mapOutMax);





      val1=mappedinval1;
      val2=mappedinvalPowInv;
      val3=mappedinvalPow;

      //val1=lerp(val1, mappedinval1, lerpval);
      //val2=lerp(val2, mappedinvalPowInv, lerpval);
      //val3=lerp(val3, mappedinvalPow, lerpval);
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

int getThrustForceLevel(float _thrustforce) {

  int thrustforce;
  float cdist=10000;
  int index=0;
  for (int i=0; i<thrustforcearray.length; i++) {
    float d=abs(thrustforcearray[i]-_thrustforce);
    println(d+" "+cdist);
    if (d<cdist) {
      cdist=d;
      index=i;
    }
  }
  thrustforce=(int)thrustforcearray[index];
  return  thrustforce;
}



void preSolve(Contact cp, Manifold oldManifold) {
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  if (o1.getClass() == CustomShape.class && o2.getClass() == CustomShape.class) {
    CustomShape cs1 = (CustomShape) o1;
    CustomShape cs2 = (CustomShape) o2;
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
    cs1.hitShipPostsolve();
    cs2.hitShipPostsolve();
  }
}

// Collision event functions!
void beginContact(Contact cp) {
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  if (o1.getClass() == CustomShape.class && o2.getClass() == CustomShape.class) {
    CustomShape cs1 = (CustomShape) o1;
    CustomShape cs2 = (CustomShape) o2;
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
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();
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




void oscEvent(OscMessage theOscMessage) {
  String address = theOscMessage.netAddress().address();
  myRemoteLocation = new NetAddress(address, 9000);
  String addr = theOscMessage.addrPattern();
  float  val  = theOscMessage.get(0).floatValue();

  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());


  if (addr.equals("/1/gravity")) { 
    println("GRAVITY "+val);

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
    player1.setRestitution(RESTITUTION);
    player2.setRestitution(RESTITUTION);
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
  } else if (addr.equals("/1/maxspeed")) { 
    MAXSPEED = val;
    OscMessage myMessage = new OscMessage("/1/maxspeedlabel");
    myMessage.add(val); /* add an int to the osc message */
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player1mapInMin")) { 
    player1mapInMin = val;
    OscMessage  myMessage = new OscMessage("/2/player1mapInMinLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player1mapInMax")) { 
    player1mapInMax = val;
    OscMessage  myMessage = new OscMessage("/2/player1mapInMaxLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player1mapOutMin")) { 
    player1mapOutMin = val;
    OscMessage  myMessage = new OscMessage("/2/player1mapOutMinLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player1mapOutMax")) { 
    player1mapOutMax = val;
    OscMessage  myMessage = new OscMessage("/2/player1mapOutMaxLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player1leftTriggerVal")) { 
    player1mapOutMax = val;
    OscMessage  myMessage = new OscMessage("/2/player1leftTriggerValLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player1rightTriggerVal")) { 
    player1mapOutMax = val;
    OscMessage  myMessage = new OscMessage("/2/player1rightTriggerValLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player2mapInMin")) { 
    player1mapInMin = val;
    OscMessage  myMessage = new OscMessage("/2/player2mapInMinLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player2mapInMax")) { 
    player1mapInMax = val;
    OscMessage  myMessage = new OscMessage("/2/player2mapInMaxLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player2mapOutMin")) { 
    player1mapOutMin = val;
    OscMessage  myMessage = new OscMessage("/2/player2mapOutMinLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player2mapOutMax")) { 
    player1mapOutMax = val;
    OscMessage  myMessage = new OscMessage("/2/player2mapOutMaxLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player2leftTriggerVal")) { 
    player1mapOutMax = val;
    OscMessage  myMessage = new OscMessage("/2/player2leftTriggerValLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player2rightTriggerVal")) { 
    player1mapOutMax = val;
    OscMessage  myMessage = new OscMessage("/2/player2rightTriggerValLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/3/load")) { 
    println("LOAD SETTINGS");
    loadSettings(myRemoteLocation);
  } else if (addr.equals("/3/save")) { 
    saveSettings();
  } else if (addr.equals("/3/countdownbutton")) { 
    changeGameState(COUNTDOWN);
  } else if (addr.equals("/3/startbutton")) { 
    changeGameState(PLAYING);
  } else if (addr.equals("/3/resetbutton")) { 
    reset();
  }
}

void loadSettings(NetAddress _myRemoteLocation) {
  settings = loadJSONObject("settings.json");

  delay(20);
  println("hoi");

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



  player1leftTriggerVal=200;
  player1rightTriggerVal=500;
  player1mapInMin= 200;
  player1mapInMax=700;
  player1mapOutMin =0;
  player1mapOutMax=600;


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
  myMessage = new OscMessage("/1/maxspeedlabel");
  myMessage.add(MAXSPEED); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/1/maxspeed");
  myMessage.add(MAXSPEED); 
  oscP5.send(myMessage, _myRemoteLocation);


  myMessage = new OscMessage("/2/player1mapInMin");
  myMessage.add(player1mapInMin); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player1mapInMinLabel");
  myMessage.add(player1mapInMin); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player1mapInMax");
  myMessage.add(player1mapInMax); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player1mapInMaxLabel");
  myMessage.add(player1mapInMax); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player1mapOutMin");
  myMessage.add(player1mapOutMin); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player1mapOutMinLabel");
  myMessage.add(player1mapOutMin); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player1mapOutMax");
  myMessage.add(player1mapOutMax); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player1mapOutMaxLabel");
  myMessage.add(player1mapOutMax); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player1leftTriggerVal");
  myMessage.add(player1leftTriggerVal); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player1leftTriggerValLabel");
  myMessage.add(player1leftTriggerVal); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player1rightTriggerVal");
  myMessage.add(player1rightTriggerVal); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player1rightTriggerValLabel");
  myMessage.add(player1rightTriggerVal); 
  oscP5.send(myMessage, _myRemoteLocation);

  myMessage = new OscMessage("/2/player2mapInMin");
  myMessage.add(player1mapInMin); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2mapInMinLabel");
  myMessage.add(player1mapInMin); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2mapInMax");
  myMessage.add(player1mapInMax); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2mapInMaxLabel");
  myMessage.add(player1mapInMax); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2mapOutMin");
  myMessage.add(player1mapOutMin); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2mapOutMinLabel");
  myMessage.add(player1mapOutMin); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2mapOutMax");
  myMessage.add(player1mapOutMax); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2mapOutMaxLabel");
  myMessage.add(player1mapOutMax); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2leftTriggerVal");
  myMessage.add(player1leftTriggerVal); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2leftTriggerValLabel");
  myMessage.add(player1leftTriggerVal); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2rightTriggerVal");
  myMessage.add(player1rightTriggerVal); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2rightTriggerValLabel");
  myMessage.add(player1rightTriggerVal); 
  oscP5.send(myMessage, _myRemoteLocation);


  /*
  oscP5.send(myMessage, _myRemoteLocation);
   myMessage = new OscMessage("/1/maxspeed");
   myMessage.add(MAXSPEED); 
   oscP5.send(myMessage, _myRemoteLocation);
   myMessage = new OscMessage("/1/maxspeed");
   myMessage.add(MAXSPEED); 
   oscP5.send(myMessage, _myRemoteLocation);
   myMessage = new OscMessage("/1/maxspeed");
   myMessage.add(MAXSPEED); 
   oscP5.send(myMessage, _myRemoteLocation);
   myMessage = new OscMessage("/1/maxspeed");
   myMessage.add(MAXSPEED); 
   oscP5.send(myMessage, _myRemoteLocation);
   */
}

void reset() {
  player1.reset();
  player2.reset();
  changeGameState(STARTSCREEN);
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