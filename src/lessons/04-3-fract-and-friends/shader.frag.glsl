uniform int uFunction;
uniform float uModFnValue;
uniform vec2 uResolution;

varying vec2 vUvs;

vec3 red = vec3(1.0, 0.0, 0.0);
vec3 green = vec3(0.0, 1.0, 0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);
vec3 pink = vec3(1.0, 0.0, 1.0);
vec3 lightBlue = vec3(0.0, 1.0, 1.0);
vec3 white = vec3(1.0, 1.0, 1.0);
vec3 black = vec3(0.0, 0.0, 0.0);
vec3 yellow = vec3(1.0, 1.0, 0.0);
vec3 gray = vec3(0.5, 0.5, 0.5);

const float SM = 0.01;
const float MD = 0.002;
const float LG = 0.03;

#pragma glslify: cell_line = require(../../shared/remap_narrow, thickness=SM)
#pragma glslify: axis_line = require(../../shared/remap_narrow, thickness=MD)
#pragma glslify: fn_line = require(../../shared/remap_narrow, thickness=LG)

void main() {
  vec3 color = vec3(0.75);
  vec2 center = vUvs - 0.5;

  // Create grid
  vec2 cell = fract(center * uResolution / 100.0);
  cell = abs(cell - 0.5);
  float distToCell = 1.0 - 2.0 * max(cell.x, cell.y);
  float cellLine = cell_line(distToCell);

  // Create axes
  float xAxis = axis_line(abs(vUvs.y - 0.5));
  float yAxis = axis_line(abs(vUvs.x - 0.5));

  // Reference function: y = x, centered at [0,0], maps to 100px
  vec2 pos = center * uResolution / 100.0;
  float val = pos.x;
  float fn = fn_line(abs(pos.y - val));

  // Functions
  float absFn = fn_line(abs(pos.y - abs(val)));
  float floorFn = fn_line(abs(pos.y - floor(val)));
  float ceilFn = fn_line(abs(pos.y - ceil(val)));
  float roundFn = fn_line(abs(pos.y - round(val)));
  float fractFn = fn_line(abs(pos.y - fract(val)));
  float modFn = fn_line(abs(pos.y - mod(val, uModFnValue)));

  color = mix(black, color, cellLine);
  color = mix(blue, color, xAxis);
  color = mix(blue, color, yAxis);
  color = mix(yellow, color, fn);

  if (uFunction == 0) {
    color = mix(red, color, absFn);
  } else if (uFunction == 1) {
    color = mix(red, color, floorFn);
  } else if (uFunction == 2) {
    color = mix(red, color, ceilFn);
  } else if (uFunction == 3) {
    color = mix(red, color, roundFn);
  } else if (uFunction == 4) {
    color = mix(red, color, fractFn);
  } else if (uFunction == 5) {
    color = mix(red, color, modFn);
  }

  gl_FragColor = vec4(color, 1.0);
}
