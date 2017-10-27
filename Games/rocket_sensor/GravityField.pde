class GravityField {
  PVector position=new PVector(width/2, height/2);

  float outerDiameter=600;
  float innerDiameter=200;
  float radiusDiff=0;
  float distance=0;
  float ammount=0;

  float animationDiameter;


  color myColor=color(255, 0, 0);
  float gravityForce=0.05;
  float alphaVal;
  boolean bIsRotating=false;
  PVector rotateAround=new PVector(width/2, height/2);
  float rotationspeed=0;



  GravityField(float _innerRadius, float _outerRadius, float _force, PVector _position, color _col) {
    innerDiameter=_innerRadius;
    outerDiameter=_outerRadius;
    gravityForce=_force;
    position=_position;
    myColor=_col;

    // field visuals
    setupFieldVisualsVars();
  }


  GravityField(float _innerRadius, float _outerRadius, float _force, PVector _position, color _col, boolean _bIsRotating, float _rotationspeed, PVector _rotateAround) {
    innerDiameter=_innerRadius;
    outerDiameter=_outerRadius;
    gravityForce=_force;
    position=_position;
    myColor=_col;
    bIsRotating=_bIsRotating;
    rotationspeed=_rotationspeed;
    rotateAround=_rotateAround;

    setupFieldVisualsVars();
  }

  void update() {
    if (bIsRotating) {
      position = rotatePointAroundCentre(rotateAround, position, rotationspeed);
    }

    animationDiameter-=gravityForce*100;
    if (animationDiameter<innerDiameter) {
      animationDiameter=outerDiameter;
    }
  }

  void render() {
    pushStyle();
    pushMatrix();
    translate(position.x, position.y);
    noFill();
    float radius=0;

    stroke(myColor, alphaVal);
    noFill();
    ellipse(0, 0, animationDiameter, animationDiameter);

    fill(myColor, alphaVal);
    ellipse(0, 0, outerDiameter, outerDiameter);
    fill(myColor, alphaVal);
    ellipse(0, 0, innerDiameter, innerDiameter);
    popMatrix();
    popStyle();
  }

  boolean isInside(PVector pos) {
    PVector p=pos.get();
    PVector pp=position.get();
    pp.sub(p);
    if (pp.mag()<outerDiameter/2 && pp.mag()>innerDiameter/2)return true;
    else return false;
  }

  PVector rotatePointAroundCentre(PVector center, PVector _pos, float rotation) {
    PVector rotatedPoint = _pos.copy();
    rotatedPoint.sub(center.x, center.y);
    Float angle  = rotation;
    rotatedPoint.rotate(angle);
    rotatedPoint.add(center.x, center.y);
    return rotatedPoint;
  }

  void setupFieldVisualsVars() {
    alphaVal=map(gravityForce, 0.01, 0.1, 30, 70);
    // field visuals
    distance=map(gravityForce, 0.01, 0.1, 200, 50);
    ammount=outerDiameter/distance;
  }


  // Helper & Getter
  PVector getPosition() {
    return position.copy();
  }

  float getInnerRadius() {
    return innerDiameter/2;
  }

  float getOuterRadius() {
    return outerDiameter/2;
  }
}