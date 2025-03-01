varying vec2 vUvs;

uniform sampler2D uDiffuse;

void main() {
  vec4 diffuseSample = texture2D(uDiffuse, vUvs);

  // Apply individually
  // diffuseSample.r = smoothstep(0.0, 1.0, diffuseSample.r);
  // diffuseSample.g = smoothstep(0.0, 1.0, diffuseSample.g);
  // diffuseSample.b = smoothstep(0.0, 1.0, diffuseSample.b);
  // diffuseSample.w = smoothstep(0.0, 1.0, diffuseSample.w);
  // gl_FragColor = diffuseSample;

  // Apply as a vector operation
  gl_FragColor = smoothstep(vec4(0.0), vec4(1.0), diffuseSample);
}
