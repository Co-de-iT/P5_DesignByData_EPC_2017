import toxi.geom.*;
import peasy.*;

PeasyCam cam;
Particle[] dots;
Particle p;
Vec3D po, ve;
Vec3D world = new Vec3D(600,600,300);
ArrayList<DustPart> dust; // flagged ArrayList
int nParts = 200;

void setup() {
  size(800, 800, P3D); // width, height, rendering engine
  
  cam = new PeasyCam(this,500);
  
  dots = new Particle[nParts];
  
  // i=i+1; i+= 1; i++;
  for (int i= 0; i< dots.length; i++) {
    po = new Vec3D();
    ve = new Vec3D(random(-1, 1), random(-1, 1),
    random(-1, 1));
    dots[i] = new Particle(po, ve, world,int(random(50,200)));
  }
  
  dust = new ArrayList<DustPart>();
}

void draw() {
  background(255,199,236);
  
  // particles
  for (Particle p : dots) {
     p.move();
     p.bounce();
     p.deposit(dust);
     p.display();
  }
  
  // dust
  for(DustPart d : dust){
    d.update(dust, world);
  }
  
  //for(int i=dust.size()-1; i>=0; i--){
  //  DustPart d = dust.get(i);
  //  if(d.life <= 0) dust.remove(i);
  //}
  
  stroke(0);
  strokeWeight(1);
  noFill();
  box(world.x,world.y,world.z);
  //rect(0,0,width, height);
  
  cam.beginHUD();
  fill(0);
  text("dust particles: "+dust.size(),10,20);
  text(frameCount, 10,40);
  cam.endHUD();
}