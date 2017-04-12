/* //<>//

 Agent Body
 
 */

import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.processing.*;
import peasy.*;
import java.util.*;

int nAgents = 2000;//3000
float rad = 250, pSize;
AgentBody[] agents;
ToxiclibsSupport gfx;
PeasyCam cam;
TensorPt[] field;

boolean vidRec = false;
boolean displayField = false;
boolean lock = false;

void setup() {

  size(900, 900, P3D);
  //fullScreen(P3D);
  smooth(8);



  cam = new PeasyCam(this, 500);
  gfx = new ToxiclibsSupport(this);

  agents = importAgents("agents.txt");

/*
  agents = new AgentBody[nAgents];
  for (int i=0; i<nAgents; i++) {
    agents[i] = new AgentBody(Vec3D.randomVector().scale(random(rad*0.2, rad)), Vec3D.randomVector(),0, false);
  }
  */

  field = importField("field.txt");


  //frameRate(1);
}

void draw() {
  background(60);

  for (AgentBody a : agents) {
    ////a.alignWithNeighbor(agents);
    ////a.alignWithNeighbors(agents, 80);
    //if (!a.locked && frameCount>200) a.locked = true; // locks agents after 200 frames
    if (lock) a.locked = true; // locks agents 
    a.update(agents, 80, 10);
    a.alignWithField(field, 0.04);
    ////a.displayPos();
    ////a.displayPlane(10);
    a.displayBody();
    ////a.displayAxis(10);
    ////a.displayVel(10);
  }


  // display field
  if (displayField) {
    for (TensorPt t : field) {
      t.display(color(255), 3, color(0, 255, 255), 5);
    }
  }
  strokeWeight(1);
  gfx.origin(10); // axis tripod
  cam.beginHUD();
  // write or draw something on screen that overlays the 3D
  //fill(255);
  //if (frameCount<200) text(frameCount, 10, 20);
  cam.endHUD();

  if (vidRec) saveFrame("video_01/Agent_Body_####.jpg");
}

void keyPressed() {
  if (key =='i') saveFrame("img/Agent_Body_####.png");
  if (key=='v') vidRec = false;
  if (key=='e') exportBodies(agents, "Y_struct");
  if (key=='f') displayField = !displayField;
  if (key=='l') lock = true;
}