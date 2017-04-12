class Strand {
  ArrayList <StrandPoint> points;
  ArrayList<Line3D> lines;
  int size;
  boolean done;
  
  Strand(int size) {
    points = new ArrayList <StrandPoint>();
    lines = new ArrayList<Line3D>();
    this.size = size;
    done = false;
  }
  
  Strand() {
    this(10);
  }

  void addPoint(StrandPoint p) {
    if (points.size()<size) {
      points.add(p);
      int pC = points.size();
      if (pC > 1 && pC <= size) {

        StrandPoint p1 = points.get(pC-1);
        StrandPoint p2 = points.get(pC-2);
        lines.add(new Line3D(p1, p2));
      }
      done = (pC == size);
    }
  }

  void display() {
    noFill();
    stroke(255);
    strokeWeight(1);
    for (Line3D l : lines) {
      //Line3D l =  lines.get(i);
      //stroke((255/lines.size()) * i);

      line(l.a.x, l.a.y, l.a.z, l.b.x, l.b.y, l.b.z);
    }
    strokeWeight(3);
    for (StrandPoint p : points) {
      point(p.x, p.y, p.z);
    }
  }
}


// __________________ strand point

class StrandPoint extends Vec3D {

  Strand strand;
  int id;

  StrandPoint(Vec3D pos, Strand strand, int id) {
    super(pos);
    this.strand = strand;
    this.id = id;
  }
}