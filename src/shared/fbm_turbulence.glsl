#pragma glslify: noise3d = require('./noise3d.glsl')

float turbulenceFBM(vec3 p, int octaves, float persistence, float lacunarity) {
  float amplitude = 0.5;
  float frequency = 1.0;
  float total = 0.0;
  float normalization = 0.0;

  for (int i = 0; i < octaves; ++i) {
    float noiseValue = noise3d(p * frequency);

    // Absolute of the noise value
    noiseValue = abs(noiseValue);

    total += noiseValue * amplitude;
    normalization += amplitude;
    amplitude *= persistence;
    frequency *= lacunarity;
  }

  total /= normalization;

  return total;
}

#pragma glslify: export(turbulenceFBM)
