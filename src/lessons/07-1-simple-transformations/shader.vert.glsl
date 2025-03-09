varying vec3 vNormal;
varying vec3 vPosition;

uniform float uTime;

#pragma glslify: remap = require('../../shared/remap.glsl')
#pragma glslify: rotateY = require('../../shared/rotate_y.glsl')
#pragma glslify: rotateX = require('../../shared/rotate_x.glsl')
#pragma glslify: rotateZ = require('../../shared/rotate_z.glsl')

void main() {
  // Any transformations done in local space will carry over to world space
  vec3 localSpacePosition = position;

  /**
   * Scaling
   */
  localSpacePosition.xz *= remap(sin(uTime), -1.0, 1.0, 0.5, 1.5);

  /**
   * Rotation
   */
  localSpacePosition = rotateY(uTime) * localSpacePosition;

  /**
   * Translation
   */
  localSpacePosition.xz += sin(uTime);


  // Typically use 1.0 for position matrices, and 0.0 for directional vector transformations
  gl_Position = projectionMatrix * modelViewMatrix * vec4(localSpacePosition, 1.0); // <- transform to clip space
  vNormal = (modelMatrix * vec4(normal, 0.0)).xyz;
  vPosition = (modelMatrix * vec4(localSpacePosition, 1.0)).xyz;
}