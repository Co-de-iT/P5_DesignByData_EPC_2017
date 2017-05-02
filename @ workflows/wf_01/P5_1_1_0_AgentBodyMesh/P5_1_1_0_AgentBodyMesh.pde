/*

 Encoded Bodies/Embodied Codes
 
 Processing workshop @ Design By Data ws - EPC Paris
 
 Workflow 01 /////////////////////// Agent Bodies on Mesh surface
 
 Code by Alessio Erioli
 
 (c) Co-de-iT 2017
 
 includes:
 
 . an extended TriangleMesh class to implement vertex topology & vertex color + some mesh helping functions
 . Agent, AgentBody, Strand, Body, Tip, TensorPt classes
 
 /////////////////////// NOTE ON SENSIBLE VARIABLES /////////////////////// 
 
 The workflow has a few "sensible" variables, here they are with their location (most of them are now located in AA_parameters for convenience):
 
 . *body shape and size* - Body class
 try to design a real tri-dimensional body, they will ensure better connections to be established.
 The forward vector is key - check how the body plane orients itself by hitting the 'd' key (debug view) after you have deployed the bodies with 'b' (but before locking them with 'l')
 
 . *body type* - designed in the Body class, assigned in RHino+GH)
 try with bodies that have radical different characteristics (i.e. one with branches in all directions + one more "directional")
 and start simple - learn to control and experimentn with 2 body types as much as you can before stepping up to 3 or more bodies.
 
 . *strand length and deposition frequency* - AA_parameters
 control how many bodies are deployed and at which distance
 
 . *tip search radius* - AA_parameters
 the larger the radius, the more the probability to find connection
 
 . *agent bodies alignment and separation radius* - AA_parameters
 the former controls the range of planar alignment, the second the amount of separation between the cores
 
 . *field* - Rhino + GH
 go for gradients of vector orientations, or very few vectors in given directions (i.e. using lines)
 
 . *field intensity* - AA_parameters
 determines how strongly the bodies are influenced by the field in their orientation
 
 . *mesh* (Rhino + GH)
 start with simple meshes, also regular and symmetrical ones with (as much as possible) evenly spaced vertices, try to understand the influence of curvature and mesh proportions
 
 . some advice:
 
 . do not cram a lot of bodies together as in accumulating them (especialli if they are planar, they will just tend to stack up with no benefit for the complexity of the whole)
 . 3D bodies, with controlled spacing and a well distributed, gradual field yeld the best results
 
 /////////////////////// NOTE ON BODY TYPE SELECTION /////////////////////// 
 
 body type is chosen when creating bodies from strands (tab Bodies_functions, makeBodies function)
 
 
 
 key map:
 
 ' '   (space bar) go/pause
 1-5   viewmodes
 m     cycles through viewmodes
 T/t   display agent trails/change trail style
 f     display field
 d     debug view (bounding boxes, octrees, etc)
 o     display octree points (under debug view)
 
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

  size(1400, 900, P3D);
  //fullScreen(P3D); // uncheck this and check size() to see the sketch fullscreen
  smooth(8);


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

  world = new Vec3D(extent.x*3, extent.y*3, extent.z*3); // define the world extent for agents

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

  background(237, 168, 226); // nice pink shade

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
        ag.updateOnMeshField(agents, octree, .02, mesh, .1, false, strandFreq); // influences of field and mesh .1 and .2
        //ag.addForce(new Vec3D(.1,0,0)); // adds a directional force to the agent
        ag.display();
        ag.strand.display();
        if (trailDisp) {
          if (trailMode) ag.dispTrailCurve();
          else ag.dispTrail(2);
        }
        if (!ag.strand.done)strandDone = false; // checks if all strands are done
      } // end for (Agent ag : agents)
    }


    // if switching to phase 2 makes and/or updates bodies
    if (phase2 && strandDone) {
      if (!makeBod) {
        bodies = makeBodies(mesh, agents);
        makeBod = true;
      }
      runBodies(mesh, bodies, abAlignRadius, abSeparationRadius, fieldIntensity);
    }
  } else {

    // just display agents
    for (Agent ag : agents) {
      ag.display();
      ag.strand.display();
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
  if (viewOct) octDisplay(octPts);


  // __________________________ bounding box section

  if (debugView) {
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
    popStyle();
  }

  // __________________________ "the rest" section

  // field display
  if (fieldDisp) mesh.tgFDisplay(10);

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
  if (key>'0' && key<'7') viewMode = int(key)-int('1'); // controls Mesh viewModes
  if (key=='m') viewMode = (viewMode+1)%5; // cycles through viewModes
  if (key=='M') meshDisp = !meshDisp;
  if (key=='o') viewOct = !viewOct;
  if (key=='T') trailDisp = !trailDisp;
  if (key=='t') trailMode = !trailMode;
  if (key=='f') fieldDisp = !fieldDisp;
  if (key=='d') debugView = !debugView;
  if (key=='i') saveFrame("img/AgentBodyMesh_####.png");
  if (key=='v') vidRec = !vidRec;
  if (key==' ') go = !go;

  if (key=='b') phase2 = true;
  if (key=='l') lock = true;
  if (key=='e') exportBodies(bodies, "_struct_topoXt");
}