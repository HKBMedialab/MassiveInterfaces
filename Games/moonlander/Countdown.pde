class Countdown {
  int starttime;
  int starttimeInSeconds;

  int duration=5000;
  int startseconds=5;
  boolean bIsCountdownOver=false;
  Countdown() {
    starttime=millis();
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