class Particle {
  // fields
  Vec3D pos;
  Vec3D vel;

  // constructor
  Particle(Vec3D myPos, Vec3D myVel) {
    pos = myPos;
    vel = myVel;
  }
  
  // methods - functions - behaviors
  void move(){
    pos.addSelf(vel);
  }
  
  void display(){
    pushStyle(); // 
    strokeWeight(5);
    stroke(255,0,0);
    point(pos.x, pos.y, pos.z);
    popStyle();
  }
}