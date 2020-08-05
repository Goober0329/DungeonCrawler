
int MAXKEYS = 256;
boolean[] keys = new boolean[MAXKEYS];

PVector dir = new PVector(0, 0);

void setup() {
  size(300, 300);
}

void draw() {
  background(0);
  stroke(255);
  strokeWeight(10);
  translate(width/2, height/2);
  line(0, 0, dir.x*100, dir.y*100);
  
  dir.set(0, 0);
  if (keys['w']) {
    dir.y -= 1;
  }
  if (keys['a']) {
    dir.x -= 1;
  }
  if (keys['s']) {
    dir.y += 1;
  }
  if (keys['d']) {
    dir.x += 1;
  }
  dir.normalize();
}

void setMovement(int k, boolean b) {
  if (k < MAXKEYS) {
    keys[k] = b;
    println(k);
  }
}

void keyPressed() {
  setMovement(key, true);
}

void keyReleased() {
  setMovement(key, false);
}
