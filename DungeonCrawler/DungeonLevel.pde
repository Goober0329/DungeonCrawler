//<>// //<>// //<>// //<>// //<>// //<>// //<>//
// todo This will hold a dungeon map and all of the items, npcs, and other features in it...

class DungeonLevel {

  int dmSize;
  float dmTileSize;
  
  DungeonMap dm;

  int numNPC;
  ArrayList<NonPlayerCharacter> npcs;
  ArrayList<Tile> occTiles;

  Pathfinder pf;
  boolean updatePathfinder = false;

  int numItem;
  ArrayList<Item> items;

  DungeonLevel(int dm_size, float dmTileSize, int num_NPC, int num_Item, boolean bottom) {
    this.dmSize = dm_size;
    this.numNPC = num_NPC;
    this.numItem = num_Item;

    // Dungeon Map creation
    dm = new DungeonMap(dmSize, 10, 4, 0.13, 0.15);
    this.dmTileSize = dmTileSize;

    occTiles = new ArrayList<Tile>();
    dm.placeStairs(bottom, occTiles);
    dm.placePits(bottom, occTiles);

    // NPC creation (one boss per level) (add boss after a certain number of kills? we dont want the boss to immediately track after and kill the PC)
    String[] types = new String[]{"DWARF", "HUMAN", "OGRE", "ORC", "TROLL", "UNDEAD", "BOSS"};
    npcs = new ArrayList<NonPlayerCharacter>();
    ArrayList<NPCgenerator> NPCtypeGenerators;
    for (int i = 0; i < numNPC; i++) {
      int f = floor(random(types.length-1)); // exclude BOSS
      NPCtypeGenerators = foeOptions.get(types[f]);
      NonPlayerCharacter temp = NPCtypeGenerators.get(floor(random(NPCtypeGenerators.size()))).generate(); 
      temp.setRandomFloorLocation(dm, occTiles);
      occTiles.add(dm.tiles[temp.tile[0]][temp.tile[1]]);
      temp.health *= 2;
      npcs.add(temp);
    }

    // add a boss to the level
    if (!bottom) {
      NPCtypeGenerators = foeOptions.get("BOSS");
      NonPlayerCharacter tempo = NPCtypeGenerators.get(floor(random(NPCtypeGenerators.size()))).generate(); 
      tempo.setRandomFloorLocation(dm, occTiles);
      occTiles.add(dm.tiles[tempo.tile[0]][tempo.tile[1]]);
      tempo.health *= 2;

      npcs.add(tempo);
    }

    //INTE, TELE, TUNN, ERRA, LAZY, PASS, BOSS
    //for (NonPlayerCharacter npc : npcs) {
    //  npc.abilities[0] = true;   // INTE
    //  npc.abilities[1] = true;   // TELE
    //  npc.abilities[2] = true;   // TUNN
    //  npc.abilities[3] = true;  // ERRA
    //  npc.abilities[4] = false;  // LAZY
    //  npc.abilities[5] = false;   // PASS
    //  npc.abilities[6] = false;  // BOSS
    //} 

    // Item creation
    items = new ArrayList<Item>();
    ArrayList<ItemGenerator> ItemTypeGenerators;
    for (HashMap.Entry<String, Integer> type : itemDistribution.entrySet()) {
      // loop through itemDistribution and create items
      for (int i = 0; i < type.getValue(); i++) {
        ItemTypeGenerators = itemOptions.get(type.getKey());
        Item temp = ItemTypeGenerators.get(floor(random(ItemTypeGenerators.size()))).generate(); 
        temp.setDungeonLocation(dm);
        //temp.pos.set(pyc.pos.x, pyc.pos.y);
        items.add(temp);
      }
    }
  }


  DungeonLevel() {
    // used for loading character from file.
    // see fileSaveLoad
  }

  void update(PlayerCharacter pyc) {
    // update npcs
    NonPlayerCharacter temp;
    for (int i = 0; i < npcs.size(); i++) {
      temp = npcs.get(i);
      // only move if not freeze or if freeze and out
      if (!pyc.equipment.hasAttr("FREEZE") || (pyc.hasAttr("FREEZE") && pbcDist(pyc.pos.x, pyc.pos.y, npcs.get(i).pos.x, npcs.get(i).pos.y, dmSize) > pyc.sight)) {
        temp.update(this, pc);
      }
      // death?
      if (temp.health <= 0) {
        // drop 1-3 items around/on death spot.
        ArrayList<ItemGenerator> geners;
        Item tempi;
        boolean boss = temp.abilities[6] ? true : false;
        if (boss) {
          pyc.bossKills++;
        } else {
          pyc.npcKills++;
        }
        int nItem = boss ? floor(random(3, 6)) : floor(random(0, 3));
        for (int j = 0; j < nItem; j++) {
          geners = itemOptions.get(itemTypes[floor(random(itemTypes.length))]);
          tempi = geners.get(floor(random(geners.size()))).generate();
          tempi.pos = temp.pos;
          items.add(tempi);
        }

        // boss death
        // spawn more NPCs of same type and set currNPCs of same type to tele, tunn, etc... remove lazy and erratic
        if (temp.abilities[6]) {
          ArrayList<NPCgenerator> bossTypeFoes = foeOptions.get(temp.type);
          for (int j = 0; j < random(5, 10); j++) {
            NonPlayerCharacter newtemp = bossTypeFoes.get(floor(random(bossTypeFoes.size()))).generate(); 
            newtemp.setRandomFloorLocation(dm, occTiles);
            occTiles.add(dm.tiles[newtemp.tile[0]][newtemp.tile[1]]);
            newtemp.abilities[0] = true;
            newtemp.abilities[1] = true;
            newtemp.abilities[2] = true;
            newtemp.abilities[3] = false;
            newtemp.abilities[4] = false;
            npcs.add(newtemp);
          }
        }

        npcs.remove(temp);
      }
    }

    // update items
    for (int i = 0; i < items.size(); i++) {
      items.get(i).update(pyc);
    }

    if (updatePathfinder && !pf.pathThreading) {
      thread("threadUpdatePathfinder");
    }
  }

  void updateLighting(PlayerCharacter pyc) {
    recursiveLighting(pyc, pyc.tile[0], pyc.tile[1], false, 1);
  }

  void recursiveLighting(PlayerCharacter pyc, int currx, int curry, boolean corner, float lastLight) {
    float d = pbcDist(pyc.pos.x, pyc.pos.y, currx+0.5, curry+0.5, dmSize);
    if (d > pyc.sight) { 
      return;
    }

    int cx = pbc(currx, dmSize);
    int cy = pbc(curry, dmSize);
    float baseDrop = (float)1/pyc.sight/1.25;
    float lightBlocking = dm.tiles[cx][cy].hardness == 0 ? baseDrop : (float)dm.tiles[cx][cy].hardness/255/1.8;
    if (corner) {
      lightBlocking *= sqrt(2);
    }
    float newLight = lastLight-lightBlocking;
    newLight = newLight < 0 ? 0 : newLight;

    if (newLight <= dm.getLight(cx, cy)) {
      return;
    }

    dm.setLight(cx, cy, newLight);

    // non-corners
    recursiveLighting(pyc, cx-1, cy, false, newLight);
    recursiveLighting(pyc, cx+1, cy, false, newLight);
    recursiveLighting(pyc, cx, cy-1, false, newLight);
    recursiveLighting(pyc, cx, cy+1, false, newLight);
    // corners
    recursiveLighting(pyc, cx-1, cy-1, true, newLight);
    recursiveLighting(pyc, cx+1, cy+1, true, newLight);
    recursiveLighting(pyc, cx+1, cy-1, true, newLight);
    recursiveLighting(pyc, cx-1, cy+1, true, newLight);
  }

  void display(PlayerCharacter pyc) {

    // update lighting
    updateLighting(pyc);
    dm.display(pyc, dmTileSize);

    int nx = ceil(width/dmTileSize);
    int ny = ceil(height/dmTileSize);
    for (Item i : items) {
      //  if xpos > pbc(lxboundary) and ypos < pbc(byboundary)
      //  or xpos > pbc(lxboundary) and ypos > pbc(tyboundary)
      //  or xpos < pbc(rxboundary) and ypos < pbc(byboundary)
      //  or xpos < pbc(rxboundary) and ypos > pbc(tyboundary)
      if ((i.pos.x > pbc(floor(pyc.pos.x-nx/2-1), dmSize) && i.pos.y < pbc(ceil(pyc.pos.y+ny/2+1), dmSize))
        || (i.pos.x > pbc(floor(pyc.pos.x-nx/2-1), dmSize) && i.pos.y > pbc(floor(pyc.pos.y-ny/2-1), dmSize))
        || (i.pos.x < pbc(ceil(pyc.pos.x+nx/2+1), dmSize) && i.pos.y < pbc(ceil(pyc.pos.y+ny/2+1), dmSize))
        || (i.pos.x < pbc(ceil(pyc.pos.x+nx/2+1), dmSize) && i.pos.y > pbc(floor(pyc.pos.y-ny/2-1), dmSize))) {
        float t = dm.tiles[floor(i.pos.x)][floor(i.pos.y)].light;
        i.display(pyc, dmSize, dmTileSize, t*255);
      }
    }

    for (NonPlayerCharacter npc : npcs) {
      if ((npc.pos.x > pbc(floor(pyc.pos.x-nx/2-1), dmSize) && npc.pos.y < pbc(ceil(pyc.pos.y+ny/2+1), dmSize))
        || (npc.pos.x > pbc(floor(pyc.pos.x-nx/2-1), dmSize) && npc.pos.y > pbc(floor(pyc.pos.y-ny/2-1), dmSize))
        || (npc.pos.x < pbc(ceil(pyc.pos.x+nx/2+1), dmSize) && npc.pos.y < pbc(ceil(pyc.pos.y+ny/2+1), dmSize))
        || (npc.pos.x < pbc(ceil(pyc.pos.x+nx/2+1), dmSize) && npc.pos.y > pbc(floor(pyc.pos.y-ny/2-1), dmSize))) {
        //pf.highlightPathFrom(npc.tile[0], npc.tile[1], dmTileSize, true); // this doesn't work now that I have fixed how the game displays
        float t = dm.tiles[pbc(floor(npc.pos.x), dmSize)][pbc(floor(npc.pos.y), dmSize)].light;
        npc.display(pyc, dmSize, dmTileSize, t*255);
      }
    }
  }

  void createPathfinder(PlayerCharacter pyc) {
    // Pathfinder creation
    pf = new Pathfinder(dm);
    pf.updateTunnelingMap(pyc.tile[0], pyc.tile[1]);
  }
}
