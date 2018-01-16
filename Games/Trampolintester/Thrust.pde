class Thrust {

  PVector position=new PVector (0, 80);
  PVector speed=new PVector (0, 3);

  float tWidth=80;
  float tHeight=10;
  Thrust() {
  }
  void update() {
   
    position.add(speed);
    tWidth-=3;
    tHeight-=0.3;
  }
}