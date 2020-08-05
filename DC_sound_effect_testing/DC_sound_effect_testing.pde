
import processing.sound.*;

SoundPlayer pcDig;
SoundPlayer pcWalk;

void setup() {
  pcDig = new SoundPlayer(this, "pc dig");
  pcDig.adjustVolume(3, 10, true); // found out the digging sound was a little loud. 
  // its a good thing it could be tested here first to know what level to set it at.
  
  pcWalk = new SoundPlayer(this, "pc walk");
  println(pcWalk.sounds.size());
} 

void draw() {
  if (!pcDig.isPlaying()) {
    pcDig.play(true);
  }

  if (!pcWalk.isPlaying()) {
    pcWalk.loop();
  }
}


class SoundPlayer {

  ArrayList<SoundFile> sounds;
  int current = 0;

  SoundPlayer(PApplet papp, String dataFolder) {
    sounds = new ArrayList<SoundFile>();

    String[] filenames;
    filenames = listFileNames(sketchPath()+"/data/"+dataFolder);
    for (String file : filenames) {
      String[] parts = file.split("\\.");
      if (parts.length == 2 && parts[1].equals("wav")) {
        sounds.add(new SoundFile(papp, dataFolder+"/"+file));
      }
    }
  }

  void play(boolean newCurrent) {
    // pick random file from list and play it.
    if (newCurrent) {
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

  void adjustVolume(int vol, int scale, boolean universal) {
    float volume = map(vol, 0, scale, 0, 1);
    if (!universal) {
      sounds.get(current).amp(volume);
    } else {
      for (SoundFile s : sounds) {
        s.amp(volume);
      }
    }
  }
}



String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}
