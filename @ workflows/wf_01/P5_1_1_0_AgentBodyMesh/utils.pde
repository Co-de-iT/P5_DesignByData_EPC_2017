// this aligns the drawing plane with the current camera view
// put in between a pushMatrix() and popMatrix()
// to draw something at a specific point, call a translate(x,y,z)
// before this function

void alignToView(PeasyCam cam) {

  float[] cRot = cam.getRotations();
  rotateX(cRot[0]);
  rotateY(cRot[1]);
  rotateZ(cRot[2]);
}

void alignAtPoint(Vec3D p, PeasyCam cam) {
  translate(p.x, p.y, p.z);
  alignToView(cam);
}

void textAtPoint(Vec3D p, String txt, PeasyCam cam) {
  pushMatrix();
  alignAtPoint(p, cam);
  text(txt, 0, 0);
  popMatrix();
}