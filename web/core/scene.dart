/*
  Copyright (C) 2013 Jorge Vargas <vargasjorgeluis@gmail.com>
*/
library scene;

import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'globals.dart';
import '../helpers/coordinate.dart';
import '../lib/message.dart';
import 'mapset.dart';
import 'character.dart';
import 'actor.dart';
import 'entity.dart';
import 'tile.dart';
import 'action.dart';
import 'animation.dart';
import 'particle.dart';
import 'dart:math' as Math;

class Scene{
  HtmlDocument _doc;
  CanvasRenderingContext2D _ctx;
  CanvasElement canvas;
  
  MapSet gameMap;
  List<Actor> actors; //List of current characters
  Actor player;
  List<Entity> entities;
  List<Action> activeEvents;
  List<Animation> activeAnimations;
  Particle particle;
  
  //Camera offset tiles
  int displayX;
  int displayY;
  
//Camera offset tiles
  int displayPxX;
  int displayPxY;
  
  Scene(HtmlDocument _doc, CanvasRenderingContext2D _ctx, CanvasElement canvas) {
    this._doc = _doc;
    this._ctx = _ctx;
    this.canvas = canvas;
    gameMap = new MapSet(_doc, _ctx, canvas, this);
    Coordinate initCoor = new Coordinate(10, 6);
    Coordinate initCoor2 = new Coordinate(12 * TILE_SIZE, 4* TILE_SIZE);
    Animation animation = new Animation(_doc, _ctx, canvas, this, initCoor2, 'fire_001');
    animation.startAnimation();
    Coordinate partCoor = new Coordinate(12 * TILE_SIZE, 7 * TILE_SIZE);
    particle = new Particle(_doc, _ctx, canvas, this, partCoor, "smoke");
    particle.start();
    activeAnimations = new List<Animation>();
    activeAnimations.add(animation);
    player = new Actor(_doc, _ctx, canvas, initCoor, 0, 1, this, "characters.png"); //Main Player
    player.initializeActor( true, ACTOR_BEHAVIOUR_GOOD, 100, 100);
    //player.moveTo( 13, 4);
    actors = new List<Actor>();
    entities = new List<Entity>();
    displayX = 0;
    displayY = 0;
    displayPxX = 0 * TILE_SIZE;
    displayPxY = 0 * TILE_SIZE;
    activeEvents = new List<Action>();
    loadProperties();
  }
  
  void update(){
    //The order of rendering here controls the priority of visualization
    if(isMoving() && player.isMoving()){
      updateMove();
    }else{
      stopMove();
    }
    gameMap.update();
    Iterator<Actor> charas = actors.iterator;
    while(charas.moveNext()){
      Actor c = charas.current;
      c.update();
    }
    Iterator<Entity> entitiesIte = entities.iterator;
    while(entitiesIte.moveNext()){
      Entity i = entitiesIte.current;
      i.update();
    }
    player.update();  
    Iterator<Animation> animationsIte = activeAnimations.iterator;
    while(animationsIte.moveNext()){
      Animation a = animationsIte.current;
      a.update();
    }
    particle.update();
    Iterator<Action> eventIte = activeEvents.iterator;
    while(eventIte.moveNext()){
      Action e = eventIte.current;
      e.update();
    }
  }
  
  void updateMove(){
    var distance = 2 * player.speed;
    if(displayY * TILE_SIZE > displayPxY){
      displayPxY = Math.min(displayPxY + distance, displayY * TILE_SIZE);
    }
    if(displayX * TILE_SIZE > displayPxX){
      displayPxX = Math.min(displayPxX + distance, displayX * TILE_SIZE);  
    }
    if(displayY * TILE_SIZE < displayPxY){
      displayPxY = Math.max(displayPxY - distance, displayY * TILE_SIZE);
    }
    if(displayX * TILE_SIZE < displayPxX){
      displayPxX = Math.max(displayPxX - distance, displayX * TILE_SIZE);
    }
  }
  
  bool isMoving(){
    return (displayPxX != displayX * TILE_SIZE || displayPxY != displayY * TILE_SIZE);
  }
  
  void stopMove(){
    if(displayY * TILE_SIZE > displayPxY){
      num dy = (displayY + (TILE_SIZE - (displayPxY % TILE_SIZE))) / TILE_SIZE;
      displayY = Math.min(dy.floor(), displayY);
    }
    if(displayX * TILE_SIZE > displayPxX){
      num dx = (displayX + (TILE_SIZE - (displayPxX % TILE_SIZE))) / TILE_SIZE;
      displayX = Math.min(dx.floor(), displayX);
    }
    if(displayY * TILE_SIZE < displayPxY){
      num dy = (displayPxY + (TILE_SIZE - (displayPxY % TILE_SIZE))) / TILE_SIZE;
      displayY = Math.max(dy.floor(), displayY) -1;
    }
    if(displayX * TILE_SIZE < displayPxY){
      num dx = (displayPxX + (TILE_SIZE - (displayPxX % TILE_SIZE))) / TILE_SIZE;
      displayX = Math.max(dx.floor(), displayX) -1;
    }
  }
  
  void move(int direction){
    switch (direction){
      case UP:
        player.move(UP);
        if(player.curPos.y > (CAMERA_HEIGHT_TILES / 2 )
            && player.curPos.y < (MAP_HEIGHT_TILES - displayY)
            && player.curPos.y < MAP_HEIGHT_TILES - (CAMERA_HEIGHT_TILES / 2)){
          centerCamera(CENTER_TYPE_VERTICAL);
        }
        break;
      case DOWN:
        player.move(DOWN);
        if(player.curPos.y > (CAMERA_HEIGHT_TILES / 2 )
            && player.curPos.y < (MAP_HEIGHT_TILES - displayY)
            && player.curPos.y < MAP_HEIGHT_TILES - (CAMERA_HEIGHT_TILES / 2)){
          centerCamera(CENTER_TYPE_VERTICAL);
        }
        break;
      case LEFT:
        player.move(LEFT);
        if(player.curPos.x < (MAP_WIDTH_TILES - displayX)
            && player.curPos.x < MAP_WIDTH_TILES - (CAMERA_WIDTH_TILES / 2)
            && player.curPos.x < MAP_WIDTH_TILES - (CAMERA_WIDTH_TILES / 2)){
          centerCamera(CENTER_TYPE_HORIZONTAL);
        }
        break;
      case RIGHT:
        player.move(RIGHT);
        if(player.curPos.x < (MAP_WIDTH_TILES - displayX)
            && player.curPos.x < MAP_WIDTH_TILES - (CAMERA_WIDTH_TILES / 2)
            && player.curPos.x < MAP_WIDTH_TILES - (CAMERA_WIDTH_TILES / 2)){
          centerCamera(CENTER_TYPE_HORIZONTAL);
        }
        break;  
    }
  }
  
  // This have to be adjusted depending if the window size is odd or even
  void centerCamera(int type){
    if(type == CENTER_TYPE_HORIZONTAL){
      // Adjusted with -1 because the window width is odd
      displayX = Math.max(Math.min(player.curPos.x - ((CAMERA_WIDTH_TILES / 2) - 1).floor(), 
        MAP_WIDTH_TILES), 0);
    }else{
      displayY = Math.max(Math.min(player.curPos.y - (CAMERA_HEIGHT_TILES / 2).floor(), 
        MAP_HEIGHT_TILES), 0);
    }
  }
  
  void loadProperties(){
    var request = HttpRequest.getString("data/characters.json").then(loadCharacters);
    var request2 = HttpRequest.getString("data/structures.json").then(loadStructures);
    var request3 = HttpRequest.getString("data/entities.json").then(loadEntities);
  }
  
  void loadEntities(String responseText){
    Map entitiesData = JSON.decode(responseText);
    Iterator<Map> iteEntities = entitiesData['entities'].iterator;
    while(iteEntities.moveNext()){
      Map i = iteEntities.current;
      Coordinate coords = new Coordinate(i['x'], i['y']);
      Tile tile = new Tile(i['xTile'], i['yTile']);
      Entity item = new Entity(_doc, _ctx, canvas, coords, tile, this, i['pushable']);
      entities.add(item);
      gameMap.occupyTile(i['x'], i['y'], item);
    }
  }
  
  void loadCharacters(String responseText) {
    Map charactersData = JSON.decode(responseText);
    Iterator<Map> characters = charactersData['characters'].iterator;
    while(characters.moveNext()){
      Map m = characters.current;
      Coordinate coords = new Coordinate(m['x'], m['y']);
      Actor character = new Actor(_doc, _ctx, canvas, coords, m['characterId'], m['characterRow'], 
          this, m['imageSource']);
      character.initializeActor( m['combatable'], m['behaviour'], 100, 100, m['message']);
      if(m['moveRandom']){
        character.moveRandom();
      }
      actors.add(character);
      gameMap.occupyTile(m['x'], m['y'], character);
    }
  }
  
  void loadStructures(String responseText) {
    gameMap.structuresData = JSON.decode(responseText);
    gameMap.addBuilding(0, 6,5);
    gameMap.addRandomDetails();
  }
  
  void createMessage(Actor char){
    Message msg = new Message(_ctx, char.message, char.screenPosPx.x, char.screenPosPx.y, 100, 20);
    const ms = const Duration(milliseconds: 5000);
    Timer t = new Timer( ms, removeEvent);
    Action event = new Action(char, msg, EVENT_TYPE_MESSAGE);
    activeEvents.add(event);
  }
  
  void createAnimation(Actor char){
    Coordinate coord = new Coordinate(0,0);
    Animation animation = new Animation(_doc, _ctx, canvas, this, coord, 'light_001');
    Action event = new Action(char, animation, EVENT_TYPE_ANIMATION);
    activeEvents.add(event);
    animation.startAnimation();
    Timer t = new Timer( const Duration(milliseconds: 500), removeEvent);
  }
  
  void removeEvent(){
    Action event = activeEvents.elementAt(0);
    if(event.type == EVENT_TYPE_MESSAGE){
      Actor char = event.object;
      char.trigger = false;
    }
    activeEvents.removeAt(0);
  }
  
  bool shallPass(int face, var c){
    Coordinate newCoords;
    if(face == UP && c.curPos.y >= 1){
      newCoords = new Coordinate(c.curPos.x, c.curPos.y - 1);
    }else if(face == DOWN && c.curPos.y < gameMap.eventMapset.rows -1){
      newCoords = new Coordinate(c.curPos.x, c.curPos.y + 1);
    }else if(face == LEFT && c.curPos.x >= 1){
      newCoords = new Coordinate(c.curPos.x - 1, c.curPos.y);
    }else if(face == RIGHT && c.curPos.x < gameMap.eventMapset.cols -1){
      newCoords = new Coordinate(c.curPos.x + 1, c.curPos.y);
    }else{
      return false;
    }
    
    return objectIsPassable(c, newCoords, face);
  }
  
  bool objectIsPassable( var c, Coordinate newCoords, int face){
    var tileObject = gameMap.eventMapset.get(newCoords.x, newCoords.y);
    if(!identical(tileObject, c) && tileObject != null){
      if(tileObject is Actor && !tileObject.phasable ){
        return false;
      }else if(tileObject is Tile){
        return false;
      }else if(tileObject is Entity && !tileObject.pushable){
        return false;
      }else if(tileObject is Entity && tileObject.pushable){
        if(!tileObject.move(face)){
          return false;
        }
      }
    }
    
    if(c != player){
      bool nextTo = player.curPos.nextToThis2(newCoords);
      if(!player.phasable && nextTo){
        return false;
      }
    }
    return true;
  }
  
  Actor getCharacterInFront(){
    Iterator<Actor> charas = actors.iterator;
    while(charas.moveNext()){
      Actor char = charas.current;
      int charFace = char.curPosPx.facingThis(player.getCurrentDirection(), player.curPosPx);
      if(charFace >= 0){
        char.faceDirection(charFace);
        return char;
      }
    }
    return null;
  }
  
}