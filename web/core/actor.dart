/*
  Copyright (C) 2014 Jorge Vargas <vargasjorgeluis@gmail.com>
*/

library actor;

import 'dart:html';
import 'dart:async';
import 'globals.dart';
import 'scene.dart';
import '../helpers/coordinate.dart';
import 'dart:math' as Math;
import 'character.dart';

class Actor extends Character{
  
  // Max life
  int maxLife;
  // Current life
  int life;
  // Type of the actor behaviour
  int behaviour;
  // Max energy
  int maxEnergy;
  // Current energy
  int energy;
  //Message of the character
  String message;
  // If the actor can combat
  bool combatable; 
  
  ImageElement barHpImage;
  ImageElement barMpImage;
  
  String srcBarHp = "hp_pixel.png";
  String srcBarMp = "mp_pixel.png";
  
  Actor(HtmlDocument doc, CanvasRenderingContext2D ctx, CanvasElement canvas, 
        Coordinate curPos, int charSprite, int charRow, Scene scene, String imageSource, [ int speed = 1]) : 
          super( doc, ctx, canvas, curPos, charSprite, charRow, scene, imageSource, speed);
  
  void initializeActor( bool combatable, int behaviour, [int maxLife = 0, int maxEnergy = 0, String message = ""]){
    this.combatable = combatable;
    this.behaviour = behaviour;
    this.maxLife = maxLife;
    this.life = maxLife;
    this.maxEnergy = maxEnergy;
    this.energy = maxEnergy;
    this.message = message;
    loadBars();
  }
  
  void loadBars(){
    barHpImage = new Element.tag('img'); 
    barHpImage = doc.createElement('img'); 
    barHpImage.src = "assets/character/extra/hp_pixel.png";
    barMpImage = new Element.tag('img'); 
    barMpImage = doc.createElement('img'); 
    barMpImage.src = "assets/character/extra/" + srcBarMp;
  }
  
  void update(){
    super.update();
    if(combatable){
      int barWeigth = (TILE_SIZE * (life / maxLife)).floor();
      ctx.drawImageScaled(barHpImage, screenPosPx.x, screenPosPx.y + TILE_SIZE + 3, 
          barWeigth, 3);
    }
  }
  
  
}