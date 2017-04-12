PVector p1;
PVector p2; // variable declaration <- oh, btw this is a one line comment
PVector speed;
int i; // integer numbers
float f; // floating point numbers
boolean b; // 

int w = 800; // w <- 800
int h = 800;

void setup(){
size(800,800, P3D);
p1 = new PVector(100,100,0); // instantiation
speed = new PVector(5,0,0);
}

void draw(){
  background(255);
  p2 = new PVector(mouseX, mouseY,0);
  myLine(p1, p2);
  //p1.x = p1.x+1;
  p1.add(speed);
  if(p1.x<0 || p1.x >800){ // && AND || OR ! NOT
  //p1.x = 0;
  speed.x = speed.x*-1;
  }
  //line(100,100,0,mouseX,mouseY,0);
}


void myLine(PVector a, PVector b){
  line(a.x,a.y,a.z,b.x,b.y,b.z);
}