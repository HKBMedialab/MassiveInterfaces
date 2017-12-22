class Shield {
  PVector position=new PVector (0, 0);
  float sWidth=100;
  float sHeight=100;
  boolean bIsActive=false;
  float [] boundingbox = new float[4];
  float hue, sat, bright, alpha;

  int energycounter=0;
  int startenergy=100;

  Shield() {
    hue=map(219, 0, 360, 0, 255);
    sat=map(77, 0, 100, 0, 255);
    bright=map(99, 0, 100, 0, 255);
    alpha=100;
  }

  void update() {
    energycounter--;
    if (energycounter<0) {
      energycounter=0;
      setShieldActive(false);
    }
  }

  void render() {
    if (bIsActive) {
      pushMatrix();
      pushStyle();
      fill(hue, sat, bright, alpha);
      stroke(hue, sat, bright, 255);
      translate(position.x, position.y);
      ellipse(0, 0, sWidth, sHeight);
      popStyle();
      popMatrix();
    }
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
    if(bIsActive)energycounter=startenergy;
  }

  boolean getShieldActive() {
    return bIsActive;
  }

  boolean isActive() {
    return bIsActive;
  }
}