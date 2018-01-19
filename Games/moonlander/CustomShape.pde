class CustomShape {
  boolean thrust=false;
  boolean leftthrust=false;
  boolean rightthrust=false;

  int thrustcounter=0;
  boolean useCounter=true;

  int thrustforce=100;
  int leftthrustforce=-500;
  int rightthrustforce=500;

  //Thrust animation
  int num=5;
  ArrayList <Thrust>thrustrings; 


  int thrustFramedistance=3;

  color col;

  boolean changeType=false;
  boolean changeRestitution=false;

  Shield shield;

  PImage ship;
  PImage duese;

  PImage thrustimg;
  PImage leftimg;
  PImage rightimg;

  PApplet sketchRef;

  // We need to keep track of a Body and a width and height
  Body body;

  // Constructor
  CustomShape(PApplet pa, float x, float y) {
    sketchRef=pa;
    // Add the box to the box2d world
    makeBody(new Vec2(x, y));
    body.setUserData(this);

    shield=new Shield(this);
    shield.setShieldActive(false);


    col = color(175);

    ship = loadImage("ship/raumschiff_rot_30x40.png");
    thrustimg = loadImage("ship/000.png");
    rightimg = loadImage("ship/001.png");
    leftimg = loadImage("ship/002.png");
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
    if (changeType)changeBodytype();
    shield.update();

    body.setLinearDamping(DAMPING);

    if (useCounter) {
      if (thrust) {
        thrustcounter++;
      }

      if (thrustcounter>IMPULSE) {
        thrust=false;
        thrustcounter=0;
      }
    }

    if (thrust)verticalThrust();
    if (leftthrust )leftThrust();
    if (rightthrust )rightThrust();


    // limit to max Speed;
    Vec2 velocity = body.getLinearVelocity();
    float speed = velocity.length();
    if (speed > MAXSPEED) {
      body.setLinearVelocity(velocity.mul(MAXSPEED/speed));
    }




    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();

    Fixture f = body.getFixtureList();
    PolygonShape ps = (PolygonShape) f.getShape();
    shield.setPosition(new PVector(pos.x, pos.y));



    rectMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);

    rotate(-a);
    fill(col);

    stroke(0);

    pushMatrix();
    scale(2, 2);
    image(ship, -15, 0);
    popMatrix();


    /* beginShape();
     //println(vertices.length);
     // For every vertex, convert to pixel vector
     for (int i = 0; i < ps.getVertexCount(); i++) {
     Vec2 v = box2d.vectorWorldToPixels(ps.getVertex(i));
     vertex(v.x, v.y);
     }
     endShape(CLOSE);*/


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
      float h=map(thrustforce, 0, MAXTHRUSTFORCE*500, 80, 180);
      if (frameCount%thrustFramedistance==0) {
        Thrust t = new Thrust();
        thrustrings.add(t);
      }
    }


    if (rightthrust) {
      if (frameCount%thrustFramedistance==0) {
        Thrust t = new Thrust();
        t.speed.rotate(PI/4);
        t.position.set(-15, 75);
        t.tWidth=30;
        t.tHeight=10;
        thrustrings.add(t);
      }
    }

    if (leftthrust) {
      if (frameCount%thrustFramedistance==0) {
        Thrust t = new Thrust();
        t.speed.rotate(-PI/4);
        t.position.set(15, 75);
        t.tWidth=30;
        t.tHeight=10;
        thrustrings.add(t);
      }
    }


    popMatrix();

    shield.render();
  }

  // This function adds the rectangle to the box2d world
  void makeBody(Vec2 center) {

    // Define a polygon (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();

    Vec2[] vertices = new Vec2[5];
    vertices[0] = box2d.vectorPixelsToWorld(new Vec2(0, 0));
    vertices[1] = box2d.vectorPixelsToWorld(new Vec2(13, 20));
    vertices[2] = box2d.vectorPixelsToWorld(new Vec2(13, 70));
    vertices[3] = box2d.vectorPixelsToWorld(new Vec2(-13, 70));
    vertices[4] = box2d.vectorPixelsToWorld(new Vec2(-13, 20));


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

    //body.createFixture(sd, 1.0);


    // Give it some initial random velocity
    //body.setLinearVelocity(new Vec2(random(-5, 5), random(2, 5)));
    //body.setAngularVelocity(random(-5, 5));
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
    thrust=_thrust;
    thrustforce=_thrustforce;
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
      changeType=true;
      setRestitution(0);
    } else {
      setRestitution(RESTITUTION);
    }
  }

  // Change color when hit
  void hitSurface() {

    Vec2 pos = box2d.getBodyPixelCoord(body);
    if (pos.x>(width/2-15) &&pos.x<(width/2+15)) {
      Vec2 velocity = body.getLinearVelocity();
      float speed = velocity.length();
      println("++++++++++++++"+speed);
      if (speed<MAXLANDSPEED) {
        changeGameState(LANDED);
      } else {
        changeGameState(CRASHED);
      }
    }
  }


  void changeBodytype() {
    //body.setType(BodyType.KINEMATIC);
    Fixture f = body.getFixtureList();
    f.setRestitution(0);
    changeType=false;
  }


  void changeRestitution() {
    //body.setType(BodyType.KINEMATIC);
    Fixture f = body.getFixtureList();
    f.setRestitution(0);
  }



  void setRestitution(float res) {
    //body.setType(BodyType.KINEMATIC);
    Fixture f = body.getFixtureList();
    f.setRestitution(res);
  }


  // Change color when hit
  void endContact() {
    col = color(175);
  }
}