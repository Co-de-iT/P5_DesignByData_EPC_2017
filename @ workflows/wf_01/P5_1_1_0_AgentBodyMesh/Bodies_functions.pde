

AgentBody[] makeBodies(AEMesh mesh, ArrayList<Agent> agents) {
  AgentBody[] bodies;
  int bC=0;
  int type = 0; // body type at 0 by default
  Vec3D pos = new Vec3D();
  Vec3D vel = new Vec3D();

  for (Agent a : agents) {
    bC +=a.strand.points.size();
  }
  bodies = new AgentBody[bC];
  int count = 0;
  for (Agent a : agents) {
    for (int i=0; i< a.strand.points.size(); i++) {
      pos = a.strand.points.get(i);
      vel = mesh.getClosestVertexToPoint(pos).normal;
      bodies[count] = new AgentBody(pos, vel, type, false); // here body type is selected
      //bodies[count] = new AgentBody(pos, vel, a.strand.points.get(i).id, false); // here body type is selected according to strand point id
      count++;
    }
  }

  return bodies;
}

void runBodies(AEMesh mesh, AgentBody[] bodies) {

  for (AgentBody a : bodies) {
    ////a.alignWithNeighbor(agents);
    ////a.alignWithNeighbors(agents, 80);
    //if (!a.locked && frameCount>200) a.locked = true; // locks agents after 200 frames
    if (lock) a.locked = true; // locks agents 
    a.update(bodies, 80, 10);
    a.alignWithField(mesh.tgField, 0.04);
    ////a.displayPos();
    ////a.displayPlane(10);
    a.displayBody();
    ////a.displayAxis(10);
    ////a.displayVel(10);
  }
}