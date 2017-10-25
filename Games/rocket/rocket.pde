
Player player;
GravityField gravityfield;


void setup() {
  size(1500, 1000);
  player=new Player();
  gravityfield=new GravityField();
}

void draw() {
  background(0);
  gravityfield.update();
  gravityfield.render();


  if (gravityfield.isInside(player.position.get())) {
    player.mycolor=color(255, 0, 0);
    player.applyGravity(gravityfield.position, 0.05);
  } else {
    player.mycolor=color(0, 255, 0);
  }
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