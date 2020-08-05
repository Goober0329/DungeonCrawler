
class Dice {
  // base + rolls d sides
  int base;
  int rolls;
  int sides;

  int mValue = 1;

  Dice(int b, int r, int s) {
    base = b;
    rolls = r;
    sides = s;
  }

  Dice(String dice) {
    try {
      String[] parts = dice.split("[+d]");
      char mv = parts[0].charAt(parts[0].length()-1);
      if (mv == 'g' || mv == 's' || mv == 'c') {
        if (mv == 'g') {
          mValue = 400;
        } else if (mv == 's') {
          mValue = 20;
        } else if (mv == 'c') {
          mValue = 1;
        }
        base = int(parts[0].substring(0, parts[0].length()-1));
      } else {
        base = int(parts[0]);
      }
      rolls = int(parts[1]);
      sides = int(parts[2]);
    } 
    catch (Exception e) {
      base = 0;
      rolls = 0;
      sides = 0;
    }
  }

  int roll() {
    int toReturn = base;
    for (int i = 0; i < rolls; i++) {
      toReturn += floor(random(1, sides+1));
    }
    return toReturn;
  }
  
  int low() {
    return base+rolls;
  }
  
  int high() {
    return base+rolls*sides;
  }

  String toString() {
    return base+"+"+rolls+"d"+sides;
  }
}
