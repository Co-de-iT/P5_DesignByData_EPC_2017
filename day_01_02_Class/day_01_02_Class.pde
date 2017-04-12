import toxi.geom.*;
import peasy.*;

PeasyCam cam;
Particle[] dots;
Particle p;
Vec3D po, ve;
int nParts = 1000;

void setup() {
  size(800, 800, P3D); // width, height, rendering engine
  
  cam = new PeasyCam(this,500);
  
  dots = new Particle[nParts];
  
  // i=i+1; i+= 1; i++;
  for (int i= 0; i< dots.length; i++) {
    po = new Vec3D(width*0.5, height*0.5, 0);
    ve = new Vec3D(random(-1, 1), random(-1, 1), 0);
    dots[i] = new Particle(po, ve);
  }
}

void draw() {
  background(220);
  for (Particle p : dots) {
     p.move();
     p.display();
  }
  noFill();
  box(600,600,300);
  rect(0,0,width, height);
}