class Attractor {
  Vec3D pos;
  PShape rad;
  float radius, charge, rr;
  color col;

  Attractor(Vec3D pos, float radius, float charge, color col) {
    this.pos = pos;
    this.radius = radius;
    this.charge = charge;
    this.col = col;
    rr = radius*radius;
    rad=createShape();
    rad.beginShape(POINTS);
    rad.strokeWeight(2);
    rad.stroke(col);
    float ang=0;
    for (int i=0; i<50; i++) {
      ang = TWO_PI*i/50.0;
      rad.vertex(cos(ang)*radius, sin(ang)*radius, 0);
    }
    rad.endShape();
  }

  Attractor(Vec3D pos, float radius, float charge) {
    this (pos, radius, charge, charge>0?color(255, 0, 0): color(0, 255, 0));
  }

  void display() {
    stroke(col);
    strokeWeight(5);
    point(pos.x, pos.y, pos.z);
  }

  void displayRad() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    stroke(col);
    strokeWeight(1);
    noFill();
    shape(rad);
    popMatrix();
  }
}