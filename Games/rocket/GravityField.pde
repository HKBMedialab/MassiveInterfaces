class GravityField {
  PVector position=new PVector(width/2, height/2);

  float outerRadius=300;
  float innerRadius=100;
  color myColor=color(255, 0, 0);
  float gravityForce=0.05;
  float alphaVal;
  boolean bIsRotating=false;
  PVector rotateAround=new PVector(width/2, height/2);
  float rotationspeed=0;

  GravityField(float _innerRadius, float _outerRadius, float _force, PVector _position, color _col) {
    innerRadius=_innerRadius;
    outerRadius=_outerRadius;
    gravityForce=_force;
    position=_position;
    myColor=_col;
    alphaVal=map(gravityForce, 0, 0.1, 0, 255);
  }
  
  
    GravityField(float _innerRadius, float _outerRadius, float _force, PVector _position, color _col, boolean _bIsRotating, float _rotationspeed) {
    innerRadius=_innerRadius;
    outerRadius=_outerRadius;
    gravityForce=_force;
    position=_position;
    myColor=_col;
    alphaVal=map(gravityForce, 0, 0.1, 0, 255);
    bIsRotating=_bIsRotating;
    rotationspeed=_rotationspeed;
  }

  void update() {
    if (bIsRotating) {
    position = rotatePointAroundCentre(rotateAround, position, rotationspeed);
    }
  }

  void render() {
    pushStyle();
    pushMatrix();
    translate(position.x, position.y);
    fill(myColor, alphaVal);
    ellipse(0, 0, outerRadius*2, outerRadius*2);
    fill(0, 0, 0, alphaVal);
    ellipse(0, 0, innerRadius*2, innerRadius*2);
    popMatrix();
    popStyle();

  
  }

  boolean isInside(PVector pos) {
    PVector p=pos.get();
    PVector pp=position.get();
    pp.sub(p);
    if (pp.mag()<outerRadius && pp.mag()>innerRadius)return true;
    else return false;
  }



  PVector rotatePointAroundCentre(PVector center, PVector _pos, float rotation) {
    PVector rotatedPoint = _pos.copy();
    rotatedPoint.sub(center.x, center.y);
    Float angle  = rotation;
    rotatedPoint.rotate(angle);
    rotatedPoint.add(center.x, center.y);


    // Float angle  = radians(rotation);
    // rotatedPoint.x = centreX + (cos(angle) * x - sin(angle) * y);
    // rotatedPoint.y = centreY + (cos(angle) * y + sin(angle) * x);
    return rotatedPoint;
  }
}