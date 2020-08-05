

class ScreenMenu implements Screen {

  PImage background;
  int ss, sx, sy;

  boolean save = false;
  boolean savexit = false;

  boolean mechanics = false;

  boolean musi = false;
  boolean effe = false;
  int sliderLength;

  boolean exit = false;

  ScreenMenu(PImage backImage) {
    ss = height-height/10;
    sy = height-height/5;
    sx = width-width/10;
    background = backImage.get(backImage.width/2-ss/2, backImage.height/2-ss/2, ss, ss);
    sliderLength = ss*3/5;
  }

  void update(PlayerCharacter pyc, DungeonLevel dlvl) {
    if (exit) {
      exit();
    }

    if (keys['?'][1]) {
      mechanics = !mechanics;
      soundeffects.get("item store").play(true);
    }
    if (mechanics)
      return;

    // update boolean variables
    save = keys['s'][0];
    savexit = keys['S'][0];
    musi = keys['m'][0];
    effe = keys['e'][0];

    // save or save/exit based on booleans
    if (save) {
      soundeffects.get("item drop").play(true);
      // run save script
      saveGame();
    } else if (savexit) {
      soundeffects.get("item expunge").play(true);
      // run save script and quit program.
      saveGame();
      exit = true;
    }

    if (musi) {
      boolean changed = false;
      if (keys[ARROWLEFT][1]) {
        musicVolume--;
        changed = true;
      } else if (keys[ARROWRIGHT][1]) {
        musicVolume++;
        changed = true;
      }
      musicVolume = constrain(musicVolume, 0, 10);

      // adjust music volume
      if (changed) {
        soundeffects.get("item store").play(true);
        // adjust all music volume based on global variable musicVolume
        for (HashMap.Entry<String, SoundPlayer> entry : music.entrySet()) {
          music.get(entry.getKey()).adjustVolume(musicVolume, 10, true);
        }
        saveVolume();
      }
    } 

    if (effe) {
      boolean changed = false;
      if (keys[ARROWLEFT][1]) {
        effectVolume--;
        changed = true;
      } else if (keys[ARROWRIGHT][1]) {
        effectVolume++;
        changed = true;
      }
      effectVolume = constrain(effectVolume, 0, 10);
      // adjust sound effect volume
      if (changed) {
        soundeffects.get("item store").play(true);
        // adjust all sound effect volume based on global variable effectVolume
        for (HashMap.Entry<String, SoundPlayer> entry : soundeffects.entrySet()) {
          soundeffects.get(entry.getKey()).adjustVolume(effectVolume, 10, true);
        }
        saveVolume();
      }
    }

    // update gametime
    pc.updateGametime();
  }

  void display(PlayerCharacter pyc, DungeonLevel dlvl) {
    noFill();
    stroke(150);
    strokeWeight(5);
    rectMode(CENTER);
    textAlign(CENTER, CENTER);

    tint(230);
    image(background, width/2, height/2);
    rect(width/2, height/2, ss, ss, 5);

    strokeWeight(1);
    stroke(25);
    color f = color(150);
    color t = color(120);
    float x, y;
    textFont(generalFonts.get(18));

    // display volume sliders
    x = width/2+ss/8+15;
    y = height-(height-ss)/2-ss/8;
    fill(f);
    rect(x, y, sliderLength, 10, 10);
    fill(effe ? t : f);
    x = map(effectVolume, 0, 10, x-sliderLength/2, x+sliderLength/2);
    ellipse(x, y, 15, 15);
    fill(200);
    text("Sound Effects [e]", width/2-ss/2+ss/6, y-3);

    x = width/2+ss/8+15;
    y = height-(height-ss)/2-ss/5;
    fill(f);
    rect(x, y, sliderLength, 10, 10);
    fill(musi ? t : f);
    x = map(musicVolume, 0, 10, x-sliderLength/2, x+sliderLength/2);
    ellipse(x, y, 15, 15);
    fill(200);
    text("Background Music [m]", width/2-ss/2+ss/6, y-3);

    // display save buttons
    textFont(generalFonts.get(18));
    x = width/2-ss/2+ss*2/5-15;
    y = height-(height-ss)/2-ss/20;
    fill(save ? t : f);
    rect(x, y, 100, 30, 5);
    fill(0);
    text("Save [s]", x, y-3);

    x = width/2+ss/2-ss*2/5+15;
    y = height-(height-ss)/2-ss/20;
    fill(savexit ? t : f);
    rect(x, y, 120, 30, 5);
    fill(0);
    text("Save/Quit [S]", x, y-3);

    // show player stats
    textFont(generalFonts.get(22));
    fill(200);
    textAlign(CORNER);
    x = width/2-ss/2+20;
    y = height/2-ss/2+45;
    String toShow = pyc.name+"'s Score\n"
      +"  Score: "+pyc.getScore()+"\n"
      +"   Accrued Wealth: "+wealthToText(pyc.getWealth())+"\n"
      +"   Enemies Killed: "+pyc.npcKills+"\n"
      +"   Bosses Killed: "+pyc.bossKills+"\n"
      +"   Game Time: "+millisToTime(pyc.gametime);
    text(toShow, x, y);

    // show high scores
    x = width/2+ss/2-230;
    String highscoresText = "Highscores:\n";
    int i = 1;
    for (String[] score : highscores) {
      if (i > 5) 
        break;
      highscoresText += "  "+i+". "+score[0]+": "+score[1]+"\n";
      i++;
    }
    text(highscoresText, x, y);


    // show ? button
    noFill();
    strokeWeight(1);
    stroke(f);
    ellipse(width/2+ss/2-20, height/2+ss/2-20, 25, 25);
    textFont(generalFonts.get(20));
    textAlign(CENTER, CENTER);
    text("?", width/2+ss/2-20, height/2+ss/2-22);

    // display mechanics
    if (mechanics) {
      displayMechanics();
    }
  }

  void displayMechanics() {
    fill(100);
    stroke(150);
    strokeWeight(5);
    rectMode(CENTER);
    rect(width/2, height/2, sx, sy, 5);
    textAlign(LEFT, CENTER);
    fill(0);
    String[] parts;
    int titleCount = 0;
    float x0 = width/2-sx/2+20;
    float y0 = height/2-sy/2+20;
    int off = 0;
    for (int i = 0; i < gameMechanics.length; i++) {
      if (gameMechanics[i].equals("#")) {
        x0 = width/2;
        off = i+1;
        titleCount = 0;
        continue;
      }
      parts = gameMechanics[i].split("@");
      if (parts.length == 1) {
        textFont(generalFonts.get(23));
        text(parts[0], x0, y0+1*titleCount+19*(i-off));
        titleCount++;
      } else if (parts.length == 2) {
        textFont(generalFonts.get(19));
        text("   "+parts[0], x0, y0+1*titleCount+19*(i-off));
        text("- "+parts[1], x0+130, y0+1*titleCount+19*(i-off));
      }
    }

    // display game creator information
    String toDisplay = "Grayson Harrington,  2020";
    textAlign(RIGHT, BOTTOM);
    float x = width/2+sx/2-10;
    float y = height/2+sy/2-10;
    text(toDisplay, x, y);
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
