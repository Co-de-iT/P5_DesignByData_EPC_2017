// initialize octree
void initOctree() {
  octree = octreeFromMesh(mesh);

  //Face f = mesh.faces.get(0);
  Vertex v0 = mesh.getVertexForID(0);
  boolean initializeOctreeSampleDist=true;

  octPts = octShape(octree, color(200), 3); // stores points in a shape for faster visualization

  //initialize ocTree sample distance
  while (initializeOctreeSampleDist) {
    octreeSampleDist += octreeSampleIncrement;
    ArrayList<Vec3D> pts00 = new ArrayList <Vec3D>();
    pts00 = (ArrayList<Vec3D>) octree.getPointsWithinSphere(v0, octreeSampleDist);
    if (pts00 == null) pts00 = new ArrayList<Vec3D>();
    if (pts00.size() > 25) {
      initializeOctreeSampleDist = false;
      println("octreeSampleDist set to: " + octreeSampleDist);
    }
  }
}


// Octree creation from mesh

/*
 note on Octree:
 
 . octree must always be a cube in shape
 . pivot is the lower corner (min coordinates) and extension is the side of a cube
 . must be initialized to its maximum size from the beginning
 
 */

PointOctree octreeFromMesh(TriangleMesh mesh) {
  PointOctree octree;
  AABB bBox = mesh.getBoundingBox();
  Vec3D extent = mesh.getBoundingBox().getExtent(); // AABB diagonal vector
  // finds larger dimension
  float maxDim = extent.x>extent.y? (extent.x > extent.z? extent.x: extent.z):(extent.y > extent.z? extent.y: extent.z);

  Vec3D mPivot = bBox.getMin().add(bBox.getMax()).scale(0.5); // finds mesh pivot (the AABB center)

  Vec3D pivot = mPivot.addSelf(new Vec3D(-1, -1, -1).scaleSelf(maxDim)); // find octree pivot

  octree = new PointOctree(pivot, maxDim*2);
  // adds mesh vertices to the Octree
  for (Vertex v : mesh.vertices.values()) {
    octree.addPoint(v);
  }
  return octree;
}

// retrieve vertices

ArrayList<Vertex> getVerts(PointOctree oct, Vec3D p, float r) {

  ArrayList vs = (ArrayList) oct.getPointsWithinSphere(p, r);
  ArrayList<Vertex> verts = (ArrayList<Vertex>) vs;
  return verts;
}

// display

void octDisplay(PointOctree octree) {
  stroke(200, 0, 0);
  strokeWeight(3);
  for (Vec3D v : octree.getPoints()) {
    point(v.x, v.y, v.z);
  }
}

void octDisplay(PShape o) {
  shape(o, 0, 0);
}

// stores Octree Points in a PShape (faster display)

PShape octShape(PointOctree octree, color stroke, float weight) {

  PShape o = createShape();

  o.beginShape(POINTS);
  o.stroke(stroke);
  o.strokeWeight(weight);
  for (Vec3D v : octree.getPoints()) {
    o.vertex(v.x, v.y, v.z);
  }
  o.endShape();

  return o;
}

// toxi display methods

// this method recursively paints an entire octree structure
void drawOctree(PointOctree node, boolean doShowGrid, int col) {
  if (doShowGrid) {
    drawBox(node);
  }
  if (node.getNumChildren() > 0) {
    PointOctree[] children = node.getChildren();
    for (int i = 0; i < 8; i++) {
      if (children[i] != null) {
        drawOctree(children[i], doShowGrid, col);
      }
    }
  } else {
    java.util.List points = node.getPoints();
    if (points != null) {
      stroke(col);
      strokeWeight(5);
      beginShape(POINTS);
      int numP = points.size();
      for (int i = 0; i < numP; i += 10) {
        Vec3D p = (Vec3D)points.get(i);
        vertex(p.x, p.y, p.z);
      }
      endShape();
    }
  }
}

void drawBox(PointOctree node) {
  noFill();
  stroke(0, 24);
  strokeWeight(1);
  pushMatrix();
  translate(node.x, node.y, node.z);
  box(node.getSize());
  popMatrix();
}