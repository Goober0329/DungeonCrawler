//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
// FILE PARSING
HashMap<String, ArrayList<NPCgenerator>> foeOptions;
HashMap<String, ArrayList<ItemGenerator>> itemOptions;
HashMap<String, Integer> itemDistribution;
String[] itemTypes;

String[] dungeonHistory;

String[][] highscores;

String[] gameMechanics;

/************************************************************************************************************************************************/

String[] listFileNames(String dir) {
  File file = new File(sketchPath()+"/data/"+dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

/************************************************************************************************************************************************/
/************************************************************************************************************************************************/
/*********************************************************** NPCS and ITEMS *********************************************************************/
/************************************************************************************************************************************************/
/************************************************************************************************************************************************/

HashMap<String, ArrayList<NPCgenerator>> parseFoes() {
  HashMap<String, ArrayList<NPCgenerator>> foeOps = new HashMap<String, ArrayList<NPCgenerator>>();
  //ArrayList<NPCgenerator> foeOps = new ArrayList<NPCgenerator>();
  String[] lines = loadStrings("foes.txt");
  for (int i = 0; i < lines.length; i++) {           // loop through lines
    if (lines[i].equals("BEGIN") == true) {        // if BEGIN, loop until END
      i++;
      String name = "", type = "", desc = "", speed = "", sight = "", damage = "", health = "", rarity = "";

      boolean[] abil = new boolean[]{false, false, false, false, false, false, false};
      while (lines[i].equals("END") == false) {    // get parts and create a character
        int s = lines[i].indexOf('\t');
        String attr = lines[i].substring(0, s);
        String[] parts = lines[i].substring(s+1, lines[i].length()).split(" ");
        String rest = join(parts, " ");
        switch(attr) {
        case "NAME":
          name = rest;
          break;
        case "TYPE":
          type = rest;
          break;
        case "DESC":
          desc = rest;
          break;
        case "SPEED":
          speed = rest;
          break;
        case "SIGHT":
          sight = rest;
          break;
        case "DAMAGE":
          damage = rest;
          break;
        case "HEALTH":
          health = rest;
          break;
        case "RARITY":
          rarity = rest;
          break;
        case "ABILS":
          for (String str : parts) {
            switch (str) {
            case "INTE":
              abil[0] = true;
              break;
            case "TELE":
              abil[1] = true;
              break;
            case "TUNN":
              abil[2] = true;
              break;
            case "ERRA":
              abil[3] = true;
              break;
            case "LAZY":
              abil[4] = true;
              break;
            case "PASS":
              abil[5] = true;
              break;
            case "BOSS":
              abil[6] = true;
              break;
            }
          }
          break;
        }
        i++;
      }
      NPCgenerator temp = new NPCgenerator(name, type, desc, health, damage, speed, sight, rarity, abil);
      if (temp.abilities[6]) { // is BOSS
        if (foeOps.containsKey("BOSS")) {
          foeOps.get("BOSS").add(temp);
        } else {
          ArrayList<NPCgenerator> tempList = new ArrayList<NPCgenerator>();
          tempList.add(temp);
          foeOps.put("BOSS", tempList);
        }
      } else if (foeOps.containsKey(temp.type)) {
        foeOps.get(temp.type).add(temp);
      } else {
        ArrayList<NPCgenerator> tempList = new ArrayList<NPCgenerator>();
        tempList.add(temp);
        foeOps.put(temp.type, tempList);
      }
    }
  }
  return foeOps;
}


HashMap<String, ArrayList<ItemGenerator>> parseItems() {
  HashMap<String, ArrayList<ItemGenerator>> itemOps = new HashMap<String, ArrayList<ItemGenerator>>();
  String[] lines = loadStrings("items.txt");
  for (int i = 0; i < lines.length; i++) {           // loop through lines
    if (lines[i].equals("BEGIN") == true) {        // if BEGIN, loop until END
      i++;
      String name = "", desc = "", healthB = "", damageB = "", defenseB = "", speedB = "", sightB = "", weight = "", value = "", rarity = "", type = "";
      HashMap<String, Boolean> attributes = new HashMap<String, Boolean>();
      while (lines[i].equals("END") == false) {    // get parts and create a character
        int s = lines[i].indexOf('\t');
        String attr = lines[i].substring(0, s);
        String[] parts = lines[i].substring(s+1, lines[i].length()).split(" ");
        String rest = join(parts, " ");
        switch(attr) {
        case "NAME":
          name = rest;
          break;
        case "TYPE":
          type = rest;
          break;
        case "DESC":
          desc = rest;
          break;
        case "HEALB":
          healthB = rest;
          break;
        case "DAMB":
          damageB = rest;
          break;
        case "DEFB":
          defenseB = rest;
          break;
        case "SPEEB":
          speedB = rest;
          break;
        case "SIGHB":
          sightB = rest;
          break;
        case "WEIGHT":
          weight = rest;
          break;
        case "VAL":
          value = rest;
          break;
        case "RRTY":
          rarity = rest;
          break;
        case "ATTR":
          for (String p : parts) {
            attributes.put(p, true);
          }
          break;
        }
        i++;
      }
      ItemGenerator temp = new ItemGenerator(name, type, desc, healthB, damageB, defenseB, speedB, sightB, weight, value, rarity, attributes);
      if (itemOps.containsKey(temp.type)) {
        itemOps.get(temp.type).add(temp);
      } else {
        ArrayList<ItemGenerator> tempList = new ArrayList<ItemGenerator>();
        tempList.add(temp);
        itemOps.put(temp.type, tempList);
      }
    }
  }
  return itemOps;
}

HashMap<String, Integer> parseItemDistribution(int nItems) {
  HashMap<String, Integer> itemDist = new HashMap<String, Integer>();
  String[] lines = loadStrings("item distribution.txt");
  itemTypes = new String[lines.length-1];
  int nDist = int(lines[0]);
  for (int i = 1; i < lines.length; i++) {
    String l = lines[i];
    String[] parts = l.split("\t");
    if (parts.length == 2) {
      itemDist.put(parts[0], ceil(nItems*float(parts[1])/nDist));
      itemTypes[i-1] = parts[0];
    }
  }
  return itemDist;
}

/************************************************************************************************************************************************/
/************************************************************************************************************************************************/
/*********************************************************** DUNGEON HISTORY ********************************************************************/
/************************************************************************************************************************************************/
/************************************************************************************************************************************************/

void parseDungeonHistory() {
  dungeonHistory = loadStrings("dungeon history.txt");
  for (int i = 0; i < dungeonHistory.length; i++) {
    String s = dungeonHistory[i];
    if (!Character.isUpperCase(s.charAt(0))) {
      s = "..."+s;
    }
    if (s.charAt(s.length()-1) != '.') {
      s = s+"...";
    }
    dungeonHistory[i] = s;
  }
}

/************************************************************************************************************************************************/
/************************************************************************************************************************************************/
/************************************************************ GAME MECHANICS  *******************************************************************/
/************************************************************************************************************************************************/
/************************************************************************************************************************************************/

void loadMechanics() {
  gameMechanics = loadStrings("mechanics.txt");
}

/************************************************************************************************************************************************/
/************************************************************************************************************************************************/
/************************************************************** HIGHSCORES  *********************************************************************/
/************************************************************************************************************************************************/
/************************************************************************************************************************************************/

void parseDungeonHighscores() {
  try {
    String[] lines = loadStrings("scores.txt");
    highscores = new String[lines.length][2];
    for (int i = 0; i < lines.length; i++) {
      String[] parts = lines[i].split("\t");
      if (parts.length == 2) {
        highscores[i][0] = parts[0];
        highscores[i][1] = parts[1];
      }
    }
    // Using built-in sort function Arrays.sort 
    // https://www.google.com/search?q=java+string+to+integer&oq=java+string+to+integer&aqs=chrome.0.35i39j0l7.2544j0j7&sourceid=chrome&ie=UTF-8
    Arrays.sort(highscores, new Comparator<String[]>() { 
      @Override              
        // Compare values according to columns 
        public int compare(final String[] entry1, final String[] entry2) { 
        if (Integer.parseInt(entry1[1]) < Integer.parseInt(entry2[1])) {
          return 1;
        } else {
          return -1;
        }
      }
    }
    );
  } 
  catch (Exception e) {
    e.printStackTrace();
    highscores = new String[0][2];
  }
}

void writeScoreToFile(String name, int score) {
  File f = new File(dataPath("scores.txt"));
  if (!f.exists()) {
    File parentDir = f.getParentFile();
    try {
      parentDir.mkdirs(); 
      f.createNewFile();
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }
  try {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(name+"\t"+score);
    out.close();
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

/************************************************************************************************************************************************/
/************************************************************************************************************************************************/
/************************************************************** GAME VOLUME  ********************************************************************/
/************************************************************************************************************************************************/
/************************************************************************************************************************************************/

void saveVolume() {
  File f = new File(dataPath("audio/volume.txt"));
  if (!f.exists()) {
    File parentDir = f.getParentFile();
    try {
      parentDir.mkdirs(); 
      f.createNewFile();
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  } 

  try {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, false)));
    out.println(musicVolume);
    out.println(effectVolume);
    out.close();
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

void loadVolume() {
  try {
    String[] volume = loadStrings("audio/volume.txt");
    musicVolume = Integer.parseInt(volume[0]);
    effectVolume = Integer.parseInt(volume[1]);
    updateAudioVolume();
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}
