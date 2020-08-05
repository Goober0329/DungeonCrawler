//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
class Pathfinder {

  DungeonMap dm;
  Node[][] weightedTunnelingMap;
  boolean pathThreading = false;

  // used for easy neighbor checking. 
  int[][] nbrs = new int[][]{{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}};

  Pathfinder(DungeonMap dungmap) {
    this.dm = dungmap;
    weightedTunnelingMap = new Node[dungmap.dmSize][dungmap.dmSize];
  }

  void updateTunnelingMap(int sx, int sy) {
    pathThreading = true;

    //reset the nodes
    for (int i = 0; i < dm.dmSize; i++) {
      for (int j = 0; j < dm.dmSize; j++) {
        weightedTunnelingMap[i][j] = new Node(null, i, j, dm.getHardness(i, j)+1);
      }
    }

    PriorityQueue<Node> oList = new PriorityQueue<Node>();
    ArrayList<Node> cList = new ArrayList<Node>();
    oList.add(weightedTunnelingMap[sx][sy]);

    Node curr;
    while (oList.size() > 0) {
      // get lowest score node in the open list and remove cell from oList
      curr = oList.poll();
      // put in cList
      cList.add(curr);
      // for each neighbor of curr
      for (int[] xydif : nbrs) {
        Node nbr = weightedTunnelingMap[pbc(curr.x+xydif[0], dm.dmSize)][pbc(curr.y+xydif[1], dm.dmSize)];
        // if neighbor is in cList, ignore
        if (cList.contains(nbr)) {
          continue;
        } 

        float adjust = pow(pbcDist(sx, sy, nbr.x, nbr.y, dm.dmSize), 2)/(dm.dmSize);
        adjust += (abs(xydif[0]) == abs(xydif[1])) ? 1 : 0;
        // if neighbor is not in oList, add it and compute it's score
        if (!oList.contains(nbr)) {
          nbr.parent = curr;
          nbr.s = curr.s + nbr.w + adjust;
          oList.add(nbr);
          continue;
        }
        // if neighbor is in oList, check if it's new score is lower than it's previous. adjust accordingly
        if (oList.contains(nbr)) {
          float tempS = curr.s + nbr.w + adjust;
          if (tempS < nbr.s) {
            nbr.parent = curr;
            nbr.s = tempS;
          }
        }
      }
    }

    pathThreading = false;
  }

  void highlightPathFrom(int fx, int fy, float dmTileSize, boolean tunneling) {
    /* THIS IS BROKE WITH THE NEW DISPLAY FORMAT */
    Node curr = weightedTunnelingMap[fx][fy];
    if (curr  == null) {
      return;
    }
    while (curr.parent != null) {
      fill(0, 255, 0);
      rect(curr.x*dmTileSize, curr.y*dmTileSize, dmTileSize, dmTileSize);
      curr = curr.parent;
      if (!tunneling && dm.tiles[curr.x][curr.y].hardness > 0)
        break;
    }
  }

  Tile nextTileToStair(Tile stair, int ntb) {
    Node curr = weightedTunnelingMap[stair.x][stair.y];
    if (curr  == null) {
      return stair;
    }
    Node backntb = curr;
    int count = 0;
    while (curr.parent != null) {
      count++;
      curr = curr.parent;
      if (count%ntb == 0 && curr.parent != null) {
        backntb = curr;
      }
    }
    return dm.tiles[backntb.x][backntb.y];
  }

  int[] getNextTile(int tx, int ty) {
    Node curr = weightedTunnelingMap[tx][ty];
    if (curr == null) {
      return null;
    } else {
      if (curr.parent != null) {
        return new int[]{curr.parent.x, curr.parent.y};
      } else {
        return null;
      }
    }
  }

  ArrayList<int[]> getNextTiles(int tx, int ty) {
    ArrayList<int[]> toReturn = new ArrayList<int[]>();

    Node curr = weightedTunnelingMap[tx][ty];
    if (curr == null) {
      return toReturn;
    } 
    while (curr.parent != null) {
      toReturn.add(new int[]{curr.x, curr.y});
      curr = curr.parent;
    }
    if (toReturn.size() > 0) {
      toReturn.remove(0);
    }
    return toReturn;
  }

  PVector getDirFromNextTile(int[] nextTile, PVector pos) {
    PVector point = new PVector(0, 0);

    /*
     four cases:
     1. next tile is at xmax and pos is near xmin
     2. next tile is at xmin and pos is near xmax
     3. next tile is at ymax and pos is near ymin
     4. next tile is at ymin and pos is near ymax
     */

    // note: the random factor of 5 ensures that crossing the border is more favorable than sliding down it...    
    if (nextTile[0] == dmSize-1 && pos.x < dmSize/20) {                                      // case 1
      point = (new PVector((nextTile[0]-dmSize+0.5)*5, nextTile[1]+0.5));
    } else if (nextTile[0] == 0 && pos.x > dmSize-dmSize/20) {                               // case 2
      point = (new PVector((nextTile[0]+0.5+dmSize)*5, nextTile[1]+0.5));
    } else if (nextTile[1] == dmSize-1 && pos.y < dmSize/20) {                               // case 3
      point = (new PVector(nextTile[0]+0.5, (nextTile[1]+0.5-dmSize)*5));
    } else if (nextTile[1] == 0 && pos.y > dmSize-dmSize/20) {                               // case 4
      point = (new PVector(nextTile[0]+0.5, (nextTile[1]+0.5+dmSize)*5));
    } else {
      point = (new PVector(nextTile[0]+0.5, nextTile[1]+0.5));
    }
    point.x = floor(point.x)+0.5;
    point.y = floor(point.y)+0.5;
    return point.sub(pos).normalize();
  }
}

void threadUpdatePathfinder() {
  dLevels.get(currLevel).pf.updateTunnelingMap(pc.tile[0], pc.tile[1]);
}


/*
  Node class for use in pathfinding
 */
class Node implements Comparable<Node> {
  int x, y, w;
  float s;
  Node parent;

  Node(Node p, int x, int y, int w) {
    this.parent = p;
    this.x = x;
    this.y = y;
    this.w = w;
    this.s = 0;
  }

  int compareTo(Node other) {
    return int((this.s-other.s)*100);
  }
}
