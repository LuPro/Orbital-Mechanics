ArrayList<Planet> planets;
Rocket rocket;

float deltaTime, curTime, prevTime;
//float sizeScale = 100000, distanceScale = 1000000000.0;
float sizeScale = 1, distanceScale = 1;

final float G = 6.674e-11;
final float AU = 149597870700.0;

void setup() {
  size(600, 620);
  background(255,255,255);
  
  planets = new ArrayList<Planet>();
  
  Planet origin, destination, sun;
  
  origin = new Planet();
  //origin.size = 6378100.0;
  //origin.pos.set(AU, AU);
  //origin.mass = 5.972 * (pow(10, 24));
  origin.size = 30;
  origin.orbitTime = 20;
  origin.orbitRadius = 100;
  origin.centerPos.x = 300; origin.centerPos.y = 300;
  origin.mass = 1e15;
  origin.col = color(100,100,180,255);
  planets.add(origin);
  
  destination = new Planet();
  //destination.size = 12078100.0;
  //destination.pos.set(AU * 3, AU);
  //destination.mass = 18 * (pow(10, 24));
  destination.size = 50;
  destination.orbitTime = 30;
  destination.orbitRadius = 200;
  destination.centerPos.x = 300; destination.centerPos.y = 300;
  destination.orbitOffset = PI;
  destination.mass = 3e15;
  destination.col = color(180,100,100,255);
  planets.add(destination);
  
  sun = new Planet();
  sun.size = 50;
  sun.orbitTime = 5;
  sun.orbitRadius = 2;
  sun.centerPos.x = 300; sun.centerPos.y = 300;
  sun.mass = 5e15;
  sun.col = color(255,255,100,255);
  planets.add(sun);
  
  rocket = new Rocket();
  rocket.pos.set(50.0, 320.0);
  //rocket.velocity.set(1000.0, 1000.0);
  rocket.velocity.set(5, -94);
}

void draw() {
  /*color bg = color (255, 255, 255, 5);
  fill(bg);
  noStroke();
  rect(0, 0, width, height);*/
  background(255, 255, 255);
  frameRate(60);
  
  for (int i = 0; i < planets.size(); i++) {
    planets.get(i).generate();
  }
  
  textSize(20);
  fill(color(200,200,200,255));
  noStroke();
  rect(0,0,width,25);
  fill(color(0,0,0,255));
  text(String.format("%.2f", millis() / 1000.0) + "s", 10, 20);
  
  rocket.generate();
}

PVector calcPlanetAcceleration (Rocket rocket, Planet planet) {
  PVector acceleration = new PVector();
  boolean below = false;
  
  float xDistance = planet.pos.x - rocket.pos.x, yDistance = planet.pos.y - rocket.pos.y;
  float distance = mag(xDistance, yDistance);
  float totalAcceleration = (planet.mass * G) / (pow(distance, 2));
  float alpha = atan(xDistance / yDistance);
  
  if (rocket.pos.y > planet.pos.y) {
    below = true;
  }
  
  if (!below) {
    alpha = -1 * (PI/2 + alpha);
  } else {
    alpha = PI/2 - alpha;
  }
  
  /*println("xDis: " + xDistance);
  println("yDis: " + yDistance);
  println("xDir: " + xDirection);
  println("yDir: " + yDirection);
  println("alpha:" + alpha);
  println("aldeg:" + alpha * 180 / PI);
  println("tAcc: " + totalAcceleration);*/
  acceleration.x = -1 * totalAcceleration * cos(alpha);
  acceleration.y = -1 * totalAcceleration * sin(alpha);
  
  //show direction of acceleration directly at the rocket
  /*float xLine = rocket.pos.x - 10 * cos(alpha), yLine = rocket.pos.y - 10 * sin(alpha);
  stroke(1);
  fill(255,0,0,255);
  line(rocket.pos.x, rocket.pos.y, xLine, yLine);*/
  
  return acceleration;
}

class Planet {
  public Planet() {
    pos = new PVector();
    centerPos = new PVector();
  }
  
  private void move() {
    pos.x = centerPos.x + orbitRadius * cos((millis() / 1000.0) / orbitTime * 2*PI + orbitOffset);
    pos.y = centerPos.y + orbitRadius * sin((millis() / 1000.0) / orbitTime * 2*PI + orbitOffset);
  }
  
  public void generate() {
    fill(255,255,255);
    noStroke();
    circle(pos.x / distanceScale, pos.y / distanceScale, (size * 1.2) / sizeScale);
    
    move();
    
    //generate orbit circle
    noFill();
    stroke(1);
    stroke(100,100,100,255);
    circle(centerPos.x / distanceScale, centerPos.y / distanceScale, orbitRadius * 2 / distanceScale);
    fill(col);
    
    //generate planet
    stroke(0,0,0,255);
    circle(pos.x / distanceScale, pos.y / distanceScale, size / sizeScale);
  }
  
  //calculation values
  public PVector pos;
  public float size;
  public float mass;
  
  //orbit values
  public PVector centerPos;
  public float orbitTime;
  public float orbitRadius;
  public float orbitOffset;
  
  public color col;
  
}

class Rocket {
  public Rocket() {
    pos = new PVector();
    velocity = new PVector();
    acceleration = new PVector();
  }
  
  //sets the pos in member
  private void calcPos() {
    PVector newPos = new PVector();
    PVector newVel = new PVector();
    PVector totalPlanetAcceleration = new PVector();
    
    curTime = millis();
    deltaTime = (curTime - prevTime) / 1000.0;
    
    for (int i = 0; i < planets.size(); i++) {
      totalPlanetAcceleration.add(calcPlanetAcceleration(this, planets.get(i)));
    }
    
    newVel.x = velocity.x + acceleration.x * deltaTime + totalPlanetAcceleration.x * deltaTime;
    newVel.y = velocity.y + acceleration.y * deltaTime + totalPlanetAcceleration.y * deltaTime;
    newPos.x = pos.x + newVel.x * deltaTime;
    newPos.y = pos.y + newVel.y * deltaTime;
    //println("x: " + newPos.x);
    //println("y: " + newPos.y);
    
    textSize(20);
    fill(color(0,0,0,255));
    text(String.format("%.2f", totalPlanetAcceleration.mag()) + "m/s^2", 110, 20);
    text(String.format("%.2f", velocity.mag()) + "m/s", 270, 20);
    
    float x1Line = 400, y1Line = 12;
    float alpha = PVector.angleBetween(totalPlanetAcceleration, PVector.fromAngle(0));
    
    int below = 1;
    if (totalPlanetAcceleration.y < 0) {
      below = -1;
    }
    
    float x2AccLine = x1Line + 10 * cos(alpha), y2AccLine = y1Line + below * 10 * sin(alpha);
    stroke(2);
    stroke(255,0,0,255);
    line(x1Line, y1Line, x2AccLine, y2AccLine);
    
    alpha = PVector.angleBetween(velocity, PVector.fromAngle(0));
    
    below = 1;
    if (velocity.y < 0) {
      below = -1;
    }
    
    float x2VelLine = x1Line + 10 * cos(alpha), y2VelLine = y1Line + below * 10 * sin(alpha);
    stroke(2);
    stroke(0,255,0,255);
    line(x1Line, y1Line, x2VelLine, y2VelLine);
    
    pos = newPos;
    velocity = newVel;
    
    prevTime = curTime;
    return;
  }
  
  public void generate() {
    //overdraw old circle and replace with smaller
    /*fill(255,255,255,255);
    circle(pos.x, pos.y, 4);
    fill(0,0,0,255);
    circle(pos.x, pos.y, 2);*/
    
    calcPos();
    
    stroke(0,0,0,255);
    circle(pos.x, pos.y, 2);
  }
  
  public PVector velocity;
  public PVector acceleration;
  public PVector pos;
  public float mass = 100;
}
