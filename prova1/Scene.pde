import java.lang.Math;

class Scene
{
  class Object
  {
    int vertN=0, triangN=0;
    PVector[] vertexes;
    PVector[] projected;
    Triangle[] triangles;
    Color col;
    Math.Matrix transformationMatrix;
    
    Object(int triangleN)
    {
      vertexes=new PVector[triangleN*3];
      projected=new PVector[triangleN*3];
      triangles=new Triangle[triangleN];
      transformationMatrix=new Math.Matrix(4,4);
      transformationMatrix.fill(0);
      transformationMatrix.a[0][0]=transformationMatrix.a[1][1]=transformationMatrix.a[2][2]=transformationMatrix.a[3][3]=1;
    }
    
    class Triangle
    {
      int Aid=-1,Bid=-1,Cid=-1;
      Color a=new Color(-1,-1,-1),b=a,c=a;
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
        
        nA=nB=nC=PVector.sub(C0, A0).cross(PVector.sub(B0,A0)).normalize();
      }
      
      Triangle(PVector A0, PVector B0, PVector C0, Color col)
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
        
        nA=nB=nC=PVector.sub(C0, A0).cross(PVector.sub(B0,A0)).normalize();
        
        a=col;
      }
      
      Triangle(int A, int B, int C) {Aid=A; Bid=B; Cid=C;nA=nB=nC=PVector.sub(vertexes[C], vertexes[A]).cross(PVector.sub(vertexes[B],vertexes[A])).normalize();}
      
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
    
    int newTriangle(PVector A, PVector B, PVector C, Color c)
    {
      triangles[triangN]=new Triangle(A,B,C,c);
      return triangN++;
    }
    
    int newTriangle(int A, int B, int C)
    {
      triangles[triangN]=new Triangle(A,B,C);
      return triangN++;
    }
    
    int newVert(PVector P)
    {
      vertexes[vertN]=P;
      return vertN++;
    }
    
    int newVert(float x, float y, float z)
    {
      vertexes[vertN]=new PVector(x,y,z);
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
      transformationMatrix=transformationMatrix.multiply(translation);
      //transform(translation);
    }
    
    void rotateX(double a)
    {
      Math.Matrix rotation = new Math.Matrix(3,3);
      rotation.fill(0);
      rotation.a[0][0]=1;
      rotation.a[1][1]=rotation.a[2][2]=java.lang.Math.cos(a);
      rotation.a[2][1]=-(rotation.a[1][2]=java.lang.Math.sin(a));
      transformationMatrix=transformationMatrix.multiply(rotation);
      //transform(rotation);
    }
    
    void rotateY(double a)
    {
      Math.Matrix rotation = new Math.Matrix(3,3);
      rotation.fill(0);
      rotation.a[1][1]=1;
      rotation.a[0][0]=rotation.a[2][2]=java.lang.Math.cos(a);
      rotation.a[2][0]=-(rotation.a[0][2]=java.lang.Math.sin(a));
      transformationMatrix=transformationMatrix.multiply(rotation);
      //transform(rotation);
    }
    
    void scale(float x, float y, float z)
    {
      Math.Matrix scale = new Math.Matrix(3,3);
      scale.fill(0);
      scale.a[0][0]=x;
      scale.a[1][1]=y;
      scale.a[2][2]=z;
      transform(scale);
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
    Color col;
    PVector direction;
    
    Light(float x, float y, float z, PVector direction, Color col)
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
  
  int addParallelepiped(PVector A, PVector l1, PVector l2, PVector l3, Color col)
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
  
  int addSphere(PVector O, double R, int rows, int cols, Color col)
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