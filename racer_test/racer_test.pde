

PVector carpos;
int steeringamt=15;


float[] backgroundpositions = new float[20];
int backgroundrectheight=80;
int speed=5;


//road
float[] middledashpositions = new float[20];
float middledashheight=20;
float middledashdist=10;

void setup() {
  size(500, 500);
  carpos=new PVector(width/2, height/2);

  backgroundrectheight=height/backgroundpositions.length;
  for (int i=0; i<backgroundpositions.length; i++ ) {
    backgroundpositions[i]=backgroundrectheight*i;
  }

  float mpos=0;
  for (int i=0; i<middledashpositions.length; i++ ) {
    middledashpositions[i]=mpos;
    mpos+=middledashheight+middledashdist;
  }
}

void draw() {
  background(100, 200, 180);

  //draw background
  for (int i=0; i<backgroundpositions.length; i++ ) {
    if (i%2==0) {
      fill(100, 200, 180);
    } else {
      fill(100, 150, 100);
    };
    noStroke();
    rect(0, backgroundpositions[i], width, backgroundrectheight);
  }

  fill(50);
  rect(width/2-100, 0, 200, height);

  //draw background
  for (int i=0; i<middledashpositions.length; i++ ) {
    fill(255);
    noStroke();
    rect(width/2, middledashpositions[i], 10, middledashheight);
  }

  fill(255, 0, 0);
  //car
  rect(carpos.x, carpos.y, 10, 20);


  //move background
  for (int i=0; i<backgroundpositions.length; i++ ) {
    backgroundpositions[i]+=speed;
    if (backgroundpositions[i]>=height)backgroundpositions[i]=0;
  }

  for (int i=0; i<middledashpositions.length; i++ ) {
    middledashpositions[i]+=speed;
    if (middledashpositions[i]>=height)middledashpositions[i]=0;
  }
}


void keyPressed() {

  if (keyCode == LEFT) {
    carpos.x-=steeringamt;
  }
  if (keyCode == RIGHT) {
    carpos.x+=steeringamt;
  }
}