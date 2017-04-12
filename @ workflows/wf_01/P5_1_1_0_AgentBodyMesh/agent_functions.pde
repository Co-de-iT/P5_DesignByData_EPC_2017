

void initAgentsMesh(AEMesh mesh) {

  sR = 5;
  sI = 1;
  cR= 80; //200
  cI= 0.05;
  aR= 20;
  aI = 0.05;

  agents = new ArrayList<Agent>();
  Vec3D pos, vel;
  int nVerts = mesh.vertices.size();
  int id;
  ArrayList<Integer> ind = new ArrayList<Integer>();
  for (int i=0; i< nVerts; i++) {
    ind.add(i);
  }

  for (int i=0; i< nAgents; i++) {
  id = round(random(ind.size()-1));
    pos = mesh.getVertexForID(id).copy();
    vel = mesh.tgField[id].dir.copy();
    Agent a = new Agent(pos, vel, world);
    //a = new Agent(pos, Vec3D.randomVector().scale(3), world);
    agents.add(a);
    ind.remove(id);
  }
}