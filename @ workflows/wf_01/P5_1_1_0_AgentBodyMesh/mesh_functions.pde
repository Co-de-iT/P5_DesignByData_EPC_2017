// Mesh helping functions


void initMesh() {

  mesh = new AEMesh(meshFile);
  mesh.buildTgField(importField("field.txt"));

  mesh.computeVertexNormals();
  mesh.computeFaceNormals();
}

void meshDisplay(AEMesh mesh, int viewMode) {
  Vec3D norm;
  switch(viewMode) { //alike stream gates in GH
  case 0: //wireframe
    pushStyle();
    stroke(100, 40);
    strokeWeight(1);
    noFill();
    gfx.mesh(mesh, false);
    popStyle();
    break;
  case 1:
    pushStyle();
    fill(55);
    lightSpecular(230, 255, 255);
    directionalLight(255, 255, 255, -1, -1, -1);
    directionalLight(55, 55, 55, 1, 1, 1);
    shininess(1.0);
    //stroke(0, 100, 100, 100);
    stroke(200, 20);
    strokeWeight(1);
    gfx.mesh(mesh, false);
    noLights();
    popStyle();
    break;
  case 2:
    pushStyle();
    noStroke();
    gfx.meshNormalMapped(mesh, true);
    int i=0;
    stroke(0, 80);
    strokeWeight(1);
    for (Vertex v : mesh.vertices.values()) {
      norm = v.normal.scale(5); // normals are a field of Vertex
      line(v.x, v.y, v.z, v.x+norm.x, v.y+norm.y, v.z+norm.z);
      i++;
    }
    popStyle();
    break;
  case 3: // colored mesh vertices
    pushStyle();
    noFill();
    stroke(0);
    strokeWeight(2);
    for (Vertex v : mesh.vertices.values()) {
      stroke(mesh.vCols[v.id]);
      point(v.x, v.y, v.z);
    }
    popStyle();
    break;
  case 4: // colored mesh
    shape(mesh.cMesh, 0, 0);
    break;
  }
}