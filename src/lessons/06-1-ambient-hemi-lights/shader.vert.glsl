

varying vec3 vNormal;
varying vec3 vPosition;

void main() {
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

  // Pass a normal transformed local space -> world space
  vNormal = (modelMatrix * vec4(normal, 0.0)).xyz; // 0.0 because we don't care about translation, only rotation
}