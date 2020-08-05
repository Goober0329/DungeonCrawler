/************************************************************************************************************************************************///<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
/************************************************************************************************************************************************/
/****************************************************************** SAVING **********************************************************************/
/************************************************************************************************************************************************/
/************************************************************************************************************************************************/

void saveGame() {
  // create savegame directory
  File dir = new File(dataPath("savegame"));
  if (!dir.exists()) {
    try {
      dir.mkdirs();
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  // create save files for all important things...

  // things to save:
  saveGlobalVariables();
  savePlayerCharacter();
  saveDungeon();
}


void saveGlobalVariables() {
  File f = new File(dataPath("savegame/globalvariables.txt"));
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
    // dLevel information
    out.println(dmSize);
    out.println(dmTileSize);
    out.println(numNPC);
    out.println(numItem);

    // game Information
    out.println(nLevels);
    out.println(currLevel);
    out.println(maxLevel);

    // volume
    out.println(musicVolume);
    out.println(effectVolume);
    out.close();
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

void savePlayerCharacter() {
  // create player character directory
  File dir = new File(dataPath("savegame/playercharacter"));
  if (!dir.exists()) {
    try {
      dir.mkdirs();
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  // VARIABLES
  File f = new File(dataPath("savegame/playercharacter/pcvariables.txt"));
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
    // basic variables
    out.println(pc.name);
    out.println(pc.health);
    for (Dice d : pc.damage) {
      out.print(d.toString()+",");
    }
    out.println();
    for (Dice d : pc.defense) {
      out.print(d.toString()+",");
    }
    out.println();
    out.println(pc.speed);
    out.println(pc.sight);
    out.println(pc.weight);
    out.println(pc.money);

    // location information
    out.println(pc.pos);
    out.println(pc.dirFace);
    out.println(pc.dirMove);
    out.println(pc.tile[0]+","+pc.tile[1]);
    out.println(pc.updatePathfinder);

    // stats
    out.println(pc.npcKills);
    out.println(pc.bossKills);
    out.println(pc.gametime);

    // game control
    out.println(pc.minSpeed);
    out.println(pc.maxSpeed);
    out.println(pc.speedMult);
    out.println(pc.tunnMult);
    out.println(pc.initWeight);
    out.println(pc.weightMult);
    out.println(pc.tunn);
    out.println(pc.pass);
    out.println(pc.smacks2break);
    out.println(pc.smacks);
    out.println(pc.attack);
    out.println(pc.ticks2attack);
    out.println(pc.ticks);

    // audio logic
    out.println(pc.broke);
    out.println(pc.pickup);
    out.println(pc.attackMade);
    out.println(pc.pitfall);

    out.close();
  } 
  catch (IOException e) {
    e.printStackTrace();
  }

  // INVENTORY
  f = new File(dataPath("savegame/playercharacter/pcinventory.txt"));
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
    for (int pos = 0; pos < pc.inventory.favorites.length; pos++) {
      if (pc.inventory.favorites[pos] != null) {
        out.println(pos);
        writeItem(pc.inventory.favorites[pos], out);
      }
    }
    out.println("END FAVORITE ITEMS");

    for (Item i : pc.inventory.inventory) {
      if (i != null) {
        out.println();
        writeItem(i, out);
      }
    }
    out.println("END INVENTORY ITEMS");

    out.close();
  } 
  catch (IOException e) {
    e.printStackTrace();
  }


  // EQUIPMENT
  f = new File(dataPath("savegame/playercharacter/pcequipment.txt"));
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
    for (HashMap.Entry<String, Item> itemEntry : pc.equipment.equipment.entrySet()) {
      if (itemEntry.getValue() != null) {
        out.println();
        out.println(itemEntry.getValue());
        writeItem(itemEntry.getValue(), out);
      }
    }
    out.println("END EQUIPMENT ITEMS");

    for (Item i : pc.equipment.rings) {
      if (i != null) {
        out.println();
        out.println(i);
        writeItem(i, out);
      }
    }
    out.println("END RING ITEMS");

    for (Item i : pc.equipment.temporaryAttrItems) {
      if (i != null) {
        out.println();
        out.println(i);
        writeItem(i, out);
      }
    }
    out.println("END TEMPATTR ITEMS");

    for (Item i : pc.equipment.permanentAttrItems) {
      if (i != null) {
        out.println();
        out.println(i);
        writeItem(i, out);
      }
    }
    out.println("END PERMATTR ITEMS");

    out.close();
  } 
  catch (IOException e) {
    e.printStackTrace();
  }
}

void saveDungeon() {
  // create player character directory
  File dir = new File(dataPath("savegame/dungeon"));
  if (!dir.exists()) {
    try {
      dir.mkdirs();
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  // DUNGEON LEVELS
  for (int i = 0; i < nLevels; i++) {
    // DUNGEON LEVEL
    File f = new File(dataPath("savegame/dungeon/level"+i+".txt"));
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
      writeDungeonLevel(dLevels.get(i), out);
      out.close();
    } 
    catch (IOException e) {
      e.printStackTrace();
    }
  }
}

void writeDungeonLevel(DungeonLevel dlvl, PrintWriter p) {
  try {
    p.println(dlvl.dmSize);
    p.println(dlvl.dmTileSize);

    // Dungeon Map
    p.println(dlvl.dm.dmSize);
    for (int i = 0; i < dlvl.dm.dmSize; i++) {
      for (int j = 0; j < dlvl.dm.dmSize; j++) {
        p.println(i+" "+j);
        p.println(dlvl.dm.tiles[i][j]);
        writeTile(dlvl.dm.tiles[i][j], p);
      }
    }
    p.println(dlvl.dm.numHardness);
    p.println(dlvl.dm.hInc);
    p.println(dlvl.dm.thresh);
    for (int[] arr : dlvl.dm.floor) {
      p.print(arr[0]+","+arr[1]+"|");
    }
    p.println();
    p.println(dlvl.dm.upstair);
    p.println(dlvl.dm.downstair);
    if (dlvl.dm.pits != null) {
      for (Tile t : dlvl.dm.pits) {
        p.print(t+",");
      }
      p.println();
    } else {
      p.println("null");
    }
    p.println(dlvl.dm.xoff0);
    p.println(dlvl.dm.yoff0);
    p.println(dlvl.dm.blend);

    // NonPlayerCharacters
    p.println(dlvl.numNPC);
    p.println(dlvl.npcs.size()); // for creating the loop v when loading
    for (int i = 0; i < dlvl.npcs.size(); i++) {
      writeNPC(dlvl.npcs.get(i), p);
    }

    // Occupied Tiles
    p.println(dlvl.occTiles.size());
    for (int i = 0; i < dlvl.occTiles.size(); i++) {
      p.println(dlvl.occTiles.get(i)); // to be hash mapped back to the original tiles.
    }

    // Pathfinder
    p.println(dlvl.updatePathfinder);
    // a new pathfinder can be created with the loaded dm. No need to write the pathfinder to file.


    // Items
    p.println(dlvl.numItem);
    p.println(dlvl.items.size());
    for (int i = 0; i < dlvl.items.size(); i++) {
      p.println(dlvl.items.get(i)); // for hashmapping and comparing to equipped items (have to avoid duplicate item loading)
      writeItem(dlvl.items.get(i), p);
    }
  }
  catch (Exception e) {
    e.printStackTrace();
  }
}

void writeTile(Tile t, PrintWriter p) {
  try {
    p.println(t.x);
    p.println(t.y);
    p.println(t.hardness);
    p.println(t.light);
    p.println(t.hInc);
    p.println(t.thresh);
    p.println(t.upstair);
    p.println(t.downstair);
    p.println(t.pit);
    p.println(t.pitUncovered);
  }
  catch (Exception e) {
    e.printStackTrace();
  }
}

void writeNPC(NonPlayerCharacter npc, PrintWriter p) {
  p.println(npc.name);
  p.println(npc.health);
  p.println(npc.damage.toString());
  p.println(npc.speed);
  p.println(npc.sight);
  for (int i = 0; i < npc.abilities.length; i++) {
    p.print(npc.abilities[i]+",");
  }
  p.println();
  p.println(npc.type);
  p.println(npc.desc);
  p.println(npc.rarity);

  p.println(npc.minSpeed);
  p.println(npc.maxSpeed);
  p.println(npc.speedMult);

  p.println(npc.pos);
  p.println(npc.tile[0]+" "+npc.tile[1]);
  p.println(npc.nextTile == null ? "null" : npc.nextTile[0]+" "+npc.nextTile[1]);
  for (int i = 0; i < npc.tilesToTarget.size(); i++) {
    int[] temp = npc.tilesToTarget.get(i);
    p.print(temp[0]+","+temp[1]+"|");
  }
  p.println();
  p.println(npc.ontarget);
  p.println(npc.smacks2break);
  p.println(npc.smacks);
  p.println(npc.ticks2attack);
  p.println(npc.ticks);
  p.println(npc.attackMade);

  p.println(npc.lastDir);
  p.println(npc.currDir);
  p.println(npc.rMovement);
  p.println(npc.eMovement);
}

void writeItem(Item i, PrintWriter p) {
  try {
    p.println(i.name);
    p.println(i.type);
    p.println(i.desc);
    p.println(i.healthBonus);
    p.println(i.damageBonus.toString());
    p.println(i.defenseBonus.toString());
    p.println(i.speedBonus);
    p.println(i.sightBonus);
    p.println(i.weight);
    p.println(i.value);
    p.println(i.rarity);
    p.println(i.hasAttributes);
    if (i.hasAttributes) {
      for (HashMap.Entry<String, Boolean> attr : i.attributes.entrySet()) {
        p.print(attr.getKey()+",");
      }
      p.println();
    }
    p.println(i.attrLifetime);
    p.println(i.attrLifespan);
    p.println(i.rangedShots);
    p.println(i.maxShots);
    p.println(i.pos);
    p.println(i.covered);
    p.println(i.holding);
    p.println(i.dropped);
  }
  catch (Exception e) {
    e.printStackTrace();
  }
}



/************************************************************************************************************************************************/
/************************************************************************************************************************************************/
/****************************************************************** LOADING *********************************************************************/
/************************************************************************************************************************************************/
/************************************************************************************************************************************************/

boolean loadGame() {
  // check for savegame directory
  File dir = new File(dataPath("savegame"));
  if (!dir.exists()) {
    return false;
  }

  // things to load:
  boolean good = loadGlobalVariables();
  if (!good)
    return false;

  updateAudioVolume();

  pc = loadPlayerCharacter();
  if (pc == null)
    return false;

  dLevels = loadDungeon();
  if (dLevels == null) 
    return false;

  // need to loop through each level and all of the item arraylists in each level then compare with each item on PC
  // at anypoint if there is a duplicate, replace that item with the one from dlevel list
  for (DungeonLevel dlvl : dLevels) {
    for (Item it1 : dlvl.items) {
      for (Item it2 : pc.getAllItems()) {
        // compare items. if they are the same, then set dlvl.items to pc Item
        if (it1.isDuplicate(it2)) {
          it2 = it1;
        }
      }
    }
  }
  return true;
}

boolean loadGlobalVariables() {
  File f;
  BufferedReader in;

  // VARIABLES
  f = new File(dataPath("savegame/globalvariables.txt"));
  if (!f.exists()) {
    return false;
  }
  try {
    in = new BufferedReader(new FileReader(f));

    // dLevel information
    dmSize = Integer.parseInt(in.readLine());
    dmTileSize = Integer.parseInt(in.readLine());
    numNPC = Integer.parseInt(in.readLine());
    numItem = Integer.parseInt(in.readLine());

    // game Information
    nLevels = Integer.parseInt(in.readLine());
    currLevel = Integer.parseInt(in.readLine());
    maxLevel = Integer.parseInt(in.readLine());

    // volume
    musicVolume = Integer.parseInt(in.readLine());
    effectVolume = Integer.parseInt(in.readLine());
    in.close();
  } 
  catch (IOException e) {
    e.printStackTrace();
    return false;
  }
  return true;
}


PlayerCharacter loadPlayerCharacter() {
  PlayerCharacter toReturn = new PlayerCharacter();

  File f;
  BufferedReader in;
  String line;
  String[] parts;

  // VARIABLES
  f = new File(dataPath("savegame/playercharacter/pcvariables.txt"));
  if (!f.exists()) {
    return null;
  }
  try {
    in = new BufferedReader(new FileReader(f));

    // basic variables
    toReturn.name = in.readLine();
    toReturn.health = Integer.parseInt(in.readLine());

    line = in.readLine();
    parts = line.split(",");
    toReturn.damage = new ArrayList<Dice>();
    for (String part : parts) {
      if (part.contains("+"))
        toReturn.damage.add(new Dice(part));
    }

    line = in.readLine();
    parts = line.split(",");
    toReturn.defense = new ArrayList<Dice>();
    for (String part : parts) {
      if (part.contains("+"))
        toReturn.defense.add(new Dice(part));
    }

    toReturn.speed = Float.parseFloat(in.readLine());
    toReturn.sight = Integer.parseInt(in.readLine());
    toReturn.weight = Float.parseFloat(in.readLine());
    toReturn.money = Integer.parseInt(in.readLine());

    // location information
    line = in.readLine().trim().substring(1);
    parts = line.split(",");
    toReturn.pos = new PVector(Float.parseFloat(parts[0]), Float.parseFloat(parts[1]));
    line = in.readLine().trim().substring(1);
    parts = line.split(",");
    toReturn.dirFace = new PVector(Float.parseFloat(parts[0]), Float.parseFloat(parts[1]));
    line = in.readLine().trim().substring(1);
    parts = line.split(",");
    toReturn.dirMove = new PVector(Float.parseFloat(parts[0]), Float.parseFloat(parts[1]));
    line = in.readLine().trim();
    parts = line.split(",");
    toReturn.tile = new int[]{Integer.parseInt(parts[0]), Integer.parseInt(parts[1])};
    toReturn.updatePathfinder = Boolean.parseBoolean(in.readLine());

    // stats
    toReturn.npcKills = Integer.parseInt(in.readLine());
    toReturn.bossKills = Integer.parseInt(in.readLine());
    toReturn.gametime = Integer.parseInt(in.readLine());

    // game control
    toReturn.minSpeed = Integer.parseInt(in.readLine());
    toReturn.maxSpeed = Integer.parseInt(in.readLine());
    toReturn.speedMult = Float.parseFloat(in.readLine());
    toReturn.tunnMult = Float.parseFloat(in.readLine());
    toReturn.initWeight = Integer.parseInt(in.readLine());
    toReturn.weightMult = Float.parseFloat(in.readLine());
    toReturn.tunn = Boolean.parseBoolean(in.readLine());
    toReturn.pass = Boolean.parseBoolean(in.readLine());
    toReturn.smacks2break = Integer.parseInt(in.readLine());
    toReturn.smacks = Integer.parseInt(in.readLine());
    toReturn.attack = Boolean.parseBoolean(in.readLine());
    toReturn.ticks2attack = Integer.parseInt(in.readLine());
    toReturn.ticks = Integer.parseInt(in.readLine());

    // audio logic
    toReturn.broke = Boolean.parseBoolean(in.readLine());
    toReturn.pickup = Boolean.parseBoolean(in.readLine());
    toReturn.attackMade = Boolean.parseBoolean(in.readLine());
    toReturn.pitfall = Boolean.parseBoolean(in.readLine());

    in.close();
  } 
  catch (IOException e) {
    e.printStackTrace();
    return null;
  }

  // INVENTORY
  f = new File(dataPath("savegame/playercharacter/pcinventory.txt"));
  if (!f.exists()) {
    return null;
  }

  try {
    in = new BufferedReader(new FileReader(f));

    toReturn.inventory = new Inventory();
    String l = in.readLine();
    while (!l.equals("END FAVORITE ITEMS")) {
      int pos = Integer.parseInt(l);
      toReturn.inventory.favorites[pos] = readItem(in);
      l = in.readLine();
    }

    l = in.readLine();
    while (!l.equals("END INVENTORY ITEMS")) {
      toReturn.inventory.inventory.add(readItem(in));
      l = in.readLine();
    }
  } 
  catch (IOException e) {
    e.printStackTrace();
    return null;
  }

  // EQUIPMENT
  f = new File(dataPath("savegame/playercharacter/pcequipment.txt"));
  if (!f.exists()) {
    return null;
  }

  try {
    in = new BufferedReader(new FileReader(f));

    HashMap<String, Item> equipItems = new HashMap<String, Item>();

    String l = in.readLine();
    while (!l.equals("END EQUIPMENT ITEMS")) {
      l = in.readLine();
      equipItems.put(l, readItem(in));
      l = in.readLine();
    }

    l = in.readLine();
    while (!l.equals("END RING ITEMS")) {
      l = in.readLine();
      equipItems.put(l, readItem(in));
      l = in.readLine();
    }

    l = in.readLine();
    while (!l.equals("END TEMPATTR ITEMS")) {
      l = in.readLine();
      equipItems.put(l, readItem(in));
      l = in.readLine();
    }

    l = in.readLine();
    while (!l.equals("END PERMATTR ITEMS")) {
      l = in.readLine();
      equipItems.put(l, readItem(in));
      l = in.readLine();
    }

    toReturn.equipment = new Equipment();

    // clearing all dunce Dice from the PC
    Dice tempDice;
    tempDice = toReturn.damage.get(0);
    toReturn.damage.clear();
    toReturn.damage.add(tempDice);
    tempDice = toReturn.defense.get(0);
    toReturn.defense.clear();
    toReturn.defense.add(tempDice);
    // loop through all items
    Item tempItem;
    int ringCount = 0;
    for (HashMap.Entry<String, Item> itemEntry : equipItems.entrySet()) {
      tempItem = itemEntry.getValue();
      if (tempItem.type.equals("RING")) {
        // place ring
        toReturn.equipment.rings[ringCount] = tempItem;
        ringCount++;
      } 
      if (Arrays.asList(toReturn.equipment.types).contains(tempItem.type)) {
        // equip item
        toReturn.equipment.equipment.put(tempItem.type, tempItem);
      }
      if (tempItem.hasAttributes && tempItem.attributes.get("TEMP") != null) {
        // place in tempAttr
        toReturn.equipment.temporaryAttrItems.add(tempItem);
      }
      if (tempItem.hasAttributes && tempItem.attributes.get("TEMP") == null) {
        // place in permAttr
        toReturn.equipment.permanentAttrItems.add(tempItem);
      }

      // place Dice where they belong if they belong (not 0+0d0)
      if (!tempItem.damageBonus.toString().equals("0+0d0")) {
        toReturn.damage.add(tempItem.damageBonus);
      }
      if (!tempItem.defenseBonus.toString().equals("0+0d0")) {
        toReturn.defense.add(tempItem.defenseBonus);
      }
    }
  } 
  catch (IOException e) {
    e.printStackTrace();
    return null;
  }

  return toReturn;
}

ArrayList<DungeonLevel> loadDungeon() {
  ArrayList<DungeonLevel> returnLevels;

  File f;
  BufferedReader in;

  // init dLevels
  String[] files = listFileNames("savegame/dungeon");

  returnLevels = new ArrayList<DungeonLevel>();
  for (int i = 0; i < files.length; i++) {
    returnLevels.add(null);
  }

  for (String filename : files) {
    f = new File(dataPath("savegame/dungeon/"+filename));
    if (!f.exists()) {
      return null;
    }
    try {
      in = new BufferedReader(new FileReader(f));
      int pos = Character.getNumericValue((filename.replace("level", "").charAt(0)));
      returnLevels.set(pos, readDungeonLevel(in));
      in.close();
    } 
    catch (IOException e) {
      e.printStackTrace();
      return null;
    }
  }

  return returnLevels;
}

DungeonLevel readDungeonLevel(BufferedReader r) {
  DungeonLevel toReturn = new DungeonLevel();
  try {
    // DungeonLevel variables
    toReturn.dmSize = Integer.parseInt(r.readLine());
    toReturn.dmTileSize = Float.parseFloat(r.readLine());

    // Dungeon Map
    toReturn.dm = new DungeonMap();
    toReturn.dm.dmSize = Integer.parseInt(r.readLine());
    int s = toReturn.dm.dmSize;
    toReturn.dm.tiles = new Tile[s][s];

    // load in tiles
    HashMap<String, Tile> tileHash = new HashMap<String, Tile>();
    for (int i = 0; i < s; i++) {
      for (int j = 0; j < s; j++) {
        r.readLine(); // the variables stored here are not needed. oops.
        String tileTag = r.readLine();
        toReturn.dm.tiles[i][j] = readTile(r);
        tileHash.put(tileTag, toReturn.dm.tiles[i][j]);
      }
    }

    // more DungeonMap variables
    toReturn.dm.numHardness = Integer.parseInt(r.readLine());
    toReturn.dm.hInc = Integer.parseInt(r.readLine());
    toReturn.dm.thresh = Float.parseFloat(r.readLine());

    String line = r.readLine();
    String[] parts = split(line, "|");
    toReturn.dm.floor = new ArrayList<int[]>();
    for (String p : parts) {
      if (!p.equals("")) {
        String[] np = p.split(",");
        toReturn.dm.floor.add(new int[]{Integer.parseInt(np[0]), Integer.parseInt(np[1])});
      }
    }

    line = r.readLine();
    toReturn.dm.upstair = line.equals("null") ? null : tileHash.get(line);
    line = r.readLine();
    toReturn.dm.downstair = line.equals("null") ? null : tileHash.get(line);
    line = r.readLine();
    if (line.equals("null")) {
      toReturn.dm.pits = null;
    } else {
      parts = line.split(",");
      toReturn.dm.pits = new Tile[parts.length];
      for (int i = 0; i < parts.length; i++) {
        toReturn.dm.pits[i] = tileHash.get(parts[i]);
      }
    }

    toReturn.dm.xoff0 = Float.parseFloat(r.readLine());
    toReturn.dm.yoff0 = Float.parseFloat(r.readLine());
    toReturn.dm.blend = Integer.parseInt(r.readLine());

    // NonPlayerCharacters
    toReturn.numNPC = Integer.parseInt(r.readLine());
    toReturn.npcs = new ArrayList<NonPlayerCharacter>();
    String jj = r.readLine();
    int currNumNPC = Integer.parseInt(jj); // stored another variable that doesn't matter. oops. :P
    for (int i = 0; i < currNumNPC; i++) {
      toReturn.npcs.add(readNPC(r));
    }

    // OccTiles
    toReturn.occTiles = new ArrayList<Tile>();
    int occSize = Integer.parseInt(r.readLine());
    for (int i = 0; i < occSize; i++) {
      toReturn.occTiles.add(tileHash.get(r.readLine()));
    }

    // Pathfinder
    toReturn.updatePathfinder = Boolean.parseBoolean(r.readLine());
    toReturn.pf = new Pathfinder(toReturn.dm);

    // Items
    toReturn.numItem = Integer.parseInt(r.readLine());
    toReturn.items = new ArrayList<Item>();
    int itemSize = Integer.parseInt(r.readLine());
    for (int i = 0; i < itemSize; i++) {
      r.readLine(); // unused data, I don't think it will be necessary...
      toReturn.items.add(readItem(r));
    }
  }
  catch (Exception e) {
    e.printStackTrace();
    return null;
  }
  return toReturn;
}

Tile readTile(BufferedReader r) {
  Tile toReturn = new Tile();
  try {
    toReturn.x = Integer.parseInt(r.readLine());
    toReturn.y = Integer.parseInt(r.readLine());
    toReturn.hardness = Integer.parseInt(r.readLine());
    toReturn.light = Float.parseFloat(r.readLine());
    toReturn.hInc = Integer.parseInt(r.readLine());
    toReturn.thresh = Float.parseFloat(r.readLine());
    toReturn.upstair = Boolean.parseBoolean(r.readLine());
    toReturn.downstair = Boolean.parseBoolean(r.readLine());
    toReturn.pit = Boolean.parseBoolean(r.readLine());
    toReturn.pitUncovered = Boolean.parseBoolean(r.readLine());
  }
  catch (Exception e) {
    e.printStackTrace();
    return null;
  }
  return toReturn;
}

NonPlayerCharacter readNPC(BufferedReader r) {
  NonPlayerCharacter toReturn = new NonPlayerCharacter();
  try {
    toReturn.name = r.readLine();
    toReturn.health = Integer.parseInt(r.readLine());
    toReturn.damage = new Dice(r.readLine());
    toReturn.speed = Float.parseFloat(r.readLine());
    toReturn.sight = Integer.parseInt(r.readLine());
    String[] abilStrings = r.readLine().split(",");
    toReturn.abilities = new boolean[abilStrings.length];
    for (int i = 0; i < toReturn.abilities.length; i++) {
      toReturn.abilities[i] = Boolean.parseBoolean(abilStrings[i]);
    }
    toReturn.type = r.readLine();
    toReturn.desc = r.readLine();
    toReturn.rarity = Float.parseFloat(r.readLine());
    toReturn.minSpeed = Integer.parseInt(r.readLine());
    toReturn.maxSpeed = Integer.parseInt(r.readLine());
    toReturn.speedMult = Float.parseFloat(r.readLine());

    String line = r.readLine().trim().substring(1);
    String[] parts = line.split(",");
    toReturn.pos = new PVector(Float.parseFloat(parts[0]), Float.parseFloat(parts[1]));

    line = r.readLine();
    parts = line.split(" ");
    toReturn.tile = new int[]{Integer.parseInt(parts[0]), Integer.parseInt(parts[1])};

    line = r.readLine();
    if (line.equals("null")) {
      toReturn.nextTile = null;
    } else {
      parts = line.split(" ");
      toReturn.nextTile = new int[]{Integer.parseInt(parts[0]), Integer.parseInt(parts[1])};
    }

    line = r.readLine();
    parts = split(line, "|");
    toReturn.tilesToTarget = new ArrayList<int[]>();
    for (String p : parts) {
      if (!p.equals("")) {
        String[] np = p.split(",");
        toReturn.tilesToTarget.add(new int[]{Integer.parseInt(np[0]), Integer.parseInt(np[1])});
      }
    }

    toReturn.ontarget = Boolean.parseBoolean(r.readLine());
    toReturn.smacks2break = Integer.parseInt(r.readLine());
    toReturn.smacks = Integer.parseInt(r.readLine());
    toReturn.ticks2attack = Integer.parseInt(r.readLine());
    toReturn.ticks = Integer.parseInt(r.readLine());
    toReturn.attackMade = Boolean.parseBoolean(r.readLine());

    line = r.readLine().trim().substring(1);
    parts = line.split(",");
    toReturn.lastDir = new PVector(Float.parseFloat(parts[0]), Float.parseFloat(parts[1]));

    line = r.readLine().trim().substring(1);
    parts = line.split(",");
    toReturn.currDir = new PVector(Float.parseFloat(parts[0]), Float.parseFloat(parts[1]));

    toReturn.rMovement = Float.parseFloat(r.readLine());
    toReturn.eMovement = Float.parseFloat(r.readLine());
  }
  catch (Exception e) {
    e.printStackTrace();
    return null;
  }
  return toReturn;
}

Item readItem(BufferedReader r) {
  Item toReturn = new Item();
  try {
    toReturn.name = r.readLine();
    toReturn.type = r.readLine();
    toReturn.desc = r.readLine();
    toReturn.healthBonus = Integer.parseInt(r.readLine());
    toReturn.damageBonus = new Dice(r.readLine());
    toReturn.defenseBonus = new Dice(r.readLine());
    toReturn.speedBonus = Integer.parseInt(r.readLine());
    toReturn.sightBonus = Integer.parseInt(r.readLine());
    toReturn.weight = Integer.parseInt(r.readLine());
    toReturn.value = Integer.parseInt(r.readLine());
    toReturn.rarity = Float.parseFloat(r.readLine());
    toReturn.hasAttributes = Boolean.parseBoolean(r.readLine());
    toReturn.attributes = new HashMap<String, Boolean>();
    if (toReturn.hasAttributes) {
      String[] attrs = r.readLine().trim().split(",");
      for (String attr : attrs) {
        toReturn.attributes.put(attr, true);
      }
    }
    toReturn.attrLifetime = Integer.parseInt(r.readLine());
    toReturn.attrLifespan = Integer.parseInt(r.readLine());
    toReturn.rangedShots = Integer.parseInt(r.readLine());
    toReturn.maxShots = Integer.parseInt(r.readLine());
    String line = r.readLine().trim().substring(1);
    String[] parts = line.split(",");
    toReturn.pos = new PVector(Float.parseFloat(parts[0]), Float.parseFloat(parts[1]));
    toReturn.covered = Boolean.parseBoolean(r.readLine());
    toReturn.holding = Boolean.parseBoolean(r.readLine());
    toReturn.dropped = Boolean.parseBoolean(r.readLine());
  }
  catch (Exception e) {
    e.printStackTrace();
    return null;
  }
  return toReturn;
}

/************************************************************************************************************************************************/
/************************************************************************************************************************************************/
/************************************************************** MISC FUNCTIONS ******************************************************************/
/************************************************************************************************************************************************/
/************************************************************************************************************************************************/

void removeSavedGame() {
  // erase game save
  File f;
  f = new File(dataPath("savegame"));
  try {
    if (f.exists()) {
      deleteDirectoryRecursive(f);
    }
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}

void deleteDirectoryRecursive(File file) throws IOException {
  if (file.isDirectory()) {
    File[] entries = file.listFiles();
    if (entries != null) {
      for (File entry : entries) {
        deleteDirectoryRecursive(entry);
      }
    }
  }
  if (!file.delete()) {
    throw new IOException("Failed to delete " + file);
  }
}

boolean loadAvailable() {
  File f;
  f = new File(dataPath("savegame"));
  try {
    if (f.exists()) {
      return true;
    }
  } 
  catch (Exception e) {
    e.printStackTrace();
    return false;
  }
  return false;
}
