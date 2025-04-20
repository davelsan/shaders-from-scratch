uniform vec2 uResolution;
varying vec2 vUvs;

#pragma glslify: noise = require('../../shared/noise2d.glsl')

void main() {
  vec2 pixelCoords = (vUvs - 0.5) * uResolution;

  vec3 colour = vec3(noise(pixelCoords / 16.0));

  gl_FragColor = vec4(colour, 1.0);
}