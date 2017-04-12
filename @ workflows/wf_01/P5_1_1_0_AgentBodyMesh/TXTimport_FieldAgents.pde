// agents import

ArrayList <Agent> importAgents(String fileName, Vec3D world) {

  ArrayList <Agent> ag;
  Vec3D pt, vec;
  int type;

  // load file and split lines into separate strings
  String[] txtLines = loadStrings(dataPath(fileName));

  ag = new ArrayList <Agent>();
  //pts = new Vec3D[txtLines.length];
  //vecs = new Vec3D[txtLines.length];
  //type = new int[txtLines.length];

  // loop thru them
  for (int i = 0; i < txtLines.length; ++i) {

    //splits into elements
    String[] elements = split(txtLines[i], ' ');

    //separates coords point
    String[] arrToks = split(elements[0], ',');
    float xx = Float.valueOf(arrToks[0]);
    float yy = Float.valueOf(arrToks[1]);
    float zz = Float.valueOf(arrToks[2]);

    //add pt to pts array
    pt = new Vec3D(xx, yy, zz);


    //separates coords vector
    arrToks = split(elements[1], ',');
    xx = Float.valueOf(arrToks[0]);
    yy = Float.valueOf(arrToks[1]);
    zz = Float.valueOf(arrToks[2]);

    //add pt to pts array
    vec = new Vec3D(xx, yy, zz);

    // add type
    type = Integer.valueOf(elements[2]);

    ag.add(new Agent(pt, vec, world));
  }

  return ag;
}

// field import

Vec3D[] importField(String fileName) {

  Vec3D[] f;
  Vec3D pt, vec;
  int type;

  // load file and split lines into separate strings
  String[] txtLines = loadStrings(dataPath(fileName));

  f = new Vec3D[txtLines.length];
  //pts = new Vec3D[txtLines.length];
  //vecs = new Vec3D[txtLines.length];
  //type = new int[txtLines.length];

  // loop thru them
  for (int i = 0; i < txtLines.length; ++i) {

    //splits into elements
    String[] elements = split(txtLines[i], ' ');

    //separates coords point
    String[] arrToks = split(elements[0], ',');
    float xx = Float.valueOf(arrToks[0]);
    float yy = Float.valueOf(arrToks[1]);
    float zz = Float.valueOf(arrToks[2]);

    //add pt to pts array
    pt = new Vec3D(xx, yy, zz);


    //separates coords vector
    arrToks = split(elements[1], ',');
    xx = Float.valueOf(arrToks[0]);
    yy = Float.valueOf(arrToks[1]);
    zz = Float.valueOf(arrToks[2]);

    //add pt to pts array
    vec = new Vec3D(xx, yy, zz);

    // add type
    type = Integer.valueOf(elements[2]);

    f[i] = vec;
  }

  return f;
}

// field import

TensorPt[] importTensField(String fileName) {

  TensorPt[] f;
  Vec3D pt, vec;
  int type;

  // load file and split lines into separate strings
  String[] txtLines = loadStrings(dataPath(fileName));

  f = new TensorPt[txtLines.length];
  //pts = new Vec3D[txtLines.length];
  //vecs = new Vec3D[txtLines.length];
  //type = new int[txtLines.length];

  // loop thru them
  for (int i = 0; i < txtLines.length; ++i) {

    //splits into elements
    String[] elements = split(txtLines[i], ' ');

    //separates coords point
    String[] arrToks = split(elements[0], ',');
    float xx = Float.valueOf(arrToks[0]);
    float yy = Float.valueOf(arrToks[1]);
    float zz = Float.valueOf(arrToks[2]);

    //add pt to pts array
    pt = new Vec3D(xx, yy, zz);


    //separates coords vector
    arrToks = split(elements[1], ',');
    xx = Float.valueOf(arrToks[0]);
    yy = Float.valueOf(arrToks[1]);
    zz = Float.valueOf(arrToks[2]);

    //add pt to pts array
    vec = new Vec3D(xx, yy, zz).normalize();

    // add type
    type = Integer.valueOf(elements[2]);
    
    f[i] = new TensorPt(pt,vec,type);
  }

  return f;
}