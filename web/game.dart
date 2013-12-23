import 'dart:html';
import 'dart:math';

class Game {
  final CanvasRenderingContext2D context =
      (querySelector("#canvas") as CanvasElement).context2D;
  ImageElement image = new ImageElement(src:"../assets/mainMenu.png");
  
  List<List<int>> map;
  List<String> colors;
 
  // Location of the player in the map list
  int playerX;
  int playerY;
  
  // Different types of map entities (no enums in dart?)
  static const BORDER = 16;
  static const NODE = 17;
  static const PLAYER = 18;
  static const EMPTY = 19;
  
  static const MENU = 0;
  static const PLAY = 1;
  static const OVER = 2;

  // Source of random numbers in Game
  var rand;
  
  // Symbols that need to be found
  String symbolsRem;
  double timeRemaining;
  double lastUpdate;
  Stopwatch timer;
  
  int gameState;
  
  Game() {
    rand = new Random();
    gameState = MENU;
    
    map = [];
    map.length = 80;
    
    colors = [];
    colors.length = 16;
  }
  
  void update(num delta) {
    context.clearRect(0,0,800,550);
    if(gameState == PLAY) {
      timeRemaining = 60 - (timer.elapsedMilliseconds * .001);
      if(timeRemaining <= 0) {
        timeRemaining = 0.0;
        gameState = OVER;
      }
      if(lastUpdate == 0 || delta - lastUpdate > 100000) { 
        lastUpdate = delta;
        window.onKeyDown.listen(onKeyDown);
      }
      drawMap(map,colors);
    }
    else if(gameState == MENU) {
      querySelector('#canvas').onClick.listen((e) { 
        start();
      });
      drawMenu();
    }
    else if(gameState == OVER) {
      drawGameOver();
      querySelector('#canvas').onClick.listen((e) { 
        start();
      });
    }
    window.animationFrame.then(update);
  }
  
  void drawMenu() {
    context..drawImage(image, 0, 0);
  }

  void drawMap(List<List<int>> map, List<String> colors) {
    for(int x = 0; x < map.length; x++ ) {
      for(int y = 0; y < map[x].length; y++ ) {
        int ent = map[x][y];
        if(ent == BORDER) {
          context..fillStyle = 'white';
          context..fillText('*', x*10, y*10); 
        }
        else if(ent == NODE) { 
          context..fillStyle = randomColor();
          context..fillText('@', x*10, y*10); 
        }
        else if(ent == PLAYER) {
          context..fillStyle = 'white';
          context..fillText('1', x*10, y*10); 
        }
        else if(ent < 16) { //Number
          context..fillStyle = colors[ent];
          context..fillText(ent.toRadixString(16).toUpperCase(), x*10, y*10); 
        }
      }
    }
    var q = querySelector("#remaining");
    q.innerHtml = "Symbols Remaining: " + symbolsRem;
    q = querySelector("#timeleft");
    q.innerHtml = "Time Remaining: " + timeRemaining.round().toString();
    context..stroke();
  }
  
  void drawGameOver() {
    context..fillStyle = randomColor();
    context..font = "70px sans-serif";
    context..fillText("GAME OVER", 180, 200);
    context..font = "30px sans-serif";
    context..fillStyle = 'white';
    context..fillText('Click to restart', 300, 300);
    context..font = '10px sans-serif';
  }

  void onKeyDown(KeyboardEvent args) {
    move(args.keyCode);
    patternCheck(args.keyCode);
  }
  
  void start() {
    gameState = PLAY;
    makeMap(map);
    makeColors(colors);
    timer = new Stopwatch()..start();
    symbolsRem = "2 3 4 5 6 7 8 9 A B C D E F";
    lastUpdate = 0.0;
  }
  
  void move(int key) {
    if(key == KeyCode.W) {
        var newY = playerY -1;
        if(map[playerX][newY] == EMPTY) {
          map[playerX][playerY] = EMPTY;
          map[playerX][newY] = PLAYER;
          playerY = newY;
        }
        else if(map[playerX][newY] == NODE) { //Activate Node
          map[playerX][newY] = 10 + rand.nextInt(5);
        }
      }
      if(key == KeyCode.A) {
        var newX = playerX -1;
        if(map[newX][playerY] == EMPTY) {
          map[playerX][playerY] = EMPTY;
          map[newX][playerY] = PLAYER;
          playerX = newX;
        }
        else if(map[newX][playerY] == NODE) { //Activate Node
          map[newX][playerY] = 10 + rand.nextInt(5);
        }
      }
      if(key == KeyCode.S) {
        var newY = playerY +1;
        if(map[playerX][newY] == EMPTY) {
          map[playerX][playerY] = EMPTY;
          map[playerX][newY] = PLAYER;
          playerY = newY;
        }
        else if(map[playerX][newY] == NODE) { //Activate Node
          map[playerX][newY] = 10 + rand.nextInt(5);
        }
      }
      if(key == KeyCode.D) {
        var newX = playerX +1;
        if(map[newX][playerY] == EMPTY) {
          map[playerX][playerY] = EMPTY;
          map[newX][playerY] = PLAYER;
          playerX = newX;
        }
        else if(map[newX][playerY] == NODE) { //Activate Node
          map[newX][playerY] = 10 + rand.nextInt(5);
        }
      }
  }
  
  void patternCheck(int key) {
    int count = 0;
    if(key == KeyCode.UP) {
      int value = 1;
      for( int y = playerY-1; y > playerY-4; y-- ) {
        int ent = map[playerX][y];
        if(ent > 1) break;
        else {
          count++;
          value += ent * pow(2,count);
          map[playerX][y] = EMPTY;
        }
      }
      if(count != 0) {
        map[playerX][playerY-count] = value; 
        symbolsRem = symbolsRem.replaceAll(value.toRadixString(16).toUpperCase(), ' ');
      }
    }
    if(key == KeyCode.LEFT) {
      int value = 1;
      for( int x = playerX-1; x > playerX-4; x-- ) {
        int ent = map[x][playerY];
        if(ent > 1) break;
        else {
          count++;
          value += ent * pow(2,count);
          map[x][playerY] = EMPTY;
        }
      }
      if(count != 0) {
        map[playerX-count][playerY] = value; 
        symbolsRem = symbolsRem.replaceAll(value.toRadixString(16).toUpperCase(), ' ');
      }
    }
    if(key == KeyCode.DOWN) {
      int value = 8;
      for( int y = playerY+1; y < playerY+4; y++ ) {
        int ent = map[playerX][y];
        if(ent > 1) break;
        else {
          count++;
          value += ent * pow(2,3-count);
          map[playerX][y] = EMPTY;
        }
      }
      if(count != 0) {
        map[playerX][playerY+count] = value; 
        symbolsRem = symbolsRem.replaceAll(value.toRadixString(16).toUpperCase(), ' ');
      }
    } 
    if(key == KeyCode.RIGHT) {
      int value = 8;
      for( int x = playerX+1; x < playerX+4; x++ ) {
        int ent = map[x][playerY];
        if(ent > 1) break;
        else {
          count++;
          value += ent * pow(2,3-count);
          map[x][playerY] = EMPTY;
        }
      }
      if(count != 0) {
        map[playerX+count][playerY] = value;
        symbolsRem = symbolsRem.replaceAll(value.toRadixString(16).toUpperCase(), ' ');
      }
    }
  }
  
  void makeColors(List<String> colors) {
    for(int i=0; i < 16; i++) {
      colors[i] = randomColor();
    }
  }

  void makeMap(List<List<int>> map) {
    //Randomly fill with 0 or 1
    for(int x=0; x < map.length; x++) {
      List<int> col = [];
      col.length = 55;
      map[x] = col;
      for(int y=0; y < map[0].length; y++) {
        map[x][y] = rand.nextInt(1000) % 2; //
      }
    }
    makeNodes(map);
    for(int x = 0; x < map.length; x++ ) {
      for(int y = 0; y < map[x].length; y++ ) {
        // Create the border on the edge
        if(x == 0 || y == 1 || x == map.length-1 || y == map[x].length-1) {
          map[x][y] = BORDER;
        }
        // Else, randomly fill with spaces
        else if(map[x][y] != NODE) {
          var mapMiddle = (map.length / 2);
          if(x == mapMiddle) {
            if(y == mapMiddle) {
              playerX = x;
              playerY = y;
              map[x][y] = PLAYER; //Create player in the map
            }  
            else { 
              map[x][y] = EMPTY;
            }
          }
          else if(!randomPercent(25)) {
            map[x][y] = EMPTY;
          }
        }
      }
    }
  }

  void makeNodes(List<List<int>> map) {
      // Top Left Node
      map[3][4] = NODE;
      map[3][5] = NODE;
      map[4][4] = NODE;
      map[4][5] = NODE;
      
      // Top Right Node
      map[map.length-4][4] = NODE;
      map[map.length-4][5] = NODE;
      map[map.length-5][4] = NODE;
      map[map.length-5][5] = NODE;
      
      // Bottom Left Node
      map[3][map[0].length-4] = NODE;
      map[3][map[0].length-5] = NODE;
      map[4][map[0].length-4] = NODE;
      map[4][map[0].length-5] = NODE;
      
      // Bottom Right Node
      map[map.length-4][map[0].length-4] = NODE;
      map[map.length-4][map[0].length-5] = NODE;
      map[map.length-5][map[0].length-4] = NODE;
      map[map.length-5][map[0].length-5] = NODE;
      
  }

  bool randomPercent(int n) {
    if( n >= rand.nextInt(100) ) {
      return true;
    }
    return false;
  }

  String randomColor() {
      var r = rand.nextInt(255);
      var g = rand.nextInt(255);
      var b = rand.nextInt(255);
      return "rgb(" + r.floor().toString() + "," + g.floor().toString() +
          "," + b.floor().toString() +")";
  }
}