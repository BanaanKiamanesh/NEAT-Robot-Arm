Population pop;
Arm reference;

///////////////////////////////////////// NEAT Specs
float mutationRate = 0.05;
float keepRate = 0.5;
int generation = 0;
int maxGen = 50;
float bestError = 100000;


void setup() {
  fullScreen(P3D);
  smooth(8);

  pop = new Population(9);

  reference = new Arm(-width / 4, 0, 0, "IK");
  reference.setScale(4);
}

void draw() {
  background(50);
  translate(width / 2, height / 2, 0);

  textSize(30);
  text("Generation = " + generation, -800, 450);
  textSize(30);
  text("Best Error = " + str(floor(bestError)), -800, 500);

  if (generation == maxGen) 
    exit();

  updateTime();

  reference.update();

  pop.setDesired(reference.posX, reference.posY, reference.posZ);
  pop.setDestination(reference.tmpX, reference.tmpY, reference.tmpZ);
  pop.update();

  if (reference.setPointChangeCount == 3) {
    reference.setPointChangeCount = 0;
    pop.genNewPop();
    println("Generation = ", generation);
    generation++;
    bestError = (float)pop.arms.get(0).fitness();
  }
}
