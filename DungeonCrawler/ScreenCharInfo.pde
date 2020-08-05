//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
/****************************************************************************************************/
/****************************** Character Information Screen ****************************************/
/****************************************************************************************************/
class ScreenCharacterInfo implements Screen {
  int edge = 25;
  PImage bodySilh;
  float itemSize = height/9;
  float itemGap = itemSize/10;
  float itemRad = 10;

  int numFav, numInv, numEquip, numRings;
  float[][] positions;
  int selected = 10;
  int oldselected = 10;

  float bodyCenterX;
  float bodyCenterY;

  boolean inspect = false;
  // 0 - store
  // 1 - equip
  // 2 - drop
  // 3 - expunge
  int audioOutput = -1; 

  int selectedHistory = -1;
  boolean histSelectChanged = false;

  ScreenCharacterInfo(PlayerCharacter pyc) {

    bodySilh = loadImage("body-silhouette.png");
    bodySilh.resize(0, height*2/3-5-edge);

    bodyCenterX = width/2+(width/2-edge*2)*2/5+edge/2;
    bodyCenterY = height-bodySilh.height/2-edge-5;

    numFav = pyc.inventory.numFavs;
    numInv = pyc.inventory.maxInv;
    numEquip = 9;
    numRings = pyc.equipment.maxRings;
    positions = new float[numFav+numInv+numEquip+numRings][2];
    int off = 0;
    // favorites
    for (int i = off; i < pyc.inventory.favorites.length; i++) {
      positions[i][0] = edge+itemSize/2+10+(i%5)*(itemSize+itemGap);
      positions[i][1] = edge+itemSize/2+15+(i/5)*(itemSize+itemGap);
      off++;
    }
    // inventory
    for (int i = 0; i < pyc.inventory.maxInv; i++) {
      positions[off][0] = edge+itemSize/2+10+(i%5)*(itemSize+itemGap);
      positions[off][1] = height/3+itemSize/2+10+(i/5)*(itemSize+itemGap);
      off++;
    }
    // equipment
    for (String s : pyc.equipment.types) {
      switch (s) {
      case "WEAPON":
        positions[off][0] = bodyCenterX-itemSize-20;
        positions[off][1] = bodyCenterY;
        break;
      case "OFFHAND":
        positions[off][0] = bodyCenterX+itemSize+20;
        positions[off][1] = bodyCenterY;
        break;
      case "ARMOR":
        positions[off][0] = bodyCenterX;
        positions[off][1] = bodyCenterY-50;
        break;
      case "HELMET":
        positions[off][0] = bodyCenterX;
        positions[off][1] = bodyCenterY-bodySilh.height/2+20;
        break;
      case "CLOAK":
        positions[off][0] = bodyCenterX-itemSize-15;
        positions[off][1] = bodyCenterY-bodySilh.height/2+itemSize+10;
        break;
      case "GLOVES":
        positions[off][0] = bodyCenterX+itemSize+20;
        positions[off][1] = bodyCenterY+bodySilh.height/2-itemSize;
        break;
      case "BOOTS":
        positions[off][0] = bodyCenterX;
        positions[off][1] = bodyCenterY+bodySilh.height/2-40;
        break;
      case "AMULET":
        positions[off][0] = bodyCenterX+itemSize+15;
        positions[off][1] = bodyCenterY-bodySilh.height/2+itemSize+10;
        break;
      case "LIGHT":
        positions[off][0] = bodyCenterX-itemSize-20;
        positions[off][1] = bodyCenterY+bodySilh.height/2-itemSize;
        break;
      }
      off++;
    }
    // rings
    for (int i = 0; i < pyc.equipment.rings.length; i++) {
      positions[off][0] = width-edge-itemSize*3/4;
      positions[off][1] = bodyCenterY-bodySilh.height*2/5 + i*(itemSize*7/8);
      off++;
    }
  }

  void update(PlayerCharacter pyc, DungeonLevel dlvl) {
    updateSelected();
    updateFavorites(pyc);
    updateEquipment(pyc, dlvl);
    checkDrop(pyc, dlvl);
    checkExpunge(pyc, dlvl);

    if (keys['i'][1]) {
      inspect = !inspect;
    }

    updateAudio();
  }

  void updateSelected() {
    int off = 0;
    oldselected = selected;
    if (selected < numFav) {
      if (keys[ARROWUP][1]) {
        selected = selected >= 5 ? selected-5 : selected;
      } else if (keys[ARROWDOWN][1]) {
        selected += 5;
      } else if (keys[ARROWLEFT][1]) {
        selected = selected%5 != 0 ? selected-1 : selected;
      } else if (keys[ARROWRIGHT][1]) {
        selected = selected%5 != 4 ? selected+1 : off+numFav+numInv;
      }
    } else if (selected < numFav+numInv) {
      off = numFav;
      if (keys[ARROWUP][1]) {
        selected -= 5;
      } else if (keys[ARROWDOWN][1]) {
        selected = selected < off+numInv-5 ? selected+5 : selected;
      } else if (keys[ARROWLEFT][1]) {
        selected = selected%5 != 0 ? selected-1 : selected;
      } else if (keys[ARROWRIGHT][1]) {
        selected = selected%5 != 4 ? selected+1 : off+numInv;
      }
    } else if (selected < numFav+numInv+numEquip) {
      off = numFav+numInv;
      if (keys[ARROWUP][1]) {
        selected = selected >= off+3 ? selected-3 : selected;
      } else if (keys[ARROWDOWN][1]) {
        selected = selected < off+numEquip-3 ? selected+3 : selected;
      } else if (keys[ARROWLEFT][1]) {
        selected = (selected-off%3)%3 != 0 ? selected-1 : numFav+4;
      } else if (keys[ARROWRIGHT][1]) {
        selected = (selected-off%3)%3 != 2 ? selected+1 : off+numEquip;
      }
    } else if (selected < positions.length) {
      off = numFav+numInv+numEquip;
      if (keys[ARROWUP][1]) {
        selected = selected > off ? selected-1 : selected;
      } else if (keys[ARROWDOWN][1]) {
        selected = selected < off+numRings-1 ? selected+1 : selected;
      } else if (keys[ARROWLEFT][1]) {
        selected = off-7;
      } else if (keys[ARROWRIGHT][1]) {
      }
    }
  }

  void updateFavorites(PlayerCharacter pyc) {
    if (selected < numFav) {
      // check for (s)
      if (keys['s'][1]) {
        Item temp = pyc.inventory.removeFavorite(selected);
        if (temp != null) {
          pyc.inventory.put(temp);
          audioOutput = 0;
        }
      }
      // check for (0-9)
      for (int i = 0; i <= 9; i++) {
        if (keys[(int)Character.forDigit(i, 10)][1]) {
          int pos = i == 0 ? 9 : i-1;
          if (pyc.inventory.favorites[pos] == null) {
            pyc.inventory.favorites[pos] = pyc.inventory.favorites[selected];
            pyc.inventory.favorites[selected] = null;
          } else {
            Item temp = pyc.inventory.favorites[pos];
            pyc.inventory.favorites[pos] = pyc.inventory.favorites[selected];
            pyc.inventory.favorites[selected] = temp;
          }
          audioOutput = 0;
          break;
        }
      }
    } else if (selected < numFav+numInv) {
      // check for 0-9 
      for (int i = 0; i <= 9; i++) {
        if (keys[(int)Character.forDigit(i, 10)][1]) {
          int pos = i == 0 ? 9 : i-1;
          if (selectedItem(pyc) != null) {
            pyc.inventory.putFavorite(selectedItem(pyc), pos);
            audioOutput = 0;
          }
          break;
        }
      }
    } else {
      // check for 0-9 
      int off = numFav+numInv;
      for (int i = 0; i <= 9; i++) {
        if (keys[(int)Character.forDigit(i, 10)][1]) {
          int pos = i == 0 ? 9 : i-1;
          Item temp = selectedItem(pyc);
          if (temp != null) {
            if (selected-off == 5) {
              Item returnI = pyc.equipment.putFavorite(temp, true, pyc.inventory, pos);
              if (returnI == null) {
                pyc.manageItemBonuses(temp, false, true);
                audioOutput = 0;
              }
            } else {
              Item returnI = pyc.equipment.putFavorite(temp, false, pyc.inventory, pos);
              if (returnI == null) {
                pyc.manageItemBonuses(temp, false, true);
                audioOutput = 0;
              }
            }
          }
          break;
        }
      }
    }
  }

  void updateEquipment(PlayerCharacter pyc, DungeonLevel dlvl) {
    int off = 0;
    if (selected < numFav) {
      // (w)
      if (keys['w'][1]) {
        Item toEquip = pyc.inventory.removeFavorite(selected-off);
        if (toEquip != null) {
          Item temp = pyc.useItem(toEquip, dlvl);
          if (temp != null) {
            pyc.inventory.putFavorite(temp, selected-off);
          } else {
            audioOutput = 1;
          }
        }
      }
    } else if (selected < numFav+numInv) {
      // (w)
      off = numFav;
      if (keys['w'][1] && selected-off < pyc.inventory.size()) {
        Item toEquip = pyc.inventory.remove(selected-off);
        if (toEquip != null) {
          Item temp = pyc.useItem(toEquip, dlvl);
          if (temp != null) {
            pyc.inventory.put(temp, selected-off);
          } else {
            audioOutput = 1;
          }
        }
      }
    } else if (selected < numFav+numInv+numEquip) {
      off = numFav+numInv;
      // (s)
      if (keys['s'][1]) {
        if (pyc.inventory.size() != numInv) {
          Item removed;
          if (selected-off == 3) {
            removed = pyc.equipment.removeEquipment(true);
          } else if (selected-off == 5) {
            removed = pyc.equipment.removeEquipment(false);
          } else {
            removed = pyc.equipment.removeEquipment(pyc.equipment.types[selected-off]);
          }
          if (removed != null) {
            pyc.manageItemBonuses(removed, false, true);
            pyc.inventory.put(removed);
            audioOutput = 0;
          }
        }
      }
    } else if (selected < numFav+numInv+numEquip+numRings) {
      off = numFav+numInv+numEquip;
      // (s)
      if (keys['s'][1]) {
        if (pyc.inventory.size() != numInv) {
          Item removed = pyc.equipment.removeRing(selected-off);
          if (removed != null) {
            pyc.manageItemBonuses(removed, false, true);
            pyc.inventory.put(removed);
            audioOutput = 0;
          }
        }
      }
    }
  }

  void checkDrop(PlayerCharacter pyc, DungeonLevel dlvl) {
    if (keys['d'][1]) {
      int off = 0;
      Item toDrop = null;
      if (selected < numFav) {
        toDrop = pyc.inventory.removeFavorite(selected-off);
      } else if (selected < numFav+numInv) {
        off = numFav;
        if (selected-off < pyc.inventory.size())
          toDrop = pyc.inventory.remove(selected-off);
      } else if (selected < numFav+numInv+numEquip) {
        off = numFav+numInv;
        toDrop = pyc.equipment.removeEquipment(pyc.equipment.types[selected-off]);
        if (toDrop != null) {
          pyc.manageItemBonuses(toDrop, false, true);
          //pyc.inventory.put(toDrop);
        }
      } else if (selected < numFav+numInv+numEquip+numRings) {
        off = numFav+numInv+numEquip;
        toDrop = pyc.equipment.removeRing(selected-off);
        if (toDrop != null) {
          pyc.manageItemBonuses(toDrop, false, true);
          //pyc.inventory.put(toDrop);
        }
      }
      // drop
      if (toDrop != null) {
        toDrop.pos = pyc.pos.copy();
        toDrop.covered = false;
        toDrop.holding = false;
        toDrop.dropped = true;
        audioOutput = 2;
        dlvl.items.add(toDrop);
      }
    }
  }

  void checkExpunge(PlayerCharacter pyc, DungeonLevel dlvl) {
    boolean wasEquipped = false;
    if (keys['e'][1]) {
      int off = 0;
      Item toExpunge = null;
      if (selected < numFav) {
        toExpunge = pyc.inventory.removeFavorite(selected-off);
      } else if (selected < numFav+numInv) {
        off = numFav;
        if (selected-off < pyc.inventory.size())
          toExpunge = pyc.inventory.remove(selected-off);
      } else if (selected < numFav+numInv+numEquip) {
        off = numFav+numInv;
        if (selected-off == 5) {
          toExpunge = pyc.equipment.removeEquipment(false);
        } else {
          toExpunge = pyc.equipment.removeEquipment(pyc.equipment.types[selected-off]);
        }
        wasEquipped = true;
      } else if (selected < numFav+numInv+numEquip+numRings) {
        off = numFav+numInv+numEquip;
        toExpunge = pyc.equipment.removeRing(selected-off);
        wasEquipped = true;
      }

      if (toExpunge != null) {
        if (wasEquipped) {
          pyc.manageItemBonuses(toExpunge, false, true);
        }
        dlvl.items.remove(toExpunge);
        audioOutput = 3;
      }
    }
  }

  Item selectedItem(PlayerCharacter pyc) {
    int off = 0;
    if (selected < numFav) {
      return pyc.inventory.get(selected, false);
    } else if (selected < numFav+numInv) {
      off = numFav;
      return pyc.inventory.get(selected-off, true);
    } else if (selected < numFav+numInv+numEquip) {
      off = numFav+numInv;
      switch (selected-off) {
      case 0:
        return pyc.equipment.get("CLOAK");
      case 1:
        return pyc.equipment.get("HELMET");
      case 2:
        return pyc.equipment.get("AMULET");
      case 3:
        return pyc.equipment.get("WEAPON");
      case 4:
        return pyc.equipment.get("ARMOR");
      case 5:
        return pyc.equipment.get("OFFHAND");
      case 6:
        return pyc.equipment.get("LIGHT");
      case 7:
        return pyc.equipment.get("BOOTS");
      case 8:
        return pyc.equipment.get("GLOVES");
      }
      return null;
    } else if (selected < positions.length) {
      off = numFav+numInv+numEquip;
      return pyc.equipment.getRing(selected-off);
    } else {
      return null;
    }
  }

  void updateAudio() {

    if (oldselected != selected) {
      soundeffects.get("item select").play(false);
    }

    switch (audioOutput) {
    case 0:
      soundeffects.get("item store").play(false);
      break;
    case 1:
      soundeffects.get("item equip").play(false);
      break;
    case 2:
      soundeffects.get("item drop").play(false);
      break;
    case 3:
      soundeffects.get("item expunge").play(false);
      break;
    }
    audioOutput = -1;
  }

  void display(PlayerCharacter pyc, DungeonLevel dlvl) {
    rectMode(CENTER);
    textFont(generalFonts.get(18));

    // screen background 
    fill(100);
    stroke(150);
    strokeWeight(5);
    rect(width/2, height/2, width-edge*2, height-edge*2, 25);

    // line placement
    stroke(0);
    strokeCap(PROJECT);
    line(width/2, edge+g.strokeWeight, width/2, height-edge-g.strokeWeight);
    line(edge+g.strokeWeight, height/3-5, width/2, height/3-5);

    // silhouette placement
    imageMode(CENTER);
    tint(255, 25);
    image(bodySilh, bodyCenterX, bodyCenterY);

    strokeWeight(2);
    noFill();
    // favorites
    int off = 0;
    for (int i = 0; i < pyc.inventory.favorites.length; i++) {
      rect(positions[off][0], positions[off][1], itemSize, itemSize, itemRad);
      if (pyc.inventory.favorites[i]  != null)
        pyc.inventory.favorites[i].displayCharacterScreen(positions[off][0], positions[off][1]);
      off++;
    }
    // inventory
    for (int i = 0; i < pyc.inventory.maxInv; i++) {
      rect(positions[off][0], positions[off][1], itemSize, itemSize, itemRad);
      if (i < pyc.inventory.inventory.size() && pyc.inventory.inventory.get(i) != null)
        pyc.inventory.inventory.get(i).displayCharacterScreen(positions[off][0], positions[off][1]);
      off++;
    }

    // equipment
    for (String s : pyc.equipment.types) {
      switch (s) {
      case "WEAPON":
        rect(positions[off][0], positions[off][1], itemSize, itemSize, itemRad);
        if (pyc.equipment.equipment.get("WEAPON")  != null)
          pyc.equipment.equipment.get("WEAPON").displayCharacterScreen(positions[off][0], positions[off][1]);
        break;
      case "OFFHAND":
        rect(positions[off][0], positions[off][1], itemSize, itemSize, itemRad);
        if (pyc.equipment.equipment.get("OFFHAND")  != null)
          pyc.equipment.equipment.get("OFFHAND").displayCharacterScreen(positions[off][0], positions[off][1]);
        break;
      case "ARMOR":
        rect(positions[off][0], positions[off][1], itemSize, itemSize, itemRad);
        if (pyc.equipment.equipment.get("ARMOR")  != null)
          pyc.equipment.equipment.get("ARMOR").displayCharacterScreen(positions[off][0], positions[off][1]);
        break;
      case "HELMET":
        rect(positions[off][0], positions[off][1], itemSize, itemSize, itemRad);
        if (pyc.equipment.equipment.get("HELMET")  != null)
          pyc.equipment.equipment.get("HELMET").displayCharacterScreen(positions[off][0], positions[off][1]);
        break;
      case "CLOAK":
        rect(positions[off][0], positions[off][1], itemSize, itemSize, itemRad);
        if (pyc.equipment.equipment.get("CLOAK")  != null)
          pyc.equipment.equipment.get("CLOAK").displayCharacterScreen(positions[off][0], positions[off][1]);
        break;
      case "GLOVES":
        rect(positions[off][0], positions[off][1], itemSize, itemSize, itemRad);
        if (pyc.equipment.equipment.get("GLOVES")  != null)
          pyc.equipment.equipment.get("GLOVES").displayCharacterScreen(positions[off][0], positions[off][1]);
        break;
      case "BOOTS":
        rect(positions[off][0], positions[off][1], itemSize, itemSize, itemRad);
        if (pyc.equipment.equipment.get("BOOTS")  != null)
          pyc.equipment.equipment.get("BOOTS").displayCharacterScreen(positions[off][0], positions[off][1]);
        break;
      case "AMULET":
        rect(positions[off][0], positions[off][1], itemSize, itemSize, itemRad);
        if (pyc.equipment.equipment.get("AMULET")  != null)
          pyc.equipment.equipment.get("AMULET").displayCharacterScreen(positions[off][0], positions[off][1]);
        break;
      case "LIGHT":
        rect(positions[off][0], positions[off][1], itemSize, itemSize, itemRad);
        if (pyc.equipment.equipment.get("LIGHT")  != null)
          pyc.equipment.equipment.get("LIGHT").displayCharacterScreen(positions[off][0], positions[off][1]);
        break;
      }
      off++;
    }

    // rings
    for (int i = 0; i < pyc.equipment.rings.length; i++) {
      rect(positions[off][0], positions[off][1], itemSize*3/4, itemSize*3/4, 10);
      if (pyc.equipment.rings[i] != null)
        pyc.equipment.rings[i].displayCharacterScreen(positions[off][0], positions[off][1]);
      off++;
    }

    // pc information
    rectMode(CORNER);
    fill(150);
    rect(width/2+edge, edge*2-10, (width-edge*2)/5, 22, itemRad);
    rect(width/2+edge, edge*4.3-10, (width-edge*2)/5, 22, itemRad);
    rect(width/2+edge, edge*5.45-10, (width-edge*2)/5, 22, itemRad);
    //----//
    rect(width-edge*2-(width-edge*2)/5, edge*2-10, (width-edge*2)/5, 22, itemRad);
    rect(width-edge*2-(width-edge*2)/5, edge*3.15-10, (width-edge*2)/5, 22, itemRad);
    rect(width-edge*2-(width-edge*2)/5, edge*4.3-10, (width-edge*2)/5, 22, itemRad);
    rect(width-edge*2-(width-edge*2)/5, edge*5.45-10, (width-edge*2)/5, 22, itemRad);
    rect(width-edge*2-(width-edge*2)/5, edge*6.6-10, (width-edge*2)/5, 22, itemRad);
    //----//
    textAlign(LEFT, TOP);
    fill(0);
    text(pyc.name, width/2+edge+10, edge*2-10);
    text("Weight:", width/2+edge+10, edge*4.3-10);
    text(floor(pyc.weight), width/2+edge+85, edge*4.3-10);
    text("Money:", width/2+edge+10, edge*5.45-10);
    text(pyc.moneyToText(), width/2+edge+75, edge*5.45-10);
    //----//
    text("Health:", width-edge*2-(width-edge*2)/5+10, edge*2-10);
    text(pyc.health, width-edge*2-(width-edge*2)/5+90, edge*2-10);
    text("Defense:", width-edge*2-(width-edge*2)/5+10, edge*3.15-10);
    text(pyc.defenseRange(), width-edge*2-(width-edge*2)/5+90, edge*3.15-10);
    text("Damage:", width-edge*2-(width-edge*2)/5+10, edge*4.3-10);
    text(pyc.damageRange(), width-edge*2-(width-edge*2)/5+90, edge*4.3-10);
    text("Speed:", width-edge*2-(width-edge*2)/5+10, edge*5.45-10);
    text(floor(pyc.speed), width-edge*2-(width-edge*2)/5+90, edge*5.45-10);
    text("Sight:", width-edge*2-(width-edge*2)/5+10, edge*6.6-10);
    text(pyc.sight, width-edge*2-(width-edge*2)/5+90, edge*6.6-10);
    //----//
    // get attribute set.
    Set<String> attrSet = new HashSet<String>();
    for (Item i : pyc.equipment.temporaryAttrItems) {
      attrSet.addAll(i.attributes.keySet());
    }
    for (Item i : pyc.equipment.permanentAttrItems) {
      attrSet.addAll(i.attributes.keySet());
    }
    attrSet.remove("TEMP");
    int loc = 0;
    textFont(generalFonts.get(18));
    for (String s : attrSet) {
      text(s, width/2+edge, edge*(1.15*5)+14*loc+15);
      loc++;
    }


    // selected item
    noFill();
    rectMode(CENTER);
    stroke(#FFDE58);
    strokeWeight(4);
    textFont(generalFonts.get(18));
    float s = selected >= numFav+numInv+numEquip ? itemSize*3/4+g.strokeWeight/2 : itemSize+g.strokeWeight/2;
    rect(positions[selected][0], positions[selected][1], s, s, itemRad*1.5);

    // inspect
    Item item = selectedItem(pyc);
    if (inspect && item != null) {
      String[][] text = new String[11][4];
      for (int i = 0; i < text.length; i++) {
        for (int j = 0; j < text[0].length; j++) {
          text[i][j] = "";
        }
      }
      text[0][0] = "Name:";
      text[0][1] = item.name;
      text[0][2] = "Weight:";
      text[0][3] = ""+item.weight;
      text[1][0] = "Type:";
      text[1][1] = item.type;
      text[1][2] = "Value:";
      text[1][3] = ""+item.valueToText();
      text[3][0] = item.desc;
      text[5][0] = "Health Bonus:";
      text[5][1] = ""+item.healthBonus;
      text[6][0] = "Damage Bonus:";
      text[6][1] = ""+item.damageBonus;
      text[7][0] = "Defense Bonus:";
      text[7][1] = ""+item.defenseBonus;
      text[8][0] = "Speed Bonus:";
      text[8][1] = ""+item.speedBonus;
      text[9][0] = "Sight Bonus:";
      text[9][1] = ""+item.sightBonus;
      text[10][0] = "Attributes:";
      text[10][1] = item.attributes.keySet().toString();

      int skip = 3;
      int rows = text.length;
      String c0l = "", c1l = "", c2l = "", c3l = "";
      int xspacing = 15;
      int yspacing = 5;
      for (int i = 0; i < rows; i++) {
        if (i != skip) { 
          c0l = (text[i][0].length() > c0l.length() ? text[i][0] : c0l);
          c1l = (text[i][1].length() > c1l.length() ? text[i][1] : c1l);
          c2l = (text[i][2].length() > c2l.length() ? text[i][2] : c2l);
          c3l = (text[i][3].length() > c3l.length() ? text[i][3] : c3l);
        }
      }

      float lineHeight = textAscent()+textDescent();
      float totWidth = textWidth(c0l)+textWidth(c1l)+textWidth(c2l)+textWidth(c3l)+xspacing*3;
      float topHeight = (lineHeight+yspacing)*3;
      float descHeight = (textWidth(text[3][0])/totWidth+1)*(lineHeight+yspacing);
      float bottomHeight = (lineHeight+yspacing)*7;

      float x = positions[selected][0];
      float y = positions[selected][1];
      float w = totWidth;
      float h = topHeight+descHeight+bottomHeight;

      boolean right = !(x+w > width);
      boolean bottom = !(y+h > height);

      rectMode(CORNER);
      fill(100);
      stroke(150);
      if (right && bottom) {
        showInspect(text, x, y, w, h, xspacing, topHeight, descHeight);
      } else if (right && !bottom) {
        y = y-h;
        showInspect(text, x, y, w, h, xspacing, topHeight, descHeight);
      } else if (!right && bottom) {
        x = x-w;
        showInspect(text, x, y, w, h, xspacing, topHeight, descHeight);
      } else {
        x = x-w;
        y = y-h;
        showInspect(text, x, y, w, h, xspacing, topHeight, descHeight);
      }
    }

    // show dungeon history file if applicable
    if (pyc.hasAttr("HIST")) {
      if (!histSelectChanged) {
        selectedHistory = floor(random(0, dungeonHistory.length)); 
        histSelectChanged = true;
      }
      float histLength = textWidth(dungeonHistory[selectedHistory]);
      float boxW = (histLength > (width-edge*4)) ? (width-edge*4) : histLength;
      boxW += edge;
      float boxH = (textAscent()+textDescent())*(histLength/(width-edge*4)+1);
      boxH += edge/2;

      fill(100);
      stroke(150);
      rectMode(CENTER);
      rect(width/2, height/2, boxW, boxH, 15);
      fill(0);
      textAlign(CENTER, CENTER);
      text(dungeonHistory[selectedHistory], width/2, height/2, boxW-edge/2, boxH);

      if (keyPressed) {
        pyc.equipment.removeHist();
        histSelectChanged = false;
      }
    }
  }

  void showInspect(String[][] text, float x, float y, float w, float h, float s, float th, float dh) {
    rect(x, y, w, h, 15);
    fill(0);

    // 0-2
    float cw = 0;
    float tempx = x;
    for (int j = 0; j < text[0].length; j++) {
      for (int i = 0; i <= 2; i++) {
        text(text[i][j], x+s, y+s+i*24);
      }
      cw = max(textWidth(text[0][j]), textWidth(text[1][j]), textWidth(text[2][j]));
      x = x+cw+s;
    }

    // 3
    x = tempx;
    text(text[3][0], x+s, y+s+th-15, w-s, dh);

    // 4-10
    for (int j = 0; j < text[0].length; j++) {
      for (int i = 4; i <= 10; i++) {
        text(text[i][j], x+s, y+th+dh+(i-4)*24);
      }
      cw = max(textWidth(text[4][j]), textWidth(text[5][j]), textWidth(text[7][j]));
      x = x+cw+s;
    }
  }
}
