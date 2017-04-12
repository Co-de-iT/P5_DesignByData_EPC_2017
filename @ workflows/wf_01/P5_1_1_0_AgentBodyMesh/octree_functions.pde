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

PointOctree octreeFromMesh(Vec3D pivot, Vec3D extent, TriangleMesh mesh) {
  PointOctree octree;

  octree = new PointOctree(pivot, 1);  // centers octree in mesh bounding box
  octree.setExtent(extent); // scales to extent vector

  for (Vertex v : mesh.vertices.values()) {
    octree.addPoint(v);
  }
  return octree;
}

PointOctree octreeFromMesh(TriangleMesh mesh) {
  PointOctree octree;
  AABB bBox = mesh.getBoundingBox();
  Vec3D extent = mesh.getBoundingBox().getExtent(); // AABB diagonal vector
  Vec3D pivot = bBox.getMin().add(bBox.getMax()).scale(0.5); // finds mesh pivot (the AABB center)
  octree = octreeFromMesh(pivot, extent, mesh);
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