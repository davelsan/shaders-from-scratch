
varying vec2 vUvs;

uniform sampler2D uDiffuse;

vec3 red = vec3(1.0, 0.0, 0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);
vec3 white = vec3(1.0, 1.0, 1.0);

#pragma glslify: remap_narrow = require(../../shared/remap_narrow.glsl, thickness=0.0075)

void main() {
  vec3 color = vec3(0.0);

  float lineSep = smoothstep(0.0, 0.005, abs(vUvs.y - 0.5));

  float linear_x = vUvs.x;
  float lineLinear = remap_narrow(abs(vUvs.y - mix(0.5, 1.0, linear_x)));

  float smooth_x = smoothstep(0.0, 1.0, vUvs.x);
  float lineSmooth = remap_narrow(abs(vUvs.y - mix(0.0, 0.5, smooth_x)));

  // Gradients
  // - Middle: mix
  // - Bottom: smoothstep
  if (vUvs.y > 0.5) {
    color = mix(red, blue, linear_x);
  }
  else {
    color = mix(red, blue, smooth_x);
  }

  // Lines
  color = mix(white, color, lineSep);
  color = mix(white, color, lineLinear);
  color = mix(white, color, lineSmooth);

  gl_FragColor = vec4(color, 1.0);
}
