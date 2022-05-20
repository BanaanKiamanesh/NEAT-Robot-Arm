//////////////////////////////////////////////////////////////////// Generate Time new Random Point Generation
float millisOld, gTime, gSpeed = 4;
float runningTime = 0;

void updateTime() {
  gTime += ((float)millis()/1000 - millisOld) * (gSpeed/4);
  runningTime += ((float)millis()/1000 - millisOld) * (gSpeed/4);

  if (gTime >= 4) 
    gTime = 0;

  millisOld = (float)millis()/1000;
}
