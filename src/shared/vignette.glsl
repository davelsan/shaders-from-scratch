#pragma glslify: remap = require('./remap.glsl');

vec3 vignette() {
  vec2 center = vUvs - 0.5; // [0.0, 1.0] -> [-0.5, 0.5]
  float distToCenter = length(abs(center)); // [0.0, 0.5]

  // Vignette effect
  float t = 1.0 - distToCenter; // [0.5, 1.0]
  // Increase white area -> remap [0.0, >=0.7] -> [0.0, 1.0]
  t = smoothstep(0.0, 0.7, t);
  // Brighten the overall shading -> interpolate [0.0, 1.0] -> [0.3, 1.0]
  t = remap(t, 0.0, 1.0, 0.3, 1.0);

  return vec3(t);
}

#pragma glslify: export(vignette);
