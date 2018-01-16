class Plattform {

  PVector position = new PVector(0, 0);
  int pWidth =60;
  int pHeight =5;
  float [] boundingbox = new float[4];


  Plattform(PVector pos) {
    position= pos.copy();
  }

  void update() {
    boundingbox=makeBoundingbox();
  }

  void render() {

    pushMatrix();
    translate(position.x, position.y);
    pushStyle();
    fill(0,255,255);
    rect(0, 0, pWidth, pHeight);
    popStyle();
    popMatrix();
    
    drawBoundingbox();
  }



  void drawBoundingbox() {
    pushMatrix();
    pushStyle();
    rectMode(CORNER);
    noFill();
   // colorMode(RGB);
    stroke(0, 255, 0);
    rect(boundingbox[0], boundingbox[1], boundingbox [2]-boundingbox [0], boundingbox [3]-boundingbox [1]);
    popStyle();
    popMatrix();
  }


  float [] makeBoundingbox() {
    float [] bounds = new float[4];
    bounds[0]=position.x;
    bounds [1]=position.y;
    bounds [2]=position.x+pWidth;
    bounds [3]=position.y+pHeight;
    return bounds;
  }

  float [] getBoundingbox() {
    return boundingbox;
  }
}