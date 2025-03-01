/**
 * Remap a value to a very narrow interval.
 * Useful to draw thin and clear lines.
 */
float remap_narrow(float value) {
  return smoothstep(0.0, thickness, value);
}

#pragma glslify: export(remap_narrow)