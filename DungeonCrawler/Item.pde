

class Item {

  String name;
  String type;
  String desc;

  int healthBonus;
  Dice damageBonus;
  Dice defenseBonus;
  int speedBonus;
  int sightBonus;

  int weight;

  int value;
  float rarity;

  HashMap<String, Boolean> attributes;
  boolean hasAttributes = false;
  int attrLifetime = 0;
  int attrLifespan = 20*60; // s * fps roughly
  int rangedShots = 0;
  int maxShots = 5;

  PVector pos;
  boolean covered = false;
  boolean holding = false;
  boolean dropped = false;

  Item(String name, String type, String desc, Dice healthBonus, Dice damageBonus, Dice defenseBonus, Dice speedBonus, Dice sightBonus, int weight, ArrayList<Dice> value, float rarity, HashMap<String, Boolean> attributes) {
    this.name = name;
    this.type = type;
    this.desc = desc;
    this.healthBonus = healthBonus.roll();
    this.damageBonus = damageBonus;
    this.defenseBonus = defenseBonus;
    this.speedBonus = speedBonus.roll();
    this.sightBonus = sightBonus.roll();
    this.weight = weight;
    for (Dice d : value) {
      this.value += d.roll()*d.mValue;
    }
    this.rarity = rarity;
    this.attributes = attributes;
  }

  Item() {
    // used for loading character from file.
    // see fileSaveLoad
  }

  void update(PlayerCharacter pyc) {
    if (dropped && PVector.dist(pos, pyc.pos) > 3) {
      dropped = false;
    }
  }

  void setRandom() {
    healthBonus = (int)random(-5, 5);
    damageBonus.base = (int)random(-7, 5);
    damageBonus.sides = (int)random(1, 5);
    damageBonus.rolls = (int)random(1, 2);
    defenseBonus.base = (int)random(-7, 5);
    defenseBonus.sides = (int)random(1, 5);
    defenseBonus.rolls = (int)random(1, 2);
    speedBonus = (int)random(-3, 3);
    sightBonus = (int)random(-5, 5);
  }

  void display(float x, float y, float size) {
    fill(#5CF0FC);
    strokeWeight(1);
    stroke(#5CF0FC);
    ellipse(x, y, size, size);
  }

  void display(PlayerCharacter pyc, int dmSize, float tileSize, float t) {
    if (!covered && !holding) {
      PVector dir = pbcDir(pos, pyc.pos, dmSize);
      float dist = pbcDist(pos, pyc.pos, dmSize);
      displayPixelArtStatic(name.toLowerCase(), 0, width/2+(dir.x*dist)*tileSize, height/2+(dir.y*dist)*tileSize, t, true);
    }
  }

  void displayCharacterScreen(float x, float y) {
    rectMode(CENTER);
    displayPixelArtStatic(name.toLowerCase(), 0, x, y, 255, true);
  }

  void setDungeonLocation(DungeonMap dungmap) {
    pos = new PVector();
    pos.x = random(dungmap.dmSize);
    pos.y = random(dungmap.dmSize);
  }

  String valueToText() {
    int c, s, g;
    c = value;
    s = c/20;
    c = c-s*20;
    g = s/20;
    s = s-g*20;
    return ""+g+"g, "+s+"s, "+c+"c";
  }

  boolean isDuplicate(Item other) {
    if (!this.name.equals(other.name)) 
      return false;
    if (!this.type.equals(other.type)) 
      return false;
    if (!this.desc.equals(other.desc)) 
      return false;

    if (this.healthBonus != other.healthBonus)
      return false;
    if (!this.damageBonus.toString().equals(other.damageBonus.toString())) 
      return false;
    if (!this.defenseBonus.toString().equals(other.defenseBonus.toString())) 
      return false;
    if (this.speedBonus != other.speedBonus)
      return false;
    if (this.sightBonus != other.sightBonus)
      return false;

    if (this.weight != other.weight)
      return false;
    if (this.value != other.value)
      return false;
    if (this.rarity != other.rarity)
      return false;

    if (this.hasAttributes != other.hasAttributes)
      return false;
    if (!this.attributes.equals(other.attributes)) 
      return false;

    if (this.attrLifetime != other.attrLifetime)
      return false;

    if (this.rangedShots != other.rangedShots)
      return false;

    if (!this.pos.equals(other.pos))
      return false;

    if (this.covered != other.covered)
      return false;
    if (this.holding != other.holding)
      return false;
    if (this.dropped != other.dropped)
      return false;

    return true;
  }
}


class ItemGenerator {

  String name;
  String desc;
  String type;

  Dice healthBonus;
  Dice damageBonus;
  Dice defenseBonus;
  Dice speedBonus;
  Dice sightBonus;

  int weight;
  ArrayList<Dice> value;
  float rarity;

  HashMap<String, Boolean> attributes;
  boolean hasAttr = false;

  ItemGenerator(String name, String type, String desc, String health, String damage, String defense, String speed, String sight, String weight, String value, String rarity, HashMap<String, Boolean> attributes) {
    this.name = name; 
    this.type = type;
    this.desc = desc;
    this.healthBonus = new Dice(health);
    this.damageBonus = new Dice(damage);
    this.defenseBonus = new Dice(defense);
    this.speedBonus = new Dice(speed);
    this.sightBonus = new Dice(sight);
    this.weight = int(weight);

    this.value = new ArrayList<Dice>();
    String[] values = value.split(" ");
    for (String s : values) {
      this.value.add(new Dice(s));
    }

    this.rarity = float(rarity)/100;
    this.attributes = attributes;
    for (boolean val : this.attributes.values()) {
      if (val) {
        hasAttr = true;
        break;
      }
    }
  }

  Item generate() {
    Item toReturn = new Item(name, type, desc, healthBonus, damageBonus, defenseBonus, speedBonus, sightBonus, weight, value, rarity, attributes);
    toReturn.hasAttributes = hasAttr;
    return toReturn;
  }
}
