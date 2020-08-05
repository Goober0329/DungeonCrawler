

class ScreenMap implements Screen {

  ScreenMap() {
  }

  void update(PlayerCharacter pyc, DungeonLevel dlvl) {
    // might not need this at all.
  }

  void display(PlayerCharacter pyc, DungeonLevel dlvl) {
    // display map center on pc according to dmSize/2 on all sides
    // center on PC or show the actual map without PBC and then place PC?

    float mSize = height-height/10;
    float tSize = mSize/dlvl.dmSize;

    fill(100);
    noStroke();
    rectMode(CENTER);
    rect(width/2, height/2, mSize, mSize, 5);

    // first display the tiles
    rectMode(CORNER);
    strokeWeight(1);
    Tile t;
    float offx = width/2-mSize/2;
    float offy = height/2-mSize/2;
    for (int i = 0; i < dlvl.dm.tiles.length; i++) {
      for (int j = 0; j < dlvl.dm.tiles[0].length; j++) {
        t = dlvl.dm.tiles[i][j];
        t.display(offx+i*tSize, offy+j*tSize, true);
      }
    }

    // then dislpay PC
    //pyc.display(offx+pyc.pos.x*tSize, offy+pyc.pos.y*tSize, tSize);
    displayPixelArtStatic("pc top", 0, offx+pyc.pos.x*tSize, offy+pyc.pos.y*tSize, 255, true);

    // clean up the border.
    noFill();
    stroke(150);
    strokeWeight(5);
    rectMode(CENTER);
    rect(width/2, height/2, mSize, mSize, 5);
  }
}
