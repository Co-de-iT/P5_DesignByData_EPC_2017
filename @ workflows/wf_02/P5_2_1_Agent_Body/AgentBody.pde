class AgentBody {

  /*
   
   NOTE: align body only once, when rotation is complete - otherwise body gets f**ed up
   while rotation and/or movement is going on use align points just for body temporary display
   
   YES, IT IS A BUG!!! I'll try to solve it in the future.....
   
   in connect, the angVis filter doesn't work porperly.... check
   
   */

  int id;
  float maxForce;
  Vec3D pos, vel;
  Plane plane;
  Body body;
  boolean locked, aligned, connected; // if agent does not rotate/move around anymore - aligned to check if align was performed already
  ArrayList<Line3D> Connections;
  // constructor(s)

  AgentBody(Vec3D pos, Vec3D vel, int id, int bType, boolean locked) {
    this.pos = pos;
    this.vel = vel;
    this.id=id;
    this.locked = locked;
    plane = new Plane(pos, vel);
    maxForce = 0.05;
    body = new Body(bType); 
    aligned = false;
    connected = false;
  }


  AgentBody(Vec3D pos, Vec3D vel, int id, boolean locked) {
    this(pos, vel, id, 0, locked); // creates a standard Body, type 0 (3-fork)
  }

  void update(AgentBody[] agents, float aR, float sR) {
    if (!locked) { 
      separate(agents, sR);
      alignWithNeighbors(agents, aR);
    } else {
      if (!aligned)alignBody();
      if (!connected) {
        connect(agents);
      }
    }
  }

  void separate(AgentBody[] agents, float sR) {

    Vec3D steer = new Vec3D();
    int sC=0;

    for (int i=0; i< agents.length; i++) {
      if (agents[i] != this) {
        if (pos.distanceTo(agents[i].pos)<sR) {
          sC++;
          steer.addSelf(pos.sub(agents[i].pos)); // vector from other to self
        }
      }
    }
    if (sC >0) {
      steer.scaleSelf(1/(float)sC);
      steer.scaleSelf(maxForce);
    }
    pos.addSelf(steer);
    // vel.normalize();
    plane = new Plane(pos, vel);
  }

  void alignWithNeighbors(AgentBody[] agents, float aR) {
    Vec3D steer = new Vec3D();
    int aC=0;

    for (int i=0; i< agents.length; i++) {
      if (agents[i] != this) {
        if (pos.distanceTo(agents[i].pos)<aR) {
          aC++;
          steer.addSelf(agents[i].vel.sub(vel));
        }
      }
    }
    if (aC >0) {
      steer.scaleSelf(1/(float)aC);
      steer.scaleSelf(maxForce);
    }
    vel.addSelf(steer);
    vel.normalize();
    plane = new Plane(pos, vel);
  }

  void alignWithNeighbor(AgentBody[] parts) {
    Vec3D steer = new Vec3D();
    AgentBody neigh = closestNeigh(parts);
    if (neigh!=null) {
      steer = neigh.vel.sub(vel);
      steer.scaleSelf(maxForce);
    }
    vel.addSelf(steer);
    vel.normalize();
    plane = new Plane(pos, vel);
  }

  void alignWithField(TensorPt[] field, float fI) {
    Vec3D steer = new Vec3D();
    TensorPt neigh = closestFNeigh(field); // find neares field point for orientation
    if (neigh!=null) {
      steer = neigh.dir.sub(vel);
      steer.scaleSelf(fI);
    }
    vel.addSelf(steer);
    vel.normalize();
    plane = new Plane(pos, vel);
  }

  // connect:
  //
  // . if a free tip sees another free tip, join in the middle
  // . if the other tip is already locked but still in range, move there

  void connect(AgentBody[] agents) {
    float rr, ang;
    Vec3D dir, target, average;
    // for each of our tips (t)
    for (Tip t : body.tips) {
      // if tip hasn't reached max connections and it's not locked
      if (t.connections.size() < t.maxConn && !t.locked) {
        //dir = t.sub(body.core).normalize(); // calculates direction
        rr = t.rad*t.rad; // calculates squared radius (allows faster comparisons for distance)
        // scan all other agents
        for (AgentBody other : agents) {
          // but don't scan yourself
          if (other != this) { 
            // scan all other agents' tips (ot)
            for (Tip ot : other.body.tips) {
              // if other tip hasn't reached max connections
              if (ot.connections.size()<ot.maxConn) {
                target = ot.sub(t); // find target direction
                // if other tip is within search radius 
                if (target.magSquared()< rr) {
                  //if (dir.angleBetween(target, true)<t.angVis) { // and within vision angle - visAng filter not working >> check
                  // inAngle++;  
                  
                  // if other tip is already locked move there, else join in average point
                  if (ot.locked) {
                    t.set(ot);
                    t.connections.add(ot);
                    t.connInd.add(new TIndex(other.id,ot.id));
                    ot.connections.add(t);
                    ot.connInd.add(new TIndex(id,t.id));
                    t.locked = true; 
                    break;
                  } else {
                    average = t.add(ot).scale(0.5);
                    t.set(average); // moveTo
                    ot.set(average);// moveTo
                    t.connections.add(ot);
                    t.connInd.add(new TIndex(other.id,ot.id));
                    ot.connections.add(t);
                    ot.connInd.add(new TIndex(id,t.id));
                    t.locked = true;
                    ot.locked = true;
                    break;
                  }
                  //}
                }
              }
            }
          } // end if (other != this)
        } // end for (AgentBody other : agents)
      } // end if t.conn
      if (t.connections.size() == 0) t.locked = false;
    } // end for (Tip t : body.tips)
    connected = true;
  }

  // connects only one closest tip and then stops

  void connectSingle(AgentBody[] agents) {
    float rr, ang;
    Vec3D dir, target, average;
    // for each of our tips (t)
    for (Tip t : body.tips) {
      // if tip hasn't reached max connections and it's not locked
      if (t.connections.size() < t.maxConn && !t.locked) {
        //dir = t.sub(body.core).normalize(); // calculates direction
        rr = t.rad*t.rad; // calculates squared radius (allows faster comparisons for distance)
        // scan all other agents
        for (AgentBody other : agents) {
          // but don't scan yourself
          if (other != this) { 
            // scan all other agents' tips (ot)
            for (Tip ot : other.body.tips) {
              // if other tip hasn't reached max connections and not locked
              if (ot.connections.size()<ot.maxConn && !ot.locked) {
                target = ot.sub(t); // find target direction
                // if other tip is within search radius 
                if (target.magSquared()< rr) {
                  //if (dir.angleBetween(target, true)<t.angVis) { // and within vision angle - visAng filter not working >> check
                  // inAngle++;  
                  average = t.add(ot).scale(0.5);
                  t.set(average); // moveTo
                  ot.set(average);// moveTo
                  t.connections.add(ot);
                  ot.connections.add(t);
                  t.locked = true;
                  ot.locked = true;
                  break;
                  //}
                }
              }
            }
          } // end if (other != this)
        } // end for (AgentBody other : agents)
      } // end if t.conn
      if (t.connections.size() == 0) t.locked = false;
    } // end for (Tip t : body.tips)
    connected = true;
  }

  // performs a cohesion among tips (to be implemented)
  void seekConnect(AgentBody[] agents) {
    float rr, ang;
    Vec3D dir, target, average;
    // for each of our tips (t)
    for (Tip t : body.tips) {
      // if tip hasn't reached max connections and it's not locked
      if (t.connections.size() < t.maxConn && !t.locked) {
        //dir = t.sub(body.core).normalize(); // calculates direction
        rr = t.rad*t.rad; // calculates squared radius (allows faster comparisons for distance)
        // scan all other agents
        for (AgentBody other : agents) {
          // but don't scan yourself
          if (other != this) { 
            // scan all other agents' tips (ot)
            for (Tip ot : other.body.tips) {
              // if other tip hasn't reached max connections and not locked
              if (ot.connections.size()<ot.maxConn && !ot.locked) {
                target = ot.sub(t); // find target direction
                // if other tip is within search radius 
                if (target.magSquared()< rr) {
                  //if (dir.angleBetween(target, true)<t.angVis) { // and within vision angle - visAng filter not working >> check
                  // inAngle++;  
                  average = t.add(ot).scale(0.5);
                  t.set(average); // moveTo
                  ot.set(average);// moveTo
                  t.connections.add(ot);
                  ot.connections.add(t);
                  //t.locked = true;
                  //ot.locked = true;
                  //break;
                  //}
                }
              }
            }
          } // end if (other != this)
        } // end for (AgentBody other : agents)
        t.cohesion();
      } // end if t.conn
      if (t.connections.size() == 0) t.locked = false;
    } // end for (Tip t : body.tips)
    connected = true;
  }


  AgentBody closestNeigh (AgentBody[] parts) {
    int neigh=-1;
    float distSq, minDist = Float.MAX_VALUE;

    // find closest neighbor
    for (int i=0; i< parts.length; i++) {
      if (parts[i] != this) {
        distSq = pos.distanceToSquared(parts[i].pos);
        if (distSq < minDist) {
          neigh = i;
          minDist = distSq;
        }
      }
    }
    return neigh!=-1?parts[neigh]:null;
  }

  TensorPt closestFNeigh (TensorPt[] field) {
    int neigh=-1;
    float distSq, minDist = Float.MAX_VALUE;

    // find closest neighbor
    for (int i=0; i< field.length; i++) {
      distSq = pos.distanceToSquared(field[i]);
      if (distSq < minDist) {
        neigh = i;
        minDist = distSq;
      }
    }
    return neigh!=-1?field[neigh]:null;
  }

  // ___________________ display functions

  void displayBody() {
    strokeWeight(1);
    if (!locked) {
      stroke(255);
      Vec3D[] pts = alignPoints(body.tips, body.forward);
      for (Vec3D p : pts) {
        line(pos.x, pos.y, pos.z, p.x, p.y, p.z);
      }
    } else if (aligned) {
      strokeWeight(2);
      if (!connected) stroke(0); 
      else stroke(255, 121, 233, 120);
      for (Tip t : body.tips) {
        line(pos.x, pos.y, pos.z, t.x, t.y, t.z);
      }
      for (Tip t : body.tips) {
        t.display();
      }
    }
  }

  // align set of points to current plane position (pre-visualization)

  Vec3D[] alignPoints(Vec3D[] pts, Vec3D sDir) {
    Vec3D[] outPts = new Vec3D[pts.length];
    // calculate alignment orientation for source direction
    Quaternion alignment = Quaternion.getAlignmentQuat(vel, sDir);
    // construct a matrix to move shape to current curve position
    Matrix4x4 mat=new Matrix4x4().translateSelf(pos);
    // then combine with alignment matrix
    mat.multiplySelf(alignment.toMatrix4x4());
    // then apply matrix to (copies of) all source points
    for (int i=0; i< pts.length; i++) {
      outPts[i] = mat.applyToSelf(pts[i].copy());
    }
    return outPts;
  }

  void alignBody() {
    if (locked && !aligned) { // to perform ONLY if agent is locked and it was not done before
      Vec3D[] newTips = alignPoints(body.tips, body.forward);
      for (int i=0; i< newTips.length; i++) {
        body.tips[i].x = newTips[i].x;
        body.tips[i].y = newTips[i].y;
        body.tips[i].z = newTips[i].z;
      }

      body.forward = vel.copy().normalize();
      body.core = pos.copy();
      aligned = true;
    }
  }

  void displayPos() {
    stroke(0);
    strokeWeight(3);
    point(pos.x, pos.y, pos.z);
  }

  void displayVel(float scale) {
    Vec3D p = pos.add(vel.scale(scale));
    stroke(0, 0, 255);
    strokeWeight(1);
    line(pos.x, pos.y, pos.z, p.x, p.y, p.z);
  }

  void displayPlane(float scale) {
    gfx.meshNormalMapped(plane.toMesh(scale), false);
  }

  void displayAxis(float scale) {
    float[] axis=Quaternion.getAlignmentQuat(vel, Vec3D.Z_AXIS).toAxisAngle();
    pushMatrix();
    strokeWeight(1);
    // move to currposition
    gfx.translate(pos);
    // rotate around computed axis
    rotate(axis[0], axis[1], axis[2], axis[3]);
    // draw rotated coordinate system
    gfx.origin(new Vec3D(), scale);
    popMatrix();
  }

  // ___________________ old/bugged functions (for future implementation)

  /*
  
   void displayAxis_OLD(float scale) {
   Vec3D x = cs[0].scale(scale);
   Vec3D y = cs[1].scale(scale);
   Vec3D z = cs[2].scale(scale);
   
   strokeWeight(1);
   stroke(255, 0, 0);
   line(pos.x, pos.y, pos.z, pos.x+x.x, pos.y+x.y, pos.z+x.z);
   stroke(0, 255, 0);
   line(pos.x, pos.y, pos.z, pos.x+y.x, pos.y+y.y, pos.z+y.z);
   stroke(0, 0, 255);
   line(pos.x, pos.y, pos.z, pos.x+z.x, pos.y+z.y, pos.z+z.z);
   }
   
   void displayBody_BUGGED() {
   stroke(255);
   strokeWeight(1);
   
   for (Tip t : body.tips) {
   line(pos.x, pos.y, pos.z, t.x, t.y, t.z);
   }
   }
   */

  /*
  void updateBody_OLD() {
   //alignTips(body.tips, body.forward);
   alignBody_OLDBUGGED(body);
   }
   
   void alignBody_BUGGED() {
   Vec3D[] newTips = alignPoints(body.tips, body.forward);
   for (int i=0; i< newTips.length; i++) {
   body.tips[i].x = newTips[i].x;
   body.tips[i].y = newTips[i].y;
   body.tips[i].z = newTips[i].z;
   }
   
   body.forward = vel.copy().normalize();
   body.core = pos.copy();
   }
   
   void alignBody_OLDBUGGED(Body body) {
   // calculate alignment orientation for source direction
   Quaternion alignment = Quaternion.getAlignmentQuat(vel, body.forward);
   // construct a matrix to move shape to current agent position
   Matrix4x4 mat=new Matrix4x4().translateSelf(pos.sub(body.core));
   
   // then combine with alignment matrix
   mat.multiplySelf(alignment.toMatrix4x4());
   
   // then apply matrix to (copies of) all source points
   for (int i=0; i< body.tips.length; i++) {
   mat.applyToSelf(body.tips[i]);
   }
   body.forward = vel.copy().normalize();
   body.core = pos.copy();
   // update base point for tips
   for (Tip t : body.tips) {
   t.base = body.core;
   }
   }
   */
}