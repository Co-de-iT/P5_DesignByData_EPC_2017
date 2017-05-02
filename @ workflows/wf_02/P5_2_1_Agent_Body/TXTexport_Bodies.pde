/*

 body export functions
 
 format:
 
 <agent number> <body type> <center point> <forward direction> <tip 1 position> ... <tip n position> <tip 1 connection 1>,<tip 1 connection 2>_...<tip n connection 1>,<tip n connection 2>...
 
 The tip connection format is:
 
 ot.agent.id;ot.agent.body.tip.id
 
 */

void exportBodies(AgentBody[] agents, String fileName) {

  // String eol = System.getProperty("line.separator"); // line separator character
  String dir = "export_data/"+nf(frameCount, 4)+ fileName +".txt";
  String cS =","; // coordinate separator
  String pS = " ";// point separator
  String aS = "_"; // argument separator

  PrintWriter output = createWriter(dir);   //Create a new PrintWriter object

  println("creating", dir+" file");

  int count =0;

  for (AgentBody a : agents) {
    //output.println("body");
    // body agent number
    output.print(count);
    // body type
    output.print(pS+a.body.type);
    // core
    output.print(pS+a.body.core.x+cS+a.body.core.y+cS+a.body.core.z);
    // forward dir
    output.print(pS+a.body.forward.x+cS+a.body.forward.y+cS+a.body.forward.z);
    // tips
    for (int i=0; i< a.body.tips.length; i++) {
      Tip t = a.body.tips[i];
      // tip position
      output.print(pS+t.x+cS+t.y+cS+t.z);
    }
    output.print(pS);
    for (int i=0; i< a.body.tips.length; i++) {
      Tip t = a.body.tips[i];
      // tip connections indexes
      for (int j=0; j< t.connInd.size(); j++) {
        TIndex tc = t.connInd.get(j);
        output.print(tc.asString());
        if (j!=t.connInd.size()-1) output.print(cS);
      }
      if (i!= a.body.tips.length-1) output.print(aS);
    }
    output.println();
    count++;
  }

  output.flush();  //Write the remaining data to the file
  output.close();  //Finishes the files

  println(dir, "file Saved");
}

//// deprecated functions

/*

 void exportBodies_OLD(AgentBody[] agents, String fileName) {
 
 // String eol = System.getProperty("line.separator"); // line separator character
 String dir = "export_data/"+nf(frameCount, 4)+ fileName +".txt";
 String cS =","; // coordinate separator
 String pS = " ";// point separator
 String aS = "_"; // argument separator
 
 PrintWriter output = createWriter(dir);   //Create a new PrintWriter object
 
 println("creating", fileName+".txt file");
 
 int count =0;
 
 for (AgentBody a : agents) {
 
 // first row identifies the agent number
 output.print(count+aS);
 // second row is the body type
 output.print(a.body.type+aS);
 // first point is the core - others are the "arms"
 output.print(a.body.core.x+cS+a.body.core.y+cS+a.body.core.z);
 for (int i=0; i< a.body.tips.length; i++) {
 Tip t = a.body.tips[i];
 output.print(pS+t.x+cS+t.y+cS+t.z);
 }
 count++;
 output.println();
 }
 
 output.flush();  //Write the remaining data to the file
 output.close();  //Finishes the files
 
 println(dir, "file Saved");
 }
 
 
 void exportBodiesFlat(AgentBody[] agents, String fileName) {
 
 // String eol = System.getProperty("line.separator"); // line separator character
 String dir = "export_data/"+nf(frameCount, 4)+ fileName +".txt";
 String cS =","; // coordinate separator
 String pS = " ";// point separator
 String tS = "-"; // topology separator
 
 PrintWriter output = createWriter(dir);   //Create a new PrintWriter object
 
 println("creating", fileName+".txt file");
 
 int count =0;
 
 for (AgentBody a : agents) {
 //output.println("body_"+count);
 // first point is the core - others are the "arms"
 output.print(a.body.core.x+cS+a.body.core.y+cS+a.body.core.z);
 for (int i=0; i< a.body.tips.length; i++) {
 Tip t = a.body.tips[i];
 output.print(pS+t.x+cS+t.y+cS+t.z);
 }
 count++;
 output.println();
 }
 
 output.flush();  //Write the remaining data to the file
 output.close();  //Finishes the files
 
 println(dir, "file Saved");
 }
 
 */