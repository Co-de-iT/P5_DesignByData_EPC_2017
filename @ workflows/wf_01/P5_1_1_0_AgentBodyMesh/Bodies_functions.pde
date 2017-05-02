

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
      bodies[count] = new AgentBody(pos, vel, count, type,TipSearchRadius, false); // here body type is selected
      //bodies[count] = new AgentBody(pos, vel, a.strand.points.get(i).id, false); // here body type is selected according to strand point id
      count++;
    }
  }

  return bodies;
}

void runBodies(AEMesh mesh, AgentBody[] bodies, float align, float separate, float fI) {

  for (AgentBody a : bodies) {
    ////a.alignWithNeighbor(agents);
    ////a.alignWithNeighbors(agents, 80);
    //if (!a.locked && frameCount>200) a.locked = true; // locks agents after 200 frames
    if (lock) a.locked = true; // locks agents 
    a.update(bodies, align, separate); // cohesion and separation radiuses
    a.alignWithField(mesh.tgField, fI);//0.04 - strong field influence
    ////a.displayPos();
    a.displayBody();
    if (debugView) {
      noStroke();
      a.displayPlane(20);
    }
    ////a.displayAxis(10);
    ////a.displayVel(10);
  }
}