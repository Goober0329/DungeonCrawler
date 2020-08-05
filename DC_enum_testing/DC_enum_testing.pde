
// start, saveExit, death, win;
// 1, 2, 3, 4

int MAXKEYS = 256;
boolean[][] keys = new boolean[MAXKEYS][2];

GameStates states;
void setup() {
  states = GameStates.TitleScreen;
  println(states.toString());
}

String prevString;
void draw() {
  prevString = states.toString();
  states = states.nextState(keys, keys['1'][0], keys['2'][0], keys['3'][0], keys['4'][0]);
  if (!prevString.equals(states.toString())) {
    println(states.toString());
  }
}


void keyPressed() {
  updateKeys(key, true, false);
  if (key == ESC) {
    key = 0;
  }
}

void keyReleased() {
  updateKeys(key, false, true);
  if (key == ESC) {
    key = 0;
  }
}

// keys[pressed][released]
void updateKeys(int k, boolean p, boolean r) {
  if (k < MAXKEYS) {
    keys[k][0] = p;
    keys[k][1] = r;
  }

  // arrow keys etc...
}

// keep track of pressed and released as boolean variables
// reset released boolean after variable is used.


public enum GameStates {

  TitleScreen {
    @Override
      GameStates nextState(boolean[][] input, boolean start, boolean saveExit, boolean death, boolean win) {
      if (start) {
        return NormalGameplay;
      } else {
        return TitleScreen;
      }
    }
  }
  , 
    NormalGameplay {
    @Override
      GameStates nextState(boolean[][] input, boolean start, boolean saveExit, boolean death, boolean win) {
      if (death) {
        return DeathScreen;
      } else if (win) {
        return EndGame;
      } else if (input[ESC][1]) {
        input[ESC][1] = false;
        return MenuScreen;
      } else if (input['m'][1]) {
        input['m'][1] = false;
        return FullMapView;
      } else if (input['c'][1]) {
        input['c'][1] = false;
        return CharacterInformationView;
      } else {
        return NormalGameplay;
      }
    }
  }
  , 
    MenuScreen {
    @Override
      GameStates nextState(boolean[][] input, boolean start, boolean saveExit, boolean death, boolean win) {
      if (saveExit) {
        return TitleScreen;
      } else if (input[ESC][1]) {
        input[ESC][1] = false;
        return NormalGameplay;
      } else {
        return MenuScreen;
      }
    }
  }
  , 
    DeathScreen {
    @Override
      GameStates nextState(boolean[][] input, boolean start, boolean saveExit, boolean death, boolean win) {
      int todo; // stats
      return TitleScreen;
    }
  }
  , 
    FullMapView {
    @Override
      GameStates nextState(boolean[][] input, boolean start, boolean saveExit, boolean death, boolean win) {
      if (input['m'][1]) {
        input['m'][1] = false;
        return NormalGameplay;
      } else if (input['c'][1]) {
        input['c'][1] = false;
        return CharacterInformationView;
      } else {
        return FullMapView;
      }
    }
  }
  , 
    CharacterInformationView {
    @Override
      GameStates nextState(boolean[][] input, boolean start, boolean saveExit, boolean death, boolean win) {
      if (input['c'][1]) {
        input['c'][1] = false;
        return NormalGameplay;
      } else if (input['m'][1]) {
        input['m'][1] = false;
        return FullMapView;
      } else {
        return CharacterInformationView;
      }
    }
  }
  , 
    EndGame {
    @Override
      GameStates nextState(boolean[][] input, boolean start, boolean saveExit, boolean death, boolean win) {
      int todo; // credits
      return TitleScreen;
    }
  }; 

  abstract GameStates nextState(boolean[][] input, boolean start, boolean saveExit, boolean death, boolean win);
}
