class Shield {
  PVector position=new PVector (0, 0);
  float sWidth=250;
  float sHeight=250;
  boolean bIsActive=false;
  float [] boundingbox = new float[4];
  float hue, sat, bright, alpha;

  float energycounter=0;
  int startenergy=50; //Debug

  int shielStartAddTimer=0;
  int addTime=1400;

  color setColor;

  CustomShape cs;


  //Thrust animation
  int num=5;
  ArrayList <Ring>shieldrings; 
  ArrayList <LoadParticle>particles; 


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
      r.update(int(energycounter));
    }


    for (int i = shieldrings.size()-1; i >= 0; i--) {
      Ring r = shieldrings.get(i);
      if (r.alpha<5) {
        shieldrings.remove(i);
      }
    }
    if (particles.size()>0) {
      for (LoadParticle p : particles) {
        p.update();
      }
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
  }

  void render() {
    pushMatrix();
    translate(position.x, position.y);
    pushStyle();
    for (Ring r : shieldrings) {
      r.render();
    }
    popStyle();
    
   /* pushStyle();
    fill(255,0,0);
    rect(0,-energycounter,50,energycounter); 
    popStyle();
*/
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
      //energycounter=startenergy;
      shielStartAddTimer=millis();
      Ring r = new Ring();
      shieldrings.add(r);
    } else {
    }
  }

  boolean getShieldIsActive() {
    return bIsActive;
  }

  boolean isActive() {
    return bIsActive;
  }


  void loadShield(float amt) {
        if(energycounter>MAXENERGY)return;

    energycounter+=amt;
   for (int i=0; i<ceil(amt*2); i++) {
      colorMode(HSB);
      color c=color(random(50, 150), random(30, 120), 255);
      colorMode(RGB);
      LoadParticle p = new LoadParticle(c);
      particles.add(p);
    }
  }

  void setColor(color _col) {
    setColor=_col;
  }

  float getEnergyCounter() {
    return energycounter;
  }
}


class LoadParticle {
  float initDist=150;
  PVector position=new PVector (initDist, 0);
  PVector target=new PVector (0, 0);
  PVector speed=new PVector (2, 0);
  boolean removeMe=false;
  float alpha=255;
  color col;

  LoadParticle(color _col) {
    position.rotate(random(2*PI));
    speed=target.copy().sub(position.copy());
    speed.limit(random(2, 5));
    col=_col;
  }

  void update() {
    position.add(speed);
    float dist=target.copy().sub(position.copy()).mag();
    if (dist<5) {
      removeMe=true;
    }
    alpha=map(dist, initDist, 0, 255, 0);
  }

  void render() {
    colorMode(HSB);

    pushStyle();
    noStroke();
    fill(col, alpha);
    pushMatrix();
    translate(position.x, position.y);
    rect(0, 0, 5, 5);
    popMatrix();
    popStyle();
    colorMode(RGB);
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
  float endHue=50;

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
    float h=map(energy, MAXENERGY, 0, 0, 10);
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
colorMode(HSB);
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