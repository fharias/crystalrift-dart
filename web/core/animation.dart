/*
  Copyright (C) 2013 Jorge Vargas <vargasjorgeluis@gmail.com>
*/

library animation;

import 'dart:html';
import 'dart:async';
import 'globals.dart';
import 'scene.dart';
import '../helpers/coordinate.dart';
import 'graphic.dart';

class Animation implements Graphic{
  
  //Graphical vars
  HtmlDocument _doc;
  CanvasRenderingContext2D _ctx;
  CanvasElement canvas;
  ImageElement animationImage;
  Scene scene;
  Coordinate curPosPx;
  int animationFrame;
  
  Animation(HtmlDocument this._doc, CanvasRenderingContext2D this._ctx, CanvasElement this.canvas, 
       Scene this.scene, Coordinate this.curPosPx, String file){
    this.animationFrame = 0;
    loadGraphic('assets/animations/'+ file +'.png');
  }
  
  void startAnimation(){
    const ms = const Duration(milliseconds: 100);
    Timer t = new Timer( ms, updateFrame);
  }
  
  void updateFrame(){
    num maxFrames = (animationImage.height / ANIMATION_FRAME_HEIGHT) * 5;
    if(animationFrame >= maxFrames){
      animationFrame = 0;
    }
    animationFrame++;
    startAnimation();
  }
  
  void update(){
    num frameX = animationFrame % 5;
    num frameY = (animationFrame / 5).floor();
    _ctx.drawImageScaledFromSource(animationImage, ANIMATION_FRAME_WIDTH * frameX, ANIMATION_FRAME_HEIGHT * frameY, 
        ANIMATION_FRAME_WIDTH, ANIMATION_FRAME_HEIGHT, curPosPx.x - scene.displayPxX, curPosPx.y - scene.displayPxY, TILE_SIZE, TILE_SIZE+10);
  }
  
  void loadGraphic(String src){
    this.animationImage = new Element.tag('img'); 
    this.animationImage = _doc.createElement('img'); 
    this.animationImage.src = src;
    this.animationImage.onLoad.listen((value) => update());
  }
}