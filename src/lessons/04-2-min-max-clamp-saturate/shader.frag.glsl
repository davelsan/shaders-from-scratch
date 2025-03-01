varying vec2 vUvs;

uniform vec2 uResolution;

vec3 red = vec3(1.0, 0.0, 0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);
vec3 white = vec3(1.0, 1.0, 1.0);
vec3 black = vec3(0.0, 0.0, 0.0);
vec3 yellow = vec3(1.0, 1.0, 0.0);

#pragma glslify: remap_narrow = require(../../shared/remap_narrow.glsl, thickness=0.0075)

/**
 * Homework: custom clamp function using only min and max.
 */
float custom_clamp(float value, float edge_min, float edge_max) {
  return max(edge_min, min(value, edge_max));
}

void main() {
  vec3 color = vec3(0.0);

  float min_x = min(vUvs.x, 0.25);
  float clamp_mix_max = custom_clamp(vUvs.x, 0.25, 0.75);
  float max_x = max(vUvs.x, 0.75);

  float lineBottom = smoothstep(0.0, 0.005, abs(vUvs.y - 0.33));
  float lineMiddle = smoothstep(0.0, 0.005, abs(vUvs.y - 0.66));

  float lineMin = remap_narrow(abs(vUvs.y - mix(0.66, 1.0, min_x)));
  float lineClamp = remap_narrow(abs(vUvs.y - mix(0.33, 0.66, clamp_mix_max)));
  float lineMax = remap_narrow(abs(vUvs.y - mix(0.0, 0.33, max_x)));

  if (vUvs.y > 0.66) {
    color = mix(red, blue, min_x);
  }
  else if (vUvs.y > 0.33) {
    color = mix(red, blue, clamp_mix_max);
  }
  else {
    color = mix(red, blue, max_x);
  }

  color = mix(white, color, lineBottom);
  color = mix(white, color, lineMiddle);
  color = mix(white, color, lineMin);
  color = mix(white, color, lineClamp);
  color = mix(white, color, lineMax);

  gl_FragColor = vec4(color, 1.0);
}
