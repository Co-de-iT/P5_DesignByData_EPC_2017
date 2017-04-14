/* //<>//

 Encoded Bodies/Embodied Codes
 
 Processing workshop @ Design By Data ws - EPC Paris
 
 Workflow 02 /////////////////////// Agent Bodies on volumetric arrangement
 
 Code by Alessio Erioli
 
 (c) Co-de-iT 2017
 
  includes:
 
 . AgentBody, Body, Tip, TensorPt classes
 
 /////////////////////// NOTE ON *BODY TYPE* SELECTION /////////////////////// 
 
 body type is inherited from the agents.txt file and it is set in Grasshopper, in the 2_0_voxelize.gh file
 (see the export agent section in the GH file - the last expression component before the export has a "type" panel attached)
 
 key map:
 
 ' '   (space bar) go/pause
 f     display field
 d     debug view (planes, tripod, directions, etc)
 
 b     generate bodies (phase 2)
 l     lock bodies (phase 2)
 e     export bodies to file
 
 i     save screenshot image
 v     video recording on/off
 
 */

import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.processing.*;
import peasy.*;
import java.util.*;



void setup() {

  size(900, 900, P3D);
  //fullScreen(P3D); // uncheck this and check size() to see the sketch fullscreen
  smooth(8);

  cam = new PeasyCam(this, 500);
  gfx = new ToxiclibsSupport(this);

  agents = importAgents("agents.txt");

  // spheric random generation
  //agents = new AgentBody[nAgents];
  //for (int i=0; i<nAgents; i++) {
  //  agents[i] = new AgentBody(Vec3D.randomVector().scale(random(rad*0.2, rad)), Vec3D.randomVector(), 0, false);
  //}

  field = importField("field.txt");
}



void draw() {
  background(60);
  if (go) { // run and display
    for (AgentBody a : agents) {

      if (lock) a.locked = true; // locks agents 
      a.update(agents, 80, 10);
      a.alignWithField(field, 0.01);
      a.displayBody();

    }
  } else { // just display
    for (AgentBody a : agents) {

      a.displayBody();

    }
  }


  // display field
  if (fieldDisp) {
    for (TensorPt t : field) {
      t.display(color(255), 3, color(0, 255, 255), 10);
    }
  }

  if (debugView) {
    for (AgentBody a : agents) {
      // uncheck one or more for debug purposes
      //a.displayPos();
      //a.displayPlane(10);
      //a.displayAxis(10);
      //a.displayVel(10);
    }
    strokeWeight(1);
    gfx.origin(10); // axis tripod
  }

  if (vidRec) {
    saveFrame("video/AgentBodyMesh_####.jpg");
    cam.beginHUD();
    pushStyle();
    noStroke();
    fill(255, 0, 0);
    rect(10, 10, 10, 10);
    popStyle();
    cam.endHUD();
  }
}

void keyPressed() {
  if (key =='i') saveFrame("img/AgentBody_####.png");
  if (key=='v') vidRec = !vidRec;
  if (key=='f') fieldDisp = !fieldDisp;
  if (key==' ') go = !go;
  if (key=='l') lock = true;
  if (key=='d') debugView = !debugView;
  if (key=='e') exportBodies(agents, "Y_struct_topo");
}