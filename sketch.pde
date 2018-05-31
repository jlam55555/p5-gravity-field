// game variables
int numPoints = 5;
int pointRadius = 20;
int sourceRadius = 40;
int logInterval = 200;
int weight = 3;

// colors
HashMap<String, Integer> colors = new HashMap<String, Integer>();

// mechanics classes
class Vector {
  private double r;
  private double t;
  Vector(double r, double t) {
    this.r = r;
    this.t = t;
  }
  double getX() {
    return this.r * Math.cos(this.t);
  }
  double getY() {
    return this.r * Math.sin(this.t);
  }
  Vector add(Vector v) {
    double newX = this.getX() + v.getX();
    double newY = this.getY() + v.getY();
    double newR = -Util.dist(newX, newY);
    double newT = Util.ang(newX, newY);
    return new Vector(newR, newT);
  }
  void draw(double x, double y, double l) {
    line((float) x, (float) y, (float) (x+this.getX() * l), (float) (y+this.getY() * l));
  }
}
class Point {
  private double x;
  private double y;
  Point(double x, double y) {
    this.setPos(x, y);
  }
  double getX() {
    return this.x;
  }
  double getY() {
    return this.y;
  }
  void setPos(double x, double y) {
    this.x = x;
    this.y = y;
  }
  
  // dummy functions
  void draw() {}
  void updatePosition() {}
  void pull(double x, double y) {}
}
class MobilePoint extends Point {
  private Vector v;
  private Vector a;
  MobilePoint(double x, double y) {
    super(x, y);
    this.v = new Vector(0, 0);
    this.a = new Vector(0, 0);
  }
  void draw() {
    stroke(colors.get("black"));
    fill(colors.get("black"));
    ellipse((float) this.getX(), (float) this.getY(), pointRadius, pointRadius);
    stroke(colors.get("blue"));
    this.v.draw(this.getX(), this.getY(), 10);
    stroke(colors.get("red"));
    this.a.draw(this.getX(), this.getY(), 100);
  }
  void updatePosition() {
    this.setPos(this.getX() + this.v.getX(), this.getY() + this.v.getY());
  }
  void setA(Vector a) {
    this.a = a;
  }
  void setV(Vector v) {
    this.v = v;
  }
  Vector getA() {
    return this.a;
  }
  Vector getV() {
    return this.v;
  }
}
class GravityPoint extends MobilePoint {
  private double g;
  GravityPoint(double x, double y, double g) {
    super(x, y);
    this.g = g;
  }
  void pull(double sourceX, double sourceY) {
    double d = Math.max(Util.dist(sourceX - this.getX(), sourceY - this.getY()), 5);
    double r = -this.g/d;
    double t = Util.ang(sourceX - this.getX(), sourceY - this.getY());
    this.setA(new Vector(r, t));
    this.setV(this.getV().add(this.getA()));
  }
}
class SourcePoint extends Point {
  SourcePoint(double x, double y) {
    super(x, y);
  }
  void draw() {
    fill(colors.get("white"));
    stroke(colors.get("red"));
    ellipse((float) this.getX(), (float) this.getY(), sourceRadius, sourceRadius);
  }
}
class UtilStatic {
  int randInt(int max) {
    return (int) Math.floor(Math.random() * max);
  }
  double dist(double x, double y) {
    return Math.sqrt(x * x + y * y);
  }
  double ang(double x, double y) {
    return Math.atan(y / x) + (x >= 0 ? PI : 0);
  }
  void log() {
    println(msg);
  }
}
// set up logging
String msg = null;
UtilStatic Util = new UtilStatic();
//setInterval(Util.log, logInterval);

// setting up
void setup() {
  // create canvas
  size(400, 400);

  // create points
  for(int i = 0; i < numPoints; i++) {
    points.add(new GravityPoint(Util.randInt(width), Util.randInt(height), 10));
  }
  
  // set colors
  colors.put("blue", 0xff0000ff);
  colors.put("green", 0xff00ff00);
  colors.put("red", 0xffff0000);
  colors.put("black", 0xff000000);
  colors.put("white", 0xffffffff);
}

// animation
void draw() {
  background(220);
  strokeWeight(weight);
  
  for(int i = 0; i < points.size(); i++) {
    for(int j = 0; j < sources.size(); j++) {
      points.get(i).pull(sources.get(j).getX(), sources.get(j).getY());
    }
    points.get(i).updatePosition();
    points.get(i).draw();
  }

  for(int i = 0; i < sources.size(); i++) {
    sources.get(i).draw();
  }
}

// mouse events -- source interaction
// on click and drag move source point
Integer activeSource = null;
boolean isMouseDragged = false;
boolean isNewPoint = false;
void mousePressed() {
  // if outside range ignore
  if(mouseY > height || mouseY < 0 || mouseX > width || mouseX < 0) return;

  // some like forEach but short-circuits
  for(int i = 0; i < sources.size(); i++) {
    if(Util.dist(sources.get(i).getX() - mouseX, sources.get(i).getY() - mouseY) < sourceRadius) {
      activeSource = i;
      return;
    }
  }

  if(activeSource == null) {
    // if no matching found source, add source
    sources.add(new SourcePoint(mouseX, mouseY));
    activeSource = sources.size() - 1;
    isNewPoint = true;
  }
}

// on drag move active source
void mouseDragged() {
  // if dragged outside the box ignore
  if(activeSource == null) return;

  isMouseDragged = true;
  sources.get(activeSource).setPos(mouseX, mouseY);
}

// on click add source point
void mouseReleased() {
  // if dragged outside the box ignore
  if(activeSource == null) return;

  // if clicked on element and not newly created but no drag delete
  if(!isMouseDragged && !isNewPoint) {
    sources.remove(activeSource);
  }

  // reset variabless
  activeSource = null;
  isMouseDragged = false;
  isNewPoint = false;
}

// lists of points
ArrayList<Point> points = new ArrayList<Point>();
ArrayList<Point> sources = new ArrayList<Point>();
