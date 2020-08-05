//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//

class Equipment {
  HashMap<String, Item> equipment;
  Item[] rings;
  int maxRings = 6; // leave at 6 due to character information screen design
  int numRings = 0;

  // RING too
  String[] types = new String[]{"CLOAK", "HELMET", "AMULET", "WEAPON", "ARMOR", "OFFHAND", "LIGHT", "BOOTS", "GLOVES"};

  // Attribute management
  ArrayList<Item> temporaryAttrItems;
  ArrayList<Item> permanentAttrItems;

  Equipment() {
    equipment = new HashMap<String, Item>();
    for (String type : types) {
      equipment.put(type, null);
    }
    rings = new Item[maxRings];
    for (int i = 0; i < rings.length; i++) {
      rings[i] = null;
    }

    temporaryAttrItems = new ArrayList<Item>();
    permanentAttrItems = new ArrayList<Item>();
  }

  String updateTempAttr() {
    String toRemove = "";
    // increase item duration
    // if over do something
    for (int i  = 0; i < temporaryAttrItems.size(); i++) {
      Item temp = temporaryAttrItems.get(i);
      temp.attrLifetime++;
      if (temp.attrLifetime > temp.attrLifespan) {
        toRemove += i+",";
      }
    }
    return toRemove;
  }

  int tunnBonus() {
    int weight = 0;
    for (Item i : temporaryAttrItems) {
      if (i.attributes.get("TUNN") != null)
        weight += i.weight;
    }
    for (Item i : permanentAttrItems) {
      if (i.attributes.get("TUNN") != null)
        weight += i.weight;
    }
    return weight;
  }

  boolean hasAttr(String attr) {
    for (Item i : temporaryAttrItems) {
      if (i.attributes.get(attr) != null)
        return true;
    }
    for (Item i : permanentAttrItems) {
      if (i.attributes.get(attr) != null)
        return true;
    }
    return false;
  }

  void manageAttrLists(Item i, boolean add) {
    if (add) {
      if (i.hasAttributes) {
        if (i.attributes.get("RANDEFF") != null) {
          i.setRandom();
          i.attributes.remove("RANDEFF");
        }
        if (i.attributes.get("TEMP") != null) {
          temporaryAttrItems.add(i);
        } else {
          permanentAttrItems.add(i);
        }
      }
    } else {
      if (i.hasAttributes) {
        if (i.attributes.get("TEMP") != null) {
          temporaryAttrItems.remove(i);
        } else {
          permanentAttrItems.remove(i);
        }
      }
    }
  }

  void removeHist() {
    for (int i = permanentAttrItems.size()-1; i >= 0; i--) {
      if (permanentAttrItems.get(i).attributes.get("HIST")) {
        permanentAttrItems.remove(i);
        break;
      }
    }
  }

  Item getMainWeapon() {
    Item toReturn = null;
    toReturn = get("WEAPON");
    if (toReturn == null) {
      toReturn = get("OFFHAND");
    }
    if (toReturn != null && !toReturn.type.equals("WEAPON")) {
      toReturn = null;
    }
    return toReturn;
  }

  Item get(String code) {
    return equipment.get(code);
  }

  Item getRing(int pos) {
    return rings[pos];
  }

  boolean isEquipable(Item i) {
    return ((equipment.containsKey(i.type) || i.type.equals("RING")));
  }

  boolean isEquipped(Item i) {
    if (i.type.equals("RING")) {
      return isRingEquipped(i);
    } else {
      if (equipment.get(i.type) == null) {
        return false;
      } else {
        if (equipment.get(i.type).equals(i)) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  boolean wear(Item i) {
    if (i.type.equals("RING")) {
      return wearRing(i);
    } else {
      if (i.type.equals("WEAPON") && i.attributes.get("TWOHAND") != null) {
        // check for both weapon and offhand null
        if (equipment.get("WEAPON") == null && equipment.get("OFFHAND") == null) {
          equipment.put(i.type, i);
          return true;
        } else {
          // cant place the item
          return false;
        }
      } else if (i.type.equals("WEAPON") && i.attributes.get("TWOHAND") == null) {
        if (equipment.get("WEAPON") == null) {
          equipment.put(i.type, i);
          return true;
        } else {
          if (equipment.get("WEAPON").attributes.get("TWOHAND") == null) {
            if (equipment.get("OFFHAND") == null) {
              equipment.put("OFFHAND", i);
              return true;
            } else {
              //  can't be placed
              return false;
            }
          } else {
            //  can't be placed
            return false;
          }
        }
      } else if (i.type.equals("OFFHAND")) {
        if (equipment.get("OFFHAND") == null) {
          if (equipment.get("WEAPON") != null) {
            if (equipment.get("WEAPON").attributes.get("TWOHAND") == null) {
              equipment.put(i.type, i);
              return true;
            } else {
              //  can't be placed
              return false;
            }
          } else {
            equipment.put(i.type, i);
            return true;
          }
        } else {
          if (equipment.get("WEAPON") == null) {
            equipment.put("WEAPON", i);
            return true;
          } else {
            //  can't be placed
            return false;
          }
        }
      } else {
        if (equipment.get(i.type) == null) {
          equipment.put(i.type, i);
          return true;
        } else {
          // can't place the item
          return false;
        }
      }
    }
  }

  Item removeEquipment(String type) {
    if (equipment.get(type) != null) {
      return removeItem(equipment.get(type));
    } else {
      // can't remove the item because no item exists
      return null;
    }
  }

  Item removeEquipment(boolean weapoff) {
    Item toReturn = null;
    if (weapoff) {
      toReturn = equipment.get("WEAPON");
      equipment.put("WEAPON", null);
    } else {
      toReturn = equipment.get("OFFHAND");
      equipment.put("OFFHAND", null);
    }
    return toReturn;
  }

  Item removeItem(Item i) {
    // try to take off if exists
    Item toReturn = null;
    if (i.type.equals("RING")) {
      return removeRing(i);
    } else {
      String type = i.type;
      if (equipment.get(type) != null) {
        toReturn = equipment.get(type);
        equipment.put(type, null);
        return toReturn;
      } else {
        // can't remove the item because no item exists
        return null;
      }
    }
  }

  boolean wearRing(Item r) {
    if (numRings == maxRings) {
      return false;
    } else {
      rings[numRings] = r;
      numRings++;
      return true;
    }
  }

  Item removeRing(Item r) {
    Item toReturn = null;
    int rIndex = -1;
    for (int i = 0; i < numRings; i++) {
      if (rings[i].equals(r)) {
        rIndex = i;
        break;
      }
    }
    if (rIndex != -1) {
      toReturn = rings[rIndex];
      rings[rIndex] = null;
      // condense array
      for (int i = 0; i < numRings; i++) {
        if (rings[i] == null && i < numRings-1) {
          rings[i] = rings[i+1];
          rings[i+1] = null;
        }
      }
      numRings--;
      return toReturn;
    } else {
      // can't remove the item because no item exists
      return null;
    }
  }

  Item removeRing(int r) {
    Item toReturn = null;
    if (r >= 0 && r < maxRings) {
      toReturn = rings[r];
      rings[r] = null;
      // condense array
      for (int i = 0; i < numRings; i++) {
        if (rings[i] == null && i < numRings-1) {
          rings[i] = rings[i+1];
          rings[i+1] = null;
        }
      }
      numRings--;
      return toReturn;
    } else {
      // can't remove the item because no item exists
      return null;
    }
  }

  boolean isRingEquipped(Item i) {
    for (Item it : rings) {
      if (i.equals(it)) {
        return true;
      }
    }
    return false;
  }

  Item putFavorite(Item i, boolean weapoff, Inventory inv, int pos) {
    if (inv.favorites[pos] == null) {
      inv.favorites[pos] = i;
      if (weapoff) {
        removeEquipment(false);
      } else {
        removeItem(i);
      }
      return null;
    } else {
      //  can't put equipment item into occupied favorite spot.
      return i;
    }
  }

  int equipmentValue() {
    int value = 0;
    /*
    HashMap<String, Item> equipment;
     Item[] rings;
     // for (HashMap.Entry<String, Integer> type : itemDistribution.entrySet()) {
     */
    for (HashMap.Entry<String, Item> item : equipment.entrySet()) {
      if (item.getValue() != null)
        value += item.getValue().value;
    }
    for (Item ring : rings) {
      if (ring != null)
        value += ring.value;
    }
    return value;
  }


  ArrayList<Item> listAllItems() {
    ArrayList<Item> all = new ArrayList<Item>(equipment.values());
    all.addAll(temporaryAttrItems);
    all.addAll(permanentAttrItems);
    all.addAll(Arrays.asList(rings));
    return all;
  }

  // For Debugging
  String toString() {
    String toReturn = "";
    toReturn += "\n";
    for (String t : types) {
      toReturn += (t+":\t"+(equipment.get(t) == null ? "null" : equipment.get(t).name)) + "\n";
    }
    String s = "RING:\t";
    for (Item i : rings) {
      s += (i == null ? "null " : i.name+" ");
    }
    toReturn += s  + "\n";
    toReturn += "\n";
    return toReturn;
  }

  String attributesToString() {
    String toReturn = "\n[";
    for (Item i : temporaryAttrItems) {
      toReturn += i.attributes.keySet();
    }
    toReturn += "]\n[";
    for (Item i : permanentAttrItems) {
      toReturn += i.attributes.keySet();
    }
    toReturn += "]\n";
    return toReturn;
  }
}


/****************************************************************************************************/
/****************************************************************************************************/
/****************************************************************************************************/
/****************************************************************************************************/

class Inventory {

  Item[] favorites;
  int numFavs = 10;
  ArrayList<Item> inventory;
  int maxInv = 25; // max at 25, due to character screen design

  Inventory() {
    favorites = new Item[numFavs];
    inventory = new ArrayList<Item>();
  }

  Item get(int pos, boolean inv) {
    try {
      if (inv) {
        return inventory.get(pos);
      } else {
        return favorites[pos];
      }
    } 
    catch (Exception e) {
      return null;
    }
  }

  void putFavorite(Item i, int pos) {
    if (favorites[pos] == null) {
      favorites[pos] = i;
      inventory.remove(i);
    } else {
      Item temp = removeFavorite(pos);
      favorites[pos] = i;
      inventory.set(inventory.indexOf(i), temp);
    }
  }

  Item removeFavorite(int pos) {
    if (favorites[pos] == null) {
      return null;
    } else {
      Item toReturn = favorites[pos];
      favorites[pos] = null;
      return toReturn;
    }
  }

  boolean put(Item i) {
    if (inventory.size() < maxInv) {
      inventory.add(i);
      return true;
    } else {
      return false;
    }
  }

  boolean put(Item i, int pos) {
    if (inventory.size() < maxInv) {
      inventory.add(pos, i);
      return true;
    } else {
      return false;
    }
  }

  Item remove(Item i) {
    inventory.remove(i);
    return i;
  }

  Item remove(int i) {
    return inventory.remove(i);
  }

  int size() {
    return inventory.size();
  }

  int inventoryValue() {
    int value = 0;
    for (Item fav : favorites) {
      if (fav != null)
        value += fav.value;
    }
    for (Item item : inventory) {
      if (item != null)
        value += item.value;
    }
    return value;
  }

  ArrayList<Item> listAllItems() {
    ArrayList<Item> all = new ArrayList<Item>(Arrays.asList(favorites));
    all.addAll(inventory);
    return all;
  }

  // For Debugging
  String toString() {
    String toReturn = ""; 
    toReturn += "\n"; 
    toReturn += "   FAVORITES" + "\n"; 
    String favs = ""; 
    for (Item f : favorites) {
      favs += ((f == null ? "empty"+"\t" : f.name+"\t"));
    }
    toReturn += favs + "\n"; 

    toReturn += "   THE REST" + "\n"; 
    String inve = ""; 
    if (inventory.size() > 0) {
      int cnt = 0; 
      for (Item f : inventory) {
        inve += (cnt+". "+(f == null ? "empty"+"\t" : f.name+"\t")); 
        cnt++;
      }
    } else {
      inve = "empty";
    }
    toReturn += inve + "\n"; 
    toReturn += "\n"; 
    return toReturn;
  }
}
