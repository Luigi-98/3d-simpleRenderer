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