//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
class PlayerCharacter {

  String name;
  int health;
  ArrayList<Dice> damage;
  ArrayList<Dice> defense;
  float speed;
  int sight;
  float weight;
  int money;

  Inventory inventory = new Inventory();
  Equipment equipment = new Equipment();

  // stats
  int npcKills = 0;
  int bossKills = 0;
  int gametime;
  int timestart;
  int timestop;
  // also health and money.

  int minSpeed = 2;
  int maxSpeed = 10;
  float speedMult = 0.01;

  float tunnMult = 0.1;

  int initWeight = 150;
  float weightMult = 0.0013;

  boolean tunn = true;
  boolean pass = false;

  int smacks2break; //update with tunn objects.
  int smacks = 0;

  boolean attack;
  int ticks2attack;
  int ticks = 0;

  // audio booleans
  boolean broke = false;
  boolean pickup = false;
  boolean attackMade = false;
  boolean pitfall = false;

  PVector pos; // actual position. (assumes each dungeon map tile is 1 wide and 1 tall)
  PVector dirFace; // which direction the character is facing.
  PVector dirMove;
  int[] tile;    // dungeon tile position.
  boolean updatePathfinder = false;

  PlayerCharacter(String name, String health, String damage, String defense, String speed, String sight) {
    this.name = name;
    this.health = (new Dice(health)).roll();
    this.damage = new ArrayList<Dice>();
    this.damage.add(new Dice(damage));
    this.defense = new ArrayList<Dice>();
    this.defense.add(new Dice(defense));
    this.speed = (new Dice(speed)).roll();
    this.sight = (new Dice(sight)).roll();

    this.weight = initWeight;
    this.money = 0;

    this.smacks2break = (int)this.speed*60;
    this.ticks2attack = floor(abs(this.speed-maxSpeed))+60;

    this.dirFace = new PVector(1, 0);
    this.dirMove = new PVector(0, 0);

    this.timestart = millis();
  }

  PlayerCharacter() {
    // used for loading character from file.
    // see fileSaveLoad
  }

  void update(DungeonLevel dlvl) {
    dirFace = mouseDir;
    move(dlvl.dm, dlvl.npcs);
    if (updatePathfinder) {
      dlvl.updatePathfinder = true;
      updatePathfinder = false;
    }

    pickupItems(dlvl.items);
    updateAttributes();

    fight(dlvl);

    checkPits(dlvl.dm);
    checkStairs(dlvl.dm);

    updateAudio();
    updateGametime();
  }

  void display(float x, float y, float size) {
    fill(0, 255, 0);
    strokeWeight(1);
    stroke(0, 255, 0);
    ellipse(x, y, size, size);
  }

  void display(float size) {
    float x = width/2;
    float y = height/2;

    boolean ismoving = dirMove.mag() != 0;
    boolean faceRight = dirFace.x > 0;
    boolean moveRight = dirMove.x > 0;

    Item helmet, armor, boots, cloak, sheild, weapon;
    helmet = equipment.get("HELMET");
    helmet = helmet != null ? helmet : null;
    armor = equipment.get("ARMOR");
    armor = armor != null ? armor : null;
    boots = equipment.get("BOOTS");
    boots = boots != null ? boots : null;
    cloak = equipment.get("CLOAK");
    cloak = cloak != null ? cloak : null;
    sheild = equipment.get("WEAPON");
    sheild = (sheild != null && sheild.name.toLowerCase().contains("sheild")) ? sheild : null;
    sheild = sheild == null ? equipment.get("OFFHAND") : sheild;
    sheild = (sheild != null && sheild.name.toLowerCase().contains("sheild")) ? sheild : null;

    int mod;
    if (!ismoving) {
      mod = 60;
      mod = gamePause ? 0 : mod;
      if (faceRight) {
        displayPixelArtAnimation("pc idle right", x, y, mod, 255, true);
        if (boots != null) {
          displayPixelArtAnimation("boots idle right", x, y, mod, 255, true);
          syncAnimations("pc idle right", "boots idle right");
        }
        if (helmet != null)
          displayPixelArtStatic(helmet.name.toLowerCase(), 2, x, y, 255, true);
        if (armor != null)
          displayPixelArtStatic(armor.name.toLowerCase(), 2, x, y, 255, true);
        if (cloak != null)
          displayPixelArtStatic("cloak still", 0, x, y, 255, true);
        if (sheild != null)
          displayPixelArtStatic(sheild.name.toLowerCase(), 0, x+size/5, y+size/6, 255, true);
      } else {
        displayPixelArtAnimation("pc idle left", x, y, mod, 255, true);
        if (boots != null) {
          displayPixelArtAnimation("boots idle left", x, y, mod, 255, true);
          syncAnimations("pc idle left", "boots idle left");
        }
        if (helmet != null) 
          displayPixelArtStatic(helmet.name.toLowerCase(), 1, x, y, 255, true);
        if (armor != null)
          displayPixelArtStatic(armor.name.toLowerCase(), 1, x, y, 255, true);
        if (cloak != null)
          displayPixelArtStatic("cloak still", 1, x, y, 255, true);
        if (sheild != null)
          displayPixelArtStatic(sheild.name.toLowerCase(), 0, x-size/5, y+size/6, 255, true);
      }
    } else {
      mod = (int)((maxSpeed-(speed*speedMult-(weight-initWeight)*weightMult)+1))*3/4;
      mod = gamePause ? 0 : mod;
      if (dirMove.x != 0) {
        if (moveRight) {
          displayPixelArtAnimation("pc move right", x, y, mod, 255, true);
          if (boots != null) {
            displayPixelArtAnimation("boots move right", x, y, mod, 255, true);
            syncAnimations("pc move right", "boots move right");
          }
          if (helmet != null) 
            displayPixelArtStatic(helmet.name.toLowerCase(), 2, x, y, 255, true);
          if (armor != null)
            displayPixelArtStatic(armor.name.toLowerCase(), 2, x, y, 255, true);
          if (cloak != null)
            displayPixelArtAnimation("cloak move right", x, y, mod, 255, true);
          if (sheild != null)
            displayPixelArtStatic(sheild.name.toLowerCase(), 0, x+size/5, y+size/6, 255, true);
        } else {
          displayPixelArtAnimation("pc move left", x, y, mod, 255, true);
          if (boots != null) {
            displayPixelArtAnimation("boots move left", x, y, mod, 255, true);
            syncAnimations("pc move left", "boots move left");
          }
          if (helmet != null) 
            displayPixelArtStatic(helmet.name.toLowerCase(), 1, x, y, 255, true);
          if (armor != null)
            displayPixelArtStatic(armor.name.toLowerCase(), 1, x, y, 255, true);
          if (cloak != null)
            displayPixelArtAnimation("cloak move left", x, y, mod, 255, true);
          if (sheild != null)
            displayPixelArtStatic(sheild.name.toLowerCase(), 0, x-size/5, y+size/6, 255, true);
        }
      } else {
        if (faceRight) {
          displayPixelArtAnimation("pc idle right", x, y, mod, 255, true);
          if (boots != null) {
            displayPixelArtAnimation("boots idle right", x, y, mod, 255, true);
            syncAnimations("pc idle right", "boots idle right");
          }
          if (helmet != null) 
            displayPixelArtStatic(helmet.name.toLowerCase(), 2, x, y, 255, true);
          if (armor != null)
            displayPixelArtStatic(armor.name.toLowerCase(), 2, x, y, 255, true);
          if (cloak != null)
            displayPixelArtAnimation("cloak move right", x, y, mod, 255, true);
          if (sheild != null)
            displayPixelArtStatic(sheild.name.toLowerCase(), 0, x+size/5, y+size/6, 255, true);
        } else {
          displayPixelArtAnimation("pc idle left", x, y, mod, 255, true);
          if (boots != null) {
            displayPixelArtAnimation("boots idle left", x, y, mod, 255, true);
            syncAnimations("pc idle left", "boots idle left");
          }
          if (helmet != null) 
            displayPixelArtStatic(helmet.name.toLowerCase(), 1, x, y, 255, true);
          if (armor != null)
            displayPixelArtStatic(armor.name.toLowerCase(), 1, x, y, 255, true);
          if (cloak != null)
            displayPixelArtAnimation("cloak move left", x, y, mod, 255, true);
          if (sheild != null)
            displayPixelArtStatic(sheild.name.toLowerCase(), 0, x-size/5, y+size/6, 255, true);
        }
      }
    }

    // show weapon if weapon
    weapon = equipment.getMainWeapon();
    if (weapon != null) { // just one
      float mult = 3;
      float t = constrain(ticks*mult, 0, ticks2attack);
      t = map(t, 0, ticks2attack, -0.5, 0.5);
      // parabolic weapon movement
      // y = -m(0^2) + 50
      // 100 = -m(0.5^2) + 50
      // m = -200
      int dmin = 50;
      int dmax = 70;
      float m = -(dmax-dmin)/(0.5*0.5);
      float d = m*t*t+dmax;

      pushMatrix();
      translate(x+dirFace.x*d, y+dirFace.y*d);
      rotate(dirFace.heading()+PI/4);
      displayPixelArtStatic(weapon.name.toLowerCase(), 1, 0, 0, 255, true);
      popMatrix();
    }
  }

  int getScore() {
    int score = 0; 
    score += npcKills*10;
    score += bossKills*50;
    score += health*10;
    score += money;
    score += maxLevel*100;
    return score;
  }

  int getWealth() {
    // add monetary value of all items plus player money and return
    int wealth = 0;
    wealth += money;
    wealth += equipment.equipmentValue();
    wealth += inventory.inventoryValue();
    return wealth;
  }

  void updateGametime() {
    gametime += millis()-timestart;
    timestart = millis();
  }


  /*
    USE INVENTORY AND EQUIPMENT
   */
  void updateAttributes() {
    String checkTempAttr = equipment.updateTempAttr();
    if (checkTempAttr.length() > 0) {
      // go through temp attribute items and remove the ones that are dead.
      String[] toRemove = checkTempAttr.split(",");
      for (int i = toRemove.length-1; i >= 0; i--) {
        int trl = Integer.parseInt(toRemove[i]);
        Item expired = equipment.temporaryAttrItems.remove(trl);
        // remove attr item from list
        //     if it is equipped remove from equipment (which then calls "manageItemBonuses")
        //     if it is not equipped, make sure to "manageItemBonuses"
        if (equipment.isEquipped(expired)) {
          equipment.removeItem(expired);
          manageItemBonuses(expired, false, expired.weight > 0 ? true : false);
          soundeffects.get("item expunge").play(false);
        } else {
          manageItemBonuses(expired, false, expired.weight > 0 ? true : false);
        }
      }
    }
  }

  void pickupItems(ArrayList<Item> items) {
    for (int i = items.size()-1; i >= 0; i--) {
      Item temp = items.get(i);
      if (!temp.holding && !temp.covered && dist(pos.x, pos.y, temp.pos.x, temp.pos.y) < 1 && !temp.dropped) {
        if (inventory.put(temp)) {
          temp.holding = true;
          pickup = true;
          items.remove(temp);
        }
      }
    }
  }

  Item useItem(Item toEquip, DungeonLevel dlvl) {
    boolean wearable = equipment.isEquipable(toEquip);
    if (wearable) {
      // is wearable
      boolean good = equipment.wear(toEquip);
      if (!good) {
        return toEquip;
      } else {
        // apply general bonuses
        manageItemBonuses(toEquip, true, true);
      }
    } else {
      // not wearable, just useable

      // do gold seperately, everything else can be managed in the same way.
      // ----add bonuses like normal, not weight &&& Keep track of special attributes
      if (toEquip.type.equals("GOLD")) {
        money += toEquip.value;
      } else {
        manageItemBonuses(toEquip, true, false);
      }
      // remove from items list (don't put back into inventory)
      dlvl.items.remove(toEquip);
    }
    return null;
  }

  void manageItemBonuses(Item i, boolean add, boolean mass) {
    // ATTR bonuses
    equipment.manageAttrLists(i, add);

    // normal bonuses
    if (add) {
      health += i.healthBonus;
      if (!i.damageBonus.toString().equals("0+0d0"))
        damage.add(i.damageBonus);
      if (!i.defenseBonus.toString().equals("0+0d0"))
        defense.add(i.defenseBonus);
      speed += i.speedBonus;
      sight += i.sightBonus;
      if (mass) 
        weight += i.weight;
    } else {
      health -= i.healthBonus;
      damage.remove(i.damageBonus);
      defense.remove(i.defenseBonus);
      speed -= i.speedBonus;
      sight -= i.sightBonus; 
      if (mass) 
        weight -= i.weight;
    }

    // update attack speed
    ticks2attack = floor(abs(speed-maxSpeed))+60;
  }

  ArrayList<Item> getAllItems() {
    ArrayList<Item> all = inventory.listAllItems();
    all.addAll(equipment.listAllItems());
    Set<Item> set = new HashSet<Item>(all);
    all = new ArrayList<Item>(set);
    all.remove(null);
    return all;
  }

  boolean hasAttr(String attr) {
    return equipment.hasAttr(attr);
  }

  String damageRange() {
    int low = 0;
    int high = 0;
    for (Dice d : damage) {
      low += d.low();
      high += d.high();
    }
    return  ""+low+"-"+high;
  }

  String defenseRange() {
    int low = 0;
    int high = 0;
    for (Dice d : defense) {
      low += d.low();
      high += d.high();
    }
    return  ""+low+"-"+high;
  }

  void checkStairs(DungeonMap dm) {
    if (dm.tiles[tile[0]][tile[1]].upstair && keys['.'][1]) {
      //  if going upstairs
      currLevel++;
      maxLevel = currLevel > maxLevel ? currLevel : maxLevel;
      if (currLevel != nLevels) {
        pos.x = dLevels.get(currLevel).dm.downstair.x+0.5;
        pos.y = dLevels.get(currLevel).dm.downstair.y+0.5;
      } else {
        currLevel--; // so a null pointer isn't referenced later on...
        stateController.setWin(true);
      }
    } else if (dm.tiles[tile[0]][tile[1]].downstair && keys[','][1]) {
      //  if going downstairs
      currLevel--;
      pos.x = dLevels.get(currLevel).dm.upstair.x+0.5;
      pos.y = dLevels.get(currLevel).dm.upstair.y+0.5;
    }
  }

  void checkPits(DungeonMap dm) {
    if (dm.pits != null) {
      for (int i = 0; i < dm.pits.length; i++) {
        if (dist(pos.x, pos.y, dm.pits[i].x+0.5, dm.pits[i].y+0.5) < 0.75) {
          dm.pits[i].pitUncovered = true;
          pitfall = true;

          float offx = pos.x-(dm.downstair.x+0.5);
          float offy = pos.y-(dm.downstair.y+0.5);

          currLevel--;

          pos.x = dLevels.get(currLevel).dm.upstair.x+0.5+offx;
          pos.y = dLevels.get(currLevel).dm.upstair.y+0.5+offy;
        }
      }
    }
  }

  void fight(DungeonLevel dlvl) {
    ticks++;
    if (ticks >= ticks2attack) {
      NonPlayerCharacter toAttack = null;
      for (NonPlayerCharacter npc : dlvl.npcs) {
        // determine if the monster is within attacking distance (and if it's closer than toAttack

        if (pbcDist(pos, npc.pos, dlvl.dmSize) < sight 
          && ((toAttack != null && pbcDist(pos, npc.pos, dlvl.dmSize) < pbcDist(pos, toAttack.pos, dlvl.dmSize)) || toAttack == null)) {
          // determine if the monster is within attacking angle

          float angle = abs(PVector.angleBetween(dirFace, PVector.sub(npc.pos, pos)));
          if (angle <= radians(15)) {
            // determine if the monster is within birds eye view

            boolean birdy = true;
            if (pbcDist(pos, npc.pos, dlvl.dmSize) >= sqrt(2)) {
              float x, y;
              for (int i = 0; i < sight*2; i++) {
                // need to get x and y lerp between pos and npc.pos, but it has to follow pbc
                x = lerp(pos.x, npc.pos.x-floor(npc.pos.x)+pbc(floor(npc.pos.x), dlvl.dmSize), (float)i/(sight*2));
                y = lerp(pos.y, npc.pos.y-floor(npc.pos.y)+pbc(floor(npc.pos.y), dlvl.dmSize), (float)i/(sight*2));
                if (dlvl.dm.tiles[pbc(floor(x), dlvl.dmSize)][pbc(floor(y), dlvl.dmSize)].hardness != 0) {
                  birdy = false;
                  break;
                }
              }
            }
            if (birdy) {
              toAttack = npc;
            }
          }
        }
      }
      if (toAttack != null) {
        attackMade = false;
        boolean rage = hasAttr("RAGE");
        if (hasAttr("RANGED") && pbcDist(pos, toAttack.pos, dlvl.dmSize) < 5 ) {
          toAttack.health -= rollDamage()*(rage ? 3 : 1);
          Item rangedw = equipment.get("WEAPON");
          rangedw.rangedShots++;
          if (rangedw.rangedShots == rangedw.maxShots) {
            equipment.removeItem(rangedw);
            manageItemBonuses(rangedw, false, true);
            soundeffects.get("item expunge").play(false);
          }
          attackMade = true;
        } else {
          // check for proximity for close combat (tileSize*1.2?)
          if (pbcDist(pos, toAttack.pos, dlvl.dmSize) < 1.2) {
            toAttack.health -= rollDamage()*(rage ? 3 : 1);
            attackMade = true;
          }
        }
        if (attackMade) {
          attack = true;
          ticks = 0;
        }
      }
    }
  }

  int rollDamage() {
    int toReturn = 0;
    for (Dice d : damage) {
      toReturn += d.roll();
    }
    return toReturn;
  }

  int rollDefense() {
    int toReturn = 0;
    for (Dice d : defense) {
      toReturn += d.roll();
    }
    return toReturn;
  }


  void move(DungeonMap dmap, ArrayList<NonPlayerCharacter> nonpcs) {
    dirMove = nextDir();

    speed = constrain(speed, minSpeed, maxSpeed);
    float multiplier = (speed*speedMult-(weight-initWeight)*weightMult);

    // take into account TUNN, PASS and tile hardness here
    // all only applicable if currDir want's to move the character into a wall
    float xt = pos.x + dirMove.x*multiplier;
    xt = xt < 0 ? dmap.dmSize+xt : (xt > dmap.dmSize ? xt-dmap.dmSize : xt);
    int ixt = floor(xt);
    float yt = pos.y + dirMove.y*multiplier;
    yt = yt < 0 ? dmap.dmSize+yt : (yt > dmap.dmSize ? yt-dmap.dmSize : yt);
    int iyt = floor(yt);

    // distance from center of next tile
    float d = max(abs(xt-(ixt+0.5)), abs(yt-(iyt+0.5)));

    //making sure travel to a corner tile is possible.
    boolean throughCorner = false;
    int[] cornerTest = new int[]{floor(pos.x+dirMove.x/2), floor(pos.y+dirMove.y/2)};
    if (cornerTest[0] != tile[0] && cornerTest[1] != tile[1] && dist(xt, yt, cornerTest[0]+0.5, cornerTest[1]+0.5) < sqrt(2)*0.5) {
      throughCorner = true;
    }

    // if the PC is close enough to the tile it's going to dig, then dig.
    if (dmap.tiles[ixt][iyt].hardness > 0 && d < 0.5 && !throughCorner) {
      if (hasAttr("PASS") || pass) {                          // PASS
        // Nothing to see here.
      } else if (tunn) {                   // TUNN
        if (smacks >= smacks2break) {
          dmap.tiles[ixt][iyt].hardness -= dmap.hInc;
          smacks = 0;
          broke = true;
          if (!dmap.belowThresh(float(dmap.tiles[ixt][iyt].hardness))) {
            dirMove.set(0, 0);
          } else {
            dmap.tiles[ixt][iyt].hardness = 0;
          }
        } else {
          dirMove.set(0, 0);
          smacks += speed+equipment.tunnBonus();
        }
      } else {                            // not PASS not TUNN
        //nextDir.mult(0);
        dirMove.mult(-1);
      }
    } else {
      smacks = 0;
    }

    PVector nextPos = pos.copy().add(dirMove.copy().mult(multiplier));

    // take into account proximity to npcs
    boolean tooclose = false;
    for (NonPlayerCharacter npc : nonpcs) {
      if (pbcDist(nextPos.x, nextPos.y, npc.pos.x, npc.pos.y, dmap.dmSize) < 1) {
        tooclose = true;
      }
    }
    if (!tooclose) {
      pos = nextPos.copy();
    }

    // take into account pbc and tile change
    pos.x = pos.x < 0 ? dmap.dmSize+pos.x : (pos.x > dmap.dmSize ? pos.x-dmap.dmSize : pos.x);
    pos.y = pos.y < 0 ? dmap.dmSize+pos.y : (pos.y > dmap.dmSize ? pos.y-dmap.dmSize : pos.y);
    updateTile();
  }

  void updateAudio() {
    SoundPlayer toUpdate;

    // walking
    toUpdate = soundeffects.get("pc walk");
    if (dirMove.mag() != 0) {
      if (!toUpdate.isPlaying())
        toUpdate.play(true);
    } else {
      if (toUpdate.isPlaying())
        toUpdate.pause();
    }

    // digging
    if (broke) {
      toUpdate = soundeffects.get("pc dig");
      toUpdate.play(true);
      broke = false;
    }

    // attacking
    if (attackMade) {
      toUpdate = soundeffects.get("pc attack");
      toUpdate.play(true);
      attackMade = false;
    }

    // item pickup
    if (pickup) {
      toUpdate = soundeffects.get("pc item pickup");
      toUpdate.play(true);
      pickup = false;
    }

    // pit fall
    if (pitfall) {
      toUpdate = soundeffects.get("pit fall");
      toUpdate.play(true);
      delay(toUpdate.duration());
      pitfall = false;
    }
  }

  PVector nextDir() {
    PVector dir = new PVector(0, 0);
    if (keys['w'][0]) {
      dir.y -= 1;
    }
    if (keys['a'][0]) {
      dir.x -= 1;
    }
    if (keys['s'][0]) {
      dir.y += 1;
    }
    if (keys['d'][0]) {
      dir.x += 1;
    }
    dir.normalize();
    return dir;
  }

  void updateTile() {
    if (floor(pos.x) != tile[0] || floor(pos.y) != tile[1]) {
      updatePathfinder = true;
    }
    tile[0] = floor(pos.x);
    tile[1] = floor(pos.y);
  }

  void setRandomFloorLocation(DungeonMap dungmap, ArrayList<Tile> badtiles) {
    int count = 0;
    while (true) {
      this.tile = dungmap.getRandomFloorLocation();

      boolean bad = false;
      for (Tile t : badtiles) {
        if (dist(t.x, t.y, tile[0], tile[1]) < sight)
          bad = true;
      }

      if (!bad || count > 250) {
        float tx = float(this.tile[0]);
        float ty = float(this.tile[1]);
        this.pos = new PVector(tx+0.5, ty+0.5);
        break;
      }
      count++;
    }
  }

  String moneyToText() {
    int c, s, g;
    c = money;
    s = c/20;
    c = c-s*20;
    g = s/20;
    s = s-g*20;
    return ""+g+"g, "+s+"s, "+c+"c";
  }

  void printCharacterInfo(boolean equip, boolean inven, boolean stats) {
    String p = "";
    for (int i = 0; i < 10; i ++) {
      p += "\n";
    }
    // print Equipment
    if (equip) {
      p += "EQUIPMENT";
      p += equipment.toString();
    }

    // print Inventory
    if (inven) {
      p += "INVENTORY";
      p += inventory.toString();
    }

    // print Character Stats
    if (stats) {
      p += "CHARACTER STATS\n";
      p += "NAME:  "+name+"\n";
      p += "HEALTH:  "+health+"\n";
      p += "DAMAGE:  "+damage.toString();
      p += "DAMAGE:  "+defense.toString();
      p += "SPEED:  "+speed+"\n";
      p += "SIGHT:  "+sight+"\n";
      p += "WEIGHT:  "+weight+"\n";
      p += "GOLD:  "+money+"\n";
    }
  }
}
