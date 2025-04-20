uniform bool uFBM;
uniform int uOctaves;
uniform vec2 uResolution;
uniform float uTime;

varying vec2 vUvs;

#pragma glslify: fbm = require('../../shared/fbm.glsl')
#pragma glslify: noise3d = require('../../shared/noise3d.glsl')
#pragma glslify: remap = require('../../shared/remap.glsl')

void main() {
  // We use a vec3 so "z" can be used to animate over time
  vec3 coords = vec3(vUvs * 10.0, uTime * 0.2);
  float noiseSample = 0.0;

  // Typical noise output range is [-1.0, 1.0]
  if (uFBM == true) {
    noiseSample = remap(fbm(coords, uOctaves, 0.5, 2.0), -1.0, 1.0, 0.0, 1.0);
  } else {
    noiseSample = remap(noise3d(coords), -1.0, 1.0, 0.0, 1.0);
  }

  vec3 color = vec3(noiseSample);

  gl_FragColor = vec4(color, 1.0);
}