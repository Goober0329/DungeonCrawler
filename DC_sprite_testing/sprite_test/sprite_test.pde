import sprites.*;
import sprites.maths.*;
import sprites.utils.*;
 
Sprite pc_sprite;
float px, py;
 
// This will be used for timing
StopWatch sw = new StopWatch();
 
void setup() {
  size(400, 400);
  pc_sprite = new Sprite(this, "pc_pc_idle_right.png", 4, 1, 10);
  pc_sprite.setScale(5);
}
 
void draw() {  
  // Get the elapsed time since the last frame
  float elapsedTime = (float) sw.getElapsedTime();
  S4P.updateSprites(elapsedTime);
  background(200, 200, 255);
  S4P.drawSprites();
}
 
void mouseClicked(){
  // Move the sprite so it in centerd over the mouse position
  pc_sprite.setXY(mouseX, mouseY);
  // Animate the sprite using frames 0 to 24 with a frame interval 
  // of 0.02 seconds and play the sequence just once 
  pc_sprite.setFrameSequence(0, 3, 0.5, 100);
}
