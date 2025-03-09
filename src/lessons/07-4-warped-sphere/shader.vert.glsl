varying vec3 vColour;
varying vec3 vNormal;
varying vec3 vPosition;

uniform float uTime;

#pragma glslify: remap = require('../../shared/remap.glsl')

void main() {
  // Any transformations done in local space will carry over to world space
  vec3 localSpacePosition = position;

  // deform on the y-axis
  // float t = sin(localSpacePosition.y * 10.0 * uTime * 0.5);
  float t = sin(localSpacePosition.y * 20.0 + uTime * 7.5);

  // remap so it is less extreme
  t = remap(t, -1.0, 1.0, 0.0, 0.2);

  // move outwards from the sphere -> in the direction of the normal
  localSpacePosition += normal * t;

  // Typically use 1.0 for position matrices, and 0.0 for directional vector transformations
  gl_Position = projectionMatrix * modelViewMatrix * vec4(localSpacePosition, 1.0); // <- transform to clip space
  vNormal = (modelMatrix * vec4(normal, 0.0)).xyz;
  vPosition = (modelMatrix * vec4(localSpacePosition, 1.0)).xyz;

  // Lighter peaks / Darker troughs
  vColour = mix(
    vec3(0.0, 0.0, 0.5),
    vec3(0.1, 0.5, 0.8),
    smoothstep(0.0, 0.2, t)
  );
}