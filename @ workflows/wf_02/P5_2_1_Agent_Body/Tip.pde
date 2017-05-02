class Tip extends Vec3D {

  Body body;
  Vec3D base;
  float rad, angVis, force;
  int id, type;  // might identify different kinds of tips / connection type
  int cType; // connection type - 0: free or single connection - 1: multiple connection
  int maxConn;
  ArrayList<Tip> connections; // stores the connection points
  ArrayList<TIndex> connInd; // stores connected agent and tip id's
  boolean locked;

  Tip(Vec3D pos, Vec3D base, int id, float rad, float angvis, float force, int type, int maxConn, boolean locked) {
    super(pos);
    this.base = base; // base point where tip is connected
    this.id = id;
    this.rad = rad; // search radius
    this.angVis = angVis; // angle of vision
    this.force = force; // steering/moving force
    this.type = type; // type (for grouping or other purposes)
    this.maxConn = maxConn; // max number of connections
    connections = new ArrayList<Tip>();
    connInd = new ArrayList<TIndex>();
    this.locked = locked; // stops tip from moving
  }

  Tip(Vec3D pos, Vec3D base, int id, float rad, float angvis, float force, int maxConn) {
    //                                type         locked
    this(pos, base, id, rad, angvis, force, 0, maxConn, false);
  }


  void updateType() {
    if (connections.size() > 1) type = 1;
  }

  void cohesion() {
    if (connections.size() > 0) {
      Vec3D steer = new Vec3D();
      for (Tip tc : connections) {
        steer.addSelf(tc);
      }
      steer.scale(connections.size());
      steer.limit(force);
      this.addSelf(steer);
    }
  }

  void moveTo(Vec3D pos) {
    set(pos);
    for (Tip tc : connections) tc.set(pos);
  }

  void display() {
    strokeWeight(3);
    if (locked) {
      stroke (0); 
      strokeWeight(8);
    } else stroke(255, 121, 233);
    point(x, y, z);
  }
}

// _____________________ connections index class _____________________

class TIndex {
  int a, t;

  TIndex(int a, int t) {
    this.a=a;
    this.t=t;
  }

  String asString() {
    return a+";"+t;
  }
}