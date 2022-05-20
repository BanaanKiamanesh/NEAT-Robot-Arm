class Population {

  ArrayList<Arm> arms = new ArrayList<Arm>();
  int nPop;
  int nKeep;
  double[] Err;

  Population(float nPop) {
    if (nPop < 1)
      nPop = 1;

    nPop = pow(floor(sqrt(nPop)), 2);

    this.nPop = int(nPop);

    int canvasDivisor = floor(sqrt(nPop)) + 1;

    int tmp = (int)sqrt(this.nPop);

    for (int x = 0; x < tmp; x++)
      for (int y = 0; y < tmp; y++)
        arms.add(new Arm(x * (width/2) / (canvasDivisor - 1), (y + 1) * (height / canvasDivisor) -height / 2, 0, "NN"));

    nKeep = floor(keepRate * nPop);

    Err = new double[this.nPop];
  }

  void update() {
    for (Arm arm : arms)
      arm.update();
  }

  void setDesired(float posX, float posY, float posZ) {
    for (Arm arm : arms) 
      arm.setDesired(posX, posY, posZ);
  }

  void genNewPop() {

    this.sortPop();
    printErrors();

    ArrayList<Arm> newArms = new ArrayList<Arm>();

    for (int i = 0; i < this.nKeep; i++)      
      newArms.add(this.arms.get(i));

    for (int i = this.nKeep; i < this.nPop; i++) {
      int r1 = int(random(0, this.nPop));
      int r2 = int(random(0, this.nPop));

      newArms.add(arms.get(r1).mate(this.arms.get(r2)));
    }

    int canvasDivisor = floor(sqrt(this.nPop)) + 1;

    int tmp = (int)sqrt(this.nPop);
    ArrayList<Arm> tmpArms = new ArrayList<Arm>();

    for (int x = 0; x < tmp; x++)
      for (int y = 0; y < tmp; y++) {
        Arm temp = newArms.get((x) * tmp + y);
        temp.setPosition(x * (width/2) / (canvasDivisor - 1), (y + 1) * (height / canvasDivisor) -height / 2, 0);
        tmpArms.add(temp);
      }

    this.arms = tmpArms;
    println("Mating Done! Generation = ", generation);
  }


  void sortPop() {
    ArrayList<Arm> newArms = new ArrayList<Arm>();

    for (int j = 0; j < this.nPop; j++) {

      int min = 0;
      double minError = this.arms.get(0).err;
      for (int i = 1; i < this.arms.size(); i++) 
        if (this.arms.get(i).err < minError) {
          min = i;
          minError = this.arms.get(i).err;
        }

      newArms.add(this.arms.get(min));
      this.arms.remove(min);
    }

    this.arms = newArms;
  }

  void setDestination(float posX, float posY, float posZ) {
    for (Arm arm : arms)
      arm.setDestination(posX, posY, posZ);
  }

  void printErrors() {
    for (int i = 0; i < nPop; i++) 
      Err[i] = arms.get(i).fitness();

    println(Err);
  }
}
