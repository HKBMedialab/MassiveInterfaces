
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



// GAMESTATES
final int STARTSCREEN=98;
final int COUNTDOWN =99;
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
float lerpval=0.3;

float lerpdval1=0;
float lerpdval2=0;      // Data received from the serial port
float lerpdval3=0;      // Data received from the serial port

float leftTriggerVal=200;
float rightTriggerVal=500;







// Arduino 
Serial myPort;  // Create object from Serial class
float val;      // Data received from the serial port
String inString="";  // Input string from serial port
int lf = 10;      // ASCII linefeed 
int [] mysensors= new int[2];
boolean bUseArduino=false;



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


  case 'c':
    changeGameState(COUNTDOWN);
    break;
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