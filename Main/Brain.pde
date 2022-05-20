class Brain {

  int inLen = 9;
  int hiddenLen = 20;
  int outLen = 3;

  // Layers
  float[] hiddenLayerBias = new float[hiddenLen];
  float[] outLayerBias = new float[outLen];

  // Weights
  float[][] inputWeights = new float[inLen][hiddenLen];
  float[][] outWeights = new float[hiddenLen][outLen];

  Brain() {
    // Init Layers and Weights
    for (int i = 0; i < hiddenLayerBias.length; i++)
      hiddenLayerBias[i] = random(-1, 1);

    for (int i = 0; i < outLayerBias.length; i++)
      outLayerBias[i] = random(-1, 1);

    for (int i = 0; i < inLen; i++)
      for (int j = 0; j < hiddenLen; j++)
        inputWeights[i][j] = random(-1, 1);

    for (int i = 0; i < hiddenLen; i++)
      for (int j = 0; j < outLen; j++)
        outWeights[i][j] = random(-1, 1);
  }

  float sigmoid(float x) {
    return 1/(1 + exp(-x));
  }

  float[] evaluate(float[] input) {

    float[] tmpHidden = new float[hiddenLen];
    float[] out = new float[outLen];

    for (int i = 0; i < tmpHidden.length; i++) {
      tmpHidden[i] = 0;

      for (int j = 0; j < inLen; j++) 
        tmpHidden[i] += inputWeights[j][i] * input[j];

      tmpHidden[i] = sigmoid(tmpHidden[i] + hiddenLayerBias[i]);
    }


    for (int i = 0; i < out.length; i++) {
      out[i] = 0;

      for (int j = 0; j < tmpHidden.length; j++) 
        out[i] += outWeights[j][i] * tmpHidden[j];

      tmpHidden[i] = sigmoid(tmpHidden[i] + outLayerBias[i]);
    }

    out[0] = map(out[0], -1, 1, -PI, PI);
    out[1] = map(out[1], -1, 1, 0, PI);
    out[2] = map(out[2], -1, 1, radians(-130), radians(130));
    
    return out;
  }
}
