varying vec2 vUvs;

void main() {
  gl_Position = vec4(position, 1.0);
  vUvs = uv;
}