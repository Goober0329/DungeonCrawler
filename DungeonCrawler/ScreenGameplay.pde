//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
/****************************************************************************************************/
/****************************** Character Information Screen ****************************************/
/****************************************************************************************************/
class ScreenGameplay implements Screen {

  boolean newNPClist = false;
  ArrayList<NonPlayerCharacter> npcList;
  int npcListPos = 0;

  ScreenGameplay() {
    this.npcList = new ArrayList<NonPlayerCharacter>();
  }

  void update(PlayerCharacter pyc, DungeonLevel dlvl) {
    if (!gamePause) {
      updateMouseDir();
      pyc.update(dlvl);
      dlvl.update(pyc);

      if (frameCount%60 == 0) {
        updateNPClist(pyc, dlvl);
      }

      if (pyc.health <= 0) {
        stateController.setDeath(true);
      }
    } else {
      if (newNPClist) {
        updateNPClistPos();
        updateNPClist(pyc, dlvl);
        newNPClist = false;
      }
      updateNPClistPos();
    }
    boolean gpold = gamePause;
    gamePause = checkPause() ? !gamePause : gamePause;
    newNPClist = (gpold != gamePause && gamePause == true);
  }

  void updateNPClist(PlayerCharacter pyc, DungeonLevel dlvl) {
    npcList.clear();
    for (NonPlayerCharacter npc : dlvl.npcs) {
      if (pbcDist(npc.pos.x, npc.pos.y, pyc.pos.x, pyc.pos.y, dlvl.dmSize) < pyc.sight) {
        npcList.add(npc);
      }
    }
    npcList.sort(new Comparator() {
      public int compare(Object o1, Object o2) {
        return Float.compare(((NonPlayerCharacter) o1).pos.x, ((NonPlayerCharacter) o2).pos.x);
      }
    }
    );
  }

  void updateNPClistPos() {
    if (keys[ARROWLEFT][1]) {
      npcListPos -= 1;
    }
    if (keys[ARROWRIGHT][1]) {
      npcListPos += 1;
    }
    npcListPos = npcListPos < 0 ? npcListPos+npcList.size() : (npcListPos >= npcList.size() ? npcListPos-npcList.size() : npcListPos);
  }

  void display(PlayerCharacter pyc, DungeonLevel dlvl) {
    dlvl.display(pyc);
    pyc.display(dlvl.dmSize);

    displayHUD(pyc);

    displayGuide(pyc, dlvl);

    if (gamePause) {
      npcListPos = npcListPos < 0 ? npcListPos+npcList.size() : (npcListPos >= npcList.size() ? npcListPos-npcList.size() : npcListPos);
      displayNPClist(pyc, dlvl.dmSize, dlvl.dmTileSize);
    }
  }

  void displayHUD(PlayerCharacter pyc) {
    rectMode(CORNER);
    textAlign(LEFT, TOP);
    textFont(generalFonts.get(18));

    float x, y;

    // player
    fill(255, 150);
    String player = pyc.name+": "+pyc.health+" hp";
    x = 10;
    y = 10;
    rect(x, y, player.length()*9, 25, 5);
    fill(0);
    text(player, x+5, y+1);

    y += 40;
    for (NonPlayerCharacter np : npcList) {
      // nearest
      fill(255, 150);
      String npc = np.name+": "+np.health+" hp";
      rect(x, y, npc.length()*9, 25, 5);
      fill(0);
      text(npc, x+5, y+1);
      y += 25;
    }
  }

  void displayGuide(PlayerCharacter pyc, DungeonLevel dlvl) {
    if (pyc.hasAttr("SCARD")) {
      // show direction the pyc should move in toward nearest stair up.
      Tile nt = dlvl.pf.nextTileToStair(dlvl.dm.upstair, 3);
      PVector dir = pbcDir(new PVector(nt.x+0.5, nt.y+0.5), pyc.pos, dlvl.dmSize);
      showArrow(width-height/10, height/10, dir, 20);
    } else if (pyc.hasAttr("CARD")) {
      // cardinal direction toward stairs. not exact.
      Tile nt = dlvl.dm.upstair;
      PVector dir = pbcDir(new PVector(nt.x+0.5, nt.y+0.5), pyc.pos, dlvl.dmSize);
      showArrow(width-height/10, height/10, dir, 20);
    }
  }

  void showArrow(int x, int y, PVector dir, float len) {
    fill(0, 255, 0);
    strokeWeight(1);
    stroke(0, 255, 0);

    pushMatrix();
    translate(x, y);
    rotate(dir.heading()-PI/2);
    rectMode(CENTER);
    rect(0, 0, len/8, len);
    triangle(0, len/2+len/4, len/4, len/2, -len/4, len/2);
    popMatrix();
  }

  void displayNPClist(PlayerCharacter pyc, int dmSize, float tileSize) {
    // get selected NPC
    if (npcList.size() == 0) {
      return;
    }
    NonPlayerCharacter npc = npcList.get(npcListPos);

    // determine rect width and height
    float w = 0;
    float h = 0;
    String[][] text = new String[2][4];
    for (int i = 0; i < text.length; i++) {
      for (int j = 0; j < text[0].length; j++) {
        text[i][j] = "";
      }
    }
    text[0][0] = "Name:";
    text[0][1] = npc.name;
    text[0][2] = "Health:";
    text[0][3] = ""+npc.health;
    text[1][0] = npc.desc;

    int xspacing = 15;
    int yspacing = 5;
    float lineHeight = textAscent()+textDescent();
    for (int i = 0; i < text[0].length; i++) {
      w += textWidth(text[0][i])+xspacing;
    }
    w += xspacing;
    float descHeight = (textWidth(text[1][0])/w+1)*(lineHeight+yspacing);
    h = lineHeight*3+yspacing+descHeight;

    // determine which corner to display the rect on
    PVector dir = pbcDir(npc.pos, pyc.pos, dmSize);
    float dist = pbcDist(npc.pos, pyc.pos, dmSize);
    float x = width/2+(dir.x*dist)*tileSize;
    float y = height/2+(dir.y*dist)*tileSize;

    boolean right = !(x+w > width);
    boolean bottom = !(y+h > height);

    // display the rect and text.
    rectMode(CORNER);
    fill(100);
    stroke(150);
    if (right && bottom) {
      showSelectedNPC(text, x, y, w, h, xspacing, lineHeight, descHeight);
    } else if (right && !bottom) {
      y = y-h;
      showSelectedNPC(text, x, y, w, h, xspacing, lineHeight, descHeight);
    } else if (!right && bottom) {
      x = x-w;
      showSelectedNPC(text, x, y, w, h, xspacing, lineHeight, descHeight);
    } else {
      x = x-w;
      y = y-h;
      showSelectedNPC(text, x, y, w, h, xspacing, lineHeight, descHeight);
    }
  }

  void showSelectedNPC(String text[][], float x, float y, float w, float h, float s, float lh, float dh) {
    rect(x, y, w+5, h+5, 15);
    fill(0);
    textFont(generalFonts.get(18));
    textAlign(LEFT, TOP);

    float tempx = x;
    for (int j = 0; j < text[0].length; j++) {
      text(text[0][j], x+s, y+s);
      x += textWidth(text[0][j])+s;
    }

    x = tempx;
    text(text[1][0], x+s, y+s+lh*2, w-s, dh+lh);
  }
}
