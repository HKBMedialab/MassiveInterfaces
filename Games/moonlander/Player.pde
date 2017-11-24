class Player {
  PVector position=new PVector(50, 50);
  PVector velocity=new PVector(0, 0);
  PVector acceleration=new PVector(0, 0);
  float angle=PI/2;
  float heading=0;
  color mycolor=color(255, 50, 50);
  float fuel=1000;


  boolean thrust=false;
  boolean leftthrust=false;
  boolean rightthrust=false;

  int thrustcounter=0;

  int maxthrustcounter=5;


  float [] boundingbox = new float[4];

  int state=PLAYING;



  Shield shield;



  Player(PVector pos) {
    position=pos.copy();
    shield=new Shield();
    shield.setShieldActive(false);
  }

  void update() {

    if (thrust) {
      thrustcounter++;
    }

    if (thrustcounter>maxthrustcounter) {
      thrust=false;
      thrustcounter=0;
    }

    switch(state) {
    case LANDED: 
      //updatePhysics();

      break;

    case PLAYING:
      updatePhysics();
      break;
    }
    boundingbox=makeBoundingbox();
    wrap();


    shield.setPosition(position);
  }

  void render() {


    switch(state) {
    case PLAYING:
      renderRocket();
      // println(state);
      break;
    case LANDED: 
      renderRocket();
      break;
    case CRASHED:
      renderCrash();
      break;
    }


    shield.render();


    /*
    pushStyle();
     noStroke();
     rectMode(CORNER);
     pushMatrix();
     translate(20, 20);
     fill(50);
     rect(0, 0, 10, 100);
     fill(#F1F528);
     rect(0, map(fuel, 0, MAXFUEL, 100, 0), 10, map(fuel, 0, MAXFUEL, 0, 100));
     
     popMatrix();
     popStyle();
     */
  }



  void renderCrash() {
    pushMatrix();

    translate(position.x, position.y);
    float rot = map(velocity.x, -10, 10, -0.4, 0.4);
    rotate(rot);

    fill(hue(mycolor), 255, 255);
    rect(0, 0, 16, 60);
    fill(hue(mycolor), 255, 230);
    triangle(-8, -30, 8, -30, 0, -45 );
    fill(hue(mycolor), 255, 200);

    triangle(-20, 35, -8, 30, -8, 0 );
    triangle(20, 35, 8, 30, 8, 0 );
    popMatrix();
  }

  void renderRocket() {
    colorMode(HSB);
    pushStyle();
    noStroke();
    rectMode(CENTER);
    pushMatrix();

    translate(position.x, position.y);
    float rot = map(velocity.x, -10, 10, -0.4, 0.4);
    rotate(rot);

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

    if (rightthrust && fuel>0) {
      pushStyle();
      fill(#FAC903);
      triangle(-8, -20, -8, -10, -16, -5 );
      popStyle();
    }


    if (leftthrust && fuel>0) {
      pushStyle();
      fill(#FAC903);
      triangle(8, -20, 8, -10, 16, -5 );
      popStyle();
    }

    popMatrix();
    popStyle();

    drawBoundingbox();
  }



  void updatePhysics() {
    // ADD FORCES
    if (thrust && fuel>0)verticalThrust();
    if (leftthrust && fuel>0)leftThrust();
    if (rightthrust && fuel>0)rightThrust();
    applyGravity();
    steer();

    // Reset acceleration
    acceleration.set(0, 0, 0);
  }


  void steer() {
    velocity.add(acceleration);
    velocity.mult(DRAG);
    // velocity.limit(MAXSPEED);
    position.add(velocity);
  }

  void applyForce(PVector force) {
    PVector f=force.get();
    acceleration.add(f);
  }


  void applyGravityField(PVector pos, float force) {
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
    force.setMag(VERTICAL_THRUST);
    applyForce(force);
  }


  void verticalThrust() {
    fuel--;
    PVector force = new PVector(0, -1);
    force.normalize();
    force.setMag(VERTICAL_THRUST);
    applyForce(force);
  }

  void leftThrust() {
    PVector force = new PVector(-1, 0);
    force.normalize();
    force.setMag(HORIZONTAL_THRUST);
    applyForce(force);
  }

  void rightThrust() {
    PVector force = new PVector(1, 0);
    force.normalize();
    force.setMag(HORIZONTAL_THRUST);
    applyForce(force);
  }

  void thrust(float _tforce) {
    fuel--;
    float angle = heading-PI/2;
    PVector force = new PVector(cos(angle), sin(angle));
    force.normalize();
    force.setMag(VERTICAL_THRUST);
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



  void applyGravity() {
    PVector g=new PVector(0, 1);
    g.normalize();
    g.setMag(GRAVITY);
    applyForce(g);
  }


  void wrap() {
   /* if (position.y>height) {
      position.y=0;
    }
    if (position.y<0) {
      position.y=height;
    }
*/
    if (position.x>width) {
      position.x=0;
    }
    if (position.x<0) {
      position.x=width;
    }
  }


  PVector getVelocity() {
    return velocity.copy();
  }



  void drawBoundingbox() {

    pushMatrix();
    pushStyle();
    rectMode(CORNER);
    noFill();
    // colorMode(RGB);
    stroke(0, 255, 0);
    rect(boundingbox[0], boundingbox[1], boundingbox [2]-boundingbox [0], boundingbox [3]-boundingbox [1]);
    popStyle();
    popMatrix();
  }


  float [] makeBoundingbox() {
    float [] bounds = new float[4];
    bounds[0]=position.x-20;
    bounds [1]=position.y-45;
    bounds [2]=position.x-20+40;
    bounds [3]=position.y-45+80;
    return bounds;
  }

  float [] getBoundingbox() {
    return boundingbox;
  }


  void setState(int _state) {
    state=_state;
  }

  int getState() {
    return state;
  }

  void  setThrust(boolean _thrust) {
    thrust=_thrust;
  }

  void setShieldActive(boolean _active) {
    shield.setShieldActive(_active);
  }
}