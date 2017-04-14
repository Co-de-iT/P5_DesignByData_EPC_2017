class Body {

  int type;
  Vec3D core;
  Vec3D forward;
  Tip[] tips;
  boolean locked;

  float tipRad=10;
  float angVis = PI*0.5;

  // custom body constructors
  Body (Tip[] tips, int type) {
    this.tips = tips;
    this.type = type;
    locked = false;
    //build(tips);
  }

  Body(Tip[] tips) {
    this(tips, -1); // -1 identifies custom type unless another number is provided
  }

  // default body constructors
  Body(int type) {
    this.type = type;
    build(type);
    locked = false;
  }

  Body() {
    this(0);
  }

  void scale(float sf) {
    for (Tip t : tips) {
      t.subSelf(core).scaleSelf(sf).addSelf(core);
    }
  }

  void build(int type) {
    Vec3D pos;
    switch (type) {
    case 0:
      // tri-fork asymmetrical shape
      core = new Vec3D();
      forward = new Vec3D(0, 0, 1);
      tips = new Tip[4];
      pos = new Vec3D(20, 0, 0).rotateZ(PI*0.4);
      tips[0] = new Tip(pos, new Vec3D(), tipRad, angVis, 0.01, 3); // because base is (0,0,0)
      pos = new Vec3D(18, 0, 0).rotateZ(PI*0.7);
      tips[1] = new Tip(pos, new Vec3D(), tipRad, angVis, 0.01, 3);
      pos = new Vec3D(15, 0, 0).rotateZ(PI*1.6);
      tips[2] = new Tip(pos, new Vec3D(), tipRad, angVis, 0.01, 3);
      pos = new Vec3D(0, 0, -10);
      tips[3] = new Tip(pos, new Vec3D(), tipRad, angVis, 0.01, 3);
      scale(1.5);
      break; 

    case 1 : 
      // quad cross
      core = new Vec3D();
      forward = new Vec3D(0, 0, 1);
      tips = new Tip[4];
      pos = new Vec3D(10, 0, -3).rotateZ(PI*0.4);
      tips[0] = new Tip(pos, new Vec3D(), tipRad, angVis, 0.01, 3);
      pos = new Vec3D(13, 0, 0).rotateZ(PI*0.7);
      tips[1] = new Tip(pos, new Vec3D(), tipRad, angVis, 0.01, 3);
      pos = new Vec3D(15, 0, 4).rotateZ(PI*1.25);
      tips[2] = new Tip(pos, new Vec3D(), tipRad, angVis, 0.01, 3);
      pos = new Vec3D(15, 0, 0).rotateZ(PI*1.7);
      tips[3] = new Tip(pos, new Vec3D(), tipRad, angVis, 0.01, 3);

      break;
    case 2:
      // tripod
      core = new Vec3D();
      forward = new Vec3D(0, 0, 1);
      tips = new Tip[3];
      pos = new Vec3D(10, 0, 0);
      tips[0] = new Tip(pos, new Vec3D(), tipRad, angVis, 0.01, 3); // because base is (0,0,0)
      pos = new Vec3D(0, 10, 0);
      tips[1] = new Tip(pos, new Vec3D(), tipRad, angVis, 0.01, 3);
      pos = new Vec3D(0, 0, 10);
      tips[2] = new Tip(pos, new Vec3D(), tipRad, angVis, 0.01, 3);
      break;
    }
  }

  void update() {
    // if the body has autonomous functions for update
  }
}