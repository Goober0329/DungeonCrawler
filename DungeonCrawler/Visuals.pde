//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
HashMap<String, Animation> pixelart;
int pixArtSize = 16;

FontContainer dungeonFonts;
FontContainer generalFonts;

void loadPixelArt() {
  pixelart = new HashMap<String, Animation>();

  String dataFolder;
  String[] filenames;

  // Load in Dungeon Tiles
  dataFolder = "pixart/tiles";
  filenames = listFileNames(dataFolder);
  loadPixArtFiles(filenames, dataFolder, dmTileSize);

  // Load in Map Tiles
  dataFolder = "pixart/map";
  filenames = listFileNames(dataFolder);
  float mSize = height-height/10;
  int  tSize = ceil(mSize/dmSize); // ceil?
  loadPixArtFiles(filenames, dataFolder, tSize);


  // Load in Items
  dataFolder = "pixart/items";
  filenames = listFileNames(dataFolder);
  for (String s : filenames) {
    String tempDataFolder = dataFolder + "/"+s;
    String[] nextLayer = listFileNames(tempDataFolder);
    if (nextLayer != null)
      loadPixArtItems(nextLayer, tempDataFolder, dmTileSize-16, dmTileSize);
  }

  // Load in NPCs
  dataFolder = "pixart/npcs";
  filenames = listFileNames(dataFolder);
  for (String s : filenames) {
    String tempDataFolder = dataFolder + "/"+s;
    String[] nextLayer = listFileNames(tempDataFolder);
    if (nextLayer != null)
      loadPixArtFiles(nextLayer, tempDataFolder, dmTileSize);
  }

  // Load in PC
  dataFolder = "pixart/pc";
  filenames = listFileNames(dataFolder);
  loadPixArtFiles(filenames, dataFolder, dmTileSize);

  // Load in Endgame Tiles
  dataFolder = "pixart/winner";
  filenames = listFileNames(dataFolder);
  loadPixArtFiles(filenames, dataFolder, dmTileSize-12);
}

void loadPixArtFiles(String[] filenames, String dataFolder, int size) {
  Animation toPut;
  for (String file : filenames) {
    String[] parts = file.split("\\.");
    if (parts.length == 2 && parts[1].equals("png")) {
      toPut = new Animation(dataFolder+"/"+file, pixArtSize, size);
      pixelart.put(parts[0], toPut);
    }
  }
}

void loadPixArtItems(String[] filenames, String dataFolder, int sizenorm, int sizewear) {
  Animation toPut;
  for (String file : filenames) {
    String[] parts = file.split("\\.");
    if (parts.length == 2 && parts[1].equals("png")) {
      if (parts[0].contains("helmet") || parts[0].contains("armor") || parts[0].contains("boots") || parts[0].contains("cloak")) {
        toPut = new Animation(dataFolder+"/"+file, pixArtSize, sizewear);
      } else {
        toPut = new Animation(dataFolder+"/"+file, pixArtSize, sizenorm);
      }
      pixelart.put(parts[0], toPut);
    }
  }
}

void displayPixelArtStatic(String animationName, int tile, float x, float y, float t, boolean center) {
  tint(t);
  imageMode(center ? CENTER : CORNER);
  Animation temp = pixelart.get(animationName);
  if (temp == null) {
    println(animationName);
    println("oops");
  } else {
    temp.displayStatic(x, y, tile);
  }
}

void displayPixelArtAnimation(String animationName, float x, float y, int mod, float t, boolean center) {
  tint(t);
  imageMode(center ? CENTER : CORNER);
  Animation temp = pixelart.get(animationName);
  if (temp == null) {
    println(animationName);
    println("oops");
  } else {
    temp.displayAnimation(x, y, mod);
  }
}

void syncAnimations(String ani1, String ani2) {
  Animation anim1 = pixelart.get(ani1);
  Animation anim2 = pixelart.get(ani2);
  anim2.currFrame = anim1.currFrame;
}


/********************************************************************************/
/************************************ ANIMATION *********************************/
/********************************************************************************/

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
    float scale = (float)size/ (float)org.width;

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

  void displayAnimation(float x, float y, int mod) {
    image(frames[currFrame], x, y);

    if (mod != 0 && frameCount%mod == 0) {
      currFrame++;
      currFrame = currFrame == frames.length ? 0 : currFrame;
    }
  }

  void displayStatic(float x, float y, int tile) {
    image(frames[tile], x, y);
  }
}


/********************************************************************************/
/************************************** FONTS ***********************************/
/********************************************************************************/

class FontContainer {
  String font;
  HashMap<Integer, PFont> fonts;

  FontContainer(String f) {
    font = f;
    fonts = new HashMap<Integer, PFont>();
  }

  PFont get(int fSize) {
    PFont toReturn;
    toReturn = fonts.get(fSize);
    if (toReturn == null) {
      fonts.put(fSize, createFont(font, fSize));
      toReturn = fonts.get(fSize);
    } 
    return toReturn;
  }
}
