// parameters and global variables are collected here

int strandLength = 30;
int strandFreq = 10;
float TipSearchRadius = 20;
float abAlignRadius = 80;
float abSeparationRadius = 20;
float fieldIntensity = 0.02; // 0.04

String meshFile = "spheres_fused.stl"; // if you want to import a different mesh change this

ArrayList<Agent> agents;
AgentBody[] bodies;
int nAgents = 50;
Vec3D mP;

Vec3D world;
float wX = 800;
float wY = 600;
float wZ = 200;

boolean meshDisp = true;
boolean trailDisp=false;
boolean trailMode=false;
boolean go = false;
boolean strandDone = false;
boolean phase2=false;
boolean makeBod = false;
boolean lock = false;
boolean debugView = false;
boolean fieldDisp = true;
boolean vidRec = false;
float cR, cI, sR, sI, aR, aI; // cohesion & separation radius & intensity


AEMesh mesh;
AABB bBox;
ToxiclibsSupport gfx;
Vec3D vS, pivot, extent;
Vec3D samplePt;
Vertex sample;
int nVerts, id=0;
int viewMode = 0;
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