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
 /* Scene.Object cosa = scene.new Object(4);
  cosa.newTriangle(new PVector(0,0,-1), new PVector(1,0,-2), new PVector(1,1,-1), new Color(255,0,0));
  cosa.newTriangle(new PVector(0,0,-1), new PVector(0,1,-2), new PVector(1,1,-1), new Color(0,0,255));
  cosa.newTriangle(new PVector(0,0,-1), new PVector(-1,0,-2), new PVector(-1,1,-1), new Color(255,0,0));
  cosa.newTriangle(new PVector(0,0,-1), new PVector(0,1,-2), new PVector(-1,1,-1), new Color(0,0,255));
  scene.addObject(cosa);
  scene.addParallelepiped(new PVector(0.2,0.2,-1), new PVector(0,0.5,0), new PVector(0.5,0,0), new PVector(0,0,-0.5), new Color(0,0,255));
  scene.addParallelepiped(new PVector(-0.8,-0.7,-0.8), new PVector(0,0.5,0), new PVector(0.5,0,0), new PVector(0,0,-0.5), new Color(74,214,54));*/
  /*Scene.Object triangle = scene.new Object(2);
  triangle.newTriangle(new PVector(-0.3,-0.2,-1.8), new PVector(-0.3,-0.2,-1.3), new PVector(0.2,-0.2,-1.8), color(255,0,0));
  triangle.newTriangle(new PVector(0.2,-0.2,-1.3), new PVector(-0.3,-0.2,-1.3), new PVector(0.2,-0.2,-1.8), color(255,0,0));
  scene.addObject(triangle);*/
  //for (int i=0; i<scene.objects[0].vertN; i++) println(scene.objects[0].vertexes[i]);
  //scene.addSphere(new PVector(0,0,-1.5),0.5,20,20, new Color(255,0,0));
  try  {
    scene.addObject(VertlistReader.readFile(scene,"/home/luigi/Downloads/bunny/reconstruction/bun_zipper.vl"));//Development/Processing/3d-simpleRenderer/vertListTest.vl"));
  }
  catch (IOException e) {}
  scene.objects[0].move(0,0,0);
  scene.objects[0].col=new Color(255,0,0);
  scene.objects[0].scale(3,3,3);
  scene.objects[0].move(0,-0.5,-1);
  scene.addLight(scene.new Light(2,2,1,new PVector(-0.3,-0.5,-0.7), new Color(255,255,255)));
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
  //scene.objects[1].move(-0.01*0,0,-0.05);
  time=millis();
  scene.renderer.render();
  println("Rendering took ",millis()-time," milliseconds.");
  if (scene.objects[0].vertexes[0].x<=-1) println("TOTAL RENDERING TOOK: ", (millis()-time2)/nFrames, " per frame.");
}