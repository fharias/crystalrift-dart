/*
  Copyright (C) 2013 Jorge Vargas <vargasjorgeluis@gmail.com>
*/

import 'dart:html';
import 'globals.dart';
import 'graphic.dart';
import '../helpers/coordinate.dart';
import 'tile.dart';
import 'dart:math' as Math;

class Item implements Graphic{
  HtmlDocument _doc;
  CanvasRenderingContext2D _ctx;
  CanvasElement canvas;
  ImageElement itemImage;
  int speed;
  
  //Current position in tiles
  Coordinate curPos;
  //Current position in pixels
  Coordinate curPosPx;
  //Tile of the object
  Tile tile;
  
  //Item is moving?
  bool moving;
  //Item can be pushed?
  bool pushable;
  
  Item(HtmlDocument _doc, CanvasRenderingContext2D _ctx, CanvasElement canvas, Coordinate curPos, Tile tile, [bool pushable=false, int speed = 1]){
    this._doc = _doc;
    this._ctx = _ctx;
    this.canvas = canvas;
    this.curPos = curPos;
    this.tile = tile;
    this.speed = speed;
    this.curPosPx = new Coordinate(curPos.x *TILE_SIZE, curPos.y *TILE_SIZE);
    this.moving = false;
    this.pushable = pushable;
    loadGraphic("assets/tileset.png");
  }
  
  void loadGraphic(String src){
    this.itemImage = new Element.tag('img'); 
    this.itemImage = _doc.createElement('img'); 
    this.itemImage.src = src;
    this.itemImage.onLoad.listen((value) => update());
  }
  
  bool move(int face){
    int deltaY = (curPos.y * TILE_SIZE - curPosPx.y).abs();
    int deltaX = (curPos.x * TILE_SIZE - curPosPx.x).abs();
    
    switch (face) {
      case 0: //up
        if(curPos.y > 0 && deltaY < TILE_SIZE){
          curPos.y -= 1;
          return true;
        }
        break;
      case 1: //down
        if((curPos.y *TILE_SIZE)  < (canvas.height - TILE_SIZE) && deltaY < TILE_SIZE ){
          curPos.y += 1;
          return true;
        }
        break;
      case 2: //left
        if(curPos.x > 0 && deltaX < TILE_SIZE ){
          curPos.x -= 1;
          return true;
        }
        break;
      case 3: //right
        if((curPos.x* TILE_SIZE)< (canvas.width - TILE_SIZE) && deltaX < TILE_SIZE){
          curPos.x += 1;
          return true;
        }
        break;
    }
    return false;
  }
  
  void stopMove(){
    if(curPos.y * TILE_SIZE > curPosPx.y){
      num dy = (curPosPx.y + (TILE_SIZE - (curPosPx.y % TILE_SIZE))) / TILE_SIZE;
      curPos.y = Math.min(dy.floor(), curPos.y);
    }
    if(curPos.x * TILE_SIZE > curPosPx.x){
      num dx = (curPosPx.x + (TILE_SIZE - (curPosPx.x % TILE_SIZE))) / TILE_SIZE;
      curPos.x = Math.min(dx.floor(), curPos.x);
    }
    if(curPos.y * TILE_SIZE < curPosPx.y){
      num dy = (curPosPx.y + (TILE_SIZE - (curPosPx.y % TILE_SIZE))) / TILE_SIZE;
      curPos.y = Math.max(dy.floor(), curPos.y) -1;
    }
    if(curPos.x * TILE_SIZE < curPosPx.x){
      num dx = (curPosPx.x + (TILE_SIZE - (curPosPx.x % TILE_SIZE))) / TILE_SIZE;
      curPos.x = Math.max(dx.floor(), curPos.x) -1;
    }
  }
  
  bool isMoving(){
    return (curPosPx.x != curPos.x * TILE_SIZE || curPosPx.y != curPos.y * TILE_SIZE);
  }
  
  void updateMove(){
    var distance = 2 * speed;
    if(curPos.y * TILE_SIZE > curPosPx.y){
      curPosPx.y = Math.min(curPosPx.y + distance, curPos.y * TILE_SIZE);
    }
    if(curPos.x * TILE_SIZE > curPosPx.x){
      curPosPx.x = Math.min(curPosPx.x + distance, curPos.x * TILE_SIZE);  
    }
    if(curPos.y * TILE_SIZE < curPosPx.y){
      curPosPx.y = Math.max(curPosPx.y - distance, curPos.y * TILE_SIZE);
    }
    if(curPos.x * TILE_SIZE < curPosPx.x){
      curPosPx.x = Math.max(curPosPx.x - distance, curPos.x * TILE_SIZE);
    }
  }
  
  void update(){
    if(isMoving()){
      updateMove();
    }
    
    _ctx.drawImageToRect(this.itemImage , new Rect( curPosPx.x, curPosPx.y, TILE_SIZE, TILE_SIZE), //Rect to paint the image
        sourceRect: new Rect( tile.xImg, tile.yImg, TILE_SIZE, TILE_SIZE)); //Size of the image
  }
  
}