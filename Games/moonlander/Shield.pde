class Shield {
  PVector position=new PVector (0, 0);
  float sWidth=250;
  float sHeight=250;
  boolean bIsActive=false;
  float [] boundingbox = new float[4];
  float hue, sat, bright, alpha;

  int energycounter=0;
  int startenergy=200; //Debug

  int shielStartAddTimer=0;
  int addTime=1400;

  CustomShape cs;


  //Thrust animation
  int num=5;
  ArrayList <Ring>shieldrings; 

  ArrayList <LoadParticle>particles; 


  int ringFramedistance=30;

  ArrayList<Vec2> shieldPoints;


  Body body;

  Body body2;

  Shield( CustomShape _cs) {
    hue=map(219, 0, 360, 0, 255);
    sat=map(77, 0, 100, 0, 255);
    bright=map(99, 0, 100, 0, 255);
    alpha=100;
    cs=_cs;
    shieldrings= new ArrayList<Ring>();
    particles= new ArrayList<LoadParticle>();


    //  makeBody(width/2, height/2, sWidth/5);
    //body.setUserData(this);

    shieldPoints = new ArrayList<Vec2>();

    // This is what box2d uses to put the surface in its world
    ChainShape chain = new ChainShape();

    float theta=0;
    for (int i=0; i<10; i++) {
      shieldPoints.add(new Vec2(sin(theta)*80, cos(theta)*80));
      theta+=2*PI/9;
    }

    Vec2[] vertices = new Vec2[shieldPoints.size()];
    for (int i = 0; i < vertices.length; i++) {
      Vec2 edge = box2d.coordPixelsToWorld(shieldPoints.get(i));
      vertices[i] = edge;
    }

    // Create the chain!
    chain.createChain(vertices, vertices.length);

    // The edge chain is now attached to a body via a fixture
    BodyDef bd = new BodyDef();
    bd.position.set(0.0f, 0.0f);
    body = box2d.createBody(bd);
    body.createFixture(chain, 1);
    body.setUserData(this);
    //  body.setActive(false);

    energycounter=startenergy;
  }

  void update(Vec2 _pos) {
    if (getShieldIsActive())energycounter--;
    if (energycounter<0) {
      energycounter=0;
      setShieldActive(false);
      cs.setShieldActive(false);
    }

    for (Ring r : shieldrings) {
      r.update(energycounter);
    }


    for (int i = shieldrings.size()-1; i >= 0; i--) {
      Ring r = shieldrings.get(i);
      if (r.alpha<5) {
        shieldrings.remove(i);
      }
    }

    for (LoadParticle p : particles) {
      p.update();
    }

    for (int i = particles.size()-1; i >= 0; i--) {
      LoadParticle p = particles.get(i);
      if (p.removeMe) {
        particles.remove(i);
      }
    }


    if (bIsActive) {
      if (millis()-shielStartAddTimer>addTime) {
        shielStartAddTimer=millis();
        Ring r = new Ring();
        shieldrings.add(r);
      }
    }
    body.setTransform(new Vec2(box2d.scalarPixelsToWorld(_pos.x), box2d.scalarPixelsToWorld(-_pos.y)), 0);
  }

  void render() {

    Vec2 pos = box2d.getBodyPixelCoord(body);
    pushMatrix();
    translate(pos.x-width/2, pos.y-height/2);
    pushStyle();
    strokeWeight(2);
    stroke(255);
    noFill();
    beginShape();
    for (Vec2 v : shieldPoints) {
      vertex(v.x, v.y);
    }
    endShape();
    popStyle();
    popMatrix();




    pushMatrix();
    translate(position.x, position.y);

    pushStyle();
    for (Ring r : shieldrings) {
      r.render();
    }
    popStyle();


    pushStyle();
    for (LoadParticle p : particles) {
      p.render();
    }
    popStyle();

    popMatrix();
  }

  PVector getPosition() {
    return position;
  }

  void setPosition(PVector pos) {
    position=pos.copy();
  }

  void setBoundingBox(float _w, float _h) {
    sWidth=_w;
    sHeight=_h;
  }

  void setShieldActive(boolean _active) {
    bIsActive=_active;

    if (bIsActive && energycounter>0) {
      shieldrings.clear();
      energycounter=startenergy;
      shielStartAddTimer=millis();
      Ring r = new Ring();
      shieldrings.add(r);
      //body.setActive(true);
    } else {
      body.setActive(false);
    }
  }

  boolean getShieldIsActive() {
    return bIsActive;
  }

  boolean isActive() {
    return bIsActive;
  }

  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }

  void loadShield(int amt) {
    energycounter+=amt;
    println(energycounter);
    for (int i=0; i<amt; i++) {
      LoadParticle p = new LoadParticle();
      particles.add(p);
    }
  }

  /*
  // Here's our function that adds the particle to the Box2D world
   void makeBody(float x, float y, float r) {
   // Define a body
   BodyDef bd = new BodyDef();
   // Set its position
   bd.position = box2d.coordPixelsToWorld(x, y);
   bd.type = BodyType.KINEMATIC;
   body2 = box2d.createBody(bd);
   
   // Make the body's shape a circle
   CircleShape cs = new CircleShape();
   cs.m_radius = box2d.scalarPixelsToWorld(r);
   
   FixtureDef fd = new FixtureDef();
   fd.shape = cs;
   // Parameters that affect physics
   fd.density = 1;
   fd.friction = 0.01;
   fd.restitution = 0.3;
   
   // Attach fixture to body
   body2.createFixture(fd);
   
   body2.setAngularVelocity(random(-10, 10));
   }*/
}


class LoadParticle {
  PVector position=new PVector (150, 0);
  PVector target=new PVector (0, 0);

  PVector speed=new PVector (2, 0);

  boolean removeMe=false;


  LoadParticle() {
    position.rotate(random(2*PI));
    speed=target.copy().sub(position.copy());
    speed.limit(random(2, 5));
  }

  void update() {
    position.add(speed);
    if (target.copy().sub(position.copy()).mag()<5) {
      removeMe=true;
    }
  }

  void render() {
    pushStyle();
    noStroke();
    fill(255, 255, 255);
    pushMatrix();
    translate(position.x, position.y);
    rect(0, 0, 5, 5);
    popMatrix();

    fill(100, 255, 255);

    pushMatrix();
    translate(target.x, target.y);
    rect(0, 0, 5, 5);
    popMatrix();
    popStyle();
  }
}


class Ring {


  PVector position=new PVector (0, 0);
  PVector speed=new PVector (2, 0);

  float rWidth=100;
  float endRWidth=200;
  float rHeight=rWidth;

  float alpha=50;

  float hue=130;
  float starthue=130;

  float endHue=150;

  float energy=200;

  void setSpeedX(float _speedX) {
    speed.set(_speedX, 0);
  }



  Ring() {
  }

  void update(int _energycounter) {
    energy=_energycounter;
    //float movespeed=map(energy,200,0,speed.x,0.5);
    //position.add(speed);
    rWidth+=speed.x;//sqrt(speed.mag()*speed.mag());
    rHeight=rWidth;
    if (rWidth>endRWidth) {
      alpha-=10;
    } else if (alpha<220) {
      alpha+=5;
    }

    //if (alpha>200 && hue<endHue) {
    // hue++;
    float h=map(energy, 200, 0, 0, 10);
    //println(hue+" "+h);
    hue=starthue+h;
    //}
  }

  void render() {
    pushStyle();
    pushMatrix();
    translate(position.x, position.y);
    //rotate(speed.heading()+PI/2);
    noFill();
    //blendMode(SCREEN);
    /*strokeWeight(20);
     stroke(150, 255, 255, alpha-50);
     ellipse(0, 0, rWidth, rHeight );
     */
    strokeWeight(15);

    stroke(hue, 255, 255, alpha);
    ellipse(0, 0, rWidth, rHeight );

    /* strokeWeight(10);
     stroke(120, 150, 255, alpha);
     ellipse(0, 0, rWidth, rHeight );
     
     strokeWeight(4);
     stroke(150, 0, 255, alpha);
     ellipse(0, 0, rWidth, rHeight);*/
    popStyle();
    //  blendMode(BLEND);
    popMatrix();
  }
}