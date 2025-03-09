#pragma glslify: easeOutBounce = require('./ease_out_bounce.glsl')

float easeInOutBounce(float x) {
  return x < 0.5
    ? (1.0 - easeOutBounce(1.0 - 2.0 * x)) / 2.0
    : (1.0 + easeOutBounce(2.0 * x - 1.0)) / 2.0;
}

#pragma glslify: export(easeInOutBounce)
