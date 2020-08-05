 //<>//
Animation pc_idle;

void setup() {
  size(500, 500);

  pc_idle = new Animation("pc_pc_idle_left.png", 16, 100);
}

void draw() {
  background(255);
  pc_idle.display(width/2, height/2, 18);
}

class Animation {

  PImage sheet;
  PGraphics[] frames;
  int currFrame = 0;

  Animation(String sheetpath, int nx, int ny, int size) {
    sheet = loadImage(sheetpath);
    int w = sheet.width/nx;
    int h = sheet.height/ny;

    PImage temp;
    frames = new PGraphics[nx*ny];
    for (int i = 0; i < nx; i++) {
      for (int j = 0; j < ny; j++) {
        temp = sheet.get(i*w, j*h, w, h);
        frames[i+j*nx] = setGraphicSize(temp, size);
      }
    }
  }

  Animation(String sheetpath, int npixTile, int size) {
    sheet = loadImage(sheetpath);
    int nx = sheet.width/npixTile;
    int ny = sheet.height/npixTile;
    int w = sheet.width/nx;
    int h = sheet.height/ny;

    PImage temp;
    frames = new PGraphics[nx*ny];
    for (int i = 0; i < nx; i++) {
      for (int j = 0; j < ny; j++) {
        temp = sheet.get(i*w, j*h, w, h);
        frames[i+j*nx] = setGraphicSize(temp, size);
      }
    }
  }

  PGraphics setGraphicSize(PImage org, int size) {
    float scale = (float)size/org.width;

    PGraphics toReturn = createGraphics(size, size);
    toReturn.beginDraw();
    org.loadPixels();
    for (int i = 0; i < org.width; i++ ) { 
      for (int j = 0; j < org.height; j++) {
        color c = org.pixels[i+j*org.width];
        toReturn.fill(c, alpha(c));
        toReturn.stroke(c, alpha(c));
        toReturn.rect(i*scale, j*scale, scale, scale);
      }
    }
    toReturn.endDraw();

    return toReturn;
  }

  void display(float x, float y, int mod) {
    imageMode(CENTER);
    image(frames[currFrame], x, y);

    if (frameCount%mod == 0) {
      currFrame++;
      currFrame = currFrame == frames.length ? 0 : currFrame;
    }
  }
}
