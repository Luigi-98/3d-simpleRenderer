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
    
    Matrix extend(Matrix m)
    {
      if (m.h==4&&m.w==4) return m;
      Matrix res = new Matrix(4,4);
      res.fill(0);
      for (int i=0; i<m.h; i++)
        for (int j=0; j<m.w; j++)
          res.a[i][j]=m.a[i][j];
      res.a[3][3]=1;
      return res;
    }
  
    Matrix multiply(Matrix m)
    {
      if (m.h!=h||m.w!=w) return extend(this).multiply(extend(m));
      Matrix res=new Matrix(w,h);
      for (int i=0; i<w; i++)
        for (int j=0; j<h; j++)
        {
          res.a[i][j]=0;
          for (int k=0; k<w; k++)
            res.a[i][j]+=a[i][k]*m.a[k][j];
        }
      return res;
    }
    
    static Matrix identity()
    {
      Matrix res=new Matrix(4,4);
      res.fill(0);
      res.a[0][0]=res.a[1][1]=res.a[2][2]=res.a[3][3]=1;
      return res;
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