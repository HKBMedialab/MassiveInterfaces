class Plotter {

  FloatList values;
  FloatList positions;

  ArrayList<PVector> PVal = new ArrayList<PVector>();
  ArrayList<PVector> peaks = new ArrayList<PVector>();
  int peaktrigger= 5;
  int minpeaktrigger=-5;

  int maxlength=100;
  int stretch=3;
  int leftpadding=20;
  int rightpadding=20;
  int debugtranslateY=50;

  Plotter() {
    maxlength=(width-leftpadding-rightpadding)/stretch;
    values = new FloatList();
    positions = new FloatList();
  }

  Plotter(int _peaktrigger, int _minpeaktrigger) {
    peaktrigger=_peaktrigger;
    minpeaktrigger=_minpeaktrigger;
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
    // translate(0, debugtranslateY);
    for (int i=0; i<positions.size(); i++) {
      float position=positions.get(i);
      position=position+stretch;
      positions.set(i, position);
    }

    for (int i=0; i<PVal.size(); i++) {
      PVector position=PVal.get(i);
      position.x=position.x+stretch;
      PVal.set(i, new PVector(position.x, position.y));
    }
    /*
    for (int i=0; i<peaks.size(); i++) {
     PVector position=peaks.get(i);
     position.x=position.x-stretch;
     peaks.set(i, new PVector(position.x, position.y));
     rect(position.x, position.y, 5, 5);
     text(position.y, position.x, position.y);
     }
     */

    // cycle
    if (values.size()>maxlength)values.remove(0);
    if (positions.size()>maxlength)positions.remove(0);
    if (positions.size()>maxlength)positions.remove(0);
    if (PVal.size()>maxlength)PVal.remove(0);


    pushStyle();
    stroke(255, 0, 0);
    //line(0, peaktrigger, width, peaktrigger);
    //line(0, minpeaktrigger, width, minpeaktrigger);

    popStyle();
    popMatrix();

    // text(positions.size(), 100, 100);
  }

  void plott() {

    line(0, 0, width, 0);
    int pos=0;
    for (int i=1; i<values.size(); i++) {
      line(pos-stretch, values.get(i-1), pos, values.get(i));
      pos+=stretch;
    }
    text(values.get(values.size()-1), pos, 0);
  }



  void plott(float _inMin, float _inMax, float _min, float _max) {
    pushMatrix();
    //translate(0, debugtranslateY);
    line(0, 0, width, 0);
    int pos=0;
    for (int i=1; i<values.size(); i++) {
      float position=positions.get(i);
      float positionB=positions.get(i-1);

      PVector positionPPVal=PVal.get(i);
      PVector positionBPVal=PVal.get(i-1);

      float val=map(positionBPVal.y, _inMin, _inMax, _min, _max);
      float val2=map(positionPPVal.y, _inMin, _inMax, _min, _max);
      fill(255);
      stroke(255);
      line(positionPPVal.x, val2, positionBPVal.x, val);
      pos+=stretch;
    }

    for (int i=0; i<peaks.size(); i++) {
      PVector position=peaks.get(i);
      position.x=position.x+stretch;
      peaks.set(i, new PVector(position.x, position.y));
      float peakY=map(position.y, _inMin, _inMax, _min, _max);
      rect(position.x, peakY, 5, 5);
      fill(255);
      text(position.y, position.x, peakY);
    }

    float peakTY=map(peaktrigger, _inMin, _inMax, _min, _max);
    float minpeakTY=map(minpeaktrigger, _inMin, _inMax, _min, _max);
    
      //  float peakTY=map(peaktrigger, _inMin, _inMax, _min, _max);

    line(0, peakTY, width, peakTY);
    line(0, minpeakTY, width, minpeakTY);
    fill(255);
    text(values.get(values.size()-1), positions.get(positions.size()-1), _max);
    popMatrix();
  }
  
  
  void plottReverse(float _inMin, float _inMax, float _min, float _max) {
    pushMatrix();
    //translate(0, debugtranslateY);
    line(0, 0, width, 0);
    int pos=0;
    for (int i=1; i<values.size(); i++) {
      float position=positions.get(i);
      float positionB=positions.get(i-1);

      PVector positionPPVal=PVal.get(i);
      PVector positionBPVal=PVal.get(i-1);

      float val=map(positionBPVal.y, _inMin, _inMax, _min, _max);
      float val2=map(positionPPVal.y, _inMin, _inMax, _min, _max);
      fill(255);
      stroke(255);
      line(positionPPVal.x, val2, positionBPVal.x, val);
      pos+=stretch;
    }

    for (int i=0; i<peaks.size(); i++) {
      PVector position=peaks.get(i);
      position.x=position.x-stretch;
      peaks.set(i, new PVector(position.x, position.y));
      float peakY=map(position.y, _inMin, _inMax, _min, _max);
      rect(position.x, peakY, 5, 5);
      fill(255);
      text(position.y, position.x, peakY);
    }

    float peakTY=map(peaktrigger, _inMin, _inMax, _min, _max);
    float minpeakTY=map(minpeaktrigger, _inMin, _inMax, _min, _max);
    
      //  float peakTY=map(peaktrigger, _inMin, _inMax, _min, _max);

    line(0, peakTY, width, peakTY);
    line(0, minpeakTY, width, minpeakTY);
    fill(255);
    text(values.get(values.size()-1), positions.get(positions.size()-1), _max);
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
    if (values.size()>2) {
      float val1=values.get(values.size()-2);
      float val2=values.get(values.size()-1);

      if (val2>val1 && _val<val2 && val2>peaktrigger) {
       // peaks.add(new PVector(float(width-rightpadding+stretch), val2));
                peaks.add(new PVector(float(rightpadding+stretch), val2));

      }

      if (val2<val1 && _val>val2 && val2<minpeaktrigger) {
      //  peaks.add(new PVector(float(width-rightpadding+stretch), val2));
                peaks.add(new PVector(float(rightpadding+stretch), val2));

      }
    }
    values.append(_val);
   // positions.append(width-rightpadding);
   // PVal.add(new PVector(float(width-rightpadding), _val));
       positions.append(rightpadding);
    PVal.add(new PVector(float(rightpadding), _val));

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