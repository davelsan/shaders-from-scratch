

varying vec3 vNormal;
varying vec3 vPosition;

void main() {
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

  // Pass transformed local space -> world space varyings
  vNormal = (modelMatrix * vec4(normal, 0.0)).xyz; // 0.0; we need the translation, only rotation
  vPosition = (modelMatrix * vec4(position, 1.0)).xyz; // 1.0; we need the translation
}