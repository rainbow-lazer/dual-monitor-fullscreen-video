/*

play a video fullscreen over two monitors
this currently uses one video file to play over two screens, 
but could easily be combined to play multiple video files, 
eg one per screen.

also some tools for masking and projector alignment, see the
keypress function for usage

*/

import processing.video.*;
import java.awt.Frame;

//to make the exported app go fullscreen across multiple monitors
public void init() { 
  frame.removeNotify(); 
  frame.setUndecorated(true); 
  frame.addNotify(); 
  super.init();
}

Movie movie;
PImage calibGrid;
PImage cursor;
PImage mask;
PGraphics canvas;

int cursorX = 1024;
int cursorY = 0;

int vidOpacity = 106;

boolean drawMode = false;
int bgMode = 0;

void setup() {
  //set the resolution of both screens combined
  size(2048, 768);
  frameRate(30);
  textSize( 75 );
  noCursor();

  movie = new Movie(this, "MyMovie.mov");
  movie.loop();
  movie.frameRate(29.97);

  calibGrid = loadImage("grid-pattern.gif");
  cursor = loadImage( "cursors/cursor-10.gif" );

  //try to load the mask image. 
  try { 
    mask = loadImage( "mask.png" );
  }
  catch( Exception e ) { 
    mask = null;
  }
  //if mask doesn't exist, make a new one
  if ( mask == null ) {
    newMask();
  }

  canvas = createGraphics(width, height, JAVA2D);
}

void draw() {
  background(255);

  if ( drawMode ) {  //EDIT MODE
    //canvas is a temporary buffer that combines the current mask with new cursor info
    canvas.beginDraw();
    canvas.image( mask, 0, 0 );
    if (mousePressed && (mouseButton == LEFT)) {
      canvas.image( cursor, cursorX, cursorY );
      //canvas.image( cursor, mouseX - cursor.width/2, mouseY - cursor.width/2 );
    }     
    canvas.endDraw();
    //update the mask
    mask = canvas.get(0, 0, width, height);
    //clear the canvas
    canvas = createGraphics(width, height, JAVA2D);


    switch( bgMode ) {

    case 0:
      //show the movie frame or calibration img
      image(movie, 0, 0, width, height);
      break;

    case 1:
      image( calibGrid, 0, 0, 1024, 768 );
      image( calibGrid, 1024, 0, 1024, 768 );
      break;

    case 2:
      background(255);
      break;

    case 3:
      background(0);
      break;

    default:
      bgMode = 0;
      break;
    }
    //overlay the mask
    blend( mask, 0, 0, width, height, 0, 0, width, height, MULTIPLY);
    //show the cursor
    image( cursor, cursorX, cursorY );
    //image( cursor, mouseX - cursor.width/2, mouseY - cursor.width/2 );

    text( "EDIT MODE", width/2, height/2 );
  } 
  else { //REGULAR DISPLAY
    tint( 255, vidOpacity );
    image(movie, 0, 0, width, height);
    tint( 255, 255 );
    image(mask, 0, 0, width, height);
  }
}

void stop() {
  movie.stop();
}

void mouseReleased() {
  saveMask("mask.png");
}

void saveMask( String filename ) {
  mask.save( "data/" + filename );
}

//generate a blank, transparent png that matches the movie size
void newMask() {   
  PGraphics blankPG = createGraphics(movie.width, movie.height, JAVA2D);

  blankPG.beginDraw();
  blankPG.fill(255, 0);
  blankPG.rect(0, 0, movie.width, movie.height);
  blankPG.endDraw();
  blankPG.save("data/mask.png"); 
  mask = loadImage( "mask.png" );
}

//use key commands to toggle modes
// 'e' toggles edit mode to draw the mask
// up/down switches from drawing to erasing cursors
// 'n' erases the current mask with a blank one
void keyPressed() {
  if ( key == CODED ) {
    if (keyCode == UP ) {
      cursorY+=10;
      //cursor = loadImage( "cursors/cursor-10.gif" );
    }
    else if (keyCode == DOWN ) {
      cursorY--;
      //cursor = loadImage( "cursors/eraser-25.gif" );
    }
    else if (keyCode == LEFT ) {
      cursorX--;
    }
    else if (keyCode == RIGHT ) {
      cursorX++;
    }
  }
  else if (key == 'e' || key == 'E' ) {
    if ( drawMode ) { //exiting edit mode
      noCursor();
      drawMode = false;
      movie.play();
    }
    else if ( !drawMode ) { //entering edit mode
      cursor(HAND);
      drawMode = true;
      movie.pause();
    }
  }
  else if ( key == '[' ){
    vidOpacity--;
    println( vidOpacity );
  }
  else if ( key == ']' ){
    vidOpacity++;
     println( vidOpacity );
  }
  else if ( drawMode ) { 

    if ( key == '0') {
      bgMode = 0;
    }
    if ( key == '1') {
      bgMode = 1;
    }
    if ( key == '2') {
      bgMode = 2;
    }
    if ( key == '3') {
      bgMode = 3;
    }

    if ( key == 'n' || key =='N' ) {
      saveMask("mask-bkp.png");
      newMask();
    }
  }
}

void movieEvent(Movie m) {
  m.read();
}

