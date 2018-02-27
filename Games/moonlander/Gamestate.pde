

// GAMESTATE HELPER / HANDLER
void changeGameState(int _state) {
  println(_state);
  gamestate=_state;
  switch(_state) {
  case COUNTDOWN:
    countdown.startCountdown();
    break;
  }
}



void gameStateRenderHandler(){
 switch(gamestate) {




  case PLAYING:

    // We must always step through time!
    box2d.step();

    // Draw the surface
    //surface.display();

    // Display all the people
    for (CustomShape cs : polygons) {
      cs.display();
    }

    // people that leave the screen, we delete them
    // (note they have to be deleted from both the box2d world and our list
    for (int i = polygons.size()-1; i >= 0; i--) {
      CustomShape cs = polygons.get(i);
      if (cs.done()) {
        polygons.remove(i);
      }
    }
    break;

  case LANDED:
    // Display all the people
    for (CustomShape cs : polygons) {
      cs.display();
    }
    text("YOU WIN", width/2, height/2);

    break;

  case CRASHED:
    text("YOU LOOSE", width/2, height/2);
    break;

  case STARTSCREEN:
    text("START", width/2, height/2);
    break;

  case COUNTDOWN:
    countdown.update();
    countdown.display();
    break;
  }

}