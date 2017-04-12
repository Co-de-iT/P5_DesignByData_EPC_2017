

void exportBodies(AgentBody[] agents, String fileName) {

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

  println(fileName, "file Saved");
}