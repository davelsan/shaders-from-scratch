varying vec4 vColor;
varying vec3 vNormal;
varying vec3 vPosition;

#pragma glslify: remap = require('../../shared/remap.glsl')

const vec3 red = vec3(1.0, 0.0, 0.0);
const vec3 blue = vec3(0.0, 0.0, 1.0);

void main() {
  // Any transformations done in local space will carry over to world space
  vec3 localSpacePosition = position;

  // Typically use 1.0 for position matrices, and 0.0 for directional vector transformations
  gl_Position = projectionMatrix * modelViewMatrix * vec4(localSpacePosition, 1.0); // <- transform to clip space

  /**
   * Remap the vertex position.x [-0.5, 0.5] to [0.0, 1.0]
   * pow 2 width segments = [0.0, 1.0] -> [0.0, 1.0]
   * pow 4 width segments = [0.0, 0.25, 0.5, 0.75, 1.0] -> [0.0, 0.0625, 0.25, 0.5625, 1.0]
   * ...
   */
  float t = remap(localSpacePosition.x, -0.5, 0.5, 0.0, 1.0);
  t = pow(t, 2.0);

  vColor = vec4(mix(red, blue, t), t);
  vNormal = (modelMatrix * vec4(normal, 0.0)).xyz;
  vPosition = (modelMatrix * vec4(localSpacePosition, 1.0)).xyz;
}