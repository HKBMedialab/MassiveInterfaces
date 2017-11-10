class Ground {
  PVector position=new PVector (0, 0);
  float gWidth=0;
  float gHeight=0;
  color gcolor=color(139, 84, 30);
  Ground(PVector pos, float _gWidth, float _gHeight) {
    position=pos.copy();
    gWidth=_gWidth;
    gHeight=_gHeight;
  }


  void update() {
  }

  void render() {
    pushMatrix();
    translate(position.x, position.y);
    pushStyle();
    fill(gcolor);
    rect(0, 0, gWidth, gHeight);
    popStyle();
    popMatrix();
  }


  PVector getPosition() {
    return position;
  }
}