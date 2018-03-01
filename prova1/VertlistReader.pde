import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

class VertlistReader
{
  Object readFile(String filename) throws IOException
  {
    Scene.Object res=null;
    try (BufferedReader bf = Files.newBufferedReader(Paths.get(filename)))
    {
      String line = null;
      
      int nFaces=0;
      
      while ((line=bf.readLine())!=null)
      {
        
      }
      
      bf.close();
    }
    return res;
  }
}