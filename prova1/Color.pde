class Color
{
  int r, g, b;
  
  Color(int r, int g, int b) { this.r=r; this.g=g; this.b=b; }
  
  Color(float r, float g, float b) { this.r=(int)r; this.g=(int)g; this.b=(int)b; }
  
  Color multiply(float k) {r=(int)(r*k); g=(int)(g*k); b=(int)(b*k); return this;}
  
  Color multiply(float k, Color c) {return new Color((int)(c.r*k),(int)(c.g*k),(int)(c.b*k));}
  
  color getColor() {return color(r,g,b);}
}