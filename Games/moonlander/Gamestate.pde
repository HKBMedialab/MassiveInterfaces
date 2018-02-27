

// GAMESTATE HELPER / HANDLER
void changeGameState(int _state) {
  println(_state);
  gamestate=_state;
  switch(_state) {

  case STARTSCREEN:
    ambisound.shiftGain(ambisound.getGain(), AMBIMAX, 1000);

    break;


  case PLAYING:
    ambisound.shiftGain(ambisound.getGain(), AMBIMAX, 1000);
    liftoff.rewind();
    liftoff.setGain(5);
    liftoff.play();
    break;

  case COUNTDOWN:
    countdown.startCountdown();
    countdownsound.rewind();
    countdownsound.play();
    ambisound.shiftGain(ambisound.getGain(), AMBIMUTE, 1000);
    break;

  case LANDED:
    println(landed.getVolume()+" "+landed.getGain());
    landed.rewind();
    landed.setVolume(100);
    landed.play();
    ambisound.shiftGain(ambisound.getGain(), AMBIMUTE, 1000);
    break;
  }
}



void gameStateRenderHandler() {
  switch(gamestate) {




  case PLAYING:

    // We must always step through time!
    box2d.step();

    // Draw the surface
    //surface.display();

    player1.display();
    player2.display();

    // people that leave the screen, we delete them
    // (note they have to be deleted from both the box2d world and our list
    /*  for (int i = polygons.size()-1; i >= 0; i--) {
     CustomShape cs = polygons.get(i);
     if (cs.done()) {
     polygons.remove(i);
     }
     }*/
    break;

  case LANDED:
    player1.display();
    player2.display();
    text("YOU WIN", width/2, height/2);
    break;

  case CRASHED:
    text("YOU LOOSE", width/2, height/2);
    break;

  case STARTSCREEN:
    text("START", width/2, height/2);
    player1.display();
    player2.display();
    break;

  case COUNTDOWN:
    player1.display();
    player2.display();
    countdown.update();
    countdown.display();
    break;
  }
}