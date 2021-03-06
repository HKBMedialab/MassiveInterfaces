class Thrust {

  PVector position=new PVector (0, 60);
  PVector speed=new PVector (0, 4);

  float tWidth=60;
  float tHeight=tWidth/3;
  int thrustforce;

  Thrust(int _thrustforce) {
    thrustforce=_thrustforce;

    if (thrustforce==THRUSTFORCE1) {
      tWidth=20;
    } else if (thrustforce==THRUSTFORCE2) {
      tWidth=40;
    }else if (thrustforce==THRUSTFORCE3) {
      tWidth=60;
    }else if (thrustforce==THRUSTFORCE4) {
      tWidth=80;
    }
  }

  Thrust() {
  }

  void update() {

    position.add(speed);
    tWidth-=sqrt(speed.mag()*speed.mag());
    tHeight=tWidth/3;
    // tHeight-=sqrt(speed.mag());
  }

  void render() {
    pushStyle();
    pushMatrix();
    translate(position.x, position.y);
    rotate(speed.heading()+PI/2);
    noFill();
    blendMode(SCREEN);
    strokeWeight(8);
    stroke(150, 255, 255, 150);
    ellipse(0, 0, tWidth, tHeight );
    strokeWeight(4);

    stroke(100, 255, 255, 200);
    ellipse(0, 0, tWidth, tHeight );

    strokeWeight(2);
    stroke(80, 150, 255);
    ellipse(0, 0, tWidth, tHeight );

    strokeWeight(1);
    stroke(150, 0, 255);
    ellipse(0, 0, tWidth, tHeight);
    popStyle();
    blendMode(BLEND);
    popMatrix();
  }
}