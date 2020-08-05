
FontContainer dungeonFonts;
int fSize = 12;

void setup() {
  size(300, 200);
  textAlign(CENTER, CENTER);
  dungeonFonts = new FontContainer("dungeonfont.ttf");
}

void draw() {
  background(255);
  fill(frameCount%255);
  textFont(dungeonFonts.get(fSize));
  text("This is a Test", width/2, height/2);
}

void keyReleased() {
  if (keyCode == UP) {
    fSize += 5;
  }
  if (keyCode == DOWN) {
    fSize -= 5;
  }
  fSize = constrain(fSize, 6, 100);
}


/*
*
 *
 *
 *
 */


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
