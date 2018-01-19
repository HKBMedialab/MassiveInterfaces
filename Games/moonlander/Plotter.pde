class Plotter {

  FloatList values;
  FloatList positions;

  ArrayList<PVector> PVal = new ArrayList<PVector>();
  ArrayList<PVector> peaks = new ArrayList<PVector>();
  int peaktrigger= 10;
  int minpeaktrigger=10;

  int maxlength=100;
  int stretch=3;
  int leftpadding=20;
  int rightpadding=20;
  int debugtranslateY=0;

  float average=0;
  float minVal=1000;
  float maxVal=0;




  Plotter() {
    maxlength=(width-leftpadding-rightpadding)/stretch;
    values = new FloatList();
    positions = new FloatList();
  }

  void setup() {
    maxlength=(width-leftpadding-rightpadding)/stretch;
    values = new FloatList();
  }

  void update() {

    pushMatrix();
    translate(0, debugtranslateY);
    for (int i=0; i<positions.size(); i++) {
      float position=positions.get(i);
      position=position-stretch;
      positions.set(i, position);
    }

    average=0;
    for (int i=0; i<PVal.size(); i++) {
      PVector position=PVal.get(i);
      position.x=position.x-stretch;
      PVal.set(i, new PVector(position.x, position.y));
      if (position.y<minVal)minVal=position.y;
      if (position.y>maxVal)maxVal=position.y;

      average+= position.y;
    }
    average/=PVal.size();

    for (int i=0; i<peaks.size(); i++) {
      PVector position=peaks.get(i);
      position.x=position.x-stretch;
      peaks.set(i, new PVector(position.x, position.y));
      rect(position.x, position.y, 5, 5);
      text(position.y, position.x, position.y);
    }


    // cycle
    if (values.size()>maxlength)values.remove(0);
    if (positions.size()>maxlength)positions.remove(0);
    if (PVal.size()>maxlength)PVal.remove(0);
        if (peaks.size()>maxlength)peaks.remove(0);

    
    



    popMatrix();

    // text(positions.size(), 100, 100);
  }

  void plott() {

    line(0, 0, width, 0);
    int pos=0;
    for (int i=1; i<values.size(); i++) {
      line(pos-stretch, values.get(i-1), pos, values.get(i));
      //text(int(values.get(i)),pos-10,values.get(i));
      pos+=stretch;
    }
    text(values.get(values.size()-1), pos, 0);
  }








  void plott(float _inMin, float _inMax, float _min, float _max) {
    pushMatrix();
    translate(0, debugtranslateY);
    line(0, 0, width, 0);
    for (int i=1; i<values.size(); i++) {
      PVector positionPPVal=PVal.get(i);
      PVector positionBPVal=PVal.get(i-1);
      float val1=map(positionPPVal.y, _inMin, _inMax, _min, _max);
      float val2=map(positionBPVal.y, _inMin, _inMax, _min, _max);
      line(positionPPVal.x, val1, positionBPVal.x, val2);
    }


    line(0, map(average, _inMin, _inMax, _min, _max), width, map(average, _inMin, _inMax, _min, _max));
    text("Average "+average, 0, map(average, _inMin, _inMax, _min, _max));

    stroke(50, 255, 255);
    line(0, map(minVal, _inMin, _inMax, _min, _max), width, map(minVal, _inMin, _inMax, _min, _max));
    text("min "+minVal, 0, map(minVal, _inMin, _inMax, _min, _max));

    stroke(150, 255, 255);
    line(0, map(maxVal, _inMin, _inMax, _min, _max), width, map(maxVal, _inMin, _inMax, _min, _max));
    text("max "+maxVal, 0, map(maxVal, _inMin, _inMax, _min, _max));


    pushStyle();
    stroke(100, 255, 255, 200);
    line(0, map(average, _inMin, _inMax, _min, _max)+map(peaktrigger, _inMin, _inMax, _min, _max), width, map(average, _inMin, _inMax, _min, _max)+ map(peaktrigger, _inMin, _inMax, _min, _max));
    line(0, map(average, _inMin, _inMax, _min, _max)-peaktrigger, width, map(average, _inMin, _inMax, _min, _max)-peaktrigger);
    popStyle();



    for (int i=0; i<peaks.size(); i++) {
      PVector position=peaks.get(i);
      noStroke();
      rect(position.x, position.y, 5, 5);
      text(position.y, position.x, position.y);
    }



    text(values.get(values.size()-1), positions.get(positions.size()-1), _max);
    popMatrix();
  }
  
  void plottScale() {
    pushMatrix();
    line(0, 0, width, 0);
    for (int i=1; i<values.size(); i++) {
      PVector positionPPVal=PVal.get(i);
      PVector positionBPVal=PVal.get(i-1);
      line(positionPPVal.x, positionPPVal.y, positionBPVal.x, positionBPVal.y);
    }


    line(0, average, width, average);
    text("Average "+average, 0, average);

    stroke(50, 255, 255);
    line(0, minVal, width, minVal);
    text("min "+minVal, 0,minVal);

    stroke(150, 255, 255);
    line(0, maxVal, width, maxVal);
    text("max "+maxVal, 0, maxVal);

    pushStyle();
    stroke(100, 255, 255, 200);
    line(0, average+peaktrigger, width, average+peaktrigger);
    line(0, average-peaktrigger, width, average-peaktrigger);
    popStyle();

    for (int i=0; i<peaks.size(); i++) {
      PVector position=peaks.get(i);
      noStroke();
      rect(position.x, position.y, 5, 5);
      text(position.y, position.x, position.y);
    }
    popMatrix();
  }

  void reversePlott() {
    int pos=0;
    for (int i=1; i<values.size(); i++) {
      line(pos-stretch, -values.get(i-1), pos, -values.get(i));
      pos+=stretch;
    }
  }

  void addValue(float _val) {
    if (values.size()>4) {
      float val1=values.get(values.size()-2);
      float val2=values.get(values.size()-1);
      //println("Valu2 "+_val+" average+peaktrigger "+(average+peaktrigger)+" average "+average+" peaktrigger "+peaktrigger);
      if (val2>=val1 && _val<=val2 && _val>average+peaktrigger) {
        peaks.add(new PVector(float(width-rightpadding-stretch), val2));
      }

      if (val2<val1 && _val>val2 && _val<average-peaktrigger) {
        peaks.add(new PVector(float(width-rightpadding-stretch), val2));
      }
    }
    values.append(_val);
    positions.append(width-rightpadding);
    PVal.add(new PVector(float(width-rightpadding), _val));
  }

  void removeValue(int _index) {
    values.remove(_index);
  }



  // HELPER
  void setStretch(int _stretch) {
    stretch=_stretch;
  }

  void setPadding(int _padding) {
    leftpadding=_padding;
  }
}