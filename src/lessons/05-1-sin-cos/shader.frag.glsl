uniform sampler2D uDiffuse;
uniform float uTime;

varying vec2 vUvs;

vec3 red = vec3(1.0, 0.0, 0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);

#pragma glslify: remap = require(../../shared/remap.glsl)

void main() {
  vec3 color = vec3(0.0);

  vec4 texture = texture2D(uDiffuse, vUvs);
  color = texture.xyz;

  // Thin bars scrolling downwards
  float t1 = remap(sin(vUvs.y * 400.0 + uTime * 10.0), -1.0, 1.0, 0.9, 1.0);
  // Thick bars scrolling upwards
  float t2 = remap(sin(vUvs.y * 50.0 - uTime * 2.0), -1.0, 1.0, 0.9, 1.0);
  // Remap is used to lighen the moving bars, so they blend into the texture
  color = color * t1 * t2;

  gl_FragColor = vec4(color, 1.0);
}