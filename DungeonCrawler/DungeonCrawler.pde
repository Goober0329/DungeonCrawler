//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
//<>//
import java.util.*;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.FileReader;
import processing.sound.*;

String title = "Dungeon Breach";

// DUNGEON LEVEL VARIABLES
int dmSize = 50;
int dmTileSize = 48; // must be a factor of 16 (due to pixel art tile size)
int numNPC = 10;
int numItem = 35;

PlayerCharacter pc;

int nLevels = 5;
ArrayList<DungeonLevel> dLevels;
int currLevel;
int maxLevel;

// GAME STATES
GameStateController stateController;
boolean gamePause = false;

// SCREENS
Screen tScreen;

Screen pcScreen;
Screen gpScreen;
Screen mpScreen;
Screen egScreen;
Screen mScreen;

// LOADING THREAD
boolean loading = false;
boolean loadSaveGame = false;
boolean firstLoad = true;
boolean startLoad; // set in titlescreen
String currSegment = "";

void setup() {
  size(800, 600, P2D);
  background(0);
  smooth();

  surface.setTitle(title);

  dungeonFonts = new FontContainer("fonts/dungeonfont.ttf");
  generalFonts = new FontContainer("fonts/serif.ttf");

  tScreen = new ScreenTitle();
  stateController = new GameStateController(GameState.TitleScreen); 
  loadAudio();
  loadVolume();
  loadMechanics();
}


void draw() {
  if (loading) {
    if (startLoad) {
      if (loadSaveGame) {
        thread("initDungeonCrawlerFromFile");
      } else {
        thread("initDungeonCrawler");
      }
      startLoad = false;
    }
    loading();
  } else {
    stateController.update(keys);
    switch(stateController.state) {
    case TitleScreen: 
      noCursor();
      tScreen.display(null, null);
      tScreen.update(null, null);
      break;
    case NormalGameplay: 
      cursor(CROSS);
      gpScreen.display(pc, dLevels.get(currLevel));
      gpScreen.update(pc, dLevels.get(currLevel));
      break;
    case FullMapView: 
      noCursor();
      gpScreen.display(pc, dLevels.get(currLevel));
      mpScreen.update(pc, dLevels.get(currLevel));
      mpScreen.display(pc, dLevels.get(currLevel));
      break;
    case CharacterInformationView:
      noCursor();
      gpScreen.display(pc, dLevels.get(currLevel));
      pcScreen.update(pc, dLevels.get(currLevel));
      pcScreen.display(pc, dLevels.get(currLevel));
      break;
    case MenuScreen: 
      noCursor();
      gpScreen.display(pc, dLevels.get(currLevel));
      mScreen.update(pc, dLevels.get(currLevel));
      mScreen.display(pc, dLevels.get(currLevel));
      break;
    case EndGame: 
      noCursor();
      egScreen.update(pc, dLevels.get(currLevel));
      egScreen.display(pc, dLevels.get(currLevel));
      break;
    }
    clearCommands();
  }
  //saveFrame("title screen/####.png");
}


/****************************************************************************************************/
/****************************************************************************************************/
/****************************************************************************************************/
/****************************************************************************************************/

void initDungeonCrawler() {

  int lowt = 100;
  int hight = 500;

  // File parsing
  if (firstLoad) {
    currSegment = "Remembering Dungeon History";
    delay((int)random(lowt, hight));
    parseDungeonHistory();

    currSegment = "Recruiting Dungeon Enemies";
    delay((int)random(lowt, hight));
    foeOptions = parseFoes();

    currSegment = "Looking for Dungeon Items";
    delay((int)random(lowt, hight));
    itemOptions = parseItems();
    itemDistribution = parseItemDistribution(numItem);

    currSegment = "Creating Dungeon Visuals";
    delay((int)random(lowt, hight));
    loadPixelArt();

    firstLoad = false;
  }

  currSegment = "Checking Previous Dungeoneers";
  delay((int)random(lowt, hight));
  parseDungeonHighscores();

  // Dungeon Level creation
  currSegment = "Dungeon Generation in Progress";
  delay((int)random(lowt, hight));
  dLevels = new ArrayList<DungeonLevel>();
  for (int i = 0; i < nLevels; i++) {
    dLevels.add(new DungeonLevel(dmSize, dmTileSize, numNPC, numItem, i == 0 ? true : false));
  }
  currLevel = 0;
  maxLevel = 0;

  // PC creation
  currSegment = "Creating Player";
  delay((int)random(lowt, hight));
  pc = new PlayerCharacter(((ScreenTitle)tScreen).getPlayerName(), "50+0d0", "1+0d0", "0+0d0", "6+0d0", "7+0d0");
  pc.setRandomFloorLocation(dLevels.get(0).dm, dLevels.get(0).occTiles);

  // create dungeon pathfinder
  currSegment = "Dungeon Enemy Training";
  delay((int)random(lowt, hight));
  for (DungeonLevel dlvl : dLevels) {
    dlvl.createPathfinder(pc);
  }

  currSegment = "Starting";
  delay((int)random(lowt, hight));
  pcScreen = new ScreenCharacterInfo(pc);
  gpScreen = new ScreenGameplay();
  mpScreen = new ScreenMap();
  egScreen = new ScreenEndGame(((ScreenTitle)tScreen).background);
  mScreen = new ScreenMenu(((ScreenTitle)tScreen).background);

  stateController.resetStateManagement();
  stateController.setStart(true);

  loading = false;
}

void initDungeonCrawlerFromFile() {

  int lowt = 100;
  int hight = 500;

  currSegment = "Loading Dungeon";
  delay((int)random(lowt, hight));
  boolean success = loadGame();
  if (!success) {
    loading = true;
    loadSaveGame = false;
    startLoad = true;
    removeSavedGame();
    return;
  }

  // File parsing
  if (firstLoad) {
    currSegment = "Remembering Dungeon History";
    delay((int)random(lowt, hight));
    parseDungeonHistory();

    currSegment = "Recruiting Dungeon Enemies";
    delay((int)random(lowt, hight));
    foeOptions = parseFoes();

    currSegment = "Looking for Dungeon Items";
    delay((int)random(lowt, hight));
    itemOptions = parseItems();
    itemDistribution = parseItemDistribution(numItem);

    currSegment = "Creating Dungeon Visuals";
    delay((int)random(lowt, hight));
    loadPixelArt();

    firstLoad = false;
  }

  currSegment = "Checking Previous Dungeoneers";
  delay((int)random(lowt, hight));
  parseDungeonHighscores();

  currSegment = "Starting";
  delay((int)random(lowt, hight));
  pcScreen = new ScreenCharacterInfo(pc);
  gpScreen = new ScreenGameplay();
  mpScreen = new ScreenMap();
  egScreen = new ScreenEndGame(((ScreenTitle)tScreen).background);
  mScreen = new ScreenMenu(((ScreenTitle)tScreen).background);

  stateController.resetStateManagement();
  stateController.setStart(true);

  loading = false;
}

void loading() {
  background(0);
  fill(0, 231, 0);
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  textFont(dungeonFonts.get(45));
  text(currSegment+"...", width/2, height/2);
}

/****************************************************************************************************/
/******************************************** Screen ************************************************/
/****************************************************************************************************/
interface Screen {
  void update(PlayerCharacter pyc, DungeonLevel dlvl);
  void display(PlayerCharacter pyc, DungeonLevel dlvl);
}
