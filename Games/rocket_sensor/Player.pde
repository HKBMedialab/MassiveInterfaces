class Player {
  PVector position=new PVector(50, 50);
  PVector velocity=new PVector(0, 0);
  PVector acceleration=new PVector(0, 0);
  float angle=PI/2;
  float drag=0.99;
  float heading=0;
  float maxspeed=5;
  color mycolor=color(255, 50, 50);
  boolean thrust=false;
  float fuel=1000;
  float maxFuel=1000;
  float thrustforce=0.21;

  Player() {
  }

  void update() {
    // apply gravity stuff
    checkGravity();

    // check crashes
    if (checkCollisions()) {
      colorMode(RGB);
      mycolor=color(0, 0, 255);
    } else {
      colorMode(RGB);
      mycolor=color(255, 50, 50);
    }
    wrap();
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

    pushStyle();
    noStroke();
    rectMode(CORNER);
    pushMatrix();
    translate(20, 20);
    fill(50);
    rect(0, 0, 10, 100);
    fill(#F1F528);
    rect(0, map(fuel, 0, maxFuel, 100, 0), 10, map(fuel, 0, maxFuel, 0, 100));

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



  void thrust(float _tforce) {
    fuel--;
    float angle = heading-PI/2;
    PVector force = new PVector(cos(angle), sin(angle));
    force.normalize();
    force.setMag(thrustforce);
    applyForce(force);
  }

  void turn(String direction) {
    if (direction=="right") {
      heading+=0.2;
    } else if (direction=="left") {
      heading-=0.2;
    } else if (direction=="straight") {
      heading-=0;
    }
  }

  void setAngle(float ang) {
    heading=ang;
  }

  PVector getDirection() {
    float angle = heading-PI/2;
    PVector dir = new PVector(cos(angle), sin(angle));
    dir.normalize();
    return dir;
  }


  PVector getPosition() {
    return position.copy();
  }


  boolean hitTest(PVector pos, float radius) {
    PVector p=pos.copy();
    PVector pp=position.copy();
    pp.sub(p);
    if (pp.mag()<radius ) {
      return true;
    } else {
      return false;
    }
  }

  boolean checkCollisions() {
    boolean hittest=false;
    for (int i = 0; i < fields.size(); i++) {
      GravityField m = fields.get(i);
      if (hitTest(m.getPosition(), m.getInnerRadius())) {
        hittest=true;
      }
    }
    return hittest;
  }

  void checkGravity() {
    for (int i = 0; i < fields.size(); i++) {
      GravityField m = fields.get(i);
      if (m.isInside(position.copy())) {
        applyGravity(m.position, m.gravityForce);
      }
    }
  }

  void wrap() {
    if (position.y>height) {
      position.y=0;
    }
    if (position.y<0) {
      position.y=height;
    }

    if (position.x>width) {
      position.x=0;
    }
    if (position.x<0) {
      position.x=width;
    }
  }
}