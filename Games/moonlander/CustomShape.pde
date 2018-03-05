class CustomShape {
  boolean thrust=false;
  boolean leftthrust=false;
  boolean rightthrust=false;

  int thrustcounter=0;
  boolean useCounter=true;

  int thrustforce=0;
  int leftthrustforce=-500;
  int rightthrustforce=500;

  //Thrust animation
  int num=5;
  ArrayList <Thrust>thrustrings; 
  int thrustFramedistance=3;

  color col;
  color glowcolor=color(255);

  boolean changeType=false;
  boolean changeRestitution=false;

  Shield shield;

  PImage ship;
  PImage shipglow1;

  PImage shipglow2;
  PImage shipglow3;

  color shieldcolor;


  int id;

  float blinktheta=0;

  float startX;
  float startY;

  float blink=0;


  Vec2 posBefore; 
  Vec2 velocityBefore;

  PApplet sketchRef;

  // We need to keep track of a Body and a width and height
  Body body;

  // Constructor
  CustomShape(PApplet pa, float x, float y, int _id) {
    id=_id;
    sketchRef=pa;
    startX=x;
    startY=y;
    makeBody(new Vec2(x, y));
    body.setUserData(this);
    shield=new Shield(this);
    shield.setShieldActive(false);

    col = color(175);

    ship = loadImage("ship/ship_body.png");
    shipglow1 = loadImage("ship/glow_smooth1.png");

    thrustrings= new ArrayList<Thrust>();
  }

  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }

  // Is the particle ready for deletion?
  boolean done() {
    // Let's find the screen position of the particle
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Is it off the bottom of the screen?
    if (pos.y > height) {
      killBody();
      return true;
    }
    return false;
  }

  void applyForce(Vec2 force) {
    Vec2 pos = body.getWorldCenter();
    body.applyForce(force, pos);
  }



  // Drawing the box
  void display() {
    shield.update(box2d.getBodyPixelCoord(body));

    body.setLinearDamping(DAMPING);

    if (useCounter) {
      if (thrust) {
        thrustcounter++;
      }

      if (thrustcounter>IMPULSE) {
        thrust=false;
        thrustcounter=0;
        thrustforce=0;
      }
    }

    if (gamestate==PLAY) {
      if (thrust)verticalThrust();
      if (leftthrust )leftThrust();
      if (rightthrust )rightThrust();
    }

    // limit to max Speed;
    Vec2 velocity = body.getLinearVelocity();
    float speed = velocity.length();
    if (speed > MAXSPEED) {
      body.setLinearVelocity(velocity.mul(MAXSPEED/speed));
    }


    textSize(50);

    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    text(thrustforce, pos.x+50, pos.y);





    shield.setPosition(new PVector(pos.x, pos.y));


    rectMode(CENTER);
    shield.render();

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    if (rightthrust) {
      rotate(0.1);
    }

    if (leftthrust) {
      rotate(-0.1);
    }


    pushMatrix();
    //tint(glowcolor, 250);
    //println(map(sin(float(frameCount)/5),-1,1,0,255));
    if (shield.getEnergyCounter()>MAXENERGY-50) {
      // float btheta=map(shield.getEnergyCounter(),0,MAXENERGY,0,0.5);
      //   blink+=btheta;
      tint(glowcolor, map(sin((float(frameCount)/5)), -1, 1, 0, 255));
      //      tint(glowcolor, map(sin(btheta),-1,1,0,255));
    } else {
      tint(glowcolor, 250);
    }

    //  tint(lerpColor(col,glowcolor , map(shield.getEnergyCounter(),0,MAXENERGY,0,1)),250);
    // blendMode(SCREEN);
    image(shipglow1, -shipglow1.width/2, -shipglow1.height/2);
    //  image(shipglow1, -shipglow1.width/2, -shipglow1.height/2);
    //blendMode(BLEND);

    //float alpha=map(sin(blinktheta), -1, 1, 100, 255);
    //blinktheta+=0.1*shield.getEnergyCounter();
    //tint(col, alpha);
    tint(lerpColor(col, shieldcolor, map(shield.getEnergyCounter(), 0, MAXENERGY-5, 0, 1)));
    //tint(col);
    // if (pos.x>(width/2-PLATTFORMWIDTH/2) &&pos.x<(width/2+PLATTFORMWIDTH/2)) {
    //   tint(color(255, 0, 255));
    // }

    image(ship, -ship.width/2, -ship.height/2);
    noTint();
    popMatrix();

    /*
     stroke(0);
     beginShape();
     //println(vertices.length);
     // For every vertex, convert to pixel vector
     for (int i = 0; i < ps.getVertexCount(); i++) {
     Vec2 v = box2d.vectorWorldToPixels(ps.getVertex(i));
     vertex(v.x, v.y);
     }
     endShape(CLOSE);
     */

    for (Thrust t : thrustrings) {
      t.update();
      t.render();
    }


    for (int i = thrustrings.size()-1; i >= 0; i--) {
      Thrust t = thrustrings.get(i);
      if (t.tWidth<1) {
        thrustrings.remove(i);
      }
    }

    if (thrust) {
      //float h=map(thrustforce, 0, MAXTHRUSTFORCE*500, 80, 180);
      if (frameCount%thrustFramedistance==0) {
        Thrust t = new Thrust(thrustforce);
        thrustrings.add(t);
      }
    }


    if (rightthrust) {
      if (frameCount%thrustFramedistance==0) {
        Thrust t = new Thrust();
        t.speed.rotate(PI/4);
        t.position.set(-30, 60);
        t.tWidth=30;
        t.tHeight=10;
        thrustrings.add(t);
      }
    }

    if (leftthrust) {
      if (frameCount%thrustFramedistance==0) {
        Thrust t = new Thrust();
        t.speed.rotate(-PI/4);
        t.position.set(30, 60);
        t.tWidth=30;
        t.tHeight=10;
        thrustrings.add(t);
      }
    }


    popMatrix();
  }

  // This function adds the rectangle to the box2d world
  void makeBody(Vec2 center) {

    // Define a polygon (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();
    Vec2[] vertices = new Vec2[5];
    vertices[0] = box2d.vectorPixelsToWorld(new Vec2(0, -59));
    vertices[1] = box2d.vectorPixelsToWorld(new Vec2(18, -39));
    vertices[2] = box2d.vectorPixelsToWorld(new Vec2(25, 55));
    vertices[3] = box2d.vectorPixelsToWorld(new Vec2(-18, 55));
    vertices[4] = box2d.vectorPixelsToWorld(new Vec2(-18, -39));
    sd.set(vertices, vertices.length);

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    bd.fixedRotation = true;

    body = box2d.createBody(bd);

    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = DENSITY;
    fd.friction = 0.1;
    fd.restitution =RESTITUTION;
    // Attach fixture to body
    body.createFixture(fd);
  }

  void verticalThrust() {
    Vec2 force = new Vec2(0, thrustforce);
    applyForce(force);
  }

  void leftThrust() {
    Vec2 force = new Vec2(leftthrustforce, 0);
    applyForce(force);
  }

  void rightThrust() {
    Vec2 force = new Vec2(rightthrustforce, 0);
    applyForce(force);
  }

  void setLeftThrustForce(int _thrustforce) {
    leftthrustforce=_thrustforce;
  }

  void setRightThrustForce(int _thrustforce) {
    rightthrustforce=_thrustforce;
  }

  void setThrustForce(int _thrustforce) {
    thrustforce=_thrustforce;
  }


  void setThrust(boolean _thrust) {
    thrust=_thrust;
  }

  void setThrust(boolean _thrust, int _thrustforce) {
    if (useCounter) {
      //if (!thrust) {
      if ( _thrust&&!thrust) boostsound.trigger();
      thrust=_thrust;
      if (_thrustforce>thrustforce) {
        thrustforce=_thrustforce;
      }
    } else {
      thrust=_thrust;
      thrustforce=_thrustforce;
      boostsound.trigger();
    }
  }

  void setLeftThrust(boolean _thrust) {
    leftthrust=_thrust;
  }

  void setLeftThrust(boolean _thrust, int _thrustforce) {
    leftthrust=_thrust;
    leftthrustforce=_thrustforce;
  }

  void setRightThrust(boolean _thrust) {
    rightthrust=_thrust;
  }

  void setRightThrust(boolean _thrust, int _thrustforce) {
    rightthrust=_thrust;
    rightthrustforce=_thrustforce;
  }

  void setShieldActive(boolean _active) {
    shield.setShieldActive(_active);
    if (_active==true) {
      //changeType=true;
      setRestitution(0);
    } else {
      setRestitution(RESTITUTION);
    }
  }

  // Change color when hit
  void hitSurface() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    if (pos.x>(width/2-PLATTFORMWIDTH/2) &&pos.x<(width/2+PLATTFORMWIDTH/2)) {
      Vec2 velocity = body.getLinearVelocity();
      float speed = velocity.length();
      println("++++++++++++++"+speed);
      if (speed<MAXLANDSPEED  || shield.getShieldIsActive()) {
        winner=this;
        changeGameState(LANDED);
      } else {
        // changeGameState(CRASHED);
      }
    }
  }

  void hitShip() {
    velocityBefore=new Vec2(body.getLinearVelocity().x, body.getLinearVelocity().y);
  }

  void hitShipPresolve() {
    if (shield.getShieldIsActive()) {
      Fixture f = body.getFixtureList();
      f.setRestitution(0);
      f.setDensity(10);
      body.resetMassData();
    }
  }

  void hitShipPostsolve() {
    if (shield.getShieldIsActive()) {
      body.setLinearVelocity(new Vec2(0, 0));
    }
  }


  void hitShipEnd() {
    Fixture f = body.getFixtureList();
    if (shield.getShieldIsActive()) {
      setRestitution(0);
    } else {
      f.setRestitution(RESTITUTION);
      body.resetMassData();
    }
    f.setDensity(DENSITY);
    body.resetMassData();
  }


  boolean getShieldIsActive() {
    return shield.getShieldIsActive();
  }

  void setRestitution(float res) {
    Fixture f = body.getFixtureList();
    f.setRestitution(res);
    body.resetMassData();
  }

  // Change color when hit
  void endContact() {
    // col = color(175);
  }

  void setColor(color _col) {
    col=_col;
  }

  void setGlowColor(color _col) {
    glowcolor=_col;

    colorMode(HSB, 255);
    shieldcolor=color(hue(glowcolor), saturation(glowcolor)-20, brightness(glowcolor)-100);
    println("hue "+hue(glowcolor)+" "+hue(shieldcolor));

    colorMode(RGB);
  }

  void setShieldColor(color _col) {
    shield.setColor(_col);
  }

  void loadShield(float amt) {
    shield.loadShield(amt);
  }

  void reset() {
    shield.energycounter=0;
    shield.loadShield(200);
    shield.setShieldActive(false);
    body.setTransform(box2d.coordPixelsToWorld(new Vec2(startX, startY)), 0);
  }
}