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