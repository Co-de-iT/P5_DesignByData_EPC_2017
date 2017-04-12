/*

 Code by Alessio Erioli
 
 (c) Co-de-iT 2017
 
 an extension to the TriangleMesh class with topology functions implemented
 
 . neighbor vertices from a given vertex or vertex id
 . indexes of faces shared by a vertex
 
 also, some extra functions to ease the loading from file process:
 
 . a constructor where the only thing to supply is the fileName string
 NOTE: fileName must include extension
 Mesh files MUST be in STL format
 
 remember to use import java.util.*; in main context
 
 
 */


class AEMesh extends TriangleMesh {

  final int STL = 0;
  final int PLY = 1;
  HashMap<Integer, HashSet<Integer>> vTopo;
  HashMap<Integer, HashSet<Integer>> vfTopo;
  HashMap<Integer, Long> vCol;
  color[] vCols;
  PShape cMesh;
  TensorPt[] tgField;
  // int[]indexMap;
  String vColFileName;

  AEMesh() {
    super();
    vTopo = new HashMap<Integer, HashSet<Integer>>();
    vfTopo = new HashMap<Integer, HashSet<Integer>>();
  }

  AEMesh(String fileName) {
    this();

    String fileType = fileName.substring(fileName.length()-3, fileName.length());
    vColFileName = split(fileName, ".")[0]+"_vCols.txt";

    if (fileType.equals("stl") || fileType.equals("STL")) {

      importSTLMesh(fileName); // imports mesh

      computeVertexTopo();  // builds connected vertex topology
      computeVertexFaceTopo(); // builds connected faces to vertex topology

      // indexMap = new int[vertices.size()]; // just for verification (delete in the final)

      vCols = new color[vertices.size()]; // inits color table
      tgField = new TensorPt[vertices.size()]; // inits tangent field
      buildColorTable(vColFileName); // builds color table from file
      //buildColorTable();
      //buildTgField(); // builds tangent field
      //buildtgNoiseField(1, 0.05);
      colorMesh(); // generate colored mesh PShape
    } else println("non-stl files still not implemented");
  }

  //
  // ______________________ simplified import method ______________________
  //

  void importSTLMesh(String fileName) {
    addMesh(new STLReader().loadBinary(dataPath(fileName), STLReader.TRIANGLEMESH));
  }

  void buildTgField() {
    int count = 0;
    for (Vertex v : vertices.values()) {
      Vec3D n =v.normal;
      tgField[count] = new TensorPt(v, n.cross(Vec3D.Z_AXIS).normalize(),0);
      count++;
    }
  }
  
  void buildTgField(Vec3D[] vecs){
    int count = 0;
    for (Vertex v : vertices.values()) {
      Vec3D n =v.normal;
      tgField[count] = new TensorPt(v,vecs[count],0);
      count++;
    }
  }

  void buildtgNoiseField(int nd, float ns) {
    int count = 0;
    float ang;
    noiseDetail(nd);
    for (Vertex v : vertices.values()) {
      Vec3D n =v.normal;
      ang = map(noise(v.x*ns, v.y*ns, v.z*ns), 0, 1, -PI, PI);
      tgField[count] = new TensorPt(v,n.cross(Vec3D.Z_AXIS).normalize(),0);
      tgField[count].rotateAroundAxis(n, ang);
      tgField[count].normalize();
      count++;
    }
  }

  //
  // ______________________ color table methods ______________________
  //

  void buildColorTable(String vColFileName) {
    if (fileExists(dataPath(vColFileName))) {
      print("loading color table from file....");
      String[] lines = loadStrings(dataPath(vColFileName));
      if (lines.length == vertices.size()) { // if lines are same length of vertices (welded mesh) load color directly
        vCols = int(loadStrings(dataPath(vColFileName)));
      } else { // else look for closest vertex and assign color
        int ind;
        Vec3D p;
        for (int i=0; i< lines.length; i++) {
          String[] ptCol = split(lines[i], '_');
          String[] pt = split(ptCol[0], ',');
          p = new Vec3D(float(pt[0]), float(pt[1]), float(pt[2]));
          ind = getClosestVertexToPoint(p).id;
          // if (i<vertices.size()) indexMap[i]=ind;
          vCols[ind] = int(ptCol[1]);
          println(ind + " " + i);
        }
      }

      //vCols = int(loadStrings(dataPath(vColFileName)));
      println("done");
    } else {
      // if there is no color table file, color all vertices white
      for (int i=0; i< vCols.length; i++) {
        vCols[i] = color(255);
      }
    }
  }

  // build color table from external array
  void buildColorTable(color[] cols) {
    if (cols.length == vertices.size()) {
      for (int i=0; i< vCols.length; i++) {
        vCols[i] = cols[i];
      }
    } else return;
  }

  // builds a default color table based on noise
  void buildColorTable() {
    float n, ns = 0.1;
    noiseDetail(1);
    for (Vertex v : vertices.values()) {
      n = noise(v.x*ns, v.y*ns, v.z*ns);
      vCols[v.id] = color(map(n, 0.2, 0.7, 0, 255));
    }
  }

  boolean fileExists(String fName) {
    File f = new File(fName);
    return (f.exists()? true: false);
  }

  color getClosestColorToPoint(Vec3D p) {
    return vCols[getClosestVertexToPoint(p).id];
  }


  //
  // ______________________ mesh topology methods ______________________
  //

  void computeVertexTopo() {
    // vertex neighbors

    // create empty map
    for (int i=0; i<vertices.size(); i++) {
      HashSet<Integer> empty = new HashSet<Integer>();
      vTopo.put(i, empty);
    }

    for (Face f : faces) {
      // add connections for vertex a
      HashSet<Integer> a = vTopo.get(f.a.id);
      a.add(f.b.id);
      a.add(f.c.id);
      vTopo.put(f.a.id, a);
      // add connections for vertex b
      HashSet<Integer> b = vTopo.get(f.b.id);
      b.add(f.a.id);
      b.add(f.c.id);
      vTopo.put(f.b.id, b);
      // add connections for vertex c
      HashSet<Integer> c = vTopo.get(f.c.id);
      c.add(f.a.id);
      c.add(f.b.id);
      vTopo.put(f.c.id, c);
    }
  }

  void computeVertexFaceTopo() {
    // faces connected to each vertex

    // create empty map
    for (int i=0; i<vertices.size(); i++) {
      HashSet<Integer> empty = new HashSet<Integer>();
      vfTopo.put(i, empty);
    }
    Face f;
    for (int i=0; i< faces.size(); i++) {
      f = faces.get(i);
      // add connections for vertex a
      HashSet<Integer> a = vfTopo.get(f.a.id);
      a.add(i);
      vfTopo.put(f.a.id, a);
      // add connections for vertex b
      HashSet<Integer> b = vfTopo.get(f.b.id);
      b.add(i);
      vfTopo.put(f.b.id, b);
      // add connections for vertex c
      HashSet<Integer> c = vfTopo.get(f.c.id);
      c.add(i);
      vfTopo.put(f.c.id, c);
    }
  }

  // export topology as int[][] array
  int[][] getVertexTopologyAsArray() {
    int n = vertices.size();
    int[][] vertexTopo = new int[n][];

    for (int i=0; i< n; i++) {
      vertexTopo[i]= getNeighborsID(i);
    }
    return vertexTopo;
  }


  Vertex[] getNeighbors(int id) {

    HashSet n = vTopo.get(id);
    int nn = n.size();
    Vertex[] neighbors = new Vertex[nn];
    int i=0;
    for (Iterator it = n.iterator(); it.hasNext(); ) {
      neighbors[i] = getVertexForID((int)it.next());    
      i++;
    }
    return neighbors;
  }


  Vertex[] getNeighbors(Vertex v) {
    HashSet n = vTopo.get(v.id);
    int nn = n.size();
    Vertex[] neighbors = new Vertex[nn];
    int i=0;
    for (Iterator it = n.iterator(); it.hasNext(); ) {
      neighbors[i] = getVertexForID((int)it.next());    
      i++;
    }
    return neighbors;
  }

  // gets indexes of neighbour vertices given vertex id
  int[] getNeighborsID(int vId) {
    HashSet n = vTopo.get(vId);
    int nn = n.size();
    int[] neighbors = new int[nn];
    int i=0;
    for (Iterator it = n.iterator(); it.hasNext(); ) {
      neighbors[i] = (int)it.next();    
      i++;
    }
    return neighbors;
  }

  // gets indexes of faces that share that vertex id
  int[] getConnectedFaces(int vId) {
    HashSet n = vfTopo.get(vId);
    int nn = n.size();
    int[] neighbors = new int[nn];
    int i=0;
    for (Iterator it = n.iterator(); it.hasNext(); ) {
      neighbors[i] = (int) it.next();    
      i++;
    }
    return neighbors;
  }

  // gets indexes of faces that share that vertex
  int[] getConnectedFaces(Vertex v) {
    HashSet n = vfTopo.get(v.id);
    int nn = n.size();
    int[] neighbors = new int[nn];
    int i=0;
    for (Iterator it = n.iterator(); it.hasNext(); ) {
      neighbors[i] = (int) it.next();    
      i++;
    }
    return neighbors;
  }

  //
  // ______________________ display methods ______________________
  //

  // generate a vertex-colored PShape of the mesh (faster display)
  void colorMesh() {
    cMesh = createShape(GROUP);
    PShape faceShape;
    for (Face f : faces) {
      Vec3D a, b, c, n;
      a = getVertexForID(f.a.id);
      b = getVertexForID(f.b.id);
      c = getVertexForID(f.c.id);
      n = f.normal;
      faceShape = createShape();
      faceShape.beginShape(TRIANGLES);
      faceShape.normal(n.x, n.y, n.z);
      //faceShape.noStroke();
      faceShape.stroke(200, 20);
      faceShape.fill(vCols[f.a.id]);
      faceShape.vertex(a.x, a.y, a.z);
      faceShape.fill(vCols[f.b.id]);
      faceShape.vertex(b.x, b.y, b.z);
      faceShape.fill(vCols[f.c.id]);
      faceShape.vertex(c.x, c.y, c.z);
      faceShape.endShape();
      cMesh.addChild(faceShape);
    }
  }


  // topology display

  void neighDisplay(Vertex v) {
    Vertex[] neigh = getNeighbors(v);
    //stroke(0, 255, 0);
    stroke(255, 111, 231);
    strokeWeight(5);
    Vec3D p;
    for (int i=0; i< neigh.length; i++) {
      p = neigh[i];
      point(p.x, p.y, p.z);
    }
  }

  void neighDisplay(int id) {
    Vertex[] neigh = getNeighbors(id);
    //stroke(0, 255, 0);
    stroke(255, 111, 231);
    strokeWeight(5);
    Vec3D p;
    for (int i=0; i< neigh.length; i++) {
      p = neigh[i];
      point(p.x, p.y, p.z);
    }
  }

  void neighFDisplay(int id) {
    try {
      int[] ff = getConnectedFaces(id);
      for (int i=0; i<ff.length; i++) {
        faceDisplay(ff[i]);
      }
    }
    catch(Exception e) {
    }
  }

  void faceDisplay(int fi) {
    try {
      Face f = faces.get(fi);
      Vec3D a, b, c, n;
      a = getVertexForID(f.a.id);
      b = getVertexForID(f.b.id);
      c = getVertexForID(f.c.id);
      n = f.normal;

      beginShape(TRIANGLES);
      normal(n.x, n.y, n.z);
      noStroke();
      fill(vCols[f.a.id]);
      vertex(a.x, a.y, a.z);
      fill(vCols[f.b.id]);
      vertex(b.x, b.y, b.z);
      fill(vCols[f.c.id]);
      vertex(c.x, c.y, c.z);
      endShape();
    }
    catch(Exception e) {
      println("face not valid");
    }
  }

  // display tangential field

  void tgFDisplay(float len) {
    Vec3D n;
    //stroke(155, 117, 148);
    stroke(220);
    strokeWeight(1);
    for (Vertex v : vertices.values()) {
      n = tgField[v.id].dir.scale(len);
      line(v.x, v.y, v.z, v.x+n.x, v.y+n.y, v.z+n.z);
    }
  }
}