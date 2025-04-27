uniform vec2 uResolution;
uniform sampler2D uTextureDog;
uniform sampler2D uTexturePlants;
uniform float uTime;

varying vec2 vUvs;

#pragma glslify: fbm = require('../../shared/fbm.glsl')
#pragma glslify: noise3d = require('../../shared/noise3d.glsl')
#pragma glslify: remap = require('../../shared/remap.glsl')
#pragma glslify: sdfCircle = require('../../shared/sdf_circle.glsl')

const vec3 FIRE_COLOR = vec3(1.0, 0.5, 0.2); // orange
const vec3 GLOW_COLOR = vec3(1.0, 0.2, 0.05); // orange glow

void main() {
  vec2 pixelCoords = (vUvs - 0.5) * uResolution;

  // Animated circle
  float noise = fbm(vec3(pixelCoords, 0.0) * 0.005, 4, 0.5, 2.0); // uneven edge
  float diagonal = length(uResolution); // Distance from center of the screen to the corners [vec2(0.0, 0.0), vec2(x, y)]
  diagonal += 50.0; // increase circle radius to compensate for the noise reduction
  float duration = 15.0;
  float size = smoothstep(0.0, duration, uTime) * diagonal * 0.5;
  float d = sdfCircle(pixelCoords + 50.0 * noise, size);

  // Texture distortion at the edges
  vec2 distortion = (noise / uResolution) * 20.0 * smoothstep(80.0, 20.0, d);

  vec3 texDog = texture2D(uTextureDog, vUvs + distortion).xyz;
  vec3 textPlants = texture2D(uTexturePlants, vUvs).xyz;

  // Initial texture
  vec3 color = texDog;

  // Dark burn effect
  float burnAmount = 1.0 - exp(-d * d * 0.001); // exponential shaping function
  color = mix(vec3(0.0), color, burnAmount);

  // Flam burn effect
  float fireAmount = smoothstep(0.0, 10.0, d); // 10px wide
  fireAmount = pow(fireAmount, 0.25); // power function
  // float fireAmount = 1.0 - exp(-d * d * 0.5); // exponential shaping function
  color = mix(FIRE_COLOR, color, fireAmount);

  // Transition
  color = mix(textPlants, color, smoothstep(0.0, 1.0, d));

  // Fiery glow
  float glowAmount = smoothstep(0.0, 32.0, abs(d)); // 32px, abs bidirectional glow
  glowAmount = 1.0 - pow(glowAmount, 0.125); // invert (white) and rapid fall-off
  color += glowAmount * GLOW_COLOR;
  // color = vec3(glowAmount); // debug

  // gl_FragColor = vec4(color, 1.0);
  gl_FragColor = vec4(color, 1.0);
}
