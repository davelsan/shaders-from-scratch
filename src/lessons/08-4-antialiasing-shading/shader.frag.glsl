
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

mat2 rotate2d(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s, s, c);
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

  // Star: distance of the pixel to a star shape _centered in the screen
  // - The normal order of translation -> rotation leads to the opposite origin effect
  vec2 starPos = pixelCoords;
  starPos *= rotate2d(uTime * 0.25);
  float heartDist = sdfStar(starPos, 150.0);

  color = mix(black, color, gradient);
  color = mix(gray, color, gridLine_small);
  color = mix(black, color, gridLine_large);

  // red pixels inside the star
  color = mix(red * 0.25, color, smoothstep(-1.0, 1.0, heartDist)); // antialias + darker shading
  color = mix(red, color, smoothstep(-5.0, 0.0, heartDist)); // recolor inner area except 5px border

  gl_FragColor = vec4(color, 1.0);
}