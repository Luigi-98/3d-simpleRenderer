import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

class Objreader
{
  Scene readFile(String filename) throws IOException
  {
    Scene res;
    try (BufferedReader bf = Files.newBufferedReader(Paths.get(filename)))
    {
      int nObj=0, nLights=0;
      String line = null;
      
      List<Integer> objFaces = new ArrayList<Integer>();
      int nFaces=0;
      
      while ((line=bf.readLine())!=null)
      {
        if (line.startsWith("o ")) {nObj++; objFaces.add(nFaces); nFaces=0;}
        else if (line.startsWith("f ")) nFaces++;
      }
      
      bf.close();
      try (BufferedReader bf2 = Files.newBufferedReader(Paths.get(filename)))
      {
        res = new Scene(nObj, nLights);
        Scene.Object obj=null;
        int objN=0;
        while ((line=bf2.readLine())!=null)
        {
          if (line.startsWith("o "))
          {
            if (obj!=null) res.addObject(obj);
            obj = res.new Object(objFaces.get(objN++)*2);
          }
          else if (line.startsWith("v "))
          {
            
          }
        }
      }
    }
    return res;
  }
}