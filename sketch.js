// game variables
let points = [];
let sources = [];
let numPoints = 5;
let pointRadius = 20;
let sourceRadius = 40;
let logInterval = 200;
let canvasSize = 500;
let weight = 3;

// colors
const colors = {
  BLUE: 'blue',
  GREEN: 'green',
  RED: 'red',
  BLACK: 'black',
  WHITE: 'white'
};

// mechanics classes
class Vector {
  constructor(r, t) {
    this.r = r || 0;
    this.t = t || 0;
  }
  getX() {
    return this.r * Math.cos(this.t);
  }
  getY() {
    return this.r * Math.sin(this.t);
  }
  add(v) {
    let newX = this.getX() + v.getX();
    let newY = this.getY() + v.getY();
    let newR = -Util.dist(newX, newY);
    let newT = Util.ang(newX, newY);
    return new Vector(newR, newT);
  }
  draw(x, y, l) {
    x = x || width/2;
    y = y || height/2;
    l = l || 10;
    line(x, y, x+this.getX() * l, y+this.getY() * l);
  }
}
class Point {
  constructor(x, y) {
    this.setPos(x, y);
  }
  getX() {
    return this.x;
  }
  getY() {
    return this.y;
  }
  setPos(x, y) {
    this.x = x;
    this.y = y;
  }
}
class MobilePoint extends Point {
  constructor(x, y) {
    super(x, y);
    this.v = new Vector();
    this.a = new Vector();
  }
  draw() {
    stroke(colors.BLACK);
    fill(colors.BLACK);
    ellipse(this.x, this.y, pointRadius, pointRadius);
    stroke(colors.BLUE);
    this.v.draw(this.x, this.y);
    stroke(colors.RED);
    this.a.draw(this.x, this.y, 100);
  }
  updatePosition() {
    this.x += this.v.getX();
    this.y += this.v.getY();
  }
}
class GravityPoint extends MobilePoint {
  constructor(x, y, g) {
    super(x, y);
    this.g = g;
  }
  pull(sourceX, sourceY) {
    let d = Math.max(Util.dist(sourceX - this.x, sourceY - this.y), 5);
    let r = -this.g/d;
    let t = Util.ang(sourceX - this.x, sourceY - this.y);
    this.a = new Vector(r, t);
    this.v = this.v.add(this.a);
  }
}
class SourcePoint extends Point {
  constructor(x, y) {
    super(x, y);
  }
  draw() {
    fill(colors.WHITE);
    stroke(colors.RED);
    ellipse(this.x, this.y, sourceRadius, sourceRadius);
  }
}
class Util {
  static randInt(max) {
    return Math.floor(Math.random() * max);
  }
  static dist(x, y) {
    return Math.sqrt(x * x + y * y);
  }
  static ang(x, y) {
    return Math.atan(y / (x || 0.01)) + (x >= 0 ? PI : 0);
  }
  static log() {
    if(msg === null) return;
    if(typeof msg !== 'object') {
      console.log(msg);
    } else {
      console.log.apply(null, msg);
    }
  }
  static bindVar(varName, handleVarChange) {
    window.onload = () => {
      document.querySelector(`input#${varName}`).addEventListener('change', handleVarChange);
    };
  }
}
// set up logging
let msg = null;
setInterval(Util.log, logInterval);

// bind variables to inputs
Util.bindVar('numPoints', event => {
  newNumPoints = parseInt(event.target.value);
  if(newNumPoints === numPoints) {
    return;
  } else if(newNumPoints > numPoints) {
    for(let i = 0; i < newNumPoints - numPoints; i++) {
      points.push(new GravityPoint(Util.randInt(width), Util.randInt(height), 10));
    }
  } else {
    points.splice(newNumPoints);
  }
  numPoints = newNumPoints;
  document.querySelector('#numPointsSize').textContent = `(${numPoints})`;
});

// setting up
function setup() {
  let canvas = createCanvas(canvasSize, canvasSize);
  canvas.parent('canvas-container');

  for(let i = 0; i < numPoints; i++) {
    points.push(new GravityPoint(Util.randInt(width), Util.randInt(height), 10));
  }
}

// animation
function draw() {
  background(220);
  strokeWeight(weight);
  
  points.forEach(point => {
    sources.forEach(source => point.pull(source.getX(), source.getY()));
    point.updatePosition();
    point.draw();
  });

  sources.forEach(source => {
    source.draw();
  });
}

// mouse events -- source interaction
// on click and drag move source point
let activeSource = null;
let isMouseDragged = false;
let isNewPoint = false;
function mousePressed() {
  // if outside range ignore
  if(mouseY > height || mouseY < 0 || mouseX > width || mouseX < 0) return;

  // some like forEach but short-circuits
  sources.some((source, index) => {
    if(Util.dist(source.getX() - mouseX, source.getY() - mouseY) < sourceRadius) {
      activeSource = index;
      return;
    }
  });

  if(activeSource === null) {
    // if no matching found source, add source
    sources.push(new SourcePoint(mouseX, mouseY));
    activeSource = sources.length - 1;
    isNewPoint = true;
  }
}

// on drag move active source
function mouseDragged() {
  // if dragged outside the box ignore
  if(activeSource === null) return;

  isMouseDragged = true;
  sources[activeSource].setPos(mouseX, mouseY);
}

// on click add source point
function mouseReleased() {
  // if dragged outside the box ignore
  if(activeSource === null) return;

  // if clicked on element and not newly created but no drag delete
  if(!isMouseDragged && !isNewPoint) {
    sources.splice(activeSource, 1);
  }

  // reset variables
  activeSource = null;
  isMouseDragged = false;
  isNewPoint = false;
}
