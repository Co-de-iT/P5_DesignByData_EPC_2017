// parameters and variables are collected here



ArrayList<Agent> agents;
AgentBody[] bodies;
int nAgents = 50;
Vec3D mP;

Vec3D world;
float wX = 800;
float wY = 600;
float wZ = 200;

boolean meshDisp = true;
boolean trailDisp=true;
boolean trailMode=true;
boolean crawl = true;
boolean go = false;
boolean strandDone = false;
boolean phase2=false;
boolean makeBod = false;
boolean lock = false;
float cR, cI, sR, sI, aR, aI; // cohesion & separation radius & intensity


String meshFile = "spheres_fused.stl";
AEMesh mesh;
AABB bBox;
ToxiclibsSupport gfx;
Vec3D vS, pivot, extent;
Vec3D samplePt;
Vertex sample;
int nVerts, id=0;
int viewMode = 2;
int[] neighV;

PointOctree trailOctree;
PointOctree octree;
PShape octPts;
float octreeSampleDist=0;
float octreeSampleIncrement = 0.01;


PeasyCam cam;

String fStyle = "Open Sans";
PFont font;


boolean invY=false;
boolean viewOct=false;