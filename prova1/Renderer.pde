class Renderer
{
  int w=640, h=480;
  double r=1,t=1,n=1,f=2;
  Math.Matrix projection, renderMatrix;
  Pixel zbuffer[][];
  Scene scene;
  PVector[][] projected;
  
  Renderer(int width, int height)
  {
    w=width;
    h=height;
    
    zbuffer=new Pixel[w][h];
    
    for (int x=0; x<w; x++) for (int y=0; y<h; y++) zbuffer[x][y]=new Pixel();

    projection = new Math.Matrix(4,4);
    projection.fill(0);
    projection.a[0][0]=n/r;
    projection.a[1][1]=n/t;
    projection.a[2][2]=-(f+n)/(f-n);
    projection.a[2][3]=-2*f*n/(f-n);
    projection.a[3][2]=-1;
    /*projection.a[0][0]=projection.a[1][1]=n;
    projection.a[2][2]=f/(f-n);
    projection.a[2][3]=-f*n/(f-n);
    projection.a[3][2]=1;*/
    Math.Matrix screenPositioning=new Math.Matrix(4,4);
    screenPositioning.fill(0);
    screenPositioning.a[0][0]=screenPositioning.a[0][3]=w/2;
    screenPositioning.a[1][1]=-(screenPositioning.a[1][3]=h/2);
    screenPositioning.a[2][2]=screenPositioning.a[3][3]=1;
    renderMatrix=screenPositioning.multiply(projection);
  }
  
  void setScene(Scene scene)
  {
    this.scene=scene;
    
    projected=new PVector[scene.nObjects][];
    
    for (int i=0; i<scene.nObjects; i++)
      projected[i]=new PVector[scene.objects[i].vertN];
  }
  
  void project(Math.Matrix renderMatrix)
  {
    for (int j=0; j<scene.nObjects; j++)
    {
      Math.Matrix objMatrix=renderMatrix.multiply(scene.objects[j].transformationMatrix);
      for (int i=0; i<scene.objects[j].vertN; i++)
      {
        projected[j][i]=objMatrix.applyTo(scene.objects[j].vertexes[i]);
      }
    }
  }
  
  void compareBuff()
  {
    for (int x=0; x<w; x++) for (int y=0; y<h; y++) zbuffer[x][y].reset();
    
    for (int objId=0; objId<scene.nObjects; objId++)
    {
      for (int tngId=0; tngId<scene.objects[objId].triangN; tngId++)
      {
        PVector a=projected[objId][scene.objects[objId].triangles[tngId].Aid], b=projected[objId][scene.objects[objId].triangles[tngId].Bid], c=projected[objId][scene.objects[objId].triangles[tngId].Cid];
        Color col=scene.objects[objId].triangles[tngId].a;
        col=col.r==-1?scene.objects[objId].col:col;
        if (a.z>=-1&&a.z<=1&&b.z>=-1&&b.z<=1&&c.z>=-1&&c.z<=1)
        {
          double Da=(a.z*b.y-a.y*b.z-a.z*c.y+a.y*c.z+b.z*c.y-b.y*c.z)/(a.x*b.y-a.y*b.x-a.x*c.y+a.y*c.x+b.x*c.y-b.y*c.x);
          double Db=(a.x*b.z-a.z*b.x-a.x*c.z+a.z*c.x+b.x*c.z-b.z*c.x)/(a.x*b.y-a.y*b.x-a.x*c.y+a.y*c.x+b.x*c.y-b.y*c.x);
          double Dc=((a.x*b.y-a.y*b.x)*c.z+(-a.x*c.y+a.y*c.x)*b.z+(b.x*c.y-b.y*c.x)*a.z)/(a.x*b.y-a.y*b.x-a.x*c.y+a.y*c.x+b.x*c.y-b.y*c.x);
          
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
        }
      }
    }
    return;
  }
  
  color shader(int x, int y)
  {
    Scene.Object obj=scene.objects[zbuffer[x][y].objId];
    Scene.Object.Triangle tng=obj.triangles[zbuffer[x][y].tngId];
    Color col0=zbuffer[x][y].col;
    
    //PVector A=obj.projected[tng.Aid], B=obj.projected[tng.Bid], C=obj.projected[tng.Cid];
    PVector A=projected[zbuffer[x][y].objId][tng.Aid], B=projected[zbuffer[x][y].objId][tng.Bid], C=projected[zbuffer[x][y].objId][tng.Cid];
    float   alpha=(float)(((B.y*C.z-B.z*C.y)*x+(B.z*C.x-B.x*C.z)*y+(B.x*C.y-B.y*C.x)*zbuffer[x][y].dist))/(A.x*(B.y*C.z-B.z*C.y)-B.x*(A.y*C.z-A.z*C.y)+C.x*(A.y*B.z-A.z*B.y)),
            beta=(float)(((-A.y*C.z+A.z*C.y)*x+(-A.z*C.x+A.x*C.z)*y+(-A.x*C.y+A.y*C.x)*zbuffer[x][y].dist)/(A.x*(B.y*C.z-B.z*C.y)-B.x*(A.y*C.z-A.z*C.y)+C.x*(A.y*B.z-A.z*B.y)));
    PVector n=obj.transformationMatrix.applyTo(PVector.add(PVector.mult(tng.nA,alpha),PVector.mult(tng.nB,beta)).add(PVector.mult(tng.nC,1-alpha-beta))).normalize(); // devi interpolare linearmente zbuffer[x][y].nA, .nB, .nC in x,y rispetto le coordinate proiettate
    for (int i=0; i<scene.nLights; i++)
    {
      float phong=scene.lights[i].direction.dot(n);
      col0=col0.multiply(phong, col0);//color(phong*red(col0),phong*green(col0),phong*blue(col0));
    }
    return col0.getColor();
  }
  
  int[] render()
  {
    int time=millis();
    int[] result=new int[w*h];
    project(renderMatrix);
    println("Projection time:", millis()-time);
    
    time=millis();
    compareBuff();
    println("Comparebuff time:", millis()-time);
    
    time=millis();
    background(background);
    loadPixels();
    for (int y=0; y<h; y++)
    {
      for (int x=0; x<w; x++)
      {
        if (zbuffer[x][y].tngId!=-1)
        {
          pixels[w*y+x]=result[w*y+x]=shader(x,y); //cnt = w*y+x
        }
      }
    }
    updatePixels();
    println("Drawing time:",millis()-time);
    return result;
  }
  
  class Pixel
  {
    int tngId=-1,objId=-1;
    double dist=Double.POSITIVE_INFINITY;
    Color col=new Color(0,0,0);
    
    void reset()
    {
      dist=Double.POSITIVE_INFINITY;
      tngId=objId=-1;
    }
    
    Pixel(int tngId, int objId, double dist, Color col)
    {
      this.tngId=tngId; this.objId=objId; this.dist=dist; this.col=col;
    }
    
    Pixel() {}
  }
}