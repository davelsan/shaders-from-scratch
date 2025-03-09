varying vec3 vNormal;
varying vec3 vPosition;

uniform float uTime;

#pragma glslify: easeOutBounce = require('../../shared/ease_out_bounce.glsl');

void main() {
  // Any transformations done in local space will carry over to world space
  vec3 localSpacePosition = position;

  /**
   * Bounce
   */
  localSpacePosition.xz *= easeOutBounce(clamp(uTime - 2.0, 0.0, 1.0));

  // Typically use 1.0 for position matrices, and 0.0 for directional vector transformations
  gl_Position = projectionMatrix * modelViewMatrix * vec4(localSpacePosition, 1.0); // <- transform to clip space
  vNormal = (modelMatrix * vec4(normal, 0.0)).xyz;
  vPosition = (modelMatrix * vec4(localSpacePosition, 1.0)).xyz;
}