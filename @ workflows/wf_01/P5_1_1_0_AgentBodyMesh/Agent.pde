/*

 Code by Alessio Erioli
 
 (c) Co-de-iT 2017
 
 
 still to be implemented: 
 . stigmergic behavior in field
 
 */

class Agent {

  Vec3D pos, fPos, vel, acc;
  ArrayList<Vec3D>trail, trailV;
  int nTrail;
  float angVis, fMag, maxForce, maxVel;
  Strand strand;
  int strPtCount;
  Vec3D world;


  Agent(Vec3D pos, Vec3D vel, Vec3D world) {
    this.pos = pos;
    this.vel = vel;
    this.world = world;

    acc = new Vec3D();
    trail = new ArrayList<Vec3D>();
    trailV = new ArrayList<Vec3D>();
    nTrail= 10; // 20
    maxVel = 1.5;
    maxForce = 0.01;
    angVis = PI*0.3;
    fMag = 5;
    fPos = pos.add(vel.scale(fMag)); // future position
    strand = new Strand(20);// 20
    strPtCount = 0;
  }

  void update(ArrayList<Agent> agents, boolean ease) {
    //flock(agents, cR, aR, sR, cI, aI, sI, ease);
    separation(agents, sR, sI, false);
    move();
    //bounce();
    wrap();
    updateTrail(5);
    updateStrand(10);
  }

  void updateOnMesh(ArrayList<Agent> agents, AEMesh mesh, float mF, boolean ease) {
    flock(agents, cR, aR, sR, cI, aI, sI, ease);
    //separation(agents, sR, sI, ease);
    meshMove(mesh, mF);
    move();
    //bounce();
    wrap();
    updateTrail(5);
    updateStrand(10);
  }

  void updateOnMeshField(ArrayList<Agent> agents, PointOctree field, float fI, AEMesh mesh, float mI, boolean ease) {
    flock(agents, cR, aR, sR, cI, aI, sI, ease);
    //separation(agents, sR, sI, ease);
    fieldMove(mesh, field, fI);
    meshMove(mesh, mI);

    move();
    //bounce();
    wrap();
    updateTrail(5);
    updateStrand(10);
  }



  //

  void addForce(Vec3D f) {
    acc.addSelf(f);
  }

  //_______ flocking methods


  void flock(ArrayList<Agent> agents, float cR, float aR, float sR, float cI, float aI, float sI, boolean ease) {

    int cC, cS, cA; // counters
    float ccR, ssR, aaR; // squared values (faster)
    Vec3D tC, tS, tA, des, steer;
    float dist, easC, easS;
    cC = 0;
    cS = 0;
    cA = 0;

    ssR = sR*sR;
    ccR = cR*cR;
    aaR = aR*aR;

    tC = new Vec3D();
    tS = new Vec3D();
    tA = new Vec3D();

    for (int i=agents.size()-1; i>=0; i--) {

      Agent other = agents.get(i);

      if (this != other) { // see if we're not checking ourselves

        dist = pos.distanceToSquared(other.pos);

        if (dist < ccR) {
          cC++;
          tC.addSelf(other.pos);
        }
        if (dist < aaR) {
          cA++;
          tA.addSelf(other.vel);
        }
        if (dist < ssR) {
          cS++;
          tS.addSelf(other.pos);
        }
      }
    }

    if (cC > 0) {
      tC.scaleSelf(1.0/cC); // average
      des = tC.sub(pos); // t.sub(pos);
      dist = des.magSquared();
      easC = ease? dist/ccR : 1; // stronger when far
      des.normalizeTo(maxVel);// positive (cohesion)
      steer = des.sub(vel);
      steer.normalizeTo(cI*easC);
      acc.addSelf(steer);

      if (cA > 0) {

        des = tA.scale(1.0/cA); // average
        des.normalizeTo(maxVel);//
        steer = des.sub(vel);
        steer.normalizeTo(aI);
        acc.addSelf(steer);

        if (cS > 0) {
          tS.scaleSelf(1.0/cS); // average
          des = tS.sub(pos); // t.sub(pos);
          dist = des.magSquared();
          easS = ease? 1-dist/ssR : 1; // stronger when near
          des.normalizeTo(maxVel*-1);// negative (separate)
          steer = des.sub(vel);
          steer.normalizeTo(sI*easS);
          acc.addSelf(steer);
        }
      }
    }
  }

  void cohesion(ArrayList<Agent> agents, float cR, float cI, boolean ease) {
    flock(agents, cR, 0, 0, cI, 0, 0, ease);
  }

  void alignment(ArrayList<Agent> agents, float aR, float aI, boolean ease) {
    flock(agents, 0, aR, 0, 0, aI, 0, ease);
  }

  void separation(ArrayList<Agent> agents, float sR, float sI, boolean ease) {
    flock(agents, 0, 0, sR, 0, 0, sI, ease);
  }

  void octPointsFlock(PointOctree trails, float cR, float aR, float sR, float cI, float aI, float sI, boolean ease) {
    //
    // _______________________ implement separation and alignment !!!
    //
    int count=0, cC, cA, cS;
    float ccR = cR*cR;
    float aaR = aR*aR;
    float ssR = sR*sR;
    float easC, easS;
    Vec3D t= new Vec3D();
    Vec3D tC, tS, tA;
    tC = new Vec3D();
    tS = new Vec3D();
    tA = new Vec3D();
    cC=0;
    cA=0;
    cS=0;

    Vec3D tDir, des, steer;
    float dist, easing, vAng;
    ArrayList<Vec3D> neighbors = (ArrayList<Vec3D>) trails.getPointsWithinSphere(new Sphere(fPos, cR));
    //ArrayList<Vec3D> neighbors = (ArrayList<Vec3D>) trails.getPointsWithinBox(new AABB(fPos, cR));

    if (neighbors!= null && neighbors.size() > 0) { // if there are neighbors

      for (Vec3D trailPt : neighbors) {

        if (trailPt != pos) {
          tDir = trailPt.sub(fPos);
          vAng = vel.angleBetween(tDir, true); // use the bool forceNormalize to true          
          dist = tDir.magSquared();
          if (vAng <= angVis) {
            if (dist < ccR) {
              cC++;
              tC.addSelf(trailPt);
            }
            /*
            if (dist < aaR) {
             cA++;
             tA.addSelf(trailPt); // there should be a velocity vector here, not the other position
             }
             */
            if (dist < ssR) {
              cS++;
              tS.addSelf(trailPt);
            }
          }
        }
      }

      if (cC > 0) {
        tC.scaleSelf(1.0/cC); // average
        des = tC.sub(pos); // t.sub(pos);
        dist = des.magSquared();
        easC = ease? dist/ccR : 1; // stronger when far
        des.normalizeTo(maxVel);// positive (cohesion)
        steer = des.sub(vel);
        steer.normalizeTo(cI*easC);
        acc.addSelf(steer);

        /*
       if (cA > 0) {
         
         des = tA.scale(1.0/cA); // average
         des.normalizeTo(maxVel);//
         steer = des.sub(vel);
         steer.normalizeTo(aI);
         acc.addSelf(steer);
         */

        if (cS > 0) {
          tS.scaleSelf(1.0/cS); // average
          des = tS.sub(pos); // t.sub(pos);
          dist = des.magSquared();
          easS = ease? 1-dist/ssR : 1; // stronger when near
          des.normalizeTo(maxVel*-1);// negative (separate)
          steer = des.sub(vel);
          steer.normalizeTo(sI*easS);
          acc.addSelf(steer);
        }
        //} // reactivate when alignment is implemented
      }
    }
  }

  void octPointsCohesion(PointOctree trails, float cR, float cI) {
    octPointsFlock(trails, cR, 0, 0, cI, 0, 0, false);
  }

  /*
  void octPointsAlignment() // to be implemented
   */

  void octPointsSeparation(PointOctree trails, float sR, float sI) {
    octPointsFlock(trails, 0, 0, sR, 0, 0, sI, false);
  }


  Vertex getOctClosest(PointOctree trails) {
    PointOctree leaf = trails.getLeafForPoint(pos);
    Vertex cp=null;// = new Vec3D();
    if (leaf !=null && leaf.getSize()>0) {
      float dist, dMin = Float.MAX_VALUE;
      //ArrayList <Vec3D> ptLeaf = (ArrayList<Vec3D>) leaf.getPoints();
      ArrayList  ptLeaf = (ArrayList) leaf.getPoints();
      for (int i=0; i< ptLeaf.size(); i++) {
        Vertex pt = (Vertex) ptLeaf.get(i);
        dist = pos.distanceToSquared(pt);
        if (dist > 0 && dist< dMin) {
          dMin = dist;
          cp = pt;
        }
      }
    }
    return cp;
  }

  void dispVertex(Vertex v) {
    if (v!= null) {
      stroke(255, 255, 0);
      strokeWeight(5);
      point(v.x, v.y, v.z);
      /*
      pushMatrix();
       translate(v.x, v.y, v.z);
       text(v.id, 0, 0);
       popMatrix();
       */
    }
  }


  //_______ move methods

  void move() {
    vel.addSelf(acc);
    vel.limit(maxVel);
    pos.addSelf(vel);
    fPos = pos.add(vel.scale(fMag)); // future position
    acc = new Vec3D();
  }

  void movePerp(Vec3D a, Vec3D b) {
    vel = getNormalVel(a, b, false);
    pos.addSelf(vel);
  }

  void meshCrawl(AEMesh m) {
    int ptInd = m.getClosestVertexToPoint(pos).id;
    Vertex[] neigh = m.getNeighbors(ptInd);
    float ang, minAng = Float.MAX_VALUE;
    int next = -1;
    Vec3D nextVel, dir;
    nextVel = new Vec3D();
    //check neighbors for smaller angle
    for (int i=0; i< neigh.length; i++) {
      dir = neigh[i].sub(pos);
      ang = dir.angleBetween(vel, true);
      if (ang < minAng) {
        minAng = ang;
        nextVel = dir.normalizeTo(maxVel);
        next = i;
      }
    }
    // if something was found
    if (next>-1) {
      pos = neigh[next].copy();
      vel = nextVel;
    }
  }

  void meshMove(AEMesh m, float mF) {
    int ptInd = m.getClosestVertexToPoint(pos).id;
    Vertex[] neigh = m.getNeighbors(ptInd);
    float ang, minAng = Float.MAX_VALUE;
    int next = -1;
    Vec3D nextVel, dir;
    nextVel = new Vec3D();
    //check neighbors for smaller angle
    for (int i=0; i< neigh.length; i++) {
      dir = neigh[i].sub(pos);
      ang = dir.angleBetween(vel, true);
      if (ang < minAng) {
        minAng = ang;
        nextVel = dir;
        next = i;
      }
    }
    // if something was found
    if (next>-1) {
      Vec3D steer = nextVel.sub(vel);
      steer.normalizeTo(mF);
      acc.addSelf(steer);
    }
  }

  void fieldMove(AEMesh mesh, PointOctree field, float fI) {
    Vertex v = getOctClosest(field);
    if (v != null) {
      int ind = getOctClosest(field).id;
      Vec3D steer = mesh.tgField[ind].sub(vel);
      steer.normalizeTo(fI);
      acc.addSelf(steer);
    }
  }

  //_______ seek methods


  /*
  void seek(Attractor t) {
   Vec3D des = t.pos.sub(pos); // t.sub(pos);
   float dsq=des.magSquared(); // if in range
   if (dsq<t.rr) {
   des.normalizeTo(maxVel);
   Vec3D steer = des.sub(vel);
   steer.normalizeTo(map((t.rr-dsq)/t.rr, 0, 1, 0.1*t.charge, 0.8*t.charge));
   acc.add(steer);
   }
   }
   */

  void seek(Vec3D t) {
    Vec3D des = t.sub(fPos); //calculate from future position - OLD: t.sub(pos);
    des.normalizeTo(maxVel);
    Vec3D steer = des.sub(vel);
    steer.normalizeTo(maxForce);
    acc.addSelf(steer);
  }

  void seek(Vec3D t, float in) {
    Vec3D des = t.sub(pos); //calculate from future position - OLD: t.sub(pos);
    des.normalizeTo(maxVel);
    Vec3D steer = des.sub(vel);
    steer.normalizeTo(maxForce*in);
    acc.addSelf(steer);
  }

  void seek(Vec3D t, float range, float in) {
    float d = pos.distanceToSquared(t);
    if (d< range*range) {
      Vec3D des = t.sub(pos); //calculate from future position - OLD: t.sub(pos);
      des.normalizeTo(maxVel);
      Vec3D steer = des.sub(vel);
      //steer.normalizeTo(maxForce*in);
      steer.limit(maxForce*in);
      acc.addSelf(steer);
    }
  }

  Vec3D getNormalVel(Vec3D a, Vec3D b, boolean overshoot) {
    Vec3D np = getNormalPoint(pos, a, b, overshoot);
    Vec3D nv = pos.sub(np);
    nv.normalizeTo(maxVel);

    Vec3D axis = getTNBFrame(a, b)[1];

    nv.rotateAroundAxis(axis, PI*0.5);
    return nv;
  }

  Vec3D getNormalPoint(Vec3D p, Vec3D a, Vec3D b, boolean overshoot) {
    float segLen = a.distanceTo(b);
    // vector that points from a to p
    Vec3D ap = p.sub(a);
    // vector that points from a to b
    Vec3D ab = b.sub(a);

    //[full] Using the dot product for scalar projection
    ab.normalizeTo(ap.dot(ab.normalize()));
    //[end]
    // Finding the normal point along the line segment
    Vec3D normalPoint = a.add(ab);
    // checks if the point overshoots the extremities of the segment, in which case it returns the closest extremity
    if (!overshoot) {
      if (normalPoint.distanceTo(a) > segLen) { 
        return b;
      } else if (normalPoint.distanceTo(b) > segLen) {
        return a;
      } else {
        return normalPoint;
      }
    } else {
      return normalPoint;
    }
  }

  Vec3D[] getTNBFrame(Vec3D a, Vec3D b) {
    // gets the Frenet-Serret frame for a segment
    // also known as TNB frame (tangent, normal, binormal)
    if (a != b) {
      Vec3D[] tnb = new Vec3D[3];
      // tangent
      Vec3D t = b.sub(a).normalize();
      // normal
      Vec3D n = t.cross(a.add(b).normalize()).normalize();
      // binormal
      Vec3D bn = t.cross(n).normalize();
      tnb[0] = t;
      tnb[1] = n;
      tnb[2] = bn;
      return tnb;
    } else return null;
  }

  //_______ boundary methods

  void bounce() {
    if (pos.x > world.x*0.5 || pos.x <-world.x*0.5) vel.x *=-1;
    if (pos.y > world.y*0.5 || pos.y <-world.y*0.5) vel.y *=-1;
    if (pos.z > world.z*0.5 || pos.z <-world.z*0.5) vel.z *=-1;
  }


  void wrap() {
    if (pos.x > world.x*0.5) pos.x  = -world.x*0.5;
    else if (pos.x < -world.x*0.5) pos.x  = world.x*0.5;
    if (pos.y > world.y*0.5) pos.y  = -world.y*0.5;
    else if (pos.y < -world.y*0.5) pos.y  = world.y*0.5;
    if (pos.z > world.z*0.5) pos.z  = -world.z*0.5;
    else if (pos.z < -world.z*0.5) pos.z  = world.z*0.5;
  }

  //_______ trail methods

  void updateTrail(int freq) {
    if (frameCount % freq == 0) { 
      trail.add(pos.copy());
      trailV.add(vel.copy());
      if (trail.size()>nTrail) {
        trail.remove(0);
        trailV.remove(0);
      }
    }
  }

  void updateOcTrail(int freq, PointOctree trails) {
    if (frameCount % freq == 0) { 
      trail.add(pos.copy());
      trails.addPoint(pos.copy());
      trailV.add(vel.copy());
      if (trail.size()>nTrail) {
        trails.remove(trail.get(0));
        trail.remove(0);
        trailV.remove(0);
      }
    }
  }

  void updateStrand(int freq) {
    if (frameCount%freq==0) {
      strand.addPoint(new StrandPoint(pos.copy(), strand, strPtCount));
      strPtCount++;
    }
  }

  //_______ dispaly methods

  void display() {
    //float vM = vel.magSquared()/(maxVel*maxVel);
    //stroke(lerpColor(color(255, 0, 0), color(0), vM));
    stroke(200, 0, 0);
    strokeWeight(0.5);
    strokeWeight(2);
    point(pos.x, pos.y, pos.z);
  }



  void dispTrail(float w) {
    //stroke(0, 100);
    stroke(230, 100, 230, 180);
    strokeWeight(w);
    for (Vec3D p : trail) point(p.x, p.y, p.z);
  }

  void dispTrailCol(color cH, color cT, float w) {
    color c;
    float s = trail.size();
    strokeWeight(w);
    for (int i=0; i< trail.size(); i++) {
      Vec3D p = trail.get(i);
      c = lerpColor(cT, cH, i/s);
      stroke(c);
      point(p.x, p.y, p.z);
    }
  }

  void dispTrailCurve() {
    stroke(0, 100);
    strokeWeight(1);
    Vec3D p, p1;
    for (int i=0; i<trail.size()-1; i++) {
      p=trail.get(i);
      p1 =trail.get(i+1);
      if (p.distanceToSquared(p1)<10000) { // avoid drawing trail when wrapping
        line(p.x, p.y, p.z, p1.x, p1.y, p1.z);
      }
    }
  }

  void dispTrailV(float scale) {
    stroke(0, 100);
    strokeWeight(1);
    Vec3D p, p1;
    for (int i=0; i<trail.size(); i++) {
      p=trail.get(i);
      p1 =trailV.get(i).scale(scale).add(p);
      line(p.x, p.y, p.z, p1.x, p1.y, p1.z);
    }
  }

  void dispStrand() {
    strand.display();
  }
}