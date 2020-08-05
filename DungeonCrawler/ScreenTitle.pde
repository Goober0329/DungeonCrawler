//<>// //<>// //<>// //<>// //<>// //<>//

class ScreenTitle implements Screen {

  PImage background;
  Animation[] pcAni;
  Animation[] npcAni;

  int pcSize = 48;

  float pcx, pcy;
  int pcdir;
  float npcx, npcy;
  int npcdir;

  float dist = 300;
  float speed = 2.2;
  float offd = pcSize*2;

  boolean typing = true;
  String playerName = "";
  int maxLength = 20;

  boolean mechanics = false;
  int sx, sy;

  boolean loadSavegameAvailable = false;

  ScreenTitle() {
    // title background
    background = loadImage("title background.png");
    background.resize(width, 0);
    sy = height-height/5;
    sx = width-width/10;

    String dataFolder;

    // pc animations
    dataFolder = "pixart/pc";
    pcAni = new Animation[2];
    pcAni[0] = new Animation(dataFolder+"/pc move left.png", 16, pcSize);
    pcAni[1] = new Animation(dataFolder+"/pc move right.png", 16, pcSize);
    pcy = random(height-pcSize);
    pcdir = floor(random(2)); // need this to be 1, -1 
    pcdir = (pcdir == 0) ? -1 : pcdir;
    pcx = (pcdir == 1) ? -offd : width+offd;

    // npc animations
    dataFolder = "pixart/npcs";
    String[] npcFolders = new String[]{"dwarves", "humans", "trolls", "ogres", "undead", "orcs"};
    String npcFolder = npcFolders[floor(random(npcFolders.length))];
    String[] npcs = listFileNames(dataFolder+"/"+npcFolder);
    int npc = floor(random(npcs.length));
    String name = npcs[npc].split("move")[0];
    int npcl = 0, npcr = 0;
    for (int i = 0; i < npcs.length; i++) {
      if (npcs[i].contains(name) && npcs[i].contains("left")) {
        npcl = i;
      }
      if (npcs[i].contains(name) && npcs[i].contains("right")) {
        npcr = i;
      }
    }
    npcAni = new Animation[2];
    npcAni[0] = new Animation(dataFolder+"/"+npcFolder+"/"+npcs[npcl], 16, pcSize);
    npcAni[1] = new Animation(dataFolder+"/"+npcFolder+"/"+npcs[npcr], 16, pcSize);
    npcx = (pcdir == 1) ? -offd-dist : width+offd+dist;
    npcy = pcy;
    npcdir = pcdir;

    // check to see if loading is an option
    loadSavegameAvailable = loadAvailable();
  }

  void update(PlayerCharacter pyc, DungeonLevel dlvl) {
    // update PC animation position
    pcx += speed*pcdir;
    if (pcx > width + offd && pcdir == 1) {
      pcdir = floor(random(2));
      pcdir = (pcdir == 0) ? -1 : pcdir;
      if (pcdir == -1) {
        pcy = random(height-pcSize);
      } else {
        pcx = -offd;
        pcy = random(height-pcSize);
      }
    } else if (pcx < -offd && pcdir == -1) {
      pcdir = floor(random(2));
      pcdir = (pcdir == 0) ? -1 : pcdir;
      if (pcdir == -1) {
        pcx = width + offd;
        pcy = random(height-pcSize);
      } else {
        pcy = random(height-pcSize);
      }
    }
    // update NPC animation position
    npcx += speed*npcdir;
    if (npcx > width + offd && npcdir == 1) {
      npcdir = pcdir;
      if (npcdir == -1) {
        npcy = pcy;
      } else {
        npcx = -offd;
        npcy = pcy;
      }
    } else if (npcx < -offd && npcdir == -1) {
      npcdir = pcdir;
      if (pcdir == -1) {
        npcx = width + offd;
        npcy = pcy;
      } else {
        npcy = pcy;
      }
    }

    // update player name typing
    // this is happening in the updatePlayerName function, being called in keyReleased

    if (loadSavegameAvailable) {
      // require y/n
      if (keys['y'][1]) {
        loading = true;
        loadSaveGame = true;
        startLoad = true;
        typing = false;
      } else if (keys['n'][1]) {
        loadSavegameAvailable = false;
      }
    } else {
      // check for mechanics open/close
      if (keys['?'][1]) {
        mechanics = !mechanics;
      }

      // start the game when enter is pressed
      if (keys[RENTER][1] && !mechanics) {
        loading = true;
        startLoad = true;
        typing = false;
      }
    }
    updateAudio();
  }

  void updateAudio() {
    SoundPlayer toUpdate;

    // background music
    toUpdate = music.get("titlescreen");
    if (!loading) {
      if (!toUpdate.isPlaying())
        music.get("titlescreen").play(true);
    } else {
      music.get("titlescreen").stop();
    }

    // Enter pressed or y for load savegame
    if (loading) {
      soundeffects.get("item equip").play(true);
    }

    // keys typed
    // probably nothing required here...

    // mechanics open/close
    if (keys['?'][1] && !loadSavegameAvailable) {
      soundeffects.get("item store").play(true);
    }
  }

  // this function is called in side of keyReleased (not pretty, but it works)
  void updatePlayerName(Character k) {
    if (mechanics || loadSavegameAvailable)
      return;

    // normal key (letter, number)
    if (Character.isLetter(k) || Character.isDigit(k) || k == ' ') {
      if (playerName.length() < maxLength) {
        playerName += k;
      }
    } else if (keys[DELSPACE][1]) {
      if (playerName.length() > 0) {
        playerName = playerName.substring(0, playerName.length()-1);
      }
    }
  }

  void display(PlayerCharacter pyc, DungeonLevel dlvl) {
    imageMode(CORNER);
    image(background, 0, 0);
    int mod = (int)(10-speed);  
    // display PC animation
    if (pcdir == -1) {
      pcAni[0].displayAnimation(pcx, pcy, mod);
    } else {
      pcAni[1].displayAnimation(pcx, pcy, mod);
    }
    // display NPC animation
    if (npcdir == -1) {
      npcAni[0].displayAnimation(npcx, npcy, mod);
    } else {
      npcAni[1].displayAnimation(npcx, npcy, mod);
    }

    textAlign(CENTER, CENTER);
    fill(0, 255, 0);
    textFont(dungeonFonts.get(120));
    text(title, width/2, height/5);

    // need to implement character names
    textFont(dungeonFonts.get(60));
    text("Player Name: ", width/2, height/2);
    mod = 60;
    String toShow = playerName.length() == 0 ? "-------" : playerName;
    if (frameCount%mod < mod-mod/6 || loadSavegameAvailable) {
      fill(0, 255, 0);
      text(toShow, width/2, height/2+height/10);
    } else {
      fill(0, 230, 0);
      text(toShow, width/2, height/2+height/10);
    }

    // display loadgame option and press enter option
    if (loadSavegameAvailable) {
      textFont(dungeonFonts.get(60));
      if (frameCount%mod < mod-mod/6) {
        fill(0, 255, 0);
      } else {
        fill(0, 230, 0);
      }
      text("Load Saved Game? [y/n]", width/2, height-height/8);
    } else {
      textFont(dungeonFonts.get(50));
      fill(0, 255, 0);
      text("Press Enter to Begin", width/2, height-height/8);
    }

    // mechanics
    noFill();
    strokeWeight(1);
    stroke(0, 255, 0);
    ellipse(width-20, height-20, 25, 25);
    textFont(dungeonFonts.get(40));
    text("?", width-20, height-22);

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

  String getPlayerName() {
    return playerName.length() == 0 ? "no name" : playerName;
  }
}
