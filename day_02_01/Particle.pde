class Particle {
  // fields
  int dropRate;
  Vec3D pos;
  Vec3D vel;
  Vec3D world;

  // constructor
  Particle(Vec3D myPos, Vec3D myVel, Vec3D world, int dropRate) {
    pos = myPos;
    vel = myVel;
    this.world = world; // global = local
    this.dropRate = dropRate;
  }
  
  // methods - functions - behaviors
  void move(){
    pos.addSelf(vel);
  }
  
  void bounce(){
    if(pos.x < world.x*-0.5 || pos.x > world.x*0.5) vel.x *= -1; // += *= /= -=
    if(pos.y < world.y*-0.5 || pos.y > world.y*0.5) vel.y *= -1;
    if(pos.z < world.z*-0.5 || pos.z > world.z*0.5) vel.z *= -1;
  }
  
  void deposit(ArrayList<DustPart> dust){
    if(frameCount%dropRate == 0) 
    dust.add(new DustPart(pos,int(random(100,1000)))); // invent more conditions
  }
  
  void display(){
    pushStyle(); // 
    strokeWeight(2);
    stroke(255,0,0);
    point(pos.x, pos.y, pos.z);
    popStyle();
  }
}