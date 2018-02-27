class Plattform {

  PVector position = new PVector(0, 0);
  int pWidth =PLATTFORMWIDTH;
  int pHeight =5;
  float [] boundingbox = new float[4];

  float blinktheta=0;

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
    noStroke();
    colorMode(HSB);
    float s=255;
    int yp=0;
    int rand=(int)random(100,120);
    for (int i=0; i<rand; i++) {
      fill(180, s, 255,map(i,0,rand,180,0));
      rect(0, yp, pWidth, pHeight);
      s=map(i, 0, 100, 200, 0);
      yp-=5;
    }
    colorMode(RGB);
    float alpha=255+sin(blinktheta+PI)*255;
    fill(255,0,0,alpha);
    rect(-pWidth/2, 0, 10, 10);
    alpha= 255+sin(blinktheta)*255;
    fill(255,0,0, alpha);
    rect(0, 0, 10, 10);
    alpha= 255+sin(blinktheta+PI)*255;
    fill(255,0,0, alpha);
    rect(pWidth/2, 0, 10, 10);
    blinktheta+=0.1;
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