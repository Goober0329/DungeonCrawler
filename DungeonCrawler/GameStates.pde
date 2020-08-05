
class GameStateController {

  GameState state, oldstate;
  boolean start, saveExit, death, win;

  GameStateController(GameState state) {
    this.state = state;
  }

  void update(boolean[][] keys) {
    oldstate = state;
    state = state.nextState(keys, start, saveExit, death, win);

    // have sounds here based on state changes.
    if (oldstate != state) {
      // scroll sound states
      if (state == GameState.FullMapView || oldstate == GameState.FullMapView ||
        state == GameState.CharacterInformationView || oldstate == GameState.CharacterInformationView ||
        state == GameState.MenuScreen || oldstate == GameState.MenuScreen) {
        soundeffects.get("scroll open close").play(true);
      }

      // end game
      if (state == GameState.EndGame) {
        music.get("gameplay").stop();
        music.get("titlescreen").play(true);
      }

      // gameplay
      if (state == GameState.NormalGameplay) {
        if (oldstate == GameState.FullMapView ||
          oldstate == GameState.CharacterInformationView ||
          oldstate == GameState.MenuScreen) {
          // do nothing
        } else {
          music.get("gameplay").play(false);
        }
      }
    } else if (state == GameState.NormalGameplay || 
      state == GameState.FullMapView ||
      state == GameState.CharacterInformationView ||
      state == GameState.MenuScreen) {
      if (!music.get("gameplay").isPlaying()) {
        music.get("gameplay").play(false);
      }
    }
  }

  void setState(GameState s) {
    state = s;
  }

  void setStart(boolean b) {
    start = b;
  }

  void setSaveExit(boolean b) {
    saveExit = b;
  }

  void setDeath(boolean b) {
    death = b;
  }

  void setWin(boolean b) {
    win = b;
  }

  void resetStateManagement() {
    start = false; 
    saveExit = false; 
    death = false; 
    win = false;
  }

  String stateToString() {
    return state.toString();
  }
}

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

public enum GameState {

  TitleScreen {
    @Override
      GameState nextState(boolean[][] input, boolean start, boolean saveExit, boolean death, boolean win) {
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
      GameState nextState(boolean[][] input, boolean start, boolean saveExit, boolean death, boolean win) {
      if (win || death) {
        return EndGame;
      } else if (input[ESC][1]) {
        return MenuScreen;
      } else if (input['m'][1]) {
        return FullMapView;
      } else if (input['c'][1]) {
        return CharacterInformationView;
      } else {
        return NormalGameplay;
      }
    }
  }
  , 
    MenuScreen {
    @Override
      GameState nextState(boolean[][] input, boolean start, boolean saveExit, boolean death, boolean win) {
      if (saveExit) {
        return TitleScreen;
      } else if (input[ESC][1]) {
        return NormalGameplay;
      } else {
        return MenuScreen;
      }
    }
  }
  , 
    FullMapView {
    @Override
      GameState nextState(boolean[][] input, boolean start, boolean saveExit, boolean death, boolean win) {
      if (input['m'][1]) {
        return NormalGameplay;
      } else if (input['c'][1]) {
        return CharacterInformationView;
      } else {
        return FullMapView;
      }
    }
  }
  , 
    CharacterInformationView {
    @Override
      GameState nextState(boolean[][] input, boolean start, boolean saveExit, boolean death, boolean win) {
      if (input['c'][1]) {
        return NormalGameplay;
      } else if (input['m'][1]) {
        return FullMapView;
      } else {
        return CharacterInformationView;
      }
    }
  }
  , 
    EndGame {
    @Override
      GameState nextState(boolean[][] input, boolean start, boolean saveExit, boolean death, boolean win) {

      if (input['?'][1]) {
        return NormalGameplay;
      }
      return EndGame;
    }
  }; 

  abstract GameState nextState(boolean[][] input, boolean start, boolean saveExit, boolean death, boolean win);
}
