float easeOutExp(float x, float p) {
  return 1.0 - pow(1.0 - x, p);
}

#pragma glslify: export(easeOutExp)
