

class Tile {
  int x, y;
  int hardness;
  float light;

  int hInc;
  float thresh;

  boolean upstair = false;
  boolean downstair = false;

  boolean pit  = false;
  boolean pitUncovered = false;

  Tile(int x, int y, int noiseHard, int hInc, float thresh) {
    this.hardness = noiseHard;
    this.hInc = hInc;
    this.thresh = thresh;
    this.x = x;
    this.y = y;
    this.light = 0;
  }

  Tile() {
    // used for loading character from file.
    // see fileSaveLoad
  }

  void display(float px, float py, boolean mini) {
    int extra = -1;
    int tile = -1;

    if (upstair) {
      stroke(#ACCE5E);
      fill(#ACCE5E);
      extra = 0;
    } else if (downstair) {
      stroke(#B2A14A);
      fill(#B2A14A);
      extra = 1;
    } else if (pit && pitUncovered) {
      stroke(#FFE51C);
      fill(#FFE51C);
      extra = 2;
    } else {
      stroke(hardness);
      fill(hardness);
      tile = hardness == 0 ? 0 : hardness/hInc-(int)thresh+1;
    }

    if (extra != -1) {
      displayPixelArtStatic(mini ? "mapextras" : "extras", extra, px, py, light*255, false);
    } else if (tile != -1) {
      displayPixelArtStatic(mini ? "maptiling" : "tiling", tile, px, py, light*255, false);
    }
  }
}
