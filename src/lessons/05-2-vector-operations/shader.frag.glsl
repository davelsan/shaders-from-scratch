
varying vec2 vUvs;

uniform vec2 resolution;

vec3 red = vec3(1.0, 0.0, 0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);
vec3 white = vec3(1.0, 1.0, 1.0);
vec3 black = vec3(0.0, 0.0, 0.0);
vec3 yellow = vec3(1.0, 1.0, 0.0);

/**
 * Confine the line to a narrow interval, so it shows thin and clear.
 */
float narrow_line(float value) {
  return smoothstep(0.0, 0.0075, value);
}

float custom_clamp(float value, float edge1, float edge2) {
  return max(edge1, min(value, edge2));
}

void main() {
  vec3 color = vec3(0.0);

  float sqrt_x = sqrt(vUvs.x);
  float parabolic_x = vUvs.x * (1.0 - vUvs.x) * 4.0;
  float pow_x = pow(vUvs.x, 2.0);

  float lineBottom = smoothstep(0.0, 0.005, abs(vUvs.y - 0.33));
  float lineMiddle = smoothstep(0.0, 0.005, abs(vUvs.y - 0.66));

  float lineMin = narrow_line(abs(vUvs.y - mix(0.66, 1.0, sqrt_x)));
  float lineClamp = narrow_line(abs(vUvs.y - mix(0.33, 0.66, parabolic_x)));
  float lineMax = narrow_line(abs(vUvs.y - mix(0.0, 0.33, pow_x)));

  if (vUvs.y > 0.66) {
    color = mix(red, blue, sqrt_x);
  }
  else if (vUvs.y > 0.33) {
    color = mix(red, blue, parabolic_x);
  }
  else {
    color = mix(red, blue, pow_x);
  }

  color = mix(white, color, lineBottom);
  color = mix(white, color, lineMiddle);
  color = mix(white, color, lineMin);
  color = mix(white, color, lineClamp);
  color = mix(white, color, lineMax);

  gl_FragColor = vec4(color, 1.0);
}
