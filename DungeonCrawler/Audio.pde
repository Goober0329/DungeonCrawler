//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
HashMap<String, SoundPlayer> soundeffects;
HashMap<String, SoundPlayer> music;

int musicVolume = 8;
int effectVolume = 8;

class SoundPlayer {

  ArrayList<SoundFile> sounds;
  int current = 0;
  float volumeModifier = 1;

  SoundPlayer(PApplet papp, String dataFolder) {
    sounds = new ArrayList<SoundFile>();

    String[] filenames;
    filenames = listFileNames(dataFolder);
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

  int duration() {
    return floor(sounds.get(current).duration()*1000)/2;
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

void loadAudio() {
  soundeffects = new HashMap<String, SoundPlayer>();
  music = new HashMap<String, SoundPlayer>();
  String dataFolder;

  dataFolder = "audio/pc";
  String[] folders = listFileNames(dataFolder);
  for (String f : folders) {
    if (f.charAt(0) != '.')
      soundeffects.put(f, new SoundPlayer(this, dataFolder+"/"+f));
  }
  // audio amplitude tweaking
  soundeffects.get("pc dig").setVolumeModifier(1);
  soundeffects.get("pc item pickup").setVolumeModifier(0.8);
  soundeffects.get("pc attack").setVolumeModifier(0.7);
  soundeffects.get("pc walk").setVolumeModifier(0.9);

  dataFolder = "audio/npc";
  folders = listFileNames(dataFolder);
  for (String f : folders) {
    if (f.charAt(0) != '.')
      soundeffects.put(f, new SoundPlayer(this, dataFolder+"/"+f));
  }

  dataFolder = "audio/other";
  folders = listFileNames(dataFolder);
  for (String f : folders) {
    if (f.charAt(0) != '.')
      soundeffects.put(f, new SoundPlayer(this, dataFolder+"/"+f));
  }
  soundeffects.get("scroll open close").setVolumeModifier(0.8);

  // load in  music
  dataFolder = "audio/music";
  folders = listFileNames(dataFolder);
  for (String f : folders) {
    if (f.charAt(0) != '.')
      music.put(f, new SoundPlayer(this, dataFolder+"/"+f));
  }
  music.get("titlescreen").setVolumeModifier(0.25);
  music.get("gameplay").setVolumeModifier(0.25);

  updateAudioVolume();
}

void updateAudioVolume() {
  // adjust all sound effect volume based on global variable effectVolume
  for (HashMap.Entry<String, SoundPlayer> entry : soundeffects.entrySet()) {
    soundeffects.get(entry.getKey()).adjustVolume(effectVolume, 10, true);
  }
  // adjust all music volume based on global variable musicVolume
  for (HashMap.Entry<String, SoundPlayer> entry : music.entrySet()) {
    music.get(entry.getKey()).adjustVolume(musicVolume, 10, true);
  }
}
