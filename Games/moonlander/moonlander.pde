//defaults write -g ApplePressAndHoldEnabled -bool false //<>//
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

import java.util.Map;


// GUI
OscP5 oscP5;
NetAddress myRemoteLocation;
// gui settings 
JSONObject steeringsettings;
JSONObject worldsettings;


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
PVector positionPlayer1=new PVector(1920-50, 500);
PVector positionPlayer2=new PVector(50, 500);


// STARTING UP
Countdown countdown = new Countdown();

// sound
Minim minim;
AudioPlayer ambisound;
AudioSample player1boostsound;
AudioSample player2boostsound;

AudioSample hitsound;
AudioPlayer countdownsound;
AudioPlayer liftoff;
AudioPlayer landed;

AudioSample player1sideboost;
AudioSample player2sideboost;

AudioSample hitground;
AudioSample shield;



//GAMESTATE
int gamestate;

void setup() {
  size(1920, 1080);
  // size(1500, 1080);
  frameRate(30);
  // pixelDensity(2);
  //fullScreen();

  //------------------------- INITS ----------------------------------
  RG.init(this); // init geomerative for Landscape generation
  // Arduino stuff
  println(Serial.list());
  String portName = Serial.list()[2];
  if (bUseArduino) myPort = new Serial(this, "/dev/tty.usbmodem1411", 9600 );
  if (bUseArduino) myPort.bufferUntil(lf);


  /* start oscP5, listening for incoming messages at port 8000 */
  oscP5 = new OscP5(this, 8000);
  myRemoteLocation = new NetAddress(oscListenToAdress, 8000);


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
  plotterA0=new Plotter(50, -50);
  plotterA1=new Plotter(50, -50);
  plotterA2=new Plotter();

  //println("+++++++++rightTriggerVal++++++++++++"+rightTriggerVal);
  //println("+++++++++++leftTriggerVal++++++++++"+leftTriggerVal);

  //------------------------- SETTINGS ----------------------------------

  //  loadSettings(myRemoteLocation);

  //------------------------- SOUND ----------------------------------
  minim = new Minim(this);
  ambisound = minim.loadFile("sounds/Ambiet Moonlander.mp3");
  ambisound.setGain(AMBIMUTE);
  ambisound.loop();  
  player1boostsound = minim.loadSample("sounds/Boost gekürzt.mp3");
  player1boostsound.setBalance(player1balance);
  player2boostsound = minim.loadSample("sounds/Boost gekürzt.mp3");
  player2boostsound.setBalance(player2balance);

  hitsound = minim.loadSample("sounds/Hit.mp3", 512);
  countdownsound = minim.loadFile("sounds/Countdown.mp3");
  liftoff = minim.loadFile("sounds/Startliftoff.mp3");
  landed=minim.loadFile("sounds/Landing Plattform_short.mp3");
  shield=minim.loadSample("sounds/Schild aufladen.mp3");

  player1sideboost=minim.loadSample("sounds/Seiten Boost.mp3");
  player1sideboost.setBalance(player1balance);
  player1sideboost.setGain(-5);

  player2sideboost=minim.loadSample("sounds/Seiten Boost.mp3");
  player2sideboost.setBalance(player2balance);
  player2sideboost.setGain(-5);
  hitground=minim.loadSample("sounds/Hit stone.mp3");
  hitground.setGain(5);



  winPlayer1=loadImage("grafik/win_red.png");
  winPlayer2=loadImage("grafik/win_white.png");

  //------------------------- GAMEHANDLER ----------------------------------
  gamestate=STARTSCREEN;

  tramplinValuesPlayer1 = new FloatList();
  tramplinValuesPlayer2 = new FloatList();

  player1Thrustbuffer= new FloatList();
  countdown.setup();
}

void draw() {
  background(0);
  rectMode(CENTER);
  // renderDynamicBackground();

  // -------------- Render Background ----------
  image(combinedbackground, 0, 0);
  image(test_landscape, 0, 0);

  if (player1EnergyToAdd>0) {
    player1.loadShield(player1EnergyToAdd/5);
    player1EnergyToAdd=0;
  }


  if (player2EnergyToAdd>0) {
    player2.loadShield(player2EnergyToAdd/5);
    player2EnergyToAdd=0;
  }


  if (bUseArduino) {
    lerpdPlayer1Steerval=lerp(lerpdPlayer1Steerval, player1Steerval, lerpval);

    if (lerpdPlayer1Steerval-player1SteerCalibration<player1leftTriggerVal) {
      player1.setLeftThrust(true, -SIDETHRUST);
    } else {
      player1.setLeftThrust(false);
    }
    if (lerpdPlayer1Steerval-player1SteerCalibration>player1rightTriggerVal) {
      player1.setRightThrust(true, SIDETHRUST);
    } else {
      player1.setRightThrust(false);
    }


    lerpdPlayer2Steerval=lerp(lerpdPlayer2Steerval, player2Steerval, lerpval);

    if (lerpdPlayer2Steerval-player2SteerCalibration<player2leftTriggerVal) {
      player2.setLeftThrust(true, -SIDETHRUST);
    } else {
      player2.setLeftThrust(false);
    }
    if (lerpdPlayer2Steerval-player2SteerCalibration>player2rightTriggerVal) {
      player2.setRightThrust(true, SIDETHRUST);
    } else {
      player2.setRightThrust(false);
    }



    float tempval=0;
    //  val1=player1Trampolinval;
    // look for maximum
    if (tramplinValuesPlayer1.size()>2) {
      float Tval1=tramplinValuesPlayer1.get(tramplinValuesPlayer1.size()-2);
      float Tval2=tramplinValuesPlayer1.get(tramplinValuesPlayer1.size()-1);
      if (Tval2>Tval1 && player1Trampolinval<Tval2 &&Tval2>THRUSTFORCETTRIGGER1) {
        tempval=Tval2;
        player1peak=Tval2;
      }
    }
    tramplinValuesPlayer1.append(player1Trampolinval);
    //val2=tempval;
    player1TrampolThrust=tempval;
    if (player1TrampolThrust>THRUSTFORCETTRIGGER1) {
      player1.setThrust(true, int(getThrustForceLevel(player1TrampolThrust)));
    }
    if (tramplinValuesPlayer1.size()>3)tramplinValuesPlayer1.remove(0); // keep the list short...




    float tempval2=0;
    //  val1=player1Trampolinval;
    // look for maximum
    if (tramplinValuesPlayer2.size()>2) {
      float Tval1=tramplinValuesPlayer2.get(tramplinValuesPlayer2.size()-2);
      float Tval2=tramplinValuesPlayer2.get(tramplinValuesPlayer2.size()-1);
      if (Tval2>Tval1 && player2Trampolinval<Tval2 &&Tval2>THRUSTFORCETTRIGGER1) {
        tempval2=Tval2;
        player2peak=Tval2;
      }
    }
    tramplinValuesPlayer2.append(player2Trampolinval);
    //val2=tempval;
    player2TrampolThrust=tempval2;
    if (player2TrampolThrust>THRUSTFORCETTRIGGER1) {
      player2.setThrust(true, int(getThrustForceLevel(player2TrampolThrust)));
    }
    if (tramplinValuesPlayer2.size()>3)tramplinValuesPlayer2.remove(0); // keep the list short...
  }


  plattform.render();

  // -------------- Main Render Stuff  ----------
  gameStateRenderHandler();

  float rand=random(-10, 10);
  // val1=rand;
  plotterHandler();

  textSize(20);
  fill(255);
  text(frameRate, 20, 50);


  /*
  OscMessage myMessage = new OscMessage("/2/lerpdPlayer1Steerval");
   myMessage.add(player1Steerval); 
   oscP5.send(myMessage, myRemoteLocation);
   */  //myMessage = new OscMessage("/2/mappedPlayer1Steerval");
  //myMessage.add(player1Steerval); 
  //oscP5.send(myMessage, myRemoteLocation);


  /* lerpdPlayer1Steerval=lerp(lerpdPlayer1Steerval, player1Steerval, player1SteerLerpFact);
   myMessage = new OscMessage("/2/lerpdPlayer2Steerval");
   myMessage.add(lerpdPlayer2Steerval); /* add an int to the osc message */
  /* oscP5.send(myMessage, myRemoteLocation);
   myMessage = new OscMessage("/2/mappedPlayer2Steerval");
   myMessage.add(mappedPlayer2Steerval); /* add an int to the osc message */
  /*oscP5.send(myMessage, myRemoteLocation);*/
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


    //  GET SHIELD STUFF PLAYER 1
    player1Buttonval=int(sensordata[0]);
    if (player1Buttonval==1) {
      player1.setShieldActive(true);
    }
    int player1Shieldvaltemp=int(sensordata[1]);
    int player1Shieldvaldiff=player1Shieldvaltemp-player1Shieldval;
    player1Shieldval =player1Shieldvaltemp;
    player1EnergyToAdd=player1Shieldvaldiff;


    // STEERING
    rawSteerSensorDataPlayer1 =float(sensordata[2]);
    //  player1Steerval=rawSteerSensorDataPlayer1-player1SteerCalibration;
    //  player1Steerval = player1Steerval - player1Steerval%0.01;
    player1Steerval=rawSteerSensorDataPlayer1;

    // Trampolin
    player1RawTrampolinData =float(sensordata[3]);
    player1Trampolinval=player1RawTrampolinData-player1TrampolinCalibration;


    //  GET SHIELD STUFF PLAYER 1
    player2Buttonval=int(sensordata[4]);
    if (player2Buttonval==1) {
      player2.setShieldActive(true);
    }
    int player2Shieldvaltemp=int(sensordata[5]);
    int player2Shieldvaldiff=player2Shieldvaltemp-player2Shieldval;
    player2Shieldval =player2Shieldvaltemp;
    player2EnergyToAdd=player2Shieldvaldiff;


    // STEERING
    rawSteerSensorDataPlayer2 =float(sensordata[6]);
    //  player1Steerval=rawSteerSensorDataPlayer1-player1SteerCalibration;
    //  player1Steerval = player1Steerval - player1Steerval%0.01;
    player2Steerval=rawSteerSensorDataPlayer2;

    // Trampolin
    player2RawTrampolinData =float(sensordata[7]);
    player2Trampolinval=player2RawTrampolinData-player2TrampolinCalibration;
  } 
  catch (Exception e) {
    println("Initialization exception");
  }
}

int getThrustForceLevel(float _thrustforce) {
  /*
  int thrustforce;
   float cdist=10000;
   int index=0;
   for (int i=0; i<thrustforcearray.length; i++) {
   float d=abs(thrustforcearray[i][0]-_thrustforce);
   //println(d+" "+cdist);
   if (d<cdist) {
   cdist=d;
   index=i;
   }
   }
   thrustforce=(int)thrustforcearray[index][1];
   return  thrustforce;*/

  int tempthrustforce=0;
  for (int i=0; i<thrustforcearray.length; i++) {
    if (_thrustforce>thrustforcearray[i][0]) {
      tempthrustforce=(int)thrustforcearray[i][1];
    }
  }
  return  tempthrustforce;
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
    player1leftTriggerVal = val;
    OscMessage  myMessage = new OscMessage("/2/player1leftTriggerValLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player1rightTriggerVal")) { 
    player1rightTriggerVal = val;
    OscMessage  myMessage = new OscMessage("/2/player1rightTriggerValLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player2mapInMin")) { 
    player2mapInMin = val;
    OscMessage  myMessage = new OscMessage("/2/player2mapInMinLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player2mapInMax")) { 
    player2mapInMax = val;
    OscMessage  myMessage = new OscMessage("/2/player2mapInMaxLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player2mapOutMin")) { 
    player2mapOutMin = val;
    OscMessage  myMessage = new OscMessage("/2/player2mapOutMinLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player2mapOutMax")) { 
    player2mapOutMax = val;
    OscMessage  myMessage = new OscMessage("/2/player2mapOutMaxLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player2leftTriggerVal")) { 
    player2leftTriggerVal = val;
    OscMessage  myMessage = new OscMessage("/2/player2leftTriggerValLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/2/player2rightTriggerVal")) { 
    player2rightTriggerVal = val;
    OscMessage  myMessage = new OscMessage("/2/player2rightTriggerValLabel");
    myMessage.add(val);
    oscP5.send(myMessage, myRemoteLocation);
  } else if (addr.equals("/3/load")) { 
    println("LOAD All SETTINGS");
    loadAllSettings(myRemoteLocation);
  } else if (addr.equals("/2/loadSteeringSettings")) { 
    println("LOAD Steering SETTINGS");
    loadSteeringSettings(myRemoteLocation);
  } else if (addr.equals("/1/loadWorldSettings")) { 
    println("LOAD World SETTINGS");
    loadWorldSettings(myRemoteLocation);
  } else if (addr.equals("/3/save")) { 
    saveAllSettings();
  } else if (addr.equals("/2/saveSteeringSettings")) { 
    saveSteeringSettings();
  } else if (addr.equals("/3/saveWorldSettings")) { 
    saveWorldSettings();
  } else if (addr.equals("/3/countdownbutton")) { 
    changeGameState(COUNTDOWN);
  } else if (addr.equals("/3/startbutton")) { 
    changeGameState(PLAYING);
  } else if (addr.equals("/3/resetbutton")) { 
    reset();
  } else if (addr.equals("/2/player1Calibrate")) { 
    calibrateSteeringPlayer1();
  } else if (addr.equals("/2/player2Calibrate")) { 
    calibrateSteeringPlayer2();
  } else if (addr.equals("/3/calibrateTrampolin")) { 
    calibrateAllTrampolin();
  } else if (addr.equals("/3/calibrateSteering")) { 
    calibrateAllSteering();
  }
}

void loadWorldSettings(NetAddress _myRemoteLocation) {
  worldsettings = loadJSONObject("settings.json");

  delay(20);
  println("load world settings");

  //world
  GRAVITY = worldsettings.getFloat("Gravity");
  RESTITUTION = worldsettings.getFloat("Restitution");
  DAMPING = worldsettings.getFloat("Damping");

  //vessel
  DENSITY = worldsettings.getFloat("Density");
  MAXSPEED = worldsettings.getFloat("Maxspeed");
  IMPULSE = worldsettings.getFloat("Impulse");
  MAXTHRUSTFORCE = worldsettings.getFloat("Maxthrustforce");

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
  myMessage = new OscMessage("/1/maxspeedlabel");
  myMessage.add(MAXSPEED); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/1/maxspeed");
  myMessage.add(MAXSPEED); 
  oscP5.send(myMessage, _myRemoteLocation);
}

void loadSteeringSettings(NetAddress _myRemoteLocation) {
  println("load steering settings");

  steeringsettings = loadJSONObject("steeringsettings.json");

  delay(20);
  //println("load steering settings");

  player1leftTriggerVal=steeringsettings.getFloat("player1leftTriggerVal");
  player1rightTriggerVal=steeringsettings.getFloat("player1rightTriggerVal");
  player1mapInMin= steeringsettings.getFloat("player1mapInMin");
  player1mapInMax=steeringsettings.getFloat("player1mapInMax");
  player1mapOutMin =steeringsettings.getFloat("player1mapOutMin");
  player1mapOutMax=steeringsettings.getFloat("player1mapOutMax");
  player1SteerCalibration=steeringsettings.getFloat("player1SteerCalibration");

  player1TrampolinCalibration=steeringsettings.getFloat("player1TrampolinCalibration");


  player2leftTriggerVal=steeringsettings.getFloat("player2leftTriggerVal");
  player2rightTriggerVal=steeringsettings.getFloat("player2rightTriggerVal");
  player2mapInMin= steeringsettings.getFloat("player2mapInMin");
  player2mapInMax=steeringsettings.getFloat("player2mapInMax");
  player2mapOutMin =steeringsettings.getFloat("player2mapOutMin");
  player2mapOutMax=steeringsettings.getFloat("player2mapOutMax");
  player2SteerCalibration=steeringsettings.getFloat("player2SteerCalibration");

  player2TrampolinCalibration=steeringsettings.getFloat("player2TrampolinCalibration");



  OscMessage myMessage = new OscMessage("/2/player1mapInMin");
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
  myMessage.add(player2mapInMin); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2mapInMinLabel");
  myMessage.add(player2mapInMin); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2mapInMax");
  myMessage.add(player2mapInMax); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2mapInMaxLabel");
  myMessage.add(player2mapInMax); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2mapOutMin");
  myMessage.add(player2mapOutMin); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2mapOutMinLabel");
  myMessage.add(player2mapOutMin); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2mapOutMax");
  myMessage.add(player2mapOutMax); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2mapOutMaxLabel");
  myMessage.add(player2mapOutMax); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2leftTriggerVal");
  myMessage.add(player2leftTriggerVal); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2leftTriggerValLabel");
  myMessage.add(player2leftTriggerVal); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2rightTriggerVal");
  myMessage.add(player2rightTriggerVal); 
  oscP5.send(myMessage, _myRemoteLocation);
  myMessage = new OscMessage("/2/player2rightTriggerValLabel");
  myMessage.add(player2rightTriggerVal); 
  oscP5.send(myMessage, _myRemoteLocation);

  myMessage = new OscMessage("/2/player1SteerCalibration");
  myMessage.add(player1SteerCalibration); 
  oscP5.send(myMessage, _myRemoteLocation);

  myMessage = new OscMessage("/2/player2SteerCalibration");
  myMessage.add(player2SteerCalibration); 
  oscP5.send(myMessage, _myRemoteLocation);
}



void saveWorldSettings() {
  JSONObject parameters = new JSONObject();
  parameters.setFloat("Gravity", GRAVITY);
  parameters.setFloat("Restitution", RESTITUTION);
  parameters.setFloat("Damping", DAMPING);
  parameters.setFloat("Density", DENSITY);
  parameters.setFloat("Maxspeed", MAXSPEED);
  parameters.setFloat("Impulse", IMPULSE);
  parameters.setFloat("Maxthrustforce", MAXTHRUSTFORCE);

  /*parameters.setFloat("player1leftTriggerVal", player1leftTriggerVal);
   parameters.setFloat("player1rightTriggerVal", player1rightTriggerVal);
   parameters.setFloat("player1mapInMin", player1mapInMin);
   parameters.setFloat("player1mapInMax", player1mapInMax);
   parameters.setFloat("player1mapOutMin", player1mapOutMin);
   parameters.setFloat("player1mapOutMax", player1mapOutMax);
   parameters.setFloat("player1SteerCalibration", player1SteerCalibration);
   
   parameters.setFloat("player1leftTriggerVal", player2leftTriggerVal);
   parameters.setFloat("player1rightTriggerVal", player2rightTriggerVal);
   parameters.setFloat("player1mapInMin", player2mapInMin);
   parameters.setFloat("player1mapInMax", player2mapInMax);
   parameters.setFloat("player1mapOutMin", player2mapOutMin);
   parameters.setFloat("player1mapOutMax", player2mapOutMax);
   parameters.setFloat("player2SteerCalibration", player2SteerCalibration);
   */
  saveJSONObject(parameters, "data/settings.json");
}

void saveSteeringSettings() {
  println("SAVE STEERING");
  JSONObject parameters = new JSONObject();
  parameters.setFloat("player1leftTriggerVal", player1leftTriggerVal);
  parameters.setFloat("player1rightTriggerVal", player1rightTriggerVal);
  parameters.setFloat("player1mapInMin", player1mapInMin);
  parameters.setFloat("player1mapInMax", player1mapInMax);
  parameters.setFloat("player1mapOutMin", player1mapOutMin);
  parameters.setFloat("player1mapOutMax", player1mapOutMax);
  parameters.setFloat("player1SteerCalibration", player1SteerCalibration);
  parameters.setFloat("player1TrampolinCalibration", player1TrampolinCalibration);


  parameters.setFloat("player2leftTriggerVal", player2leftTriggerVal);
  parameters.setFloat("player2rightTriggerVal", player2rightTriggerVal);
  parameters.setFloat("player2mapInMin", player2mapInMin);
  parameters.setFloat("player2mapInMax", player2mapInMax);
  parameters.setFloat("player2mapOutMin", player2mapOutMin);
  parameters.setFloat("player2mapOutMax", player2mapOutMax);
  parameters.setFloat("player2SteerCalibration", player2SteerCalibration);
  parameters.setFloat("player2TrampolinCalibration", player2TrampolinCalibration);

  saveJSONObject(parameters, "data/steeringsettings.json");
}


void loadAllSettings(NetAddress _myRemoteLocation) {
  loadWorldSettings( _myRemoteLocation);
  loadSteeringSettings( _myRemoteLocation);
}

void saveAllSettings() {
  saveWorldSettings();
  saveSteeringSettings();
}

void reset() {
  player1.reset();
  player2.reset();
  changeGameState(STARTSCREEN);
}

void calibrateSteeringPlayer1() {
  player1SteerCalibration=rawSteerSensorDataPlayer1;
  OscMessage myMessage = new OscMessage("/2/player1SteerCalibration");
  myMessage.add(player1SteerCalibration); 
  oscP5.send(myMessage, myRemoteLocation);
}

void calibrateSteeringPlayer2() {
  player2SteerCalibration=player2Steerval;
  OscMessage myMessage = new OscMessage("/2/player2SteerCalibration");
  myMessage.add(player1SteerCalibration); 
  oscP5.send(myMessage, myRemoteLocation);
}

void calibrateTrampoilnPlayer1() {
  player1TrampolinCalibration=player1RawTrampolinData;
}

void calibrateTrampoilnPlayer2() {
  player2TrampolinCalibration=player2RawTrampolinData;
}

void calibrateAllTrampolin() {
  calibrateTrampoilnPlayer1() ;
  calibrateTrampoilnPlayer2() ;
}

void calibrateAllSteering() {
  calibrateSteeringPlayer1();
  calibrateSteeringPlayer2();
}
