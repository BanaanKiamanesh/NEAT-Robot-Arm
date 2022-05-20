class Arm {
  // Shape Imports
  PShape base, shoulder, upArm, loArm, end;

  // Maximum Arm Length
  int MAX_ARM_LENGTH = 120;

  // End Effector Positions
  float posX, posY, posZ;
  float tmpX, tmpY, tmpZ;

  // Canvas and Link Rotation Params
  float rotX = 0, rotY = 0;
  float alpha, beta, gamma;

  // Time Specs
  float F = 50;
  float T = 70;
  //float millisOld, gTime, gSpeed = 4;

  // Shape Size Params
  float paramX = 0, paramZ = 0;

  // Time Passed between rendered Frames
  double dt = 0;

  float xPosition, yPosition, zPosition;
  float scale;

  String mode = "IK";

  double err = 0;
  float desiredX = 0, desiredY = 0, desiredZ = 0;

  Brain brain;

  int setPointChangeCount = 0;

  //////////////////////////////////////////////////////////////////// Constructor
  Arm(float xPosition, float yPosition, float zPosition, String mode) {
    // Import 3D Objects
    this.base = loadShape("r5.obj");
    this.shoulder = loadShape("r1.obj");
    this.upArm = loadShape("r2.obj");
    this.loArm = loadShape("r3.obj");
    this.end = loadShape("r4.obj");

    // Disable Style
    this.shoulder.disableStyle();
    this.upArm.disableStyle();
    this.loArm.disableStyle();

    this.genRandomPos();
    this.posX = this.tmpX;
    this.posY = this.tmpY;
    this.posZ = this.tmpZ;

    this.xPosition = xPosition;
    this.yPosition = yPosition;
    this.zPosition = zPosition;

    this.scale = 1.5;
    this.mode = mode;

    brain = new Brain();
  }

  //////////////////////////////////////////////////////////////////// Update the Robot in the Graphical Canvas 
  void update() {

    pushMatrix();

    if (mode == "IK") 
      this.pose();

    else
      this.evalBrain();

    lights();
    directionalLight(51, 102, 126, -1, 0, 0);

    noStroke();
    translate(xPosition, yPosition, zPosition);
    rotateX(this.rotX);
    rotateY(-this.rotY);
    scale(-scale);

    this.drawEnd(5);

    this.setPose(this.gamma, this.alpha, this.beta);

    this.dt = 1 / frameRate;  // Time Taken Between Each Frame

    popMatrix();
  }

  //////////////////////////////////////////////////////////////////// Generate a Random Pos for the End Effector 
  void genRandomPos() {
    float r = random(MAX_ARM_LENGTH * 0.25, MAX_ARM_LENGTH * 0.95);
    float theta = random(0, 2 * PI);
    float phi = random(PI / 8, PI / 2);

    this.tmpX = r * cos(theta) * cos(phi);
    this.tmpY = r * sin(theta) * cos(phi);
    this.tmpZ = -r * sin(phi);

    setPointChangeCount++;
  }

  //////////////////////////////////////////////////////////////////// Calculate the Inv Kinematics
  void InvKinematics() {
    float X = posX;
    float Y = posY;
    float Z = posZ;
    float L = sqrt(Y*Y + X*X);
    float R = sqrt(Z*Z + L*L);

    this.alpha = PI/2 - (atan2(L, Z) + acos((this.T * this.T - this.F * this.F - R*R)/(-2 * this.F * R)));
    this.beta = -PI + acos((R*R - this.T * this.T - this.F * this.F)/(-2 * this.F * this.T));
    this.gamma = atan2(Y, X);
  }

  //////////////////////////////////////////////////////////////////// Navigate the Inv Kinematics based on the Mode
  void pose() {
    this.InvKinematics();

    if (gTime % 2 == 0)
      this.genRandomPos();  

    // Path Smoothing for the End Effector Movement
    this.posX += (this.tmpX - this.posX) * this.dt;
    this.posY += (this.tmpY - this.posY) * this.dt;
    this.posZ += (this.tmpZ - this.posZ) * this.dt;
  }

  //////////////////////////////////////////////////////////////////// Update Canvas View Angle
  void updateRot() {
    this.rotY -= (mouseX - pmouseX) * this.dt;
    this.rotX -= (mouseY - pmouseY) * this.dt;
  }

  //////////////////////////////////////////////////////////////////// Apply the Kinematics and Draw it on the Canvas!
  void setPose(float gamma, float alpha, float beta) {

    fill(#709AE0);
    translate(0, -40, 0); 
    shape(this.base);

    translate(0, 4, 0);
    rotateY(gamma);
    shape(this.shoulder);

    translate(0, 25, 0);
    rotateY(PI);
    rotateX(alpha);
    shape(this.upArm);

    translate(0, 0, 50);
    rotateY(PI);
    rotateX(beta);
    shape(this.loArm);

    translate(0, 0, -50);
    rotateY(PI);
    shape(this.end);

    if (mode != "IK")
      err += dist(posX, posY, posZ, desiredX, desiredY, desiredZ);
  }

  //////////////////////////////////////////////////////////////////// Draw End Destination of the End Effector  
  void drawEnd(float size) {
    pushMatrix();
    translate(-this.tmpY, -this.tmpZ, -this.tmpX);
    fill(#FFFFFF);
    sphere(size);
    popMatrix();
  }

  ////////////////////////////////////////////////////////////////////
  void setScale(float scale) {
    this.scale = scale;
  }

  ////////////////////////////////////////////////////////////////////
  void setPosition(float xPosition, float yPosition, float zPosition) {
    this.xPosition = xPosition;
    this.yPosition = yPosition;
    this.zPosition = zPosition;
  }

  ////////////////////////////////////////////////////////////////////
  void evalBrain() {
    float[] input = {posX, posY, posZ, gamma, alpha, beta, (desiredX - posX), (desiredY - posY), (desiredZ - posZ)};
    float[] angles = brain.evaluate(input);

    //this.setPose(angles[0], angles[1], angles[2]);
    gamma = angles[0];
    alpha = angles[1];
    beta = angles[2];
  }

  ////////////////////////////////////////////////////////////////////
  void setDesired(float desX, float desY, float desZ) {
    this.desiredX = desX;
    this.desiredY = desY;
    this.desiredZ = desZ;
  }

  ////////////////////////////////////////////////////////////////////
  Arm mate(Arm arm) {
    Arm child = new Arm(this.xPosition, this.yPosition, this.zPosition, this.mode);

    for (int i = 0; i < child.brain.hiddenLayerBias.length; i++) {
      float p = random(0, 1);

      if (p > 1 - mutationRate) // Mutation
        child.brain.hiddenLayerBias[i] = random(-1, 1);

      else if (p < (1 - mutationRate)/2) // This Mates Part
        child.brain.hiddenLayerBias[i] = this.brain.hiddenLayerBias[i];

      // The Other Mates Part
      else child.brain.hiddenLayerBias[i] = arm.brain.hiddenLayerBias[i];
    }    

    for (int i = 0; i < child.brain.outLayerBias.length; i++) {
      float p = random(0, 1);

      if (p > 1 - mutationRate) // Mutation
        child.brain.outLayerBias[i] = random(-1, 1);

      else if (p < (1 - mutationRate)/2) // This Mates Part
        child.brain.outLayerBias[i] = this.brain.outLayerBias[i];

      // The Other Mates Part
      else  child.brain.outLayerBias[i] = arm.brain.outLayerBias[i];
    }

    for (int i = 0; i < child.brain.inLen; i++)
      for (int j = 0; j < child.brain.hiddenLen; j++) {

        float p = random(0, 1);

        if (p > 1 - mutationRate) // Mutation
          child.brain.inputWeights[i][j] = random(-1, 1);

        else if (p < (1 - mutationRate)/2) // This Mates Part
          child.brain.inputWeights[i][j] = this.brain.inputWeights[i][j];

        // The Other Mates Part
        else  child.brain.inputWeights[i][j] = arm.brain.inputWeights[i][j];
      }


    for (int i = 0; i < child.brain.hiddenLen; i++)
      for (int j = 0; j < child.brain.outLen; j++) {

        float p = random(0, 1);

        if (p > 1 - mutationRate) // Mutation
          child.brain.outWeights[i][j] = random(-1, 1);

        else if (p < (1 - mutationRate)/2) // This Mates Part
          child.brain.outWeights[i][j] = this.brain.outWeights[i][j];

        // The Other Mates Part
        else  child.brain.outWeights[i][j] = arm.brain.outWeights[i][j];
      }

    return child;
  }

  ////////////////////////////////////////////////////////////////////
  double fitness() {
    return this.err;
  }

  ////////////////////////////////////////////////////////////////////
  void setDestination(float posX, float posY, float posZ) {
    this.tmpX = posX;
    this.tmpY = posY;
    this.tmpZ = posZ;
  }

  ////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////
}
