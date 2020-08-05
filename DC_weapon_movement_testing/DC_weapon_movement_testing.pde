int ticks = 0;
int ticks2attack = 100;



void setup() {
  size(300, 300);
}

void draw() {
  int todo; // variable 'd' needs to change with time to show attacks.
  float mult = 2;
  float t = constrain(ticks*mult, 0, ticks2attack);
  // want: parabolic movement from 50 --> 100? --> 50
  //                              min --> max --> min
  //                                0 --> ticks2attack
  t = map(t, 0, ticks2attack, -0.5, 0.5);
  // y = -m(0^2) + 50
  // 100 = -m(0.5^2) + 50
  // m = -200
  int dmin = 50;
  int dmax = 100;
  float m = -(dmax-dmin)/(0.5*0.5);
  float d = m*t*t+dmax;

  println(t, d);

  ticks++;
  if (ticks > ticks2attack && mousePressed) {
    ticks = 0;
    println("ticks reset");
  }

  background(0);
  strokeWeight(4);
  stroke(255);
  line(width/2, height/2, width/2, height/2+d);
}
