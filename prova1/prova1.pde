import java.lang.Math;

color background=color(255);
int time,time2;
Scene scene;
int w=1024, h=768;
int nFrames=0;

void setup()
{
  size(1024,768);
  background(0);
  stroke(255,255,0);
  fill(255);
  
  time=millis();
  scene=new Scene(4,1);
  Scene.Object cosa = scene.new Object(4);
  cosa.newTriangle(new PVector(0,0,-1), new PVector(1,0,-2), new PVector(1,1,-1), color(255,0,0));
  cosa.newTriangle(new PVector(0,0,-1), new PVector(0,1,-2), new PVector(1,1,-1),color(0,0,255));
  cosa.newTriangle(new PVector(0,0,-1), new PVector(-1,0,-2), new PVector(-1,1,-1),color(255,0,0));
  cosa.newTriangle(new PVector(0,0,-1), new PVector(0,1,-2), new PVector(-1,1,-1),color(0,0,255));
  scene.addObject(cosa);
  scene.addParallelepiped(new PVector(0.2,0.2,-1), new PVector(0,0.5,0), new PVector(0.5,0,0), new PVector(0,0,-0.5), color(0,0,255));
  scene.addParallelepiped(new PVector(-0.8,-0.7,-0.8), new PVector(0,0.5,0), new PVector(0.5,0,0), new PVector(0,0,-0.5), color(74,214,54));
  /*Scene.Object triangle = scene.new Object(2);
  triangle.newTriangle(new PVector(-0.3,-0.2,-1.8), new PVector(-0.3,-0.2,-1.3), new PVector(0.2,-0.2,-1.8), color(255,0,0));
  triangle.newTriangle(new PVector(0.2,-0.2,-1.3), new PVector(-0.3,-0.2,-1.3), new PVector(0.2,-0.2,-1.8), color(255,0,0));
  scene.addObject(triangle);*/
  //for (int i=0; i<scene.objects[0].vertN; i++) println(scene.objects[0].vertexes[i]);
  scene.addSphere(new PVector(0,0,-1.5),0.5,20,20,color(255,0,0));
  scene.addLight(scene.new Light(2,2,1,new PVector(-0.3,-0.5,-0.7),color(255,255,255)));
  println("Scene setup took ",millis()-time," milliseconds.");
  
  time=millis();
  scene.renderer=new Renderer(w,h);
  scene.renderer.setScene(scene);
  println("Renderer setup took ",millis()-time," milliseconds.");
  time2=millis();
}

void draw()
{
  nFrames++;
  scene.objects[1].move(-0.01*0,0,-0.05);
  time=millis();
  scene.renderer.render();
  println("Rendering took ",millis()-time," milliseconds.");
  if (scene.objects[0].vertexes[0].x<=-1) println("TOTAL RENDERING TOOK: ", (millis()-time2)/nFrames, " per frame.");
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
    
    void fill(double n)
    {
      for (int x=0; x<w; x++)
        for (int y=0; y<h; y++)
          a[x][y]=n;
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
    color col;
    
    Object(int triangleN)
    {
      vertexes=new PVector[triangleN*3];
      projected=new PVector[triangleN*3];
      triangles=new Triangle[triangleN];
    }
    
    class Triangle
    {
      int Aid=-1,Bid=-1,Cid=-1;
      color a=-1,b=-1,c=-1;
      PVector nA, nB, nC;
      PVector barycAlpha, barycBeta;
      
      Triangle(PVector A0, PVector B0, PVector C0)
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
        
        //a=c;
        
        nA=nB=nC=PVector.sub(B0, A0).cross(PVector.sub(C0,A0)).normalize();
      }
      
      Triangle(PVector A0, PVector B0, PVector C0, color col)
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
        
        nA=nB=nC=PVector.sub(B0, A0).cross(PVector.sub(C0,A0)).normalize();
        
        a=col;
      }
      
      Triangle(int A, int B, int C) {Aid=A; Bid=B; Cid=C;}
      
      void initializeBarycentric()
      {
        PVector A=projected[Aid], B=projected[Bid], C=projected[Cid];
        float den=1/(A.x*(B.y*C.z-B.z*C.y)-B.x*(A.y*C.z-A.z*C.y)+C.x*(A.y*B.z-A.z*B.y));
        barycAlpha=new PVector((B.y*C.z-B.z*C.y),(B.z*C.x-B.x*C.z),(B.x*C.y-B.y*C.x));
        barycAlpha.mult(den);
        barycBeta=new PVector((-A.y*C.z+A.z*C.y),(-A.z*C.x+A.x*C.z),(-A.x*C.y+A.y*C.x));
        barycBeta.mult(den);
        return;
      }
    }
    
    int newTriangle(PVector A, PVector B, PVector C)
    {
      triangles[triangN]=new Triangle(A,B,C);
      return triangN++;
    }
    
    int newTriangle(PVector A, PVector B, PVector C, color c)
    {
      triangles[triangN]=new Triangle(A,B,C,c);
      return triangN++;
    }
    
    int newVert(PVector P)
    {
      vertexes[vertN]=P;
      return vertN++;
    }
    
    void move(float x, float y, float z)
    {
      Math.Matrix translation = new Math.Matrix(4,4);
      translation.fill(0);
      translation.a[0][0]=translation.a[1][1]=translation.a[2][2]=1;
      translation.a[0][3]=x;
      translation.a[1][3]=y;
      translation.a[2][3]=z;
      translation.a[3][3]=1;
      transform(translation);
    }
    
    void transform(Math.Matrix m)
    {
      for (int i=0; i<vertN; i++)
      {
        vertexes[i]=m.applyTo(vertexes[i]);
      }
      return;
    }
  }
  
  class Light
  {
    float x,y,z;
    color col;
    PVector direction;
    
    Light(float x, float y, float z, PVector direction, color col)
    {
      this.x=x; this.y=y; this.z=z; this.direction=direction.normalize(); this.col=col;
    }
  }
  
  int nObjects=0, nLights=0;
  Object[] objects;
  Light[] lights; 
  Renderer renderer;
  
  Scene(int objectsN, int lightsN)
  {
    objects=new Object[objectsN];
    lights=new Light[lightsN];
  }
  
  int addObject(Object obj)
  {
    objects[nObjects]=obj;
    return nObjects++;
  }
  
  int addLight(Light light)
  {
    lights[nLights]=light;
    return nLights++;
  }
  
  int addParallelepiped(PVector A, PVector l1, PVector l2, PVector l3, color col)
  {
    Object obj=new Object(12);
    PVector B=PVector.add(A,l1).add(l2).add(l3);
    obj.newTriangle(A, PVector.add(A,l1), PVector.add(A,l2));
    obj.newTriangle(PVector.add(A,l1).add(l2), PVector.add(A,l2), PVector.add(A,l1));
    obj.newTriangle(A, PVector.add(A,l2), PVector.add(A,l3));
    obj.newTriangle(PVector.add(A,l2).add(l3), PVector.add(A,l3), PVector.add(A,l2));
    obj.newTriangle(A, PVector.add(A,l3), PVector.add(A,l1));
    obj.newTriangle(PVector.add(A,l3).add(l1), PVector.add(A,l1), PVector.add(A,l3));
    obj.newTriangle(B, PVector.sub(B,l1), PVector.sub(B,l2));
    obj.newTriangle(PVector.sub(B,l1).sub(l2), PVector.sub(B,l2), PVector.sub(B,l1));
    obj.newTriangle(B, PVector.sub(B,l3), PVector.sub(B,l2));
    obj.newTriangle(PVector.sub(B,l2).sub(l3), PVector.sub(B,l2), PVector.sub(B,l3));
    obj.newTriangle(B, PVector.sub(B,l1), PVector.sub(B,l3));
    obj.newTriangle(PVector.sub(B,l3).sub(l1), PVector.sub(B,l3), PVector.sub(B,l1));
    obj.col=col;
    return addObject(obj);
  }
  
  int addSphere(PVector O, double R, int rows, int cols, color col)
  {
    Object obj=new Object(8*(rows+1)*(cols+1));
    PVector V[][]=new PVector[rows+1][cols+1];
    for (int r=0; r<=rows; r+=1)
    {
      float Rsinphi=(float)(R*java.lang.Math.sin(java.lang.Math.PI*r/rows)), Rcosphi=(float)(R*java.lang.Math.cos(java.lang.Math.PI*r/rows));
      for (int c=0; c<=cols; c+=1)
      {
        V[r][c]=new PVector((float)(java.lang.Math.cos(2*java.lang.Math.PI*c/cols)*Rsinphi),
                                  (float)(java.lang.Math.sin(2*java.lang.Math.PI*c/cols)*Rsinphi),
                                  (float)(Rcosphi)).add(O);
      }
    }
    for (int r=0; r<=rows-1; r++)
    {
      for (int c=0; c<=cols-1; c++)
      {
        int t7=obj.newTriangle(V[r][c],V[r+1][c+1],V[r+1][c]), t8=obj.newTriangle(V[r+1][c+1],V[r][c],V[r][c+1]);
        obj.triangles[t7].nC=PVector.sub(O,V[r+1][c]).normalize();
        obj.triangles[t8].nC=PVector.sub(O,V[r][c+1]).normalize();
        obj.triangles[t7].nB=obj.triangles[t8].nA=PVector.sub(O,V[r+1][c+1]).normalize();
        obj.triangles[t7].nA=obj.triangles[t8].nB=PVector.sub(O,V[r][c]).normalize();
      }
    }
    
    obj.col=col;
    return addObject(obj);
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
  
  void project(Math.Matrix projection)
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
  
  void compareBuff()
  {
    int timec=0;
    for (int x=0; x<w; x++) for (int y=0; y<h; y++) zbuffer[x][y].reset();
    
    for (int objId=0; objId<scene.nObjects; objId++)
    {
      for (int tngId=0; tngId<scene.objects[objId].triangN; tngId++)
      {
        PVector a=scene.objects[objId].projected[scene.objects[objId].triangles[tngId].Aid], b=scene.objects[objId].projected[scene.objects[objId].triangles[tngId].Bid], c=scene.objects[objId].projected[scene.objects[objId].triangles[tngId].Cid];
        color col=scene.objects[objId].triangles[tngId].a;
        col=col==-1?scene.objects[objId].col:col;
        
        double D=1/(a.x*b.y-a.y*b.x-a.x*c.y+a.y*c.x+b.x*c.y-b.y*c.x);
        double Da=(a.z*b.y-a.y*b.z-a.z*c.y+a.y*c.z+b.z*c.y-b.y*c.z)*D;
        double Db=(a.x*b.z-a.z*b.x-a.x*c.z+a.z*c.x+b.x*c.z-b.z*c.x)*D;
        double Dc=((a.x*b.y-a.y*b.x)*c.z+(-a.x*c.y+a.y*c.x)*b.z+(b.x*c.y-b.y*c.x)*a.z)*D;
        timec=millis()-timec;
        
        PVector A,B,C;
        if (a.y<=b.y&&a.y<=c.y)  // Praticamente sto imponendo A.y<=B.y<=C.y
        { A=a; if (b.y<c.y) {B=b; C=c;} else {B=c; C=b;} }
        else if (b.y<=a.y&&b.y<=c.y)
        { A=b; if (a.y<c.y) {B=a; C=c;} else {B=c; C=a;} }
        else
        { A=c; if (a.y<b.y) {B=a; C=b;} else {B=b; C=a;} }
        
        //DRAWING BASE DOWN TRIANGLE
        
        double m1, m2, switchterm;
        int y0=(int)java.lang.Math.floor(A.y>0?A.y:0), y1=(int)java.lang.Math.floor(B.y<h?B.y:h);
        
        for (int i=0; i<2; i++) // i=0 ==> Base-down triangle, i=1 ==> Base-up triangle.
        {
          if (A.y!=B.y)
          {
            m1=(A.x-B.x)/(A.y-B.y);
            m2=(A.x-C.x)/(A.y-C.y);
            if (m1*(1-2*i)>m2*(1-2*i)) { switchterm=m1; m1=m2; m2=switchterm; }
            double x0=A.x+m1*(y0-A.y), x1=A.x+m2*(y0-A.y);
            for (int y=y0; y<y1; y++)
            {
              x0+=m1; x1+=m2;
              for (int x=(int)(x0>0?x0:0); x<=(x1<w-1?x1:(w-1)); x++)
              {
                if (Da*x+Db*y+Dc<zbuffer[x][y].dist)
                 {
                   zbuffer[x][y].dist=Da*x+Db*y+Dc;
                   zbuffer[x][y].tngId=tngId;
                   zbuffer[x][y].objId=objId;
                   zbuffer[x][y].col=col;
                 }
              }
            }
          }
          
          PVector A1=A; A=C; C=A1;
          y0=(int)java.lang.Math.floor(B.y>0?B.y:0); y1=(int)java.lang.Math.floor(A.y<h?A.y:h);
        }
        timec=millis()-timec;
      }
    }
    println("Time taken by comparebuff: ",timec);
    return;
  }
  
  color shader(int x, int y)
  {
    Scene.Object obj=scene.objects[zbuffer[x][y].objId];
    Scene.Object.Triangle tng=obj.triangles[zbuffer[x][y].tngId];
    color col0=zbuffer[x][y].col;
    tng.initializeBarycentric();
    /**
      Bisogna interpolare considerando che nA, nB ed nC sono i valori della funzione
        in (x,y,zbuffer[x][y].dist).
        
        x ed y vanno bene quelli.
        
       No, non esattamente: le coordinate proiettate non conservano proporzioni né aree, ma noi approssimiamo.
    **/
    
    float   alpha=tng.barycAlpha.dot(new PVector((float)x,(float)y,(float)zbuffer[x][y].dist)),
            beta=tng.barycBeta.dot(new PVector((float)x,(float)y,(float)zbuffer[x][y].dist));
    PVector n=PVector.add(PVector.mult(tng.nA,alpha),PVector.mult(tng.nB,beta)).add(PVector.mult(tng.nC,1-alpha-beta)); // devi interpolare linearmente zbuffer[x][y].nA, .nB, .nC in x,y rispetto le coordinate proiettate
    for (int i=0; i<scene.nLights; i++)
    {
      float phong=scene.lights[i].direction.dot(n);
      col0=color(phong*red(col0),phong*green(col0),phong*blue(col0));
    }
    return col0;
  }
  
  int[] render()
  {
    int[] result=new int[w*h];
    project();
    
    compareBuff();
    
    int time=millis();
    background(background);
    loadPixels();
    for (int x=0; x<w; x++)
    {
      for (int y=0; y<h; y++)
      {
        if (zbuffer[x][y].tngId!=-1)
        {
          pixels[y*w+x]=result[y*w+x]=shader(x,y);
        }
      }
    }
    updatePixels();
    println(millis()-time);
    return result;
  }
  
  class Pixel
  {
    int tngId=-1,objId=-1;
    double dist=Double.POSITIVE_INFINITY;
    color col=255;
    
    void reset()
    {
      dist=Double.POSITIVE_INFINITY;
      tngId=objId=-1;
    }
    
    Pixel(int tngId, int objId, double dist, color col)
    {
      this.tngId=tngId; this.objId=objId; this.dist=dist; this.col=col;
    }
    
    Pixel() {}
  }
}