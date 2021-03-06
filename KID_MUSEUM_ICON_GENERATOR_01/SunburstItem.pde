class SunburstItem {

  // relations
  int depth;
  
  // arc and lines drawing vars
  float angleStart, angleCenter, angleEnd;
  float extension;
  float radius; 
  float x,y;
  float xOffset, yOffset;
  float arcLength;
  float arcWidth = 100;
  
//  boolean enableBackground = false;
  color backgroundColor;
  float backgroundSize = 900;
  
  float strokeWeight = 10.0; // 1.0
  color strokeColor;
  color negativeStrokeColor;
  
  boolean enableNegativeSpaceColor = false;
  float negativeArcPadding = 0.01 * PI;
  
  boolean enableStroke = false;
  boolean enablePartialOutline = true;
  boolean drawDistalOutline = true;
  boolean bisectDistalOutline = true;
  boolean drawOuterArc = false;
  boolean drawProximalBoundaryLine = false;
  
  boolean enableFill = true;
  color fillColor;
  
  int arcSegmentFrequency = 5;
  
  float secondArmAngleOffset = 0;

  // ------ constructor ------
  SunburstItem (int theDepth, float theAngle, float theExtension) {

    this.depth = theDepth;

    // sunburst angles and extension
    this.angleStart = theAngle;
    this.extension = theExtension;
    this.angleCenter = theAngle + theExtension / 2;
    this.angleEnd = theAngle + theExtension;
    
    this.backgroundColor = color(255, 255, 255, 0);
    
    this.strokeColor = color(0, 0, 255, 100);
    this.negativeStrokeColor = color(0, 0, 100);
    
    this.fillColor = color(60, 0, 199, 100); // Yves Klein Blue (i.e., http://en.wikipedia.org/wiki/Yves_Klein)
    
    this.xOffset = 0;
    this.yOffset = 0;
  }
  
  void setColor(color strokeColor) {
    this.strokeColor = strokeColor;
    this.fillColor = strokeColor;
  }
  
  void setNegativeColor(color negativeStrokeColor) {
    this.negativeStrokeColor = negativeStrokeColor;
  }
  
  void setArcWidth(float arcWidth) {
    this.arcWidth = arcWidth;
  }
  
  void setOffset(float xOffset, float yOffset) {
    this.xOffset = xOffset;
    this.yOffset = yOffset;
  }

  // ------ draw functions ------
  void draw() {
    
    pushMatrix();
    
    translate(this.xOffset, this.yOffset);
    
    float arcRadius;
    
    if (this.depth > 0 ) {

      radius = calcAreaRadius(depth, depthMax);
//      radius = 10 + this.depth * arcWidth; // this.depth * 50 + 10;
      x  = cos(angleCenter) * radius;
      y  = sin(angleCenter) * radius;
      float startX  = cos(angleStart) * radius;
      float startY  = sin(angleStart) * radius;  
      float endX  = cos(angleEnd) * radius;
      float endY  = sin(angleEnd) * radius; 
      arcLength = dist(startX,startY, endX,endY);
      arcRadius = radius + arcWidth;
      
      // NOTE: This is the original drawing method used. Parameterize for "final" generator?
      // arcWrap(0, 0, arcRadius, arcRadius, angleStart, angleEnd); // normaly arc should work
      
      // Manually draw the arc geometry
      if (this.enableStroke) {
//        stroke(this.strokeColor);
        h.setStrokeColour(this.strokeColor);
        strokeWeight(this.strokeWeight); // e.g., 1.0
      } else {
        noStroke();
      }
      
      if (this.enableFill) {
        fill(this.fillColor);
        h.setFillColour(this.fillColor);
      }
      
      // Draw layer positive segment
      drawLayer(arcRadius);
      
//      // Draw background
//      if (this.enableBackground) {
//        pushMatrix();
//        noStroke();
//        fill(this.backgroundColor);
//        rect(-1 * (this.backgroundSize / 2), -1 * (this.backgroundSize / 2), this.backgroundSize, this.backgroundSize);
//        popMatrix();
//      }
      
      if (this.enableNegativeSpaceColor) {
//        stroke(this.negativeStrokeColor); // stroke(arcStrokeColor);
        h.setStrokeColour(this.negativeStrokeColor);
        float newEndAngle = angleStart;
        float newStartAngle = angleEnd % PI;
//        while (newStartAngle > newEndAngle) {
//          newStartAngle = newStartAngle % PI;
//        }
        // NOTE: This is the original drawing method used. Parameterize for "final" generator?
        // arcWrap(0, 0, arcRadius, arcRadius, newStartAngle - this.negativeArcPadding, newEndAngle + this.negativeArcPadding); // normaly arc should work
        
        // Fill in the "negative circle" at the center
//        fill(this.negativeStrokeColor);
        h.setFillColour(this.fillColor);
        ellipse(0, 0, arcWidth, arcWidth);
        noFill();
      }
    } else if (this.depth == -1) {
      if (enableYvesKleinArm) {
        drawSecondArmSegment(radius);
      }
    } else if (this.depth == -2) {
      //drawBackgroundCircle(radius * 3);
//      drawBackgroundCircle(200);
    }
    
    popMatrix();
  }

  // fix for arc
  // it seems that the arc functions has a problem with very tiny angles ... 
  // arcWrap is a quick hack to get rid of this problem
//  void arcWrap (float theX, float theY, float theW, float theH, float theA1, float theA2) {
//    if (arcLength > 2.5) {
//      arc(theX,theY, theW,theH, theA1, theA2);
//      // TODO: (Possibly) Replace with custom drawing function (e.g., Bezier curve estimation)
//    } else {
//      strokeWeight(arcLength);
//      pushMatrix();
//      rotate(angleCenter);
//      translate(radius,0);
//      line(0,0, (theW-radius)*2,0);
//      popMatrix();
//    }
//  }
  
  void drawLayer(float arcRadius) {
    float angleArcStep = PI / 180 * this.arcSegmentFrequency;

    float degreesInCircle = 360;
    float beginAngleInDegrees = (angleStart / TWO_PI) * degreesInCircle;
    float endAngleInDegrees = (angleEnd / TWO_PI) * degreesInCircle;
    float radiansPerDegree = TWO_PI / degreesInCircle;
    int angleArcStepInDegrees = int((angleArcStep / TWO_PI) * degreesInCircle);
    
    h.setBackgroundColour(color(255,255,255,0));
    // Draw the layer's inner arc
    h.beginShape(POLYGON);
    int i = 0;
    for(i = int(beginAngleInDegrees); i < int(endAngleInDegrees); i += angleArcStepInDegrees) {
      float angleInRadians = i * radiansPerDegree;
      float xx = (arcRadius - (arcWidth / 2)) * cos(angleInRadians);
      float yy = (arcRadius - (arcWidth / 2)) * sin(angleInRadians);
      h.vertex(xx, yy);
    }
    // Correct the drawing. Draw the last line "manually" if overstepped endpoint (NOTE: Removing this makes the sketch look more rough!)
    if (i > angleArcStepInDegrees) {
      i = int(endAngleInDegrees);
      float angleInRadians = i * radiansPerDegree;
      float xx = (arcRadius - (arcWidth / 2)) * cos(angleInRadians);
      float yy = (arcRadius - (arcWidth / 2)) * sin(angleInRadians);
      h.vertex(xx, yy);
    }
    
    // Draw arc boundary line connecting inner arc to outer arc
    // TODO: Optionally, draw a "rounded corner" rather than a "sharp corner". Repeat for other layer bounding line.
    float xx1, yy1;
    float xx2, yy2;
    xx1 = (arcRadius - (arcWidth / 2)) * cos(angleEnd);
    yy1 = (arcRadius - (arcWidth / 2)) * sin(angleEnd);
    xx2 = (arcRadius + (arcWidth / 2)) * cos(angleEnd);
    yy2 = (arcRadius + (arcWidth / 2)) * sin(angleEnd);
    h.line(xx1, yy1, xx2, yy2);
    
    // Draw the layer's outer arc
    for(i = int(endAngleInDegrees); i >= int(beginAngleInDegrees); i -= angleArcStepInDegrees) {
      float angleInRadians = i * radiansPerDegree;
      float xx = (arcRadius + (arcWidth / 2)) * cos(angleInRadians);
      float yy = (arcRadius + (arcWidth / 2)) * sin(angleInRadians);
      h.vertex(xx, yy);
    }
    // Correct the drawing. Draw the last line "manually" if overstepped endpoint (NOTE: Removing this makes the sketch look more rough!)
    if (i < int(beginAngleInDegrees)) {
      i = int(beginAngleInDegrees);
      float angleInRadians = i * radiansPerDegree;
      float xx = (arcRadius + (arcWidth / 2)) * cos(angleInRadians);
      float yy = (arcRadius + (arcWidth / 2)) * sin(angleInRadians);
      h.vertex(xx, yy);
    }
    
    xx1 = (arcRadius - (arcWidth / 2)) * cos(angleStart);
    yy1 = (arcRadius - (arcWidth / 2)) * sin(angleStart);
    xx2 = (arcRadius + (arcWidth / 2)) * cos(angleStart);
    yy2 = (arcRadius + (arcWidth / 2)) *  sin(angleStart);
    h.line(xx1, yy1, xx2, yy2);
    
    h.endShape();
    
    
    // TODO: Draw outline over the icon
  }
  
  void drawSecondArmSegment(float radius) {
  // Draw the "second arm" arc segment

//    strokeWeight(arcWidth); // strokeWeight(depthWeight * theFileScale);

    float armOffsetAngle = 0.2 * PI;
    float angleStart = this.angleStart + armOffsetAngle; 
    float angleEnd = this.angleEnd + armOffsetAngle;

    x  = cos(angleCenter) * radius;
    y  = sin(angleCenter) * radius;
    float startX  = cos(angleStart) * radius;
    float startY  = sin(angleStart) * radius;  
    float endX  = cos(angleEnd) * radius;
    float endY  = sin(angleEnd) * radius; 
    arcLength = dist(startX, startY, endX, endY);
    float arcRadius = radius + arcWidth;
    
    //stroke(this.negativeStrokeColor); // stroke(arcStrokeColor);
    if (this.enableStroke) {
//      stroke(this.strokeColor); // stroke(color(0, 0, 0));
      h.setStrokeColour(color(60, 0, 199));
      if (enablePartialOutline) {
        noStroke();
      } else {
        strokeWeight(this.strokeWeight);
      }
    } else {
      noStroke();
    }
    h.setStrokeColour(color(60, 0, 199));
    
//    fill(this.fillColor); // fill(color(240, 100, 100));
    h.setFillColour(color(60, 0, 199));
    
    //arcWrap(0, 0, arcRadius, arcRadius, angleStart, angleEnd); // normaly arc should work
    
    float angleArcStep = PI / 180 * 5;

    float degreesInCircle = 360;
    float beginAngleInDegrees = ((angleStart) / TWO_PI) * degreesInCircle;
    float endAngleInDegrees = (angleEnd / TWO_PI) * degreesInCircle;
    float radiansPerDegree = TWO_PI / degreesInCircle;
    int angleArcStepInDegrees = int((angleArcStep / TWO_PI) * degreesInCircle);
    
    // Draw the layer's inner arc
    h.beginShape();
    int i = 0;
    for(i = int(beginAngleInDegrees); i < int(endAngleInDegrees); i += angleArcStepInDegrees) {
      float angleInRadians = i * radiansPerDegree;
      float xx = (arcRadius - (arcWidth / 2)) * cos(angleInRadians);
      float yy = (arcRadius - (arcWidth / 2)) * sin(angleInRadians);
      h.vertex(xx, yy);
    }
    // Correct the drawing. Draw the last line "manually" if overstepped endpoint (NOTE: Removing this makes the sketch look more rough!)
    if (i > angleArcStepInDegrees) {
      i = int(endAngleInDegrees);
      float angleInRadians = i * radiansPerDegree;
      float xx = (arcRadius - (arcWidth / 2)) * cos(angleInRadians);
      float yy = (arcRadius - (arcWidth / 2)) * sin(angleInRadians);
      h.vertex(xx, yy);
    }
    
    // Draw arc boundary line connecting inner arc to outer arc
    // TODO: Optionally, draw a "rounded corner" rather than a "sharp corner". Repeat for other layer bounding line.
    float xx1, yy1;
    float xx2, yy2;
    xx1 = (arcRadius - (arcWidth / 2)) * cos(angleEnd);
    yy1 = (arcRadius - (arcWidth / 2)) * sin(angleEnd);
    xx2 = (arcRadius + (arcWidth / 2)) * cos(angleEnd);
    yy2 = (arcRadius + (arcWidth / 2)) * sin(angleEnd);
    h.line(xx1, yy1, xx2, yy2);
    
    // Draw the layer's outer arc
    for(i = int(endAngleInDegrees); i >= int(beginAngleInDegrees); i -= angleArcStepInDegrees) {
      float angleInRadians = i * radiansPerDegree;
      float xx = (arcRadius + (arcWidth / 2)) * cos(angleInRadians);
      float yy = (arcRadius + (arcWidth / 2)) * sin(angleInRadians);
      h.vertex(xx, yy);
    }
    // Correct the drawing. Draw the last line "manually" if overstepped endpoint (NOTE: Removing this makes the sketch look more rough!)
    if (i < int(beginAngleInDegrees)) {
      i = int(beginAngleInDegrees);
      float angleInRadians = i * radiansPerDegree;
      float xx = (arcRadius + (arcWidth / 2)) * cos(angleInRadians);
      float yy = (arcRadius + (arcWidth / 2)) * sin(angleInRadians);
      h.vertex(xx, yy);
    }
    
    xx1 = (arcRadius - (arcWidth / 2)) * cos(angleStart);
    yy1 = (arcRadius - (arcWidth / 2)) * sin(angleStart);
    xx2 = (arcRadius + (arcWidth / 2)) * cos(angleStart);
    yy2 = (arcRadius + (arcWidth / 2)) * sin(angleStart);
    h.line(xx1, yy1, xx2, yy2); // TODO: (Commenting out here is a hack... uncomment and fix it's drawing location)
    
    h.endShape();
    
    
//    if (enablePartialOutline) {
//      
//      if (enableStroke) {
////        stroke(this.strokeColor); // stroke(color(0, 0, 0));
//        h.setStrokeColour(this.strokeColor);
//        h.setStrokeWeight(this.strokeWeight);
//      } else {
//        noStroke();
//      }
//      
//      noFill();
//      
//      // Draw the layer's inner arc
//      h.beginShape();
//      for(i = int(beginAngleInDegrees); i < int(endAngleInDegrees); i += angleArcStepInDegrees) {
//        float angleInRadians = i * radiansPerDegree;
//        float xx = (arcRadius - (arcWidth / 2)) * cos(angleInRadians);
//        float yy = (arcRadius - (arcWidth / 2)) * sin(angleInRadians);
//        h.vertex(xx, yy);
//      }
//      
//      // Draw arc boundary line connecting inner arc to outer arc
//      // TODO: Optionally, draw a "rounded corner" rather than a "sharp corner". Repeat for other layer bounding line.
//      xx1 = (arcRadius - (arcWidth / 2)) * cos(angleEnd);
//      yy1 = (arcRadius - (arcWidth / 2)) * sin(angleEnd);
//      if (bisectDistalOutline) {
//        xx2 = (arcRadius) * cos(angleEnd);
//        yy2 = (arcRadius) * sin(angleEnd);
//      } else {
//        xx2 = (arcRadius + (arcWidth / 2)) * cos(angleEnd);
//        yy2 = (arcRadius + (arcWidth / 2)) * sin(angleEnd);
//      }
//      h.line(xx1, yy1, xx2, yy2);
//      
//      // Draw the layer's outer arc
//      if (drawOuterArc) {
//        for(int i = int(endAngleInDegrees); i >= int(beginAngleInDegrees); i -= angleArcStepInDegrees) {
//          float angleInRadians = i * radiansPerDegree;
//          float xx = (arcRadius + (arcWidth / 2)) * cos(angleInRadians);
//          float yy = (arcRadius + (arcWidth / 2)) * sin(angleInRadians);
//          h.vertex(xx, yy);
//        }
//      }
//      
//      if (drawProximalBoundaryLine) {
//        xx1 = (arcRadius - (arcWidth / 2)) * cos(angleStart);
//        yy1 = (arcRadius - (arcWidth / 2)) * sin(angleStart);
//        xx2 = (arcRadius + (arcWidth / 2)) * cos(angleStart);
//        yy2 = (arcRadius + (arcWidth / 2)) * sin(angleStart);
//        h.line(xx1, yy1, xx2, yy2);
//      }
//      
//      h.endShape();
//    }
  }

  void drawBackgroundCircle(float radius) {
  // Draw the "second arm" arc segment

//    strokeWeight(arcWidth); // strokeWeight(depthWeight * theFileScale); 

    x  = cos(angleCenter) * radius;
    y  = sin(angleCenter) * radius;
    float startX  = cos(angleStart) * radius;
    float startY  = sin(angleStart) * radius;  
    float endX  = cos(angleEnd) * radius;
    float endY  = sin(angleEnd) * radius; 
    arcLength = dist(startX, startY, endX, endY);
    float arcRadius = radius + arcWidth;
    
    //stroke(this.negativeStrokeColor); // stroke(arcStrokeColor);
//    if (this.enableStroke) {
//      stroke(this.strokeColor); // stroke(color(0, 0, 0));
//      h.setStrokeColour(color(255,255,255,255)); // this.strokeColor);
      if (enablePartialOutline) {
//        noStroke();
      } else {
        strokeWeight(this.strokeWeight);
      }
//    } else {
//      noStroke();
//    }
    h.setStrokeColour(color(255, 255, 255, 0));
    
    fill(color(60, 0, 199)); // fill(color(240, 100, 100));
    h.setFillColour(this.fillColor);
    
    //arcWrap(0, 0, arcRadius, arcRadius, angleStart, angleEnd); // normaly arc should work
    
    float angleArcStep = PI / 180 * 5;

    float degreesInCircle = 360;
    float beginAngleInDegrees = ((angleStart) / TWO_PI) * degreesInCircle;
    float endAngleInDegrees = (angleEnd / TWO_PI) * degreesInCircle;
    float radiansPerDegree = TWO_PI / degreesInCircle;
    int angleArcStepInDegrees = int((angleArcStep / TWO_PI) * degreesInCircle);
    
    // Draw the layer's inner arc
    h.beginShape();
    for(int i = int(0); i < int(360); i += angleArcStepInDegrees) {
      float angleInRadians = i * radiansPerDegree;
      float xx = (arcRadius - (arcWidth / 2)) * cos(angleInRadians);
      float yy = (arcRadius - (arcWidth / 2)) * sin(angleInRadians);
      h.vertex(xx, yy);
    }
    
    h.endShape(CLOSE);
  }
}
