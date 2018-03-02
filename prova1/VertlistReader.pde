import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

static class VertlistReader
{
  static Scene.Object readFile(Scene scene, String filename) throws IOException
  {
    Scene.Object res=null;
    try
    {
      BufferedReader bf = Files.newBufferedReader(Paths.get(filename));
      
      String line = null;
      
      int nFaces=0, nVerts=0, vertN=0;
      int[] verts = null;
      
      boolean vertReading=false, facesReading=false;
      
      while ((line=bf.readLine())!=null)
      {
        if (line.startsWith("vertN:"))
        {
          nVerts=Integer.parseInt(line.split(" ")[1]);
          verts=new int[nVerts];
        }
        else if (line.startsWith("facesN:"))
        {
          nFaces=2*Integer.parseInt(line.split(" ")[1]);
          res=scene.new Object(nFaces);
        }
        else if (line.startsWith("Vertexes:"))
        {
          vertReading=true;
        }
        else if (line.startsWith("Faces:"))
        {
          facesReading=true;
        }
        else if (line.startsWith("EndVertexes"))
        {
          vertReading=false;
        }
        else if (line.startsWith("EndFaces"))
        {
          facesReading=false;
        }
        else
        {
          if (vertReading)
          {
            String[] vals = line.split(" ");
            verts[vertN++]=res.newVert(Float.parseFloat(vals[0]),Float.parseFloat(vals[1]),Float.parseFloat(vals[2]));
          }
          else if (facesReading)
          {
            String[] vals = line.split(" ");
            if (vals[0].equals("3"))
            {
              res.newTriangle(Integer.parseInt(vals[1]),Integer.parseInt(vals[2]),Integer.parseInt(vals[3]));
            }
            else if (vals[0].equals("4"))
            {
              res.newTriangle(Integer.parseInt(vals[1]),Integer.parseInt(vals[2]),Integer.parseInt(vals[3]));
              res.newTriangle(Integer.parseInt(vals[3]),Integer.parseInt(vals[4]),Integer.parseInt(vals[1]));
            }
          }
        }
      }
      
      bf.close();
    }
    catch (IOException e) {}
    return res;
  }
}