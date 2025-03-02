mat3 rotateX(float angle) {
  float c = cos(angle);
  float s = sin(angle);

  return mat3(
    1.0, 0.0, 0.0,
    0.0, c, -s,
    0.0, s, c
  );
}

#pragma glslify: export(rotateX)