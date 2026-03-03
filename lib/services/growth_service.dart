import 'dart:math';

class GrowthService {
  static double zScore(
      double value, double L, double M, double S) {
    if (L == 0) return log(value / M) / S;
    return (pow(value / M, L) - 1) / (L * S);
  }

  static String classify(double z) {
    if (z < -3) return "Severe Deficiency";
    if (z < -2) return "Moderate Deficiency";
    if (z > 3) return "Severe Excess";
    if (z > 2) return "Overweight";
    return "Normal";
  }
}