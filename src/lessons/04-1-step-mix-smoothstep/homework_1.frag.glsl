varying vec2 vUvs;

uniform sampler2D uDiffuse;

vec3 red = vec3(1.0, 0.0, 0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);
vec3 white = vec3(1.0, 1.0, 1.0);
vec3 black = vec3(0.0, 0.0, 0.0);
vec3 yellow = vec3(1.0, 1.0, 0.0);

#pragma glslify: remap_narrow = require(../../shared/remap_narrow.glsl, thickness=0.0075)

void main() {
  vec3 color = vec3(0.0);

  float step_x = step(0.5, vUvs.x);
  float linear_x = vUvs.x;
  float smooth_x = smoothstep(0.0, 1.0, vUvs.x);

  float lineBottom = smoothstep(0.0, 0.005, abs(vUvs.y - 0.33));
  float lineMiddle = smoothstep(0.0, 0.005, abs(vUvs.y - 0.66));

  float lineStep = remap_narrow(abs(vUvs.y - mix(0.66, 1.0, step_x)));
  float lineLinear = remap_narrow(abs(vUvs.y - mix(0.33, 0.66, linear_x)));
  float lineSmooth = remap_narrow(abs(vUvs.y - mix(0.0, 0.33, smooth_x)));

  // Gradients
  // - Top: step
  // - Middle: mix
  // - Bottom: smoothstep
  if (vUvs.y > 0.66) {
    color = mix(red, blue, step_x);
  }
  else if (vUvs.y > 0.33) {
    color = mix(red, blue, linear_x);
  }
  else {
    color = mix(red, blue, smooth_x);
  }

  color = mix(white, color, lineBottom);
  color = mix(white, color, lineMiddle);
  color = mix(white, color, lineStep);
  color = mix(white, color, lineLinear);
  color = mix(white, color, lineSmooth);

  gl_FragColor = vec4(color, 1.0);
}
