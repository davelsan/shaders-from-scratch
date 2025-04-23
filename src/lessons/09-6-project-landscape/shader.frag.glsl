uniform float uBackgroundBlur;
uniform float uForegroundBlur;

uniform vec2 uResolution;
uniform float uTime;

varying vec2 vUvs;

#pragma glslify: fbm = require('../../shared/fbm.glsl')
#pragma glslify: noise3d = require('../../shared/noise3d.glsl')
#pragma glslify: remap = require('../../shared/remap.glsl')

const vec3 SKY_LIGHT = vec3(0.4, 0.6, 0.9);
const vec3 SKY_DARK = vec3(0.1, 0.15, 0.4);

vec3 drawSky() {
  return mix(SKY_LIGHT, SKY_DARK, smoothstep(0.875, 1.0, vUvs.y));
}

float sdfMountain(vec2 pixelCoords, float depth) {
  // Sine wave with limited frequency according to an arbitrary screen size
  // float y = sin(pixelCoords.x / 64.0) * 64.0;

  // Or use an FBM instead to add noise to the wave
  // Depth randomizes the noise sample for each set of mountains
  float y = fbm(
    vec3(depth + pixelCoords.x / 256.0, 1.432, 3.643),
    6, // octaves
    0.5, // persistence
    2.0 // lacunarity
  ) * 256.0;

  return pixelCoords.y - y;
}

vec3 drawMountains(
  vec2 pixelCoords,
  float yOffset,
  float xOffset,
  float frequency,
  vec3 backgroundColor,
  vec3 mountainColor,
  float depth
) {
  // Offset them upwards (reverse coord sign in SDFs)
  vec2 mountainCoords = (pixelCoords - vec2(0.0, yOffset)) * frequency + vec2(xOffset, 0.0);

  // Mountain shape
  float t = sdfMountain(mountainCoords, depth);

  // Fog
  float fogFactor = smoothstep(0.0, 8000.0, depth) * 0.5;
  float heightFactor = smoothstep(256.0, -900.0, pixelCoords.y);
  heightFactor *= heightFactor; // converge towards zero
  fogFactor = mix(heightFactor, fogFactor, fogFactor);

  mountainColor = mix(mountainColor, SKY_LIGHT, fogFactor);

  // DOF
  float blur = 1.0 +
    // background
    smoothstep(200.0, uBackgroundBlur, depth) * 128.0 +
    // foreground
    smoothstep(200.0, uForegroundBlur, depth) * 128.0;

  // Negative values are mountain color
  // Positive values are background
  // Small [0.0,1.0] range (remember, pixel coordinates) is antialiasing
  vec3 color = mix(mountainColor, backgroundColor, smoothstep(0.0, blur, t));
  return color;
}

void main() {
  vec2 pixelCoords = (vUvs - 0.5) * uResolution;

  // Sky
  vec3 color = drawSky();

  // Mountains
  float timeOffset = uTime * 20.0;

  color = drawMountains(pixelCoords, 300.0, timeOffset, 8.0, color, vec3(0.5), 6000.0);
  color = drawMountains(pixelCoords, 260.0, timeOffset, 4.0, color, vec3(0.45), 3200.0);
  color = drawMountains(pixelCoords, 200.0, timeOffset, 2.0, color, vec3(0.40), 1600.0);
  color = drawMountains(pixelCoords, 120.0, timeOffset, 1.0, color, vec3(0.35), 800.0);
  color = drawMountains(pixelCoords, -20.0, timeOffset, 0.5, color, vec3(0.30), 400.0);
  color = drawMountains(pixelCoords, -200.0, timeOffset, 0.25, color, vec3(0.25), 200.0);
  color = drawMountains(pixelCoords, -600.0, timeOffset, 0.125, color, vec3(0.20), 0.0);

  gl_FragColor = vec4(color, 1.0);
}