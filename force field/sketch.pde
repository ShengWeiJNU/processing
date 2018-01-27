/* 力场
 * created by ShengWei at 2018/01/26
 * In a field full of random force, show the paths of particles
*/

// divide the window into rows*cols blocks.
final int rows = 20;
final int cols = 20;

// field[i*2]: x dimension of the force.
// fiels[i*2+1]: y dimension of the force.
float field[] = new float[rows*cols*2];
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
void draw(){
  fill(0, 0, 0, 25);
  rect(0, 0, width, height);
  println(frameRate);
  for(int i=0,l=a.length; i<l; i++){
    // draw a[0] a[5] a[10] a[15] ...,
    // next loop draw a[1] a[6] a[11] a[16] ...,
    // to reduce computation.
    //if(i%5 == ind){
      a[i].draw();
      a[i].update();
    //}
  }
  //ind +=1;
  //ind %= 5;
}

void mousePressed(){
  createField();
  println(field);
}

// create a random force field.
void createField(){
  for(int i=0,l=field.length/2; i<l; i++){
    field[i*2] = random(-0.1, 0.1);
    field[i*2+1] = random(-0.1, 0.1);
  }
}

// rect particle class
//@ param x: posX
//@ param y: posY
//@ param m: mass
//@ param c: color
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
    rect(this.x, this.y, 2, 2);
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