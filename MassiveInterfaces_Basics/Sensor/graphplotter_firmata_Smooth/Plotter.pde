/*
HKB Massive Interfaces Graphplotter
 Created by Michael Flueckiger
 
 Diese Plotterklasse kann gebraucht werden um z.B Sensordaten zu visualisieren. 
 Einfach das File in den betreffenden Projektordner kopieren.

 Variable deklarieren:
 Plotter meinPlotter;
 
 Variable instanzieren, z.B in setup():
 meinPlotter=new Plotter();
 
 (Sensor-) daten zum Plott hinzufügen, z.B in draw():
 float sensordata = arduino.analogRead(0);
 meinPlotter.addValue(sensordata);
 
 Den Graph zeichnen:
 meinPlotter.plott();
 
 Alternative, um die Höhe der Kurve besser kontrollieren zu können:
 meinPlotter.plott(0, 1023, 0, plottHeight);  (minimaler Input, maximaler Input, minimaler Output, maximaler Output)
 -> Der Sensor wird einen Wert zwischen 0 und 1023 liefern. minimaler Output, maximaler Output geben dabei an, wie hoch die Kurve gezeichnet werden soll
 
 */


class Plotter {

  FloatList values;
  int maxlength=100;
  int stretch=3;
  int padding=20;

  Plotter() {
    maxlength=(width-padding)/stretch;
    values = new FloatList();
  }

  void setup() {
    maxlength=(width-padding)/stretch;
    values = new FloatList();
  }

  void update() {
    // cycle
    if (values.size()>maxlength)values.remove(0);
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

    line(0, 0, width, 0);
    int pos=0;
    for (int i=1; i<values.size(); i++) {
      float val=map(values.get(i-1), _inMin, _inMax, _min, _max);
      float val2=map(values.get(i), _inMin, _inMax, _min, _max);
      line(pos-stretch, val, pos, val2);
      //text(int(values.get(i)),pos-10,values.get(i));
      pos+=stretch;
    }
    text(values.get(values.size()-1), pos, _max);
  }

  void reversePlott() {
    int pos=0;
    for (int i=1; i<values.size(); i++) {
      line(pos-stretch, -values.get(i-1), pos, -values.get(i));
      pos+=stretch;
    }
  }

  void addValue(float _val) {
    values.append(_val);
  }

  void removeValue(int _index) {
    values.remove(_index);
  }

  // HELPER
  void setStretch(int _stretch) {
    stretch=_stretch;
  }

  void setPadding(int _padding) {
    padding=_padding;
  }
}