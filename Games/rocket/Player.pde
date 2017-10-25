class Player {
  PVector position=new PVector(0, 0);
  PVector velocity=new PVector(0, 0);
  PVector acceleration=new PVector(0, 0);
  float angle=PI/2;
  float drag=0.995;
  float heading=0;
  float maxspeed=3;
  color mycolor=color(0, 255, 0);
  boolean thrust=false;

  Player() {
  }

  void update() {
    steer();
    acceleration.set(0, 0, 0);
    if (thrust)thrust();
  }

  void render() {
    pushStyle();
    noStroke();
    rectMode(CENTER);
    pushMatrix();
    translate(position.x, position.y);
    rotate(heading);
    rect(0, 0, 50, 20);
    popMatrix();
    popStyle();



    stroke(0);
    fill(mycolor);
    pushMatrix();
    translate(position.x, position.y);
    rotate(heading);
    triangle(-10, 10, 10, 10, 0, -30 );
    rectMode(CENTER);

    if (thrust) {
      pushStyle();
      fill(#FAC903);
      triangle(-10, 10, 10, 10, 0, 30 );
      popStyle();
    }

    popMatrix();
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
    float angle = heading-PI/2;
    PVector force = new PVector(cos(angle), sin(angle));
    force.normalize();
    //force.mult(0.1);
    force.setMag(0.15);

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
}