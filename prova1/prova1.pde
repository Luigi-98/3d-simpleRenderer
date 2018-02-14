color background=color(255);
int time;
Scene scene;

void setup()
{
  size(640,480);
  background(0);
  stroke(255,255,0);
  fill(255);
  
  time=millis();
  scene=new Scene(1);
  Scene.Object cosa = scene.new Object(4);
  cosa.newTriangle(new PVector(0,0,-1), new PVector(1,0,-2), new PVector(1,1,-1), color(255,0,0));
  cosa.newTriangle(new PVector(0,0,-1), new PVector(0,1,-2), new PVector(1,1,-1),color(0,0,255));
  cosa.newTriangle(new PVector(0,0,-1), new PVector(-1,0,-2), new PVector(-1,1,-1),color(255,0,0));
  cosa.newTriangle(new PVector(0,0,-1), new PVector(0,1,-2), new PVector(-1,1,-1),color(0,0,255));
  scene.addObject(cosa);
  println("Scene setup took ",millis()-time," milliseconds.");
  
  time=millis();
  scene.renderer=new Renderer(640,480);
  scene.renderer.setScene(scene);
  println("Renderer setup took ",millis()-time," milliseconds.");
}

void draw()
{
  time=millis();
  scene.renderer.render();
  println("Rendering took ",millis()-time," milliseconds.");
}

static class Math
{
  static class Matrix
  {
    double a[][];
    int w,h;
    
    Matrix(int x, int y) {
      a=new double[y][x];
      w=x;
      h=y;
    }
    
    PVector applyTo(PVector v)
    {
      double k=1,a03=0,a13=0,a23=0;
      if (h==4) {
        k=1/(a[3][0]*v.x+a[3][1]*v.y+a[3][2]*v.z+a[3][3]);
        a03=a[0][3];
        a13=a[1][3];
        a23=a[2][3];
      }
      PVector result = new PVector();
      result.x=(float)(k*(a[0][0]*v.x+a[0][1]*v.y+a[0][2]*v.z+a03));
      result.y=(float)(k*(a[1][0]*v.x+a[1][1]*v.y+a[1][2]*v.z+a13));
      result.z=(float)(k*(a[2][0]*v.x+a[2][1]*v.y+a[2][2]*v.z+a23));
      return result;
    }
  }
  
  static PVector min(PVector A, PVector B, PVector C)
  {
    PVector res=new PVector(A.x<B.x?A.x:B.x,A.y<B.y?A.y:B.y);
    res.x=res.x<C.x?res.x:C.x;
    res.y=res.y<C.y?res.y:C.y;
    return res;
  }
  
  static PVector max(PVector A, PVector B, PVector C)
  {
    PVector res=new PVector(A.x>B.x?A.x:B.x,A.y>B.y?A.y:B.y);
    res.x=res.x>C.x?res.x:C.x;
    res.y=res.y>C.y?res.y:C.y;
    return res;
  }
}

class Scene
{
  class Object
  {
    int vertN=0, triangN=0;
    PVector[] vertexes;
    PVector[] projected;
    Triangle[] triangles;
    
    Object(int triangleN)
    {
      vertexes=new PVector[triangleN*3];
      projected=new PVector[triangleN*3];
      triangles=new Triangle[triangleN];
    }
    
    class Triangle
    {
      int Aid=-1,Bid=-1,Cid=-1;
      color a,b,c;
      
      Triangle(PVector A0, PVector B0, PVector C0, color c)
      {
        int q=3;
        for (int i=0; i<vertN; i++)
        {
          if (A0.equals(vertexes[i])) Aid=i+0*(q--);
          if (B0.equals(vertexes[i])) Bid=i+0*(q--);
          if (C0.equals(vertexes[i])) Cid=i+0*(q--);
          if (q==0) break;
        }
        if (Aid==-1) Aid=newVert(A0);
        if (Bid==-1) Bid=newVert(B0);
        if (Cid==-1) Cid=newVert(C0);
        
        a=c;
      }
      
      Triangle(int A, int B, int C) {Aid=A; Bid=B; Cid=C;}
    }
    
    int newTriangle(PVector A, PVector B, PVector C, color a)
    {
      triangles[triangN]=new Triangle(A,B,C,a);
      return triangN++;
    }
    
    int newVert(PVector P)
    {
      vertexes[vertN]=P;
      return vertN++;
    }
  }
  
  int nObjects=0;
  Object[] objects;
  Renderer renderer;
  
  Scene(int objectsN)
  {
    objects=new Object[objectsN];
  }
  
  int addObject(Object obj)
  {
    objects[nObjects]=obj;
    return nObjects++;
  }
}

class Renderer
{
  int w=640, h=480;
  double r=1,t=1,n=1,f=2;
  Math.Matrix projection;
  Pixel zbuffer[][];
  Scene scene;
  
  Renderer(int width, int height)
  {
    w=width;
    h=height;
    
    zbuffer=new Pixel[w][h];
    
    for (int x=0; x<w; x++) for (int y=0; y<h; y++) zbuffer[x][y]=new Pixel();

    projection = new Math.Matrix(4,4);
    projection.a[0][0]=n/r;
    projection.a[1][1]=n/t;
    projection.a[2][2]=-(f+n)/(f-n);
    projection.a[2][3]=-2*f*n/(f-n);
    projection.a[3][2]=-1;
    projection.a[0][1]=projection.a[0][2]=projection.a[0][3]=projection.a[1][0]=projection.a[1][2]=projection.a[1][3]=projection.a[2][0]=projection.a[2][1]=projection.a[3][0]=projection.a[3][1]=projection.a[3][3]=0;
  }
  
  void setScene(Scene scene)
  {
    this.scene=scene;
  }
  
  void project()
  {
    for (int j=0; j<scene.nObjects; j++)
    {
      for (int i=0; i<scene.objects[j].vertN; i++)
      {
        scene.objects[j].projected[i]=projection.applyTo(scene.objects[j].vertexes[i]);
        scene.objects[j].projected[i].x*=w/2;
        scene.objects[j].projected[i].y*=-h/2;
        scene.objects[j].projected[i].add(w/2,h/2);
      }
    }
  }
  
  void compareBuff(int objId, int tngId)
  {
    PVector a=scene.objects[objId].projected[scene.objects[objId].triangles[tngId].Aid], b=scene.objects[objId].projected[scene.objects[objId].triangles[tngId].Bid], c=scene.objects[objId].projected[scene.objects[objId].triangles[tngId].Cid];
    color col=scene.objects[objId].triangles[tngId].a;
    
    double kAB=(c.y-b.y)*(a.x-b.x)-(c.x-b.x)*(a.y-b.y);
    double kBC=(a.y-c.y)*(b.x-c.x)-(a.x-c.x)*(b.y-c.y);
    double kCA=(b.y-a.y)*(c.x-a.x)-(b.x-a.x)*(c.y-a.y);
    double D=1/(a.x*b.y-a.y*b.x-a.x*c.y+a.y*c.x+b.x*c.y-b.y*c.x);
    double Da=(a.z*b.y-a.y*b.z-a.z*c.y+a.y*c.z+b.z*c.y-b.y*c.z)*D;
    double Db=(a.x*b.z-a.z*b.x-a.x*c.z+a.z*c.x+b.x*c.z-b.z*c.x)*D;
    double Dc=((a.x*b.y-a.y*b.x)*c.z+(-a.x*c.y+a.y*c.x)*b.z+(b.x*c.y-b.y*c.x)*a.z)*D;
    PVector P0=Math.min(a,b,c), P1=Math.max(a,b,c);
    for (int x=(int)(P0.x>0?P0.x:0); x<(int)(P1.x<w?P1.x:w); x++)
    {
      for (int y=(int)(P0.y>0?P0.y:0); y<(int)(P1.y<h?P1.y:h); y++)
      {
        if ((kAB*((y-b.y)*(a.x-b.x)-(x-b.x)*(a.y-b.y))>=0)
          &&
           (kBC*((y-c.y)*(b.x-c.x)-(x-c.x)*(b.y-c.y))>=0)
          &&
           (kCA*((y-a.y)*(c.x-a.x)-(x-a.x)*(c.y-a.y))>=0))
        {
          // (x,y) is in triangle
          double dist=Da*x+Db*y+Dc;
          if (dist<zbuffer[x][y].dist)
           {
             zbuffer[x][y].dist=dist;
             zbuffer[x][y].id=tngId;
             zbuffer[x][y].col=col;
           }
        }
      }
    }
    return;
  }
  
  int[] render()
  {
    project();
    
    for (int j=0; j<scene.nObjects; j++)
    {
      for (int i=0; i<scene.objects[j].triangN; i++) compareBuff(j,i);
    }
      
    for (int x=0; x<w; x++)
    {
      for (int y=0; y<h; y++)
      {
        if (zbuffer[x][y].id!=-1)
        {
          stroke(zbuffer[x][y].col);
          point(x,y);
        }
        else
        {
          stroke(background);
          point(x,y);
        }
      }
    }
    //triangle(input[i].A1.x, input[i].A1.y, input[i].B1.x, input[i].B1.y, input[i].C1.x, input[i].C1.y);
    return new int[120];
  }
  
  class Pixel
  {
    int id=-1;
    double dist=Double.POSITIVE_INFINITY;
    color col=255;
  }
}