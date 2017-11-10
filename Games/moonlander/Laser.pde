class Laser {


  PVector velocity=new PVector(0, 0);
  PVector acceleration=new PVector(0, 0);
  PVector position =new PVector(0, 0);
  float maxSpeed=10;


  Laser(PVector _position, PVector _direction) {
    _direction.normalize();
    _direction.setMag(maxSpeed);
    velocity=_direction.copy();
    position=_position.copy();
  }

  void render() {

    pushStyle();
    pushMatrix();
    stroke(#FF08E3);
    strokeWeight(5);
    translate(position.x, position.y);
    rotate(velocity.heading()-PI/2);
    line(0, 0, 0, 10);
    popMatrix();
    popStyle();
  }


  void update() {
    steer();
    acceleration.set(0, 0, 0);
  }


  void steer() {
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    position.add(velocity);
  }

  void move() {
    position.add(velocity);
  }



  void applyGravity(PVector pos, float force) {
    PVector p=pos.copy();
    PVector pp=position.copy();
    p.sub(pp);
    p.normalize();
    p.setMag(force);
    applyForce(p);
  }

  void applyForce(PVector force) {
    PVector f=force.get();
    acceleration.add(f);
  }
}