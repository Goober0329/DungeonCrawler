//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
class NonPlayerCharacter {

  String name;
  int health;
  Dice damage;
  float speed;
  int sight;
  // INTE, TELE, TUNN, ERRA, LAZY, PASS, BOSS
  boolean[] abilities;
  String type;
  String desc;
  float rarity;

  int minSpeed = 2;
  int maxSpeed = 10;
  float speedMult = 0.008;

  PVector pos; // actual position. (assumes each dungeon map tile is 1 wide and 1 tall)
  int[] tile;    // dungeon tile position.
  int[] nextTile = null;
  ArrayList<int[]> tilesToTarget;
  boolean ontarget = false;

  int smacks2break;
  int smacks = 0;

  int ticks2attack;
  int ticks = 0;
  boolean attackMade;

  PVector lastDir = new PVector(0, 0);
  PVector currDir = lastDir;
  float rMovement = 0.02;
  float eMovement = 0.15;


  NonPlayerCharacter(String name, String type, String desc, Dice health, Dice damage, Dice speed, Dice sight, float rarity, boolean[] abils) {
    //super(name, health, damage, speed, sight);
    this.type = type;
    this.desc = desc;
    this.rarity = rarity;
    this.abilities = abils;
    this.name = name;
    this.health = health.roll();
    this.damage = damage;
    this.speed = speed.roll();
    this.sight = sight.roll();

    this.smacks2break = (int)this.speed*60;
    this.ticks2attack = floor(abs(this.speed-10))+60;

    this.tilesToTarget = new ArrayList<int[]>();
  }

  NonPlayerCharacter() {
    // used for loading character from file.
    // see fileSaveLoad
  }

  void display(PlayerCharacter pyc, int dmSize, float tileSize, float t) {
    PVector dir = pbcDir(pos, pyc.pos, dmSize);
    float dist = pbcDist(pos, pyc.pos, dmSize);

    float x = width/2+(dir.x*dist)*tileSize;
    float y = height/2+(dir.y*dist)*tileSize;

    int mod = (int)((maxSpeed-speed+1)*2);
    mod = gamePause ? 0 : mod;
    if (dir.x > 0) {
      displayPixelArtAnimation(name.toLowerCase()+" move right", x, y, mod, t, true);
    } else if (dir.x < 0) {
      displayPixelArtAnimation(name.toLowerCase()+" move left", x, y, mod, t, true);
    }
  }

  void update(DungeonLevel dlvl, PlayerCharacter pyc) {
    move(dlvl, pyc);
    fight(dlvl, pyc);
    updateAudio();
  }

  void updateAudio() {
    SoundPlayer toUpdate;

    // attacking
    toUpdate = soundeffects.get(type.toLowerCase()+" attack");
    if (attackMade) {
      toUpdate.play(true);
      attackMade = false;
    }
  }

  void move(DungeonLevel dlvl, PlayerCharacter pyc) {
    // updating tileToTarget
    if (pbcDist(pyc.pos, pos, dlvl.dmSize) < sight) {
      tilesToTarget = dlvl.pf.getNextTiles(tile[0], tile[1]);
    } else if (tilesToTarget.size() > 0) {
      if (tile[0] == tilesToTarget.get(0)[0] && tile[1] == tilesToTarget.get(0)[1]) {
        tilesToTarget.remove(0);
        if (tilesToTarget.size() > 0) {
          nextTile = tilesToTarget.get(0);
        } else {
          nextTile = null;
        }
      }
    }

    // getting nextDir
    PVector temp = nextDir(pyc, dlvl.pf, dlvl.dmSize);
    this.lastDir = this.currDir;
    this.currDir = temp;

    // take into account ERRA
    float mult = 4;
    if (abilities[3]) {
      if (ontarget && random(1) < eMovement*6) {
        currDir = lastDir.mult(mult).add(PVector.random2D()).normalize();
      }
      if (!ontarget && random(1) < eMovement) {
        currDir = lastDir.mult(mult).add(PVector.random2D()).normalize();
      }
    }

    speed = constrain(speed, minSpeed, maxSpeed);
    float multiplier = (speed*speedMult);

    // take into account TUNN, PASS and tile hardness here
    // all only applicable if currDir want's to move the character into a wall
    float xt = pos.x + currDir.x*multiplier;
    xt = xt < 0 ? dlvl.dm.dmSize+xt : (xt > dlvl.dm.dmSize ? xt-dlvl.dm.dmSize : xt);
    int ixt = pbc(floor(xt), dlvl.dmSize);
    float yt = pos.y + currDir.y*multiplier;
    yt = yt < 0 ? dlvl.dm.dmSize+yt : (yt > dlvl.dm.dmSize ? yt-dlvl.dm.dmSize : yt);
    int iyt = pbc(floor(yt), dlvl.dmSize);

    float d = max(abs(xt-(ixt+0.5)), abs(yt-(iyt+0.5)));
    boolean digtunn = false;
    if (nextTile != null) {
      digtunn = (ixt == nextTile[0] && iyt == nextTile[1]);
    } else {
      if (dlvl.dm.tiles[ixt][iyt].hardness > 0) {
        digtunn = true;
      }
    }

    // if the NPC is close enough to the tile it's going to dig (if it's the intended tile!), then dig.
    if (dlvl.dm.tiles[ixt][iyt].hardness > 0 && d < 0.5 && digtunn) {
      if (abilities[5]) {                  // PASS
        // Nothing to see here.
      } else if (abilities[2]) {           // TUNN
        if (smacks >= smacks2break) {
          dlvl.dm.tiles[ixt][iyt].hardness -= dlvl.dm.hInc;
          smacks = 0;
          if (!dlvl.dm.belowThresh(float(dlvl.dm.tiles[ixt][iyt].hardness))) {
            currDir.set(0, 0);
          } else {
            dlvl.dm.tiles[ixt][iyt].hardness = 0;
          }
        } else {
          currDir.set(0, 0);
          smacks += speed;
        }
      } else {                            // not PASS not TUNN
        currDir.mult(-1);
      }
    } else {
      smacks = 0;
    }

    PVector newPos = pos.copy().add(this.currDir.copy().mult(multiplier));

    // take into account proximity to other npcs and proximity to pyc.
    boolean tooclose = false;
    for (NonPlayerCharacter npc : dlvl.npcs) {
      if (npc != this) {
        if (pbcDist(newPos.x, newPos.y, npc.pos.x, npc.pos.y, dlvl.dm.dmSize) < 1) {
          tooclose = true;
        }
      }
    }
    if (pbcDist(newPos.x, newPos.y, pyc.pos.x, pyc.pos.y, dlvl.dm.dmSize) < 1) {
      tooclose = true;
    }
    if (!tooclose) {
      pos = newPos.copy();
    }

    pos.x = pos.x < 0 ? dlvl.dm.dmSize+pos.x : (pos.x > dlvl.dm.dmSize ? pos.x-dlvl.dm.dmSize : pos.x);
    pos.y = pos.y < 0 ? dlvl.dm.dmSize+pos.y : (pos.y > dlvl.dm.dmSize ? pos.y-dlvl.dm.dmSize : pos.y);
    updateTile(dlvl.dm);
  }

  void fight(DungeonLevel dlvl, PlayerCharacter pyc) {
    ticks++;
    if (ticks >= ticks2attack) {
      // determine if the pc is within attacking distance

      boolean toAttack = false;
      if (pbcDist(pos.x, pos.y, pyc.pos.x, pyc.pos.y, dlvl.dmSize) < pyc.sight) {
        // determine if the pc is within attacking angle

        float angle = abs(PVector.angleBetween(currDir, PVector.sub(pyc.pos, pos)));
        if (angle <= radians(15)) {
          // determine if the monster is within birds eye view

          boolean birdy = true;
          float x, y;
          for (int i = 0; i < sight*2; i++) {
            // need to get x and y lerp between pos and npc.pos, but it has to follow pbc
            x = lerp(pos.x, pyc.pos.x-floor(pyc.pos.x)+pbc(floor(pyc.pos.x), dlvl.dmSize), (float)i/(sight*2));
            y = lerp(pos.y, pyc.pos.y-floor(pyc.pos.y)+pbc(floor(pyc.pos.y), dlvl.dmSize), (float)i/(sight*2));
            if (dlvl.dm.tiles[pbc(floor(x), dlvl.dmSize)][pbc(floor(y), dlvl.dmSize)].hardness != 0) {
              birdy = false;
              break;
            }
          }
          if (birdy) {
            toAttack = true;
          }
        }
      }
      if (toAttack) {  
        attackMade = false;
        // check for proximity for close combat (tileSize*1.2?)
        if (pbcDist(pos.x, pos.y, pyc.pos.x, pyc.pos.y, dlvl.dmSize) < 1.2) {
          int attac = damage.roll()-(pyc.rollDefense()/2);
          pyc.health -= (attac > 0 ? attac : 0);
          attackMade = true;
        }

        if (attackMade) {
          ticks = 0;
        }
      }
    }
  }

  // Find the next unit vector direction that the NPC should move in.
  PVector nextDir(PlayerCharacter pyc, Pathfinder ptfd, int dmSize) {

    PVector tempDir = new PVector(0, 0);  
    float dist = pbcDist(pos, pyc.pos, dmSize);

    /*** Primary Movement ***/

    if (abilities[4]) {                                           // LAZY                done.
      // move randomly...
      tempDir = nextRandDir();
      ontarget = false;
    } else if (abilities[0] && abilities[1] && abilities[2]) {    // INTE TELE TUNN      done.
      // move toward PC with tunneling pathfinding
      tempDir = nextPathDir(ptfd);
      ontarget = true;
    } else if (abilities[0] && abilities[1] && !abilities[2]) {   // INTE TELE           done.
      // move toward PC with floor pathfinding
      tempDir = nextPathDir(ptfd);
      ontarget = true;
    } else if (abilities[0] && !abilities[1] && abilities[2]) {   // INTE TUNN           done.
      // move toward PC location w/ tunneling pathfinding if within SIGHT
      if (dist <= this.sight) {
        tempDir = nextPathDir(ptfd);
        ontarget = true;
      } else {
        if (tilesToTarget.size() > 0) {
          tempDir = ptfd.getDirFromNextTile(tilesToTarget.get(0), pos);
          ontarget = true;
        } else {
          tempDir = nextRandDir();
          ontarget = false;
        }
      }
    } else if (!abilities[0] && abilities[1] && abilities[2]) {   // TELE TUNN           done.
      // move in straight line toward PC
      tempDir = pbcDir(pyc.pos, pos, dmSize);
      ontarget = true;
    } else if (abilities[0]) {                                    // INTE                done.
      // move toward PC location w/ floor pathfinding if within SIGHT
      if (dist <= this.sight) {
        tempDir = nextPathDir(ptfd);
        ontarget = true;
      } else {
        if (tilesToTarget.size() > 0) {
          tempDir = ptfd.getDirFromNextTile(tilesToTarget.get(0), pos);
          ontarget = true;
        } else {
          tempDir = nextRandDir();
          ontarget = false;
        }
      }
    } else if (abilities[1]) {                                    // TELE                done.
      // move in straight line toward PC
      tempDir = pbcDir(pyc.pos, pos, dmSize);
      ontarget = true;
    } else if (abilities[2]) {                                    // TUNN                done.
      // can tunnel and move randomly
      // if withing SIGHT then move in straight line
      if (dist <= sight) {
        tempDir = pbcDir(pyc.pos, pos, dmSize);
        ontarget = true;
      } else {
        if (tilesToTarget.size() > 0) {
          tempDir = ptfd.getDirFromNextTile(tilesToTarget.get(0), pos);
          ontarget = true;
        } else {
          tempDir = nextRandDir();
          ontarget = false;
        }
      }
    } else if (abilities[3]) {                                    // ERRA                done.
      // if within sight, move toward PC in straight line.
      if (dist <= sight) {
        tempDir = pbcDir(pyc.pos, pos, dmSize);
        ontarget = true;
      } else {
        if (tilesToTarget.size() > 0) {
          tempDir = ptfd.getDirFromNextTile(tilesToTarget.get(0), pos);
          ontarget = true;
        } else {
          tempDir = nextRandDir();
          ontarget = false;
        }
      }
    } else {
      tempDir = new PVector(0, 0); //nextRandDir();
      ontarget = false;
    }

    // if DHIDE then randdir
    // if RHIDE then rand chance of randdir
    if (pyc.hasAttr("DHIDE")) {
      if (random(1) < rMovement) {
        tempDir = nextRandDir();
      }
    } else if (pyc.hasAttr("RHIDE")) {
      if (random(1) < rMovement*50) {
        tempDir = nextRandDir();
      }
    }

    return tempDir;
  }

  PVector nextRandDir() {
    nextTile = null; // this is necessary so NPC movement isn't broken after losing sight of the PC
    PVector tD;
    if (random(1) < rMovement) {
      tD = PVector.random2D();
    } else {
      tD = currDir;
    }
    return tD;
  }

  PVector nextPathDir(Pathfinder ptfd) {
    PVector tempDir;
    int[] nt = ptfd.getNextTile(tile[0], tile[1]); 

    if (nt != null) {
      nextTile = nt;
      tempDir = ptfd.getDirFromNextTile(nextTile, pos);
    } else if (nextTile != null) {
      tempDir = currDir;
    } else {
      tempDir = nextRandDir();
    }
    return tempDir;
  }

  void setRandomFloorLocation(DungeonMap dungmap, ArrayList<Tile> badtiles) {
    while (true) {
      this.tile = dungmap.getRandomFloorLocation();

      boolean bad = false;
      for (Tile t : badtiles) {
        if (t.x == tile[0] && t.y == tile[1])
          bad = true;
      }

      if (!bad) {
        float tx = float(this.tile[0]);
        float ty = float(this.tile[1]);
        this.pos = new PVector(tx+0.5, ty+0.5);
        break;
      }
    }
  }

  void updateTile(DungeonMap dmap) {
    // if the NPC is in the correct tile and a certain distance from the tile center
    // this ensures that corners aren't taken too tightly. Again, a magic number...
    if (nextTile == null) {
      tile[0] = floor(pos.x);
      tile[1] = floor(pos.y);
      return;
    }
    PVector temp = new PVector(nextTile[0]+0.5, nextTile[1]+0.5);
    if (floor(pos.x) == nextTile[0] && floor(pos.y) == nextTile[1] && pbcDist(pos.x, pos.y, temp.x, temp.y, dmap.dmSize) < 0.1) {
      tile[0] = nextTile[0];
      tile[1] = nextTile[1];
    }
  }

  NonPlayerCharacter copy() {
    NonPlayerCharacter toReturn = new NonPlayerCharacter("", "", "", null, null, null, null, 0, null);

    toReturn.name = this.name;
    toReturn.type = this.type;
    toReturn.desc = this.desc;
    toReturn.health = this.health;
    toReturn.damage = this.damage;
    toReturn.speed = this.speed;
    toReturn.sight = this.sight;
    toReturn.rarity = this.rarity;
    toReturn.abilities = this.abilities;

    return toReturn;
  }
}


class NPCgenerator {
  String name;
  Dice health;
  Dice damage;
  Dice speed;
  Dice sight;
  String type;
  String desc;
  float rarity;
  boolean[] abilities;

  NPCgenerator(String name, String type, String desc, String health, String damage, String speed, String sight, String rarity, boolean[] abils) {
    this.name = name;
    this.health = new Dice(health);
    this.damage = new Dice(damage);
    this.speed = new Dice(speed);
    this.sight = new Dice(sight);
    this.type = type;
    this.desc = desc;
    this.rarity = float(rarity)/100;
    this.abilities = abils;
  }

  NonPlayerCharacter generate() {
    return new NonPlayerCharacter(name, type, desc, health, damage, speed, sight, rarity, abilities);
  }
}
