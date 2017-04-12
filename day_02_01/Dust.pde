class DustPart extends Vec3D {

  int lifeSpan;
  float life, lifeRate;
  float cR = 50; // connection radius
  boolean connected;
  ArrayList<DustPart> connections;
  int maxConn;

  DustPart(Vec3D pos, int lifeSpan) {
    super(pos);// Vec3D p = new Vec3D(pos);
    this.lifeSpan = lifeSpan;
    lifeRate = 1.0/lifeSpan;
    life = 1;
    connected = false;
    connections = new ArrayList<DustPart>();
    maxConn = 3;
  }

  DustPart(Vec3D pos) {
    this(pos, 300); // this calls the more general constructor
  }

  void update(ArrayList<DustPart> dust, Vec3D world) {
    if (life >0) {
      move();
      separation(dust);
      limit(world);
      life-=lifeRate; // aging
    } else {
      if (!connected) connect(dust);
    }
    display();
    displayConnections();
  }

  void connect(ArrayList<DustPart> dust) {
    float ccR = cR*cR;
    boolean dont;
    // scan ALL THE PARTICLES
    for (DustPart d : dust) {
      // just the FROZEN ones
      if (d.life<=0) {
        // ....but not myself
        if (d != this) {
          dont=false;
          // scan ALL THE CONNECTIONS
          for (int i=0; i< d.connections.size(); i++) {
            DustPart conn = d.connections.get(i);
            if (conn == this) {
              dont=true;
              break; // gets out of the loop
            }
          } // end for connections
          if (!dont && connections.size()<maxConn) { 
            if (this.distanceToSquared(d)<ccR) connections.add(d); // add the particle
          }
        }// end if not myself
      } // end frozen only
    }// end scan all particles
    connected=true;
  } // end connect function

  void separation(ArrayList<DustPart> dust) {
    float sR = 10;
    float ssR = sR*sR;
    float sI = 0.05;
    int sC=0;
    Vec3D target = new Vec3D();

    for (DustPart oP : dust) {
      if (oP != this) {
        float dSq = this.distanceToSquared(oP);
        if (dSq < ssR) {
          target.addSelf(oP);
          sC++;
        }
      }
    } // end for loop

    if (sC >0) {

      target.scaleSelf(1.0/sC);
      Vec3D steer = this.sub(target);
      steer.normalizeTo(sI);
      this.addSelf(steer);
    }
  }

  void move() {
    this.addSelf(new Vec3D(0, 0, -1.9));
  }

  void limit(Vec3D world) {
    if (z < world.z*-0.5) z=world.z*-0.5;
  }

  void display() {
    stroke(255*life);
    strokeWeight(5);
    point(x, y, z);
  }

  void displayConnections() {
    stroke(20, 180);
    strokeWeight(1);
    for (DustPart c : connections) {
      line(x, y, z, c.x, c.y, c.z);
    }
  }
}