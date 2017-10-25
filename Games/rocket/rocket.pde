
Player player;
GravityField gravityfield;
//GravityField asteroid;
ArrayList<GravityField> moons = new ArrayList<GravityField>();

void setup() {
  size(1500, 1000);
  player=new Player();
  gravityfield=new GravityField(100, 300, 0.05, new PVector(width/2, height/2), color(0, 0, 255));
  //asteroid=new GravityField(10, 200, 0.05, new PVector(width/2-200, height/2-200), color(255, 0, 0), true, 0.01);

  GravityField moon=new GravityField(10, 200, 0.05, new PVector(width/2-200, height/2), color(255, 0, 0), true, 0.01);
  moons.add(moon);

  moon=new GravityField(10, 200, 0.08, new PVector(width/2-300, height/2), color(255, 200, 0), true, 0.001);
  moons.add(moon);
}

void draw() {
  background(0);
  gravityfield.update();
  gravityfield.render();
  //asteroid.update();
  //asteroid.render();

  for (int i = 0; i < moons.size(); i++) {
    GravityField m = moons.get(i);
    m.update();
  }

  for (int i = 0; i < moons.size(); i++) {
    GravityField m = moons.get(i);
    m.render();
  }


  for (int i = 0; i < moons.size(); i++) {
    GravityField m = moons.get(i);
    if (m.isInside(player.position.get())) {
      player.applyGravity(m.position, m.gravityForce);
    }
  }

  if (gravityfield.isInside(player.position.get())) {
    //  player.mycolor=color(255, 0, 0);
    player.applyGravity(gravityfield.position, gravityfield.gravityForce);
  } else {
    //player.mycolor=color(0, 255, 0);
  }

  /*
  if (asteroid.isInside(player.position.get())) {
   player.mycolor=color(255, 0, 0);
   player.applyGravity(asteroid.position, asteroid.gravityForce);
   } else {
   player.mycolor=color(0, 255, 0);
   }*/


  player.update();

  player.render();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      player.thrust();
    } else if (keyCode == RIGHT) {
      player.turn("right");
    } else if (keyCode == LEFT) {
      player.turn("left");
    } else {
      player.turn("straight");
    }
  }
  if (key==' ') {
    player.thrust=true;
  }
}

void keyReleased() {
  if (key==' ') {
    player.thrust=false;
  }
}