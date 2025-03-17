
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

float sdfCircle(vec2 point, float radius) {
  // length is always a positive value -> sqrt(x[0]^2 + x[2]^2)
  return length(point) - radius;
}

float sdfLine(vec2 point, vec2 a, vec2 b) {
  vec2 linePA = point - a;
  vec2 lineBA = b - a;

  // Project linePA over lineBA
  // Clamp [0.0,1.0] because we only care about the line _segment_, not the entire line
  float h = dot(linePA, lineBA) / dot(lineBA, lineBA);
  h = clamp(h, 0.0, 1.0);

  // Return the distance
  return length(linePA - lineBA * h);
}

float sdfBox(vec2 point, vec2 bounds) {
  // bounds is vec2(width,height)
  vec2 q = abs(point) - bounds;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
}

float dot2( in vec2 v ) { return dot(v,v); }

// https://iquilezles.org/articles/distfunctions2d/
float sdfStar(in vec2 p, in float r)
{
    const vec4 k = vec4(-0.5,0.8660254038,0.5773502692,1.7320508076);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= 2.0*min(dot(k.yx,p),0.0)*k.yx;
    p -= vec2(clamp(p.x,r*k.z,r*k.w),r);
    return length(p)*sign(p.y);
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
  vec3 gradient = backgroundGradient();

  // Grid lines
  float gridLine_small = gridLine(10.0, 1.0);
  float gridLine_large = gridLine(100.0, 1.5);

  // Circle: distance of the pixel to a circle in the screen
  float dCircle = sdfCircle(pixelCoords, 100.0); // centered

  // Line: distance of the pixel to a line between two arbitrary points
  // float dLine = sdfLine(pixelCoords, vec2(-100.0, -150.0), vec2(200.0, -75.0));
  float dLine = sdfLine(pixelCoords, -edge, edge);

  // Square: distance of the pixel to a box shape
  // float dBox = sdfBox(pixelCoords, vec2(100.0, 100.0)); // centered
  float dBox = sdfBox(pixelCoords + (edge * 0.6), vec2(50.0, 50.0)); // translated

  // Star: distnace of the pixel to a star shape _centered in the screen
  // float dStar = sdfStar(pixelCoords, 100.0); // centered
  // float dStar = sdfStar(pixelCoords - 200.0, 50.0); // centered
  float dStar = sdfStar(pixelCoords - edge * 0.6, 50.0); // translated

  color = mix(black, color, gradient);
  color = mix(gray, color, gridLine_small);
  color = mix(black, color, gridLine_large);

  // d < 0; inside circle (red)
  // d >= 0; outside circle (color)
  color = mix(red, color, step(0.0, dCircle));

  // red pixels within a 5px line (2.5 on each side)
  color = mix(red, color, step(2.5, dLine));

  // red pixels inside the box
  color = mix(red, color, step(0.0, dBox));

  // red pixels inside the star
  color = mix(red, color, step(0.0, dStar));

  gl_FragColor = vec4(color, 1.0);
}