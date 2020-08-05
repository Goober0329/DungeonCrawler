//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
//<>//
// USER INPUT
int ARROWUP = 256;
int ARROWDOWN = 257;
int ARROWLEFT = 258;
int ARROWRIGHT = 259;
int RENTER = 260;
int DELSPACE = 261;
int ASCII_KEYS = 256;
int MAXKEYS = ASCII_KEYS+4+1+1; // 256 ASCII characters, 4 arrow keys, ENTER/RETURN, DELETE/BACKSPACE
boolean[][] keys = new boolean[MAXKEYS][2];

PVector mouseDir = new PVector(0, 0);

// keep track of pressed and released as boolean variables
// reset released boolean after variable is used.

void keyPressed() {
  updateKeys(key, true, false);
  if (key == ESC) {
    key = 0;
  }
}

void keyReleased() {
  updateKeys(key, false, true);
  if (((ScreenTitle)tScreen).typing) {
    ((ScreenTitle)tScreen).updatePlayerName(key);
  }
  if (key == ESC) {
    key = 0;
  }
}

// keys[pressed][first press]
void updateKeys(int k, boolean p, boolean r) {
  if (k < ASCII_KEYS) {
    keys[k][0] = p;
    keys[k][1] = r;
  } 
  if (keyCode == LEFT) {
    keys[ARROWLEFT][0] = p;
    keys[ARROWLEFT][1] = r;
  } else if (keyCode == RIGHT) {
    keys[ARROWRIGHT][0] = p;
    keys[ARROWRIGHT][1] = r;
  } else if (keyCode == UP) {
    keys[ARROWUP][0] = p;
    keys[ARROWUP][1] = r;
  } else if (keyCode == DOWN) {
    keys[ARROWDOWN][0] = p;
    keys[ARROWDOWN][1] = r;
  } else if (keyCode == ENTER || keyCode == RETURN) {
    keys[RENTER][0] = p;
    keys[RENTER][1] = r;
  } else if (keyCode == DELETE || keyCode == BACKSPACE) {
    keys[DELSPACE][0] = p;
    keys[DELSPACE][1] = r;
  }
}

void updateMouseDir() {
  mouseDir.x = mouseX-width/2;
  mouseDir.y = mouseY-height/2;
  mouseDir.normalize();
}

void clearCommands() {
  for (int i = 0; i < MAXKEYS; i++) {
    keys[i][1] = false;
  }
}

boolean checkPause() {
  return keys['p'][1];
}
