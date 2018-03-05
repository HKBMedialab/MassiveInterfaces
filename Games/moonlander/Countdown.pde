class Countdown {
  int starttime;
  int starttimeInSeconds;

  int duration=5000;
  int startseconds=5;
  boolean bIsCountdownOver=false;

  PImage [] countdownimages= new PImage[6];

  Countdown() {
    starttime=millis();
  }

  void setup() {

    countdownimages[5]=loadImage("grafik/count_5.png");
    countdownimages[4]=loadImage("grafik/count_4.png");
    countdownimages[3]=loadImage("grafik/count_3.png");
    countdownimages[2]=loadImage("grafik/count_2.png");
    countdownimages[1]=loadImage("grafik/count_1.png");
    countdownimages[0]=loadImage("grafik/count_1.png");
  }

  void update() {
    if (millis()>duration+starttime) {
      bIsCountdownOver=true;
      endCountdown();
    }
  }
  void display() {
    textSize(100);
    pushStyle();
    textAlign(CENTER, CENTER); 
    textSize(60);

    int time=startseconds-floor((millis()-starttime)/1000)-1;
    fill(255, 0, 0);
    text(time+1, (width/2), int(height/2));
    fill(0);
    textSize(50);

    text(time+1, (width/2), int(height/2));
    popStyle();

    pushMatrix();
    translate(width/2-countdownimages[time+1].width/2, height/2-countdownimages[time+1].height/2);
    image(countdownimages[time+1], 0, 0);
    popMatrix();
  }

  void endCountdown() {
    changeGameState(PLAYING);
    println("Countdown end!");
  }
  void startCountdown() {
    starttime=millis();
    bIsCountdownOver=false;
  }
  boolean getIsCountdownOver() {
    return bIsCountdownOver;
  }
}