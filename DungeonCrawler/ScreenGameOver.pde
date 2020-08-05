 //<>//

class ScreenEndGame implements Screen {
  PImage background;
  int ss;

  boolean accessed = false;
  boolean won;
  int score;

  Animation[] pcAni;
  int pcSize = dmTileSize;
  float pcx, pcy;
  int pcdir;
  float speed = 2.2;

  ScreenEndGame(PImage backImage) {
    ss = height-height/10;
    background = backImage.get(backImage.width/2-ss/2, backImage.height/2-ss/2, ss, ss);
  }

  void update(PlayerCharacter pyc, DungeonLevel dlvl) {
    // one time function upon opening the screen for the first time.
    if (!accessed) {
      won = pyc.health > 0;
      accessed = true;
      score = pyc.getScore() + (won ? 1000 : 0);
      writeScoreToFile(pyc.name, score);
      removeSavedGame();

      if (won) {
        // init pc animations
        String dataFolder = "pixart/pc";
        pcAni = new Animation[2];
        pcAni[0] = new Animation(dataFolder+"/pc move left.png", 16, pcSize);
        pcAni[1] = new Animation(dataFolder+"/pc move right.png", 16, pcSize);
        pcy = height/2+pcSize;
        pcdir = floor(random(2)); // need this to be 1, -1 
        pcdir = (pcdir == 0) ? -1 : pcdir;
        pcx = (pcdir == 1) ? width/2-ss/2 : width/2+ss/2-pcSize;
      }
    }

    if (won) {
      // update PC animation position
      pcx += speed*pcdir;
      if (pcx > width/2+ss/2-pcSize || pcx < width/2-ss/2) {
        pcdir *= -1;
      }
    }

    // return to the homescreen
    if (keys[RENTER][1]) {
      stateController.setState(GameState.TitleScreen);
      stateController.resetStateManagement();
      ((ScreenTitle)tScreen).typing = true;
    }
  }

  void display(PlayerCharacter pyc, DungeonLevel dlvl) {
    if (won) {
      displayVictoryBackground();
    } else {
      displayLossBackground();
    }
    displayStats(pyc);
  }

  void displayLossBackground() {
    noFill();
    stroke(150);
    strokeWeight(5);
    rectMode(CENTER);
    imageMode(CENTER);
    textAlign(CENTER, CENTER);

    tint(230);
    image(background, width/2, height/2);
    rect(width/2, height/2, ss, ss, 5);
  } 

  void displayVictoryBackground() {

    // add blue background
    fill(#74BEF5);
    noStroke();
    rectMode(CENTER);
    rect(width/2, height/2, ss, ss);

    float x, y;
    int tSize = pixelart.get("grass").frames[0].width;
    int layers = 3;
    x = width/2-ss/2;
    y = height/2+ss/2-tSize;
    for (int j = layers; j >= 0; j--) {
      for (int i = 0; i < ss/tSize; i++) {
        displayPixelArtStatic("wtiling", j, x, y, 255, false);
        x += tSize;
      }
      x = width/2-ss/2;
      y -= tSize;
    }
    for (int i = 0; i < ss/tSize; i++) {
      displayPixelArtStatic("grass", 0, x, y, 255, false);
      x += tSize;
    }

    // pc
    int mod = (int)(10-speed); 
    if (pcdir == -1) {
      pcAni[0].displayAnimation(pcx, pcy, mod);
    } else {
      pcAni[1].displayAnimation(pcx, pcy, mod);
    }

    // border
    noFill();
    stroke(150);
    strokeWeight(5);
    rectMode(CENTER);
    rect(width/2, height/2, ss, ss, 5);
  }

  void displayStats(PlayerCharacter pyc) {
    textAlign(CENTER, CENTER);
    fill(0, 255, 0);
    textFont(dungeonFonts.get(55));
    text(won ? "You Survived the Dungeon!" : "You Died in the Dungeon...", width/2, height/2-ss/2+55);

    float x, y;
    // show player stats
    textFont(generalFonts.get(24));
    fill(won ? 50 : 200);
    textAlign(CORNER);
    x = width/2-ss/2+20;
    y = height/2-ss/4;
    String toShow = pyc.name+"'s Score\n"
      +" Score: "+score+"\n"
      +"  Accrued Wealth: "+wealthToText(pyc.getWealth())+"\n"
      +"  Enemies Killed: "+pyc.npcKills+"\n"
      +"  Bosses Killed: "+pyc.bossKills+"\n"
      +"  Game Time: "+millisToTime(pyc.gametime);
    text(toShow, x, y);

    // show high scores
    x = width/2+ss/2-230;
    String highscoresText = "Highscores:\n";
    int i = 1;
    for (String[] sc : highscores) {
      if (i > 5) 
        break;
      highscoresText += "  "+i+". "+sc[0]+": "+sc[1]+"\n";
      i++;
    }
    text(highscoresText, x, y);

    textFont(dungeonFonts.get(45));
    fill(0, 255, 0);
    textAlign(CENTER, CENTER);
    text("Press Enter to Leave", width/2, height/2+ss/2-55);
  }

  String millisToTime(int time) {
    String toReturn = "";
    time = time/1000; // seconds
    int h = time/60/60;
    int m = (time-h*60*60)/60;
    int s = (time-h*60*60-m*60);
    toReturn += nf(h, 2)+":"+nf(m, 2)+":"+nf(s, 2);
    return toReturn;
  }

  String wealthToText(int wealth) {
    int c, s, g;
    c = wealth;
    s = c/20;
    c = c-s*20;
    g = s/20;
    s = s-g*20;
    return ""+g+"g, "+s+"s, "+c+"c";
  }
}
