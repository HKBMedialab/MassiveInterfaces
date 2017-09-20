PVector carpos;
int steeringamt=15;

float[] backgroundpositions = new float[20];
int backgroundrectheight=80;
int speed=3;

//road
float[] middledashpositions = new float[20];
float middledashheight=20;
float middledashdist=10;

//donkey
PVector[] donkeypositions = new PVector[3];
int donkeywidth=30;
int donkeyheight=15;



boolean pause=false;


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


  for (int i=0; i<donkeypositions.length; i++ ) {
    donkeypositions[i]=new PVector(random(width/2-50, width/2+50), random(-500, 0));
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

  //draw middledash
  for (int i=0; i<middledashpositions.length; i++ ) {
    fill(255);
    noStroke();
    rect(width/2, middledashpositions[i], 10, middledashheight);
  }

  //draw donkey
  for (int i=0; i<donkeypositions.length; i++ ) {
    fill(200);
    noStroke();
    rect(donkeypositions[i].x, donkeypositions[i].y, donkeywidth, donkeyheight);
  }

  //car
  fill(255, 0, 0);
  rect(carpos.x, carpos.y, 15, 25);

  hittest();

  if (!pause) {
    //move background
    for (int i=0; i<backgroundpositions.length; i++ ) {
      backgroundpositions[i]+=speed;
      if (backgroundpositions[i]>=height)backgroundpositions[i]=0;
    }

    for (int i=0; i<middledashpositions.length; i++ ) {
      middledashpositions[i]+=speed;
      if (middledashpositions[i]>=height)middledashpositions[i]=0;
    }


    for (int i=0; i<donkeypositions.length; i++ ) {
      donkeypositions[i].y+=speed;

      if (donkeypositions[i].y>=height) {
        donkeypositions[i].y=random(-500, 0);
        donkeypositions[i].x=random(width/2-80, width/2+80);
      }
    }
  }
}


void hittest() {
  for (int i=0; i<donkeypositions.length; i++ ) {
    if (carpos.x>donkeypositions[i].x && carpos.x<donkeypositions[i].x+donkeywidth && carpos.y>donkeypositions[i].y &&carpos.y<donkeypositions[i].y+donkeyheight) {
      pause=true;
    }
  }
}


void keyPressed() {

  if (keyCode == LEFT) {
    carpos.x-=steeringamt;
  }
  if (keyCode == RIGHT) {
    carpos.x+=steeringamt;
  }


  if (key == 'p') {
    pause=!pause;
  }
}