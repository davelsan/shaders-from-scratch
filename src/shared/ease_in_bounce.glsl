#pragma glslify: easeOutBounce = require('./ease_out_bounce.glsl')

float easeInBounce(float x) {
  return 1.0 - easeOutBounce(1.0 - x);
}

#pragma glslify: export(easeInBounce)
