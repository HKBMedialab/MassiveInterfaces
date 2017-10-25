class Player {
  PVector position=new PVector(50, 50);
  PVector velocity=new PVector(0, 0);
  PVector acceleration=new PVector(0, 0);
  float angle=PI/2;
  float drag=0.999;
  float heading=0;
  float maxspeed=5;
  color mycolor=color(255, 50, 50);
  boolean thrust=false;
  float fuel=1000;
  float maxFuel=1000;
  float thrustforce=0.25;

  Player() {
  }

  void update() {
    steer();
    acceleration.set(0, 0, 0);
    if (thrust && fuel>0)thrust();
  }

  void render() {
    colorMode(HSB);

    pushStyle();
    noStroke();
    rectMode(CENTER);
    pushMatrix();
    
    translate(position.x, position.y);
    scale(0.8);
    rotate(heading);
    fill(hue(mycolor), 255, 255);
    rect(0, 0, 16, 60);


    fill(hue(mycolor), 255, 230);

    triangle(-8, -30, 8, -30, 0, -45 );
    fill(hue(mycolor), 255, 200);

    triangle(-20, 35, -8, 30, -8, 0 );
    triangle(20, 35, 8, 30, 8, 0 );

    if (thrust && fuel>0) {
      pushStyle();
      fill(#FAC903);
      triangle(-8, 34, 8, 34, 0, 60 );
      popStyle();
    }

    popMatrix();
    popStyle();
  }


  void steer() {
    velocity.add(acceleration);
    velocity.mult(drag);
    velocity.limit(maxspeed);
    position.add(velocity);
  }

  void applyForce(PVector force) {
    PVector f=force.get();
    acceleration.add(f);
  }


  void applyGravity(PVector pos, float force) {
    PVector p=pos.get();
    PVector pp=position.get();
    p.sub(pp);
    p.normalize();
    p.setMag(force);
    applyForce(p);
  }

  void thrust() {
    fuel--;
    float angle = heading-PI/2;
    PVector force = new PVector(cos(angle), sin(angle));
    force.normalize();
    force.setMag(thrustforce);
    applyForce(force);
  }


  void turn(String direction) {
    if (direction=="right") {
      heading+=0.3;
      println(heading);
    } else if (direction=="left") {
      heading-=0.3;
    } else if (direction=="straight") {
      heading-=0;
    }
  }

  void setAngle(float ang) {
    heading=ang;
  }
}