ArrayList<Planet> planets; //<>//
ArrayList<Rocket> rockets;

float frameTime, curTime, prevTime;
//float sizeScale = 100000, distanceScale = 1000000000.0;
float sizeScale = 1, distanceScale = 1;

final float G = 6.674e-11;
final float AU = 149597870700.0;

final int headerHeight = 25;

final color courseColor = color(#FFC246);

boolean generateRocket = false, switchInfo = false;
int displayInfo = 0;

void setup() {
  size(600, 620);
  background(255, 255, 255);

  planets = new ArrayList<Planet>();
  rockets = new ArrayList<Rocket>();

  Planet origin, destination, sun;

  origin = new Planet();
  //origin.size = 6378100.0;
  //origin.pos.set(AU, AU);
  //origin.mass = 5.972 * (pow(10, 24));
  origin.size = 30;
  origin.orbitTime = 20;
  origin.orbitRadius = 100;
  origin.centerPos.x = 300; 
  origin.centerPos.y = 300;
  origin.mass = 1e15;
  origin.col = color(100, 100, 180, 255);
  planets.add(origin);

  destination = new Planet();
  //destination.size = 12078100.0;
  //destination.pos.set(AU * 3, AU);
  //destination.mass = 18 * (pow(10, 24));
  destination.size = 50;
  destination.orbitTime = 30;
  destination.orbitRadius = 200;
  destination.centerPos.x = 300; 
  destination.centerPos.y = 300;
  destination.orbitOffset = PI;
  destination.mass = 3e15;
  destination.col = color(180, 100, 100, 255);
  planets.add(destination);

  sun = new Planet();
  sun.size = 50;
  sun.orbitTime = 5;
  sun.orbitRadius = 2;
  sun.centerPos.x = 300; 
  sun.centerPos.y = 300;
  sun.mass = 5e15;
  sun.col = color(255, 255, 100, 255);
  planets.add(sun);


  Rocket rocket = new Rocket();
  rocket.pos.set(50.0, 320.0);
  //rocket.velocity.set(1000.0, 1000.0);
  rocket.velocity.set(5, -94);
  rockets.add(rocket);
  
  rockets.get(0).showData = true;
}

void draw() {
  curTime = millis();
  frameTime = (curTime - prevTime) / 1000.0;
  
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
  fill(color(200, 200, 200, 255));
  noStroke();
  rect(0, 0, width, headerHeight);
  fill(color(0, 0, 0, 255));
  text(String.format("%.2fs", millis() / 1000.0), 10, 20);
  text(String.format("%d:", displayInfo), 90, 20);

  for (int n = 0; n < rockets.size(); n++) {
    rockets.get(n).generate();
    ArrayList<PVector> coursePoints = rockets.get(n).plotCourse(120, 1 / frameRate);
    //loadPixels();
    for (int i = 0; i < coursePoints.size(); i++) {
      //pixels[(int)coursePoints.get(i).x + (int)coursePoints.get(i).y * width] = courseColor;
      set((int)coursePoints.get(i).x, (int)coursePoints.get(i).y, courseColor);
    }
    //updatePixels();
  }

  if (generateRocket) {
    generateRocket = false;

    Rocket rocket = new Rocket();
    rocket.pos.set(mouseX, mouseY);
    rocket.velocity.set(random(-50, 50), random(-50, 50));
    rockets.add(rocket);
  }
  
  if (switchInfo) {
    switchInfo = false;
    rockets.get(displayInfo).showData = false;
    displayInfo = (displayInfo + 1) % rockets.size();
    rockets.get(displayInfo).showData = true;
  }
}

void mouseClicked () {
  if (mouseButton == LEFT) {
    generateRocket = true;
  }
  else if (mouseButton == RIGHT) {
    switchInfo = true;
  }
}

PVector calcPlanetAcceleration (Rocket rocket, Planet planet, float timeOffset) {
  PVector planetPos = new PVector();
  PVector rocketPos = new PVector();
  PVector acceleration = new PVector();
  boolean below = false;

  if (timeOffset == 0) {
    planetPos = planet.pos;
    rocketPos = rocket.pos;
  } else {
    planetPos = planet.calcMove(timeOffset);
    rocketPos = rocket.projectedPos;
  }

  float xDistance = planetPos.x - rocketPos.x, yDistance = planetPos.y - rocketPos.y;
  float distance = mag(xDistance, yDistance);
  float totalAcceleration = (planet.mass * G) / (pow(distance, 2));
  float alpha = atan(xDistance / yDistance);

  if (rocketPos.y > planetPos.y) {
    below = true;
  }

  if (!below) {
    alpha = -1 * (PI/2 + alpha);
  } else {
    alpha = PI/2 - alpha;
  }

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

  public PVector calcMove(float timeOffset) {
    PVector moveToPos = new PVector();
    moveToPos.x = centerPos.x + orbitRadius * cos((millis() / 1000.0 + timeOffset) / orbitTime * 2*PI + orbitOffset);
    moveToPos.y = centerPos.y + orbitRadius * sin((millis() / 1000.0 + timeOffset) / orbitTime * 2*PI + orbitOffset);
    return moveToPos;
  }

  private void storeNewPos(float newX, float newY) {
    pos.x = newX;
    pos.y = newY;
  }

  public void generate() {
    fill(255, 255, 255);
    noStroke();
    circle(pos.x / distanceScale, pos.y / distanceScale, (size * 1.2) / sizeScale);

    PVector newPos = new PVector();
    newPos = calcMove(0);
    storeNewPos(newPos.x, newPos.y);

    //generate orbit circle
    noFill();
    stroke(1);
    stroke(100, 100, 100, 255);
    circle(centerPos.x / distanceScale, centerPos.y / distanceScale, orbitRadius * 2 / distanceScale);
    fill(col);

    //generate planet
    stroke(0, 0, 0, 255);
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
    projectedPos = new PVector();
  }

  //sets the pos in member
  private void calcPos() {
    PVector newPos = new PVector();
    PVector newVel = new PVector();
    PVector totalPlanetAcceleration = new PVector();

    for (int i = 0; i < planets.size(); i++) {
      totalPlanetAcceleration.add(calcPlanetAcceleration(this, planets.get(i), 0));
    }

    newVel.x = velocity.x + acceleration.x * frameTime + totalPlanetAcceleration.x * frameTime;
    newVel.y = velocity.y + acceleration.y * frameTime + totalPlanetAcceleration.y * frameTime;
    newPos.x = pos.x + newVel.x * frameTime;
    newPos.y = pos.y + newVel.y * frameTime;
    //println("x: " + newPos.x);
    //println("y: " + newPos.y);

    if (showData) {
      textSize(20);
      fill(color(0, 0, 0, 255));
      text(String.format("%.2f", totalPlanetAcceleration.mag()) + "m/s^2", 120, 20);
      text(String.format("%.2f", velocity.mag()) + "m/s", 280, 20);

      float x1Line = 400, y1Line = 12;
      float alpha = PVector.angleBetween(totalPlanetAcceleration, PVector.fromAngle(0));

      int below = 1;
      if (totalPlanetAcceleration.y < 0) {
        below = -1;
      }

      float x2AccLine = x1Line + 10 * cos(alpha), y2AccLine = y1Line + below * 10 * sin(alpha);
      stroke(2);
      stroke(255, 0, 0, 255);
      line(x1Line, y1Line, x2AccLine, y2AccLine);

      alpha = PVector.angleBetween(velocity, PVector.fromAngle(0));

      below = 1;
      if (velocity.y < 0) {
        below = -1;
      }

      float x2VelLine = x1Line + 10 * cos(alpha), y2VelLine = y1Line + below * 10 * sin(alpha);
      stroke(2);
      stroke(0, 255, 0, 255);
      line(x1Line, y1Line, x2VelLine, y2VelLine);
    }

    pos = newPos;
    velocity = newVel;

    prevTime = curTime;
    return;
  }

  public ArrayList<PVector> plotCourse(int futureSteps, float timeIncrement) {
    ArrayList<PVector> coursePoints = new ArrayList<PVector>();    //possibly change type if too slow/ram hungry

    PVector newProjectedPos = new PVector();
    projectedPos.x = pos.x;
    projectedPos.y = pos.y;
    PVector newProjectedVel = new PVector();
    PVector projectedVel = new PVector();
    projectedVel.x = velocity.x;
    projectedVel.y = velocity.y;
    PVector projectedPlanetAcceleration = new PVector();

    for (int i = 0; i < futureSteps; i++) {
      for (int n = 0; n < planets.size(); n++) {
        projectedPlanetAcceleration = (calcPlanetAcceleration(this, planets.get(n), (i + 1) * timeIncrement));
      }

      newProjectedVel.x = projectedVel.x + acceleration.x * timeIncrement + projectedPlanetAcceleration.x * timeIncrement;
      newProjectedVel.y = projectedVel.y + acceleration.y * timeIncrement + projectedPlanetAcceleration.y * timeIncrement;
      newProjectedPos.x = projectedPos.x + projectedVel.x * timeIncrement;
      newProjectedPos.y = projectedPos.y + projectedVel.y * timeIncrement;

      if (newProjectedPos.x > 0 && newProjectedPos.x < width && newProjectedPos.y > headerHeight && newProjectedPos.y < height) {
        PVector coursePoint = new PVector();
        coursePoint.x = newProjectedPos.x;
        coursePoint.y = newProjectedPos.y;
        coursePoints.add(coursePoint);
      }
      projectedPos.x = newProjectedPos.x;
      projectedPos.y = newProjectedPos.y;

      projectedVel.x = newProjectedVel.x;
      projectedVel.y = newProjectedVel.y;
    }

    return coursePoints;
  }

  public void generate() {
    //overdraw old circle and replace with smaller
    /*fill(255,255,255,255);
     circle(pos.x, pos.y, 4);
     fill(0,0,0,255);
     circle(pos.x, pos.y, 2);*/

    calcPos();

    int size = 0;
    if (showData) {
      stroke(255, 0, 0, 255);
      size = 3;
    } else {
      stroke(0, 0, 0, 255);
      size = 2;
    }
    circle(pos.x, pos.y, size);
  }

  public PVector velocity;
  public PVector acceleration;
  public PVector pos;
  public PVector projectedPos;
  public float mass = 100;

  public boolean showData = false;
}
