class GravityField {
  PVector position=new PVector(width/2, height/2);
  float outerRadius=300;
  float innerRadius=100;

  GravityField() {
  }

  void update() {
  }

  void render() {
    pushStyle();
    pushMatrix();
    translate(position.x, position.y);
    fill(255, 0, 0, 100);
    ellipse(0, 0, outerRadius*2, outerRadius*2);
    fill(0, 0, 0, 100);
    ellipse(0, 0, innerRadius*2, innerRadius*2);
    popMatrix();
    popStyle();
  }

  boolean isInside(PVector pos) {
    PVector p=pos.get();
    PVector pp=position.get();
    pp.sub(p);
    if(pp.mag()<outerRadius && pp.mag()>innerRadius)return true;
    else return false;
  }
  
}