
uniform vec2 uResolution;
uniform float uTime;

varying vec2 vUvs;

vec3 black = vec3(0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);
vec3 gray = vec3(0.5);
vec3 green = vec3(0.0, 1.0, 0.0);
vec3 purple = vec3(1.0, 0.25, 1.0);
vec3 red = vec3(1.0, 0.0, 0.0);
vec3 yellow = vec3(1.0, 1.0, 0.0);

#pragma glslify: gridLine = require('../../shared/gridline.glsl', vUvs=vUvs, uResolution=uResolution);
#pragma glslify: inverseLerp = require('../../shared/inverse_lerp.glsl');
#pragma glslify: remap = require('../../shared/remap.glsl');
#pragma glslify: rotate2d = require('../../shared/rotate2d.glsl');
#pragma glslify: sdfCircle = require('../../shared/sdf_circle.glsl);
#pragma glslify: sdfStar = require('../../shared/sdf_star.glsl');
#pragma glslify: vignette = require('../../shared/vignette.glsl', vUvs=vUvs);

float opUnion(float d1, float d2) {
  return min(d1, d2);
}

float opSubtraction(float d1, float d2) {
  return max(-d1, d2);
}

float opIntersection(float d1, float d2) {
  return max(d1, d2);
}

float softMax(float a, float b, float k) {
  return log(exp(k * a) + exp(k * b)) / k;
}

float softMin(float a, float b, float k) {
  return -softMax(-a, -b, k);
}

float softMinValue(float a, float b, float k) {
  // float h = remap(a - b, -1.0 / k, 1.0 / k, 0.0, 1.0);
  // softmax probability distribution
  float h = exp(-b * k) / (exp(-a * k) + exp(-b * k));
  return h;
}

void main() {
  // Base color
  vec3 color = vec3(1.0);
  vec2 edge = uResolution / 2.0;

  // Compute pixel coordinates
  // - Centered on the screen [-0.5, 0.5]
  // - [-1/2 resolution, +1/2 resolution]
  vec2 pixelCoords = (vUvs - 0.5) * uResolution;

  // Background gradient
  vec3 gradient = vignette();

  // Grid lines
  float gridLine_small = gridLine(10.0, 1.0);
  float gridLine_large = gridLine(100.0, 1.5);

  // Star: distance of the pixel to a star shape _centered in the screen
  vec2 starPos = pixelCoords;
  starPos *= rotate2d(uTime * 0.25);
  float heartDist = sdfStar(starPos, 75.0);

  // Circles
  vec2 top = vec2(0.0, -edge.y * 0.5);
  vec2 left = vec2(edge * 0.4);
  vec2 right = vec2(-edge.x * 0.4, edge.y * 0.4);

  float d1 = sdfCircle(pixelCoords + top, 100.0);
  float d2 = sdfCircle(pixelCoords + left, 100.0);
  float d3 = sdfCircle(pixelCoords + right, 100.0);
  float d = opUnion(opUnion(d1, d2), d3);
  d = softMin(heartDist, d, 0.05);

  color = mix(black, color, gradient);
  color = mix(gray, color, gridLine_small);
  color = mix(black, color, gridLine_large);

  vec3 sdfColor = mix(red, blue, smoothstep(0.0, 1.0, softMinValue(heartDist, d, 0.01)));

  color = mix(sdfColor * 0.25, color, smoothstep(-1.0, 1.0, d)); // antialias + darker shading
  color = mix(sdfColor, color, smoothstep(-5.0, 0.0, d)); // recolor inner area except 5px border

  gl_FragColor = vec4(color, 1.0);
}