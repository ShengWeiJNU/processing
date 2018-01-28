/* 力场
 * v 1.0.2
 * created by ShengWei at 2018/01/28
 * change: add force visualization.
 * press mouseLeft to open/close visualization.
 * press mouseRight to recreate field.
*/

// divide the window into rows*cols blocks.
final int rows = 20;
final int cols = 20;

// field[i*2]: x dimension of the force.
// fiels[i*2+1]: y dimension of the force.
float field[] = new float[rows*cols*2];
// force visualization as arrow.
Arrow arrows[] = new Arrow[rows*cols];
// size of the each block.
float cellW;
float cellH;
// particles array
Rect a[];

void setup(){
  size(960, 540);
  noStroke();
  colorMode(HSB);
  background(0);
  frameRate(60);

  cellW = float(width) / cols;
  cellH = float(height) / rows;
  
  createField();
  
  a = new Rect[5000];
  for(float i=0,l=a.length; i<l; i++){
    float rate = i / l;
    a[int(i)] = new Rect(10*rate*cos(rate*10*TAU), 10*rate*sin(rate*10*TAU), 3, color(random(1)*20,255,255));
    // a[int(i)] = new Rect(width/2+205*i/l*cos(i/l*100*TAU), height/2+205*i/l*sin(i/l*100*TAU), 3, color(random(1)*20,255,255));
  }
}

int ind = 0;
boolean visualizeFieldFlag = false;
void draw(){
  fill(0, 0, 0, 25);
  rect(0, 0, width, height);
  println(frameRate);
  for(int i=0,l=a.length; i<l; i++){
    // ind = 0, draw a[0] a[5] a[10] a[15] ...,
    // next loop ind=1, draw a[1] a[6] a[11] a[16] ...,
    // to reduce computation.
    //if(i%5 == ind){
      a[i].draw();
      a[i].update();
    //}
  }
  //ind +=1;
  //ind %= 5;
  
  if(visualizeFieldFlag){
    for(int i=0,l=arrows.length; i<l; i++){
      arrows[i].draw();
    }
  }
}

void mousePressed(){
  if(mouseButton == LEFT){
    visualizeFieldFlag = !visualizeFieldFlag;
  }else if(mouseButton == RIGHT){
    createField();
  }
}

// create a random force field.
void createField(){
  float r = cellW<=cellH ? cellW/2 : cellH/2;
  for(int i=0,l=field.length/2; i<l; i++){
    // create forces
    field[i*2] = random(-0.1, 0.1);
    field[i*2+1] = random(-0.1, 0.1);
    
    // create arrows
    int col = i % cols;
    int row = (i-col) / cols;
    float x1 = col*cellW + cellW/2;
    float y1 = row*cellH + cellH/2;
    float rad = atan2(field[i*2+1], field[i*2]);
    float x2 = x1 + r*cos(rad);
    float y2 = y1 + r*sin(rad);
    arrows[i] = new Arrow(x1, y1, x2, y2);
  }
}

// rect particle class
//@ param _x: posX
//@ param _y: posY
//@ param _m: mass
//@ param _color: color
class Rect{
  float x, y, vx, vy, m;
  color c;
  Rect(float _x, float _y, float _m, color _color){
    this.x = _x;
    this.y = _y;
    this.vx = 0;
    this.vy = 0;
    this.m = _m;
    this.c = _color;
  }
  void draw(){
    pushStyle();
    fill(this.c);
    rect(this.x, this.y, 3, 3);
    popStyle();
  }
  void update(){
    // get the block which particle located in,
    // calc its col∈[0, cols] and row∈[0, rows].
    int col = floor(this.x/cellW);
    int row = floor(this.y/cellH);
    // when particle is in the range of the force field, update position.
    if(col>=0 && col<cols && row>=0 && row<rows){
      // calc block index in the field, index∈[0, rows*cols-1].
      int ind = row>1 ? (row-1)*cols+col : col;
      // update particle velocity.
      this.vx += field[ind*2] / this.m;
      this.vy += field[ind*2+1] / this.m;
      // limit velocity into [0, 1].
      this.vx = abs(this.vx)>=1 ? this.vx/abs(this.vx)*1 : this.vx;
      this.vy = abs(this.vy)>=1 ? this.vy/abs(this.vy)*1 : this.vy;
      // update particle pos.
      this.x += this.vx;
      this.y += this.vy;
    }else{
      // when particle is out of the force field range, reset position.
      if(col < 0){
        this.x += width;
      }else if(col >= cols){
        this.x -= width;
      }
      
      if(row < 0){
        this.y += height;
      }else if(row >= rows){
        this.y -= height;
      }
    }     
  }
}

// force visualization arrow class
//@ param _x1: arrow start x coordinate.
//@ param _y1: arrow start y coordinate.
//@ param _x2: arrow end x coordinate.
//@ param _y2: arrow end y coordinate.
class Arrow{
  float x, y, l, rad;
  Arrow(float _x1, float _y1, float _x2, float _y2){
    this.x = _x1;
    this.y = _y1;
    this.l = dist(_x1, _y1, _x2, _y2);
    this.rad = atan2(_y2-_y1, _x2-_x1);
  }
  void draw(){
    pushMatrix();
    pushStyle();
    translate(this.x, this.y);
    rotate(this.rad);
    scale(this.l/60);
    noStroke();
    fill(255);
    beginShape();
    vertex(-7, -7);
    vertex(30, -7);
    vertex(30, -15);
    vertex(60, 0);
    vertex(30, 15);
    vertex(30, 7);
    vertex(-7, 7);
    endShape(CLOSE);
    popStyle();
    popMatrix();
  }
}