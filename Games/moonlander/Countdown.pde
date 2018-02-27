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
    int time=startseconds-floor((millis()-starttime)/1000)-1;
    text(time+1, 11, 100);
  }

  void endCountdown() {
    changeGameState(PLAYING);
    println("Countdown end!");
    liftoff.rewind();
    liftoff.play();
    ambisound.setVolume(0.1);
  }
  void startCountdown() {
    starttime=millis();
    bIsCountdownOver=false;
    countdownsound.rewind();
    countdownsound.play();
    ambisound.setVolume(0.1);
  }
  boolean getIsCountdownOver() {
    return bIsCountdownOver;
  }
}