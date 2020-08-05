//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
class DungeonMap {
  int dmSize;
  Tile[][] tiles;
  int numHardness;
  int hInc;
  float thresh;

  ArrayList<int[]> floor;

  Tile upstair = null;
  Tile downstair = null;
  Tile[] pits = null;

  float xoff0, yoff0;
  int blend = 5;

  // map width, height, number of hardness values, 
  //   hardness threshold, x increment and y increment (noise)
  DungeonMap(int size, int nH, float thresh, float xinc, float yinc) {
    dmSize = size;
    tiles = new Tile[dmSize][dmSize];
    numHardness = nH;
    hInc = 255/numHardness;
    this.thresh = thresh;

    floor = new ArrayList<int[]>();

    xoff0 = random(99999);
    yoff0 = random(99999);

    //  create dungeon map
    float xoff = xoff0;
    for (int i = 0; i < dmSize; i++) {
      float yoff = yoff0; 
      for (int j = 0; j < dmSize; j++) {
        tiles[i][j] = new Tile(i, j, floor(noise(xoff, yoff)*255), hInc, thresh);
        yoff += yinc;
      }
      xoff += xinc;
    }

    // interpolate dungeon map edges for periodic boundary conditions
    //      bottom edge with top edge
    xoff = xoff0;
    for (int i = 0; i < dmSize; i++) {
      float yoff = yoff0-yinc; 
      for (int j = -1; j > -blend; j--) {
        int val = floor(noise(xoff, yoff)*255);
        float fracTop = float(1-j)/float(blend);
        tiles[i][dmSize+j].hardness = int(float(val)*(1-fracTop) + float(tiles[i][dmSize+j].hardness)*fracTop);
        yoff -= yinc;
      }
      xoff += xinc;
    }
    //      left edge with right edge
    xoff = xoff0-xinc;
    for (int i = -1; i > -blend; i--) {
      float yoff = yoff0; 
      for (int j = 1; j < dmSize; j++) {
        int val = floor(noise(xoff, yoff)*255);
        float fracTop = float(1-i)/float(blend);
        tiles[dmSize+i][j].hardness = int(float(val)*(1-fracTop) + float(tiles[dmSize+i][j].hardness)*fracTop);
        yoff += yinc;
      }
      xoff -= xinc;
    }

    // threshold, seperate into numHardness and add floor to the floor array
    for (int i = 0; i < dmSize; i++) {
      for (int j = 0; j < dmSize; j++) {
        float val = tiles[i][j].hardness;
        val = val/255*numHardness;
        val = val < thresh ? 0 : floor(val);
        val = val/numHardness*255;
        tiles[i][j].hardness = int(val);
        if (tiles[i][j].hardness == 0) {
          floor.add(new int[]{i, j});
        }
      }
    }
  }

  DungeonMap() {
    // used for loading character from file.
    // see fileSaveLoad
  }

  boolean belowThresh(float val) {
    return val/255*numHardness < thresh ? true : false;
  }

  void placeStairs(boolean bottomLevel, ArrayList<Tile> occTiles) {
    // stair placement
    int[] up, down;
    up = floor.get(floor(random(floor.size())));
    tiles[up[0]][up[1]].upstair = true;
    upstair = tiles[up[0]][up[1]];
    occTiles.add(tiles[up[0]][up[1]]);
    if (!bottomLevel) {
      while (true) {
        down = floor.get(floor(random(floor.size())));
        if (up[0] != down[0] || up[1] != down[1]) {
          tiles[down[0]][down[1]].downstair = true;
          downstair = tiles[down[0]][down[1]];
          break;
        }
      }
      occTiles.add(tiles[down[0]][down[1]]);
    }
  }

  void placePits(boolean bottomLevel, ArrayList<Tile> occTiles) {
    if (!bottomLevel) {
      int nPits = floor(random(0, 7))+3;
      pits = new Tile[nPits];
      int[] p;
      for (int i = 0; i < nPits; i++) {
        p = floor.get(floor(random(floor.size())));
        if (!occTiles.contains(tiles[p[0]][p[1]])) {
          tiles[p[0]][p[1]].pit = true;
          pits[i] = tiles[p[0]][p[1]];
          occTiles.add(tiles[p[0]][p[1]]);
        } else {
          i--;
        }
      }
    }
  }

  void display(PlayerCharacter pyc, float dmTileSize) {
    float nx = (width/dmTileSize);
    float ny = (height/dmTileSize);
    float shiftx = (pyc.pos.x-nx/2);
    float shifty = (pyc.pos.y-ny/2);
    int sx = ceil(shiftx);
    int sy = ceil(shifty);

    // display tiles
    strokeWeight(1);
    rectMode(CORNER);
    for (int i = -1; i < nx; i++) {
      for (int j = -1; j < ny; j++) {
        tiles[pbc(i+sx, dmSize)][pbc(j+sy, dmSize)].display((i+sx-shiftx)*dmTileSize, (j+sy-shifty)*dmTileSize, false);
      }
    }
  }

  int getHardness(int i, int j) {
    return tiles[i][j].hardness;
  }

  void setLight(int i, int j, float light) {
    tiles[i][j].light = light;
  }

  float getLight(int i, int j) {
    return tiles[i][j].light;
  }

  int[] getRandomFloorLocation() {
    int[] p = floor.get(floor(random(floor.size())));
    return p;
  }
}

// periodic boundary conditions
int pbc(int i, int n) {
  return (i+n)%n;
}

float pbcDist(float x1, float y1, float x2, float y2, int n) {
  float dx = abs(x1 - x2);
  if (dx > n/2) {
    dx = n - dx;
  }
  float dy = abs(y1 - y2);
  if (dy > n/2) {
    dy = n - dy;
  }
  return sqrt(dx*dx+dy*dy);
}

float pbcDist(int x1, int y1, int x2, int y2, int n) {
  int dx = abs(x1 - x2);
  if (dx > n/2) {
    dx = n - dx;
  }
  int dy = abs(y1 - y2);
  if (dy > n/2) {
    dy = n - dy;
  }
  return sqrt(dx*dx+dy*dy);
}

float pbcDist(PVector p1, PVector p2, int n) {
  float dx = abs(p1.x - p2.x);
  if (dx > n/2) {
    dx = n - dx;
  }
  float dy = abs(p1.y - p2.y);
  if (dy > n/2) {
    dy = n - dy;
  }
  return sqrt(dx*dx+dy*dy);
}

PVector pbcDir(PVector p1, PVector p2, int n) {
  float nx, ny;
  // x
  if (p1.x - p2.x > n/2) {
    nx = p1.x-n;
  } else if (p1.x - p2.x < -n/2) {
    nx = p1.x+n;
  } else {
    nx = p1.x;
  }
  // y
  if (p1.y - p2.y > n/2) {
    ny = p1.y-n;
  } else if (p1.y - p2.y < -n/2) {
    ny = p1.y+n;
  } else {
    ny = p1.y;
  }
  return (new PVector(nx, ny)).sub(p2).normalize();
}

PVector pbcDir(int p1x, int p1y, int p2x, int p2y, int n) {
  float nx, ny;
  // x
  if (p1x - p2x > n/2) {
    nx = p1x-n;
  } else if (p1x - p2x < -n/2) {
    nx = p1x+n;
  } else {
    nx = p1x;
  }
  // y
  if (p1y - p2y > n/2) {
    ny = p1y-n;
  } else if (p1y - p2y < -n/2) {
    ny = p1y+n;
  } else {
    ny = p1y;
  }
  return (new PVector(nx, ny)).sub(new PVector(p2x, p2y));
}
