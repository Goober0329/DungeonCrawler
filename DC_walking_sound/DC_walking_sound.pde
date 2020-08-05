
import processing.sound.*;
SoundPlayer walking;

void setup() {
  size(200, 200);
  walking = new SoundPlayer(this, "");
}

void draw() {
  // walking
  int tood; // something is wrong here. it kind of freaks out after a while.
  /*
  Here's the issue:
  There is no way to detect if the audio file has ended and the cue does not reset to 0 when it does end. So if 
  the I pause the audio file it will resume at that spot even after the audio file has ended. 
  I can't make a clean fix for this right now, so I instead am going to create more walking files.
  */

  if (mousePressed) {
    if (!walking.isPlaying()) {
      walking.play(true);
    }
  } else {
    if (walking.isPlaying()) 
      walking.pause();
  }
}

class SoundPlayer {

  ArrayList<SoundFile> sounds;
  int current = 0;
  float volumeModifier = 1;

  SoundPlayer(PApplet papp, String dataFolder) {
    sounds = new ArrayList<SoundFile>();
    sounds.add(new SoundFile(papp, sketchPath()+"/walking.wav"));
  }


  void play(boolean newCurrent) {
    // pick random file from list and play it.
    if (newCurrent) {
      sounds.get(current).cue(0);
      
      int next = floor(random(0, sounds.size()));
      current = (current == next) ? (next + 1)%sounds.size() : next;
    }
    sounds.get(current).play();
  }

  boolean isPlaying() {
    return sounds.get(current).isPlaying();
  }

  void pause() {
    sounds.get(current).pause();
  }

  void loop() {
    sounds.get(current).loop();
  }

  void stop() {
    sounds.get(current).stop();
  }

  void cue(float time) {
    sounds.get(current).cue(time);
  }

  void setVolumeModifier(float modifier) {
    volumeModifier = modifier;
  }

  void adjustVolume(int vol, int scale, boolean universal) {
    float volume = map(vol, 0, scale, 0, 1);
    if (!universal) {
      sounds.get(current).amp(volume*volumeModifier);
    } else {
      for (SoundFile s : sounds) {
        s.amp(volume*volumeModifier);
      }
    }
  }
}
