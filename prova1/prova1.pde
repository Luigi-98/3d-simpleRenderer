color background=color(255);

void setup()
{
  size(640,480);
  background(0);
  stroke(255,255,0);
  fill(255);
}

void draw()
{
  Scene scene=new Scene();
  Scene.Object cosa = new Scene.Object();
  cosa.newTriangle(new PVector(0,0,-1), new PVector(1,0,-2), new PVector(1,1,-1), color(255,0,0));
  cosa.newTriangle(new PVector(0,0,-1), new PVector(0,1,-2), new PVector(1,1,-1),color(0,0,255));
  cosa.newTriangle(new PVector(0,0,-1), new PVector(-1,0,-2), new PVector(-1,1,-1),color(255,0,0));
  cosa.newTriangle(new PVector(0,0,-1), new PVector(0,1,-2), new PVector(-1,1,-1),color(0,0,255));
  render(input);
}

class Math
{
  class Matrix
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
  
  PVector min(PVector A, PVector B, PVector C)
  {
    PVector res=new PVector(A.x<B.x?A.x:B.x,A.y<B.y?A.y:B.y);
    res.x=res.x<C.x?res.x:C.x;
    res.y=res.y<C.y?res.y:C.y;
    return res;
  }
  
  PVector max(PVector A, PVector B, PVector C)
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
    
    class Triangle
    {
      int Aid=-1,Bid=-1,Cid=-1;
      color a,b,c;
      
      Triangle(PVector A0, PVector B0, PVector C0, color c=color(255,255,255))
      {
        for (int i=0; i<vertN; i++)
        {
          if (A0==vertexes[i]) Aid=i;
          if (B0==vertexes[i]) Bid=i;
          if (C0==vertexes[i]) Cid=i;
        }
        if (Aid==-1) Aid=newVert(A0);
        if (Bid==-1) Bid=newVert(B0);
        if (Cid==-1) Cid=newVert(C0);
        
        a=c;
      }
      
      Triangle(int A,B,C) {Aid=A; Bid=B; Cid=C;}
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
  
  int addObject(Object obj)
  {
    objects[nObjects]=obj;
    return nObjects++;
  }
  
  class Renderer
  {
    int w=640, h=480;
    double r=1,t=1,n=1,f=2;
    Matrix projection;
    Pixel zbuffer[][];
    
    Renderer(int width, int height)
    {
      w=width;
      h=height;
      
      zbuffer[][]=new Pixel[w][h];
      
      for (int x=0; x<w; x++) for (int y=0; y<h; y++) zbuffer[x][y]=new Pixel();

      projection = new Matrix(4,4);
      projection.a[0][0]=n/r;
      projection.a[1][1]=n/t;
      projection.a[2][2]=-(f+n)/(f-n);
      projection.a[2][3]=-2*f*n/(f-n);
      projection.a[3][2]=-1;
      projection.a[0][1]=projection.a[0][2]=projection.a[0][3]=projection.a[1][0]=projection.a[1][2]=projection.a[1][3]=projection.a[2][0]=projection.a[2][1]=projection.a[3][0]=projection.a[3][1]=projection.a[3][3]=0;
    }
    
    void project()
    {
      for (int i=0; i<vertN; i++)
      {
        projected[i]=projection.applyTo(vertexes[i]);
        projected[i].x*=w/2;
        projected[i].y*=-h/2;
        projected[i].add(w/2,h/2);
      }
    }
    
    void compareBuff(int id)
    {
      PVector a=projected[triangles[id].Aid], b=projected[triangles[id].Bid], c=projected[triangles[id].Cid];
      color col=triangles[id].col;
      
      double kAB=(c.y-b.y)*(a.x-b.x)-(c.x-b.x)*(a.y-b.y);
      double kBC=(a.y-c.y)*(b.x-c.x)-(a.x-c.x)*(b.y-c.y);
      double kCA=(b.y-a.y)*(c.x-a.x)-(b.x-a.x)*(c.y-a.y);
      double D=1/(a.x*b.y-a.y*b.x-a.x*c.y+a.y*c.x+b.x*c.y-b.y*c.x);
      double Da=(a.z*b.y-a.y*b.z-a.z*c.y+a.y*c.z+b.z*c.y-b.y*c.z)*D;
      double Db=(a.x*b.z-a.z*b.x-a.x*c.z+a.z*c.x+b.x*c.z-b.z*c.x)*D;
      double Dc=((a.x*b.y-a.y*b.x)*c.z+(-a.x*c.y+a.y*c.x)*b.z+(b.x*c.y-b.y*c.x)*a.z)*D;
      PVector P0=min(a,b,c), P1=max(a,b,c);
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
               zbuffer[x][y].id=id;
               zbuffer[x][y].col=col;
             }
          }
        }
      }
      return zbuffer;
    }
    
    int[] render()
    {
      project();
      
      for (int i=0; i<input.length; i++)
      {
        compareBuff(i);
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
}