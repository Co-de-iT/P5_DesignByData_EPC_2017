class Tip extends Vec3D {

  Vec3D base;
  float rad, angVis, force;
  int type;  // might identify different kinds of tips / connection type
  int cType; // connection type - 0: free or single connection - 1: multiple connection
  int maxConn;
  ArrayList<Tip> connections;
  boolean locked;

  Tip(Vec3D pos, Vec3D base, float rad, float angvis, float force, int type, int maxConn, boolean locked) {
    super(pos);
    this.base = base; // base point where tip is connected
    this.rad = rad; // search radius
    this.angVis = angVis; // angle of vision
    this.force = force; // steering/moving force
    this.type = type; // type (for grouping or other purposes)
    this.maxConn = maxConn; // max number of connections
    connections = new ArrayList<Tip>();
    this.locked = locked; // stops tip from moving
  }

  Tip(Vec3D pos, Vec3D base, float rad, float angvis, float force, int maxConn) {
    //                                type         locked
    this(pos, base, rad, angvis, force, 0, maxConn, false);
  }


  void updateType() {
    if (connections.size() > 1) type = 1;
  }

  void moveTo(Vec3D pos) {
    set(pos);
    for (Tip tc : connections) tc.set(pos);
  }

  void display() {
    strokeWeight(3);
    if (locked) {stroke (0); strokeWeight(8);}
    else stroke(255, 121, 233);
    point(x, y, z);
  }
}