/*

 Code by Alessio Erioli
 
 (c) Co-de-iT 2017
 
 includes an extended TriangleMesh class to implement vertex topology & vertex color + 
 some mesh helping functions
 
 keys:
 
 1-5   viewmodes
 m     cycles through viewmodes
 y     inverts y display to match CAD systems (but messes with text and other settings, that's why is a toggle mode and not permanent
 v     cycles through vertices and shows connected vertices and faces
 o     display octree points
 T/t   display agent trails/change trail style
 
 
 */


import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.processing.*;
import peasy.*;
import java.util.*;


void setup() {

  size(1400, 900, P3D);



  //
  // _______________________________ mesh settings _______________________________
  //
  //

  initMesh();

  nVerts = mesh.vertices.size();
  vS = mesh.getVertexForID(id);

  bBox = mesh.getBoundingBox(); // the mesh bounding box
  extent = mesh.getBoundingBox().getExtent(); // AABB diagonal vector
  pivot = bBox.getMin().add(bBox.getMax()).scale(0.5); // finds mesh pivot (the AABB center)

  world = new Vec3D(extent.x*3, extent.y*3, extent.z*3);

  //
  // _______________________________ octree settings _______________________________
  //
  //

  initOctree();


  //
  // _______________________________ agents settings _______________________________
  //
  //

  //initAgents();
  //initAgentsMesh(mesh); // from mesh random points
  agents = importAgents("agents.txt", world); // from file


  //
  // _______________________________ misc settings _______________________________
  //
  //

  //// sample a closest point
  //samplePt = new Vec3D(random(-extent.x*0.5, extent.x*0.5), random(-extent.y*0.5, extent.y*0.5), 
  //  random(-extent.z*0.5, extent.z*0.5));

  //try {
  //  sample = mesh.getClosestVertexToPoint(samplePt);
  //}
  //catch(Error e) {
  //  println(e);
  //  println("point not found");
  //  sample = new Vertex(new Vec3D(), 0); // if a closest point is not found then create a vertex in the center
  //}

  //
  // _______________________________ display and view settings _______________________________
  //
  //

  // camera settings _______________________________

  cam = new PeasyCam(this, 600);
  float fov = PI/3.0; // stare tra i 2 e i 4
  float cameraZ = (height/2.0) / tan(fov/2.0);
  //           fov         ratio                  near clip     far clip
  //            |            |                        |            |
  perspective(fov, float(width)/float(height), cameraZ/100.0, cameraZ*100.0);

  cam.lookAt(pivot.x, pivot.y, pivot.z); // look at pivot

  //  font settings _______________________________

  // create a font for a better text display
  // install Open Sans if you haven't alreadyor use "Arial" instead
  font =createFont(fStyle, 50);
  textFont(font); //use the created font for text
  textSize(10);

  //  other settings _______________________________

  gfx = new ToxiclibsSupport(this); // initialize mesh visualization device
}

// _____________________________________________________________________________________________________________________________
// _______________________________________________________________________________ draw function _______________________________
// _____________________________________________________________________________________________________________________________


void draw() {

  //
  // _______________________________ preliminary operations _______________________________
  //

  //background (240); // almost white
  background(237, 168, 226); // nice pink shade

  // equals the coordinate system with those of 3D CAD (such as Rhino, 3DSMax, etc.)
  // usually, shapes are mirrored because Y points down here
  // but messes with text and some other settings, so use just as verification
  if (invY)scale(1, -1.1);

  //
  // _______________________________ update section _______________________________
  //

  /*
   your update code here.....   
   */
  if (go) {
    strandDone = true;
    // update and display agents
    if (!phase2) {
      for (Agent ag : agents) {

        /*
    if (crawl) {
         //ag.meshCrawl(mesh); // crawls following vertices positions only
         //ag.updateTrail(1); // use with meshCrawl
         }
         */
        //ag.updateOnMesh(agents, mesh, .2, false);
        ag.updateOnMeshField(agents, octree, .1, mesh, .2, false);
        //ag.addForce(new Vec3D(.1,0,0));
        ag.display();
        ag.strand.display();
        //Vertex v = ag.getOctClosest(octree);
        //ag.dispVertex(v);
        if (trailDisp) {
          if (trailMode) ag.dispTrailCurve();
          else ag.dispTrail(2);
        }
        if (!ag.strand.done)strandDone = false; // boolean "self-and" operator - when all strands are done it becomes true
      } // end for (Agent ag : agents)
    }

    if (phase2 && strandDone) {
      if (!makeBod) {
        bodies = makeBodies(mesh, agents);
        makeBod = true;
      }
      runBodies(mesh, bodies);
    }
  } else {

    // just display agents
    for (Agent ag : agents) {
      ag.display();
      ag.strand.display();
      //Vertex v = ag.getOctClosest(octree);
      //ag.dispVertex(v);
      if (trailDisp) {
        if (trailMode) ag.dispTrailCurve();
        else ag.dispTrail(2);
      }
    } // end for (Agent ag : agents)
  } // end if go

  //
  // _______________________________ end update _______________________________
  //


  //
  // _______________________________ display section _______________________________
  //

  // __________________________ mesh section

  if (meshDisp) meshDisplay(mesh, viewMode);
  if (viewOct) octDisplay(octPts); // octDisplay(octree);


  // __________________________ bounding box section

  pushMatrix();
  pushStyle();

  noFill();
  strokeWeight(1);
  stroke(255, 40);
  gfx.mesh(octree.toMesh());
  stroke(0, 40);
  gfx.mesh(bBox.toMesh());

  //noStroke();
  noFill();
  stroke(0, 80);
  strokeWeight(.5);
  //rect(0, 0, wX, wY);
  box(world.x, world.y, world.z);


  // __________________________ "the rest" section

 // if (meshDisp) {
    // draw vertex & neighbors if viewMode != 3
    //if (viewMode !=3) {
    //  mesh.neighDisplay(id); // display vertex neighbors
    //  mesh.neighFDisplay(id); // display vertex face neighbors

      // write text next to selected vertex
      //alignAtPoint(vS, cam); 
      //stroke(255);
      //strokeWeight(10);
      //point(0, 0, 0);
      //fill(255);
      //textSize(5);
      //text(" __________________ this is vertex "+id, 0, 0);
    //}
  //}
  popStyle();
  popMatrix();

  // tangent field display
  if (!strandDone) mesh.tgFDisplay(5);


  // display mesh closest point to a sample point
  //stroke(255);
  //strokeWeight(10);
  //point(samplePt.x, samplePt.y, samplePt.z);
  //point(sample.x, sample.y, sample.z);
  //strokeWeight(1);
  //line(samplePt.x, samplePt.y, samplePt.z, sample.x, sample.y, sample.z);
}


void keyPressed() {
  if (key>'0' && key<'7') viewMode = int(key)-int('1');
  if (key=='m') viewMode = (viewMode+1)%6; // cycles through viewModes
  if (key=='M') meshDisp = !meshDisp;

  if (key=='v') { // goes through vertices list
    id= (id+1)%nVerts;
    vS = mesh.getVertexForID(id);
  }
  if (key=='o') viewOct = !viewOct;
  if (key == 'T') trailDisp = !trailDisp;
  if (key == 't') trailMode = !trailMode;
  if (key =='y')invY = !invY;
  if (key=='c') crawl = !crawl;
  if (key==' ') go = !go;
  if (key=='e') exportBodies(bodies, "Y_struct");
  if (key=='2') phase2 = true;
  if (key=='l') lock = true;
}