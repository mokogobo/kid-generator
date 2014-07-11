// KID_MUSEUM_ICON_GENERATOR.pde
// RadialLayerItem.pde, GUI.pde, SunburstItem.pde
//
// This sketch was a collaborative effort by Michael Gubbels and 
// Michael Smith-Welch for KID Museum.
// 
// Copyright 2014 Michael Gubbels, Michael Smith-Welch
//
// http://www.kid-museum.org/
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// CREDITS
// Credits from KID Museum:
// Parts of this code were adapted from the M_5_5_01_TOOL.pde sketch associated with
// Generative Gestaltung, ISBN: 978-3-87439-759-9, First Edition by Hartmut Bohnacker, 
// Benedikt Gross, Julia Laub, and Claudius Lazzeroni. The website for the book is 
// located at http://www.generative-gestaltung.de.
//
// Credits from previous contributors:
// Part of the FileSystemItem class is based on code from Visualizing Data, First Edition 
// by Ben Fry. Copyright 2008 Ben Fry, 9780596514556.
//
// calcEqualAreaRadius function was done by Prof. Franklin Hernandez-Castro

/**
 * press 'o' to select an input folder!
 * take care of very big folders, loading will take up to several minutes.
 * 
 * program takes a file directory (hierarchical tree) as input 
 * and displays all files and folders with sunburst technique.
 * 
 * MOUSE
 * position x/y               : rollover -> get meta information
 * 
 * KEYS
 * o                          : select an input folder
 * 1                          : mappingMode -> last modified
 * 2                          : mappingMode -> file size
 * 3                          : mappingMode -> local folder file size
 * m                          : toogle, menu open/close
 * s                          : save png
 * p                          : save pdf
 */

import processing.pdf.*;
import controlP5.*;
import java.util.Calendar;
import java.util.Date;
import java.io.File;


// ------ ControlP5 ------
ControlP5 controlP5;
boolean showGUI = false;
Slider[] sliders;
Range[] ranges;
Toggle[] toggles;


// ------ interaction vars ------
float backgroundBrightness = 100;

boolean savePDF = false;

PFont font;

// ------ program logic ------
ArrayList<SunburstItem> sunburstItems;
ArrayList<RadialLayerItem> radialLayerItems;
Calendar now = Calendar.getInstance();
int depthMax;


boolean initialize = true;
color arcStrokeColor;
color arcFillColor;

void setup() { 
  size(800, 800, OPENGL);
  // hint(DISABLE_DEPTH_TEST);
  
  sunburstItems = new ArrayList<SunburstItem>();
  radialLayerItems = new ArrayList<RadialLayerItem>();
  
  setupGUI(); 
  colorMode(HSB, 360, 100, 100);

  //font = createFont("Arial", 14);
  font = createFont("miso-regular.ttf", 14);
  textFont(font,12);
  textLeading(14);
  textAlign(LEFT, TOP);
  cursor(CROSS);

  frame.setTitle("press 'o' to select an input folder!");
}

void draw() {
  
  if (savePDF) {
    println("\n"+"saving to pdf – starting");
    beginRecord(PDF, timestamp()+".pdf");
  }
  
  if (initialize) {
    generateSymbol(3);
    initialize = false;
    
    arcStrokeColor = color(360, 100, 100); // color(random(0, 360), 100, 100);
    arcFillColor = color(random(0, 360), 100, 100);
  }
  
  smooth();

  pushMatrix();
  colorMode(HSB, 360, 100, 100, 100);
  background(0, 0, backgroundBrightness);
  noFill();
  ellipseMode(RADIUS);
  strokeCap(SQUARE);
  textFont(font, 12);
  textLeading(14);
  textAlign(LEFT, TOP);
  smooth();

  translate(width / 2, height / 2, -200);

  // ------ draw the viz items ------
  for (int i = 0 ; i < sunburstItems.size(); i++) {
    sunburstItems.get(i).drawArc();
  }
  popMatrix();

  if (savePDF) {
    savePDF = false;
    endRecord();
    println("saving to pdf – done");
  }

  drawGUI();
}

void generateSymbol (int layerCount) {
  
  sunburstItems.clear();

  for (int i = 0; i < layerCount; i++) {
    if (i == 0) {
      RadialLayerItem radialForm = new RadialLayerItem(null);
      radialLayerItems.add(radialForm);
      sunburstItems.add(radialForm.generateSunburstItem());
      println("draw 1");
    } else {
      RadialLayerItem radialForm = new RadialLayerItem(radialLayerItems.get(i - 1));
      radialLayerItems.add(radialForm);
      sunburstItems.add(radialForm.generateSunburstItem());
      println("draw 2");
    }
  }

  // mine sunburst -> get min and max values 
  // reset the old values, without the root element
  depthMax = 0;
  for (int i = 1 ; i < sunburstItems.size(); i++) {
    depthMax = max(sunburstItems.get(i).depth, depthMax);
  }
}

// ------ returns radiuses in a linear way ------
float calcAreaRadius(int theDepth, int theDepthMax) {
  return map(theDepth, 0, theDepthMax+1, 0, height/2);
}


// ------ interaction ------
void keyReleased() {
  if (key == 's' || key == 'S') saveFrame("data/output/"+timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;
//  if (key == 'o' || key == 'O') selectFolder("please select a folder", "setInputFolder");
  
  if (key == 'r' || key == 'R') {
    initialize = true;
  }

  if (key=='m' || key=='M') {
    showGUI = controlP5.group("menu").isOpen();
    showGUI = !showGUI;
  }
  if (showGUI) controlP5.group("menu").open();
  else controlP5.group("menu").close();
}


//void mouseEntered(MouseEvent e) {
//  loop();
//}
//
//void mouseExited(MouseEvent e) {
//  noLoop();
//}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
} 



