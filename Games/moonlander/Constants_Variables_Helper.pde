//OSCADRESS
//String oscListenToAdress="147.87.39.19"; // ipad Adress
//String oscListenToAdress="172.20.10.2"; // ipad Adress
String oscListenToAdress="169.254.218.141"; // ipad Adress




// WORLD
float GRAVITY = 180;
float RESTITUTION=1.2;//1.2;
float DAMPING = 1;


// SPACESHIP
float DENSITY = 0.25;
float MAXSPEED=100;
float IMPULSE=7;
float MAXTHRUSTFORCE=8;

int THRUSTFORCE1=1000;
int THRUSTFORCE2=5000;
int THRUSTFORCE3=10000;
int THRUSTFORCE4=30000;

int THRUSTFORCETTRIGGER1=100;
int THRUSTFORCETTRIGGER2=150;
int THRUSTFORCETTRIGGER3=290;
int THRUSTFORCETTRIGGER4=500;

int thrustforcearray[][]={{THRUSTFORCETTRIGGER1, THRUSTFORCE1}, {THRUSTFORCETTRIGGER2, THRUSTFORCE2}, {THRUSTFORCETTRIGGER3, THRUSTFORCE3}, {THRUSTFORCETTRIGGER4, THRUSTFORCE4}};



int THRUSTFORCETTRIGGER1P2=80;
int THRUSTFORCETTRIGGER2P2=130;
int THRUSTFORCETTRIGGER3P2=230;
int THRUSTFORCETTRIGGER4P2=500;

int thrustforcearrayP2[][]={{THRUSTFORCETTRIGGER1P2, THRUSTFORCE1}, {THRUSTFORCETTRIGGER2P2, THRUSTFORCE2}, {THRUSTFORCETTRIGGER3P2, THRUSTFORCE3}, {THRUSTFORCETTRIGGER4P2, THRUSTFORCE4}};









int SIDETHRUST=3000;

//PLATTFORM
final int PLATTFORMWIDTH=130;

final int MAXLANDSPEED=50;
final float MAXENERGY=200;




// GAMESTATES
final int STARTSCREEN=98;
final int COUNTDOWN =99;
final int PLAYING = 100;
final int LANDED = 101;
final int CRASHED = 102;


// VOLUMES
final float AMBIMAX=-8f;
final float AMBIMUTE=-17f;
final float LIFTOFFMAX=10;
final float LIFTOFFMUTE=-5;







int player1balance=5;
int player2balance=-5;


// SENSORVALUES
/*
public float trampolinval = 0;
 public float steerval = 0;
 public float rightSteer=235;
 public float leftSteer=270;
 public  float scaledInval=0;
 public float trampolinscalemin = 1;//7;
 public float trampolinscalemax = 12;//198;
 float minVal=400;
 float maxVal=0;
 
 
 float incomingThrustBefore=0;*/

// Plotter Vars
Plotter plotterA0; 
Plotter plotterA1; 
Plotter plotterA2; 
boolean renderPlotter=false;

// style
float pH=255;


float val1=0;
float val2=0;      // Data received from the serial port
float val3=0;      // Data received from the serial port
float lerpval=0.6;

/*
float lerpdval1=0;
 float lerpdval2=0;      // Data received from the serial port
 float lerpdval3=0;      // Data received from the serial port
 
 float leftTriggerVal=200;
 float rightTriggerVal=500;
 
 */

// STEERING
float rawSteerSensorDataPlayer1=0; // Raw Data from Sensor
float player1SteerCalibration=10; // calibrate Position to get values smaller and bigger than 0
float player1Steerval=0; // value for the steerdiff from 0; Actual steering! 

// Shield
int player1Shieldval; // position of rotary encoder
int player1EnergyToAdd=0; // buffer for rotary encoder, cant add energy outside the update cycle as arraylist crashes
float player1Buttonval; // shieldbutton

FloatList tramplinValuesPlayer1; // value buffer to find maximum
float player1Trampolinval=0;
float player1RawTrampolinData=0;
float player1TrampolinCalibration=286;
float player1TrampolThrust=0;
float player1peak=0;

FloatList player1Thrustbuffer; // value buffer to find maximum


// Temp and map stuff. not sure if still needed...

float lerpdPlayer1Steerval=0;
float mappedPlayer1Steerval=0;
float player1SteerLerpFact=0.9;
float player1leftTriggerVal=-2;
float player1rightTriggerVal=2;
float player1mapInMin= 0;
float player1mapInMax=20;
float player1mapOutMin =0;
float player1mapOutMax=5;



// STEERING
float rawSteerSensorDataPlayer2=0; // Raw Data from Sensor
float player2SteerCalibration=8; // calibrate Position to get values smaller and bigger than 0
float player2Steerval=0; // value for the steerdiff from 0; Actual steering! 

// Shield
int player2Shieldval; // position of rotary encoder
int player2EnergyToAdd=0; // buffer for rotary encoder, cant add energy outside the update cycle as arraylist crashes
float player2Buttonval; // shieldbutton

FloatList tramplinValuesPlayer2; // value buffer to find maximum
float player2Trampolinval=0;
float player2RawTrampolinData=0;
float player2TrampolinCalibration=286;
float player2TrampolThrust=0;
float player2peak=0;


float lerpdPlayer2Steerval=0;
float mappedPlayer2Steerval=0;
float player2SteerLerpFact=0.05;
float player2leftTriggerVal=-2;
float player2rightTriggerVal=2;
float player2mapInMin= 0;
float player2mapInMax=100;
float player2mapOutMin =0;
float player2mapOutMax=100;


// Arduino 
Serial myPort;  // Create object from Serial class
float val;      // Data received from the serial port
String inString="";  // Input string from serial port
int lf = 10;      // ASCII linefeed 
int [] mysensors= new int[2];
boolean bUseArduino=true;



//------------------------- BACKGROUND ----------------------------------
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

PGraphics combinedbackground;


PImage winPlayer1;
PImage winPlayer2;
float winnerrotation=0;
float winnerscale=0;

PImage frontType;

CustomShape winner;

void bakeBackground() {
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
}

void renderDynamicBackground() {
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
  /*planet1.add(planet1_speed);
   if (planet1.x>width)planet1.x=-background_1_planet1.width;
   planet2.add(planet2_speed);
   if (planet2.x>width)planet1.x=-background_2_planet2.width;
   planet3.add(planet3_speed);
   if (planet3.x>width)planet1.x=-background_3_planet3.width;
   
   */
}

//------------------------- Plotter ----------------------------------

void plotterHandler() {
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

  if (renderPlotter) {
    plotterA0.addValue(val1);
    plotterA0.update();

    plotterA1.addValue(val2);
    plotterA1.update();

    plotterA2.addValue(val3);
    plotterA2.update();
  }

  if (renderPlotter) {
    float mplayer1leftTriggerVal=map(player1leftTriggerVal, 0, 10, 0, pH);
    float mplayer1rightTriggerVal=map(player1rightTriggerVal, 0, 10, 0, pH);

    textSize(20);
    colorMode(RGB);
    rectMode(CORNER);
    blendMode(BLEND);
    pushMatrix();
    translate(0, 0);
    fill(255, 0, 0, 100);
    rect(0, 0, width, pH);
    stroke(255, 0, 0, 200);
    //  line(0, mplayer1leftTriggerVal, width, mplayer1leftTriggerVal);
    stroke(0, 0, 255, 200);
    //line(0, mplayer1rightTriggerVal, width, mplayer1rightTriggerVal);

    stroke(255, 0, 255, 200);



    int scale=500;
    float mplayer1trigger=map(THRUSTFORCETTRIGGER1, -scale, scale, 0, pH);
    line(0, mplayer1trigger, width, mplayer1trigger);
    mplayer1trigger=map(THRUSTFORCETTRIGGER2, -scale, scale, 0, pH);
    line(0, mplayer1trigger, width, mplayer1trigger); 
    mplayer1trigger=map(THRUSTFORCETTRIGGER3, -scale, scale, 0, pH);
    line(0, mplayer1trigger, width, mplayer1trigger); 
    mplayer1trigger=map(THRUSTFORCETTRIGGER4, -scale, scale, 0, pH);
    line(0, mplayer1trigger, width, mplayer1trigger);



    plotterA0.plott(-scale, scale, 0, pH);


    float myline=map(500, 0, 1000, 0, pH);


    translate(0, pH);
    fill(0, 255, 0, 100);
    rect(0, 0, width, pH);
    stroke(255, 0, 0, 200);
    line(0, myline, width, myline);
    stroke(0, 0, 255, 200);

    /*
     myline=map(1000, 0, 1000, 0, pH);
     line(0, myline, width, myline);
     myline=map(3000, 0, 1000, 0, pH);
     line(0, myline, width, myline);
     */
    mplayer1trigger=map(THRUSTFORCETTRIGGER1, -scale, scale, 0, pH);
    line(0, mplayer1trigger, width, mplayer1trigger);
    mplayer1trigger=map(THRUSTFORCETTRIGGER2, -scale, scale, 0, pH);
    line(0, mplayer1trigger, width, mplayer1trigger); 
    mplayer1trigger=map(THRUSTFORCETTRIGGER3, -scale, scale, 0, pH);
    line(0, mplayer1trigger, width, mplayer1trigger); 
    mplayer1trigger=map(THRUSTFORCETTRIGGER4, -scale, scale, 0, pH);
    line(0, mplayer1trigger, width, mplayer1trigger);

    plotterA1.plott(-scale, scale, 0, pH);
    /*
     translate(0, pH);
     fill(0, 0, 255, 100);
     rect(0, 0, width, pH);
     stroke(255, 0, 0, 100);
     line(0, mleftTriggerVal, width, mleftTriggerVal);
     stroke(0, 0, 255, 100);
     line(0, mrightTriggerVal, width, mrightTriggerVal);
     plotterA2.plott(0, 600, 0, pH);*/
    popMatrix();
    //colorMode(HSB);
    rectMode(CENTER);
  }
}


//------------------------- OSC ----------------------------------

void setTocuosc(NetAddress _remoteLocation, String adress, float value) {
  OscMessage myMessage = new OscMessage("/1/gravlabel");
  myMessage.add(GRAVITY); /* add an int to the osc message */
  /* send the message */
  oscP5.send(myMessage, myRemoteLocation);
}


void keyTyped() {
  println(key);
  switch(key) {
case'v':
hitground.trigger();

break;

  case ' ':
    player1.debug= !player1.debug;
    player2.debug= !player2.debug;

    break;

  case 'c':
    player1.reset();
    player2.reset();
    changeGameState(COUNTDOWN);
    break;

  case 's':
    player1.setShieldActive(true);
    break;

  case 'S':
    saveAllSettings();
    break;


  case 'y':
    player1.loadShield(5);
    break;

  case 'p':
    changeGameState(PLAYING);
    break;

  case 'w':
    player1.setThrust(true, 5000);
    break;

  case 'a':
    player1.setLeftThrust(true, -SIDETHRUST);
    break;

  case 'd':
    player1.setRightThrust(true, SIDETHRUST);
    break;

  case 'k':
    player2.setShieldActive(true);
    break;

  case 'i':
    player2.setThrust(true, 5000);
    break;

  case 'j':
    player2.setLeftThrust(true, -SIDETHRUST);
    break;

  case 'l':
    player2.setRightThrust(true, SIDETHRUST);
    break;


 case 'L':
    loadWorldSettings();
    loadSteeringSettings();  
    break;


  case 't':
    // calibrateTrampoilnPlayer1();
    calibrateAllTrampolin();
    break;

  case '0':
    //calibrateSteeringPlayer1();
    calibrateAllSteering();
    break;


  case '1':
    player1.setThrust(true, getThrustForceLevel(51));
    break;
  case '2':
    player1.setThrust(true, getThrustForceLevel(151));
    break;
  case '3':
    player1.setThrust(true, getThrustForceLevel(251));
    break;
  case '4':
    player1.setThrust(true, getThrustForceLevel(301));
    break;
  case 'r':
    reset();
    break;


  case 'g':
    changeGameState(LANDED);
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
  float var=mapPow(0.9, mouseX, 0, width, 0, 10000);
  println("Mouse "+mouseX+" "+var);
  player1.setThrust(true, int(var));

  // CustomShape cs = new CustomShape(mouseX, mouseY);
  // polygons.add(cs);
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
