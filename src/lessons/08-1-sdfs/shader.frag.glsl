
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

#pragma glslify: remap = require('../../shared/remap.glsl');
#pragma glslify: inverseLerp = require('../../shared/inverse_lerp.glsl');

float cell_line(float value, float thickness) {
  return smoothstep(0.0, thickness, value);
}

vec3 backgroundGradient() {
  vec2 center = vUvs - 0.5; // [0.0, 1.0] -> [-0.5, 0.5]
  float distToCenter = length(abs(center)); // [0.0, 0.5]

  // Vignette effect
  float vignette = 1.0 - distToCenter; // [0.5, 1.0]
  // Increase white area -> remap [0.0, >=0.7] -> [0.0, 1.0]
  vignette = smoothstep(0.0, 0.7, vignette);
  // Brighten the overall shading -> interpolate [0.0, 1.0] -> [0.3, 1.0]
  vignette = remap(vignette, 0.0, 1.0, 0.3, 1.0);

  return vec3(vignette);
}

float gridLine(float cellSpacing, float lineWidth) {
  // Plane center
  vec2 center = vUvs - 0.5;

  // cell center
  vec2 cell = fract(center * uResolution / cellSpacing);
  cell = abs(cell - 0.5);

  // distance to cell edge [0.0, 0.5]
  float distoToEdge = 0.5 - max(cell.x, cell.y);
  // Convert to pixels
  distoToEdge *= cellSpacing;

  // Narrow the cell line to the given width
  float cellLine = smoothstep(0.0, lineWidth, distoToEdge);

  return cellLine;
}

void main() {
  // Base color
  vec3 color = vec3(1.0);

  // Compute pixel coordinates
  // - Centered on the screen [-0.5, 0.5]
  // - [-1/2 resolution, +1/2 resolution]
  vec2 pixelCoords = (vUvs - 0.5) * uResolution;

  // Background gradient
  vec3 gradient = backgroundGradient();

  // Grid lines
  float gridLine_small = gridLine(10.0, 1.0);
  float gridLine_large = gridLine(100.0, 1.5);

  color = mix(black, color, gradient);
  color = mix(gray, color, gridLine_small);
  color = mix(black, color, gridLine_large);

  gl_FragColor = vec4(color, 1.0);
}