float gridLine(float cellSpacing, float lineWidth) {
  // Plane center
  vec2 center = vUvs - 0.5;

  // cell center
  vec2 cell = fract(center * uResolution / cellSpacing);
  cell = abs(cell - 0.5);

  // distance to cell edge [0.0, 0.5]
  float distoToEdge = 0.5 - max(cell.x, cell.y);
  // Convert to pixels
  distoToEdge *= cellSpacing;

  // Narrow the cell line to the given width
  float cellLine = smoothstep(0.0, lineWidth, distoToEdge);

  return cellLine;
}

#pragma glslify: export(gridLine);