uniform bool uLighting;
uniform int uNoiseType;
uniform int uOctaves;
uniform vec2 uResolution;
uniform float uTime;
uniform bool uUseResolution;

varying vec2 vUvs;

#pragma glslify: noise3d = require('../../shared/noise3d.glsl')

#pragma glslify: fbm = require('../../shared/fbm.glsl')
#pragma glslify: ridgedFBM = require('../../shared/fbm_ridged.glsl')
#pragma glslify: turbulenceFBM = require('../../shared/fbm_turbulence.glsl')
#pragma glslify: remap = require('../../shared/remap.glsl')

float voronoi(vec3 coords) {
  vec2 gridBasePosition = floor(coords.xy);
  vec2 gridCoordOffset = fract(coords.xy);

  float closest = 1.0;
  for (float y = -2.0; y <= 2.0; y += 1.0) {
    for (float x = -2.0; x <= 2.0; x += 1.0) {
      vec2 neighborCellPos = vec2(x, y);
      vec2 cellWorldPos = gridBasePosition + neighborCellPos;

      vec2 neighborCellOffset = vec2(
        noise3d(vec3(cellWorldPos, coords.z) + vec3(243.432, 324.235, 0.0)),
        noise3d(vec3(cellWorldPos, coords.z))
      );

      float distToNeighbor = length(
        neighborCellPos + neighborCellOffset - gridCoordOffset
      );

      closest = min(closest, distToNeighbor);
    }
  }

  return closest;
}

float stepped(float noiseSample) {
  // Divide into 10 discrete steps
  float steppedSample = floor(noiseSample * 10.0) / 10.0;
  // Fractional part
  float remainder = fract(noiseSample * 10.0);
  // Halo effect: darken bright areas, brighten dark areas
  steppedSample = (steppedSample - remainder) * 0.5 + 0.5;

  return steppedSample;
}

float domainWarpingFBM(vec3 coords) {
  // First offset
  vec3 offset = vec3(
    fbm(coords, 4, 0.5, 2.0), // x: sample FBM at the coordinate
    fbm(coords + vec3(43.235, 23.112, 0.0), 4, 0.5, 2.0), // y: sample by some random amount
    0.0
  );
  // float noiseSample = fbm(coords + offset, 1, 0.5, 2.0);

  // Second offset, similar to the first with some small changes
  vec3 offset2 = vec3(
    fbm(coords + 4.0 * offset + vec3(5.325, 1.421, 3.235), 4, 0.5, 2.0),
    fbm(coords + 4.0 * offset + vec3(4.32, 0.532, 6.324), 4, 0.5, 2.0),
    0.0
  );
  float noiseSample = fbm(coords + 4.0 * offset2, 1, 0.5, 2.0);

  return noiseSample;
}

void main() {
  // We use a vec3 so "z" can be used to animate over time
  vec3 coords;
  if (uUseResolution) {
    coords = vec3((vUvs - 0.5) * uResolution / 16.0, uTime * 0.2);
  } else {
    coords = vec3(vUvs * 10.0, uTime * 0.2);
  }
  float noiseSample = 0.0;

  // Typical noise output range is [-1.0, 1.0]
  if (uNoiseType == 0) {
    noiseSample = remap(fbm(coords, uOctaves, 0.5, 2.0), -1.0, 1.0, 0.0, 1.0);
  } else if (uNoiseType == 1) {
    noiseSample = ridgedFBM(coords, uOctaves, 0.5, 2.0);
  } else if (uNoiseType == 2) {
    noiseSample = turbulenceFBM(coords, uOctaves, 0.5, 2.0);
  } else if (uNoiseType == 3) {
    noiseSample = voronoi(coords);
    // noiseSample = 1.0 - voronoi(coords);
  } else if (uNoiseType == 4) {
    noiseSample = remap(noise3d(coords), -1.0, 1.0, 0.0, 1.0);
    noiseSample = stepped(noiseSample);
  } else if (uNoiseType == 5) {
    noiseSample = remap(domainWarpingFBM(coords), -1.0, 1.0, 0.0, 1.0);
  }

  vec3 color = vec3(noiseSample);

  if (uNoiseType == 2 && uLighting) {
    // Pixel width
    vec3 pixel = vec3(0.5 / uResolution, 0.0);

    // Gather four samples in each direction
    // Swizzle trick to put the pixel value on x (or y) and zero out the other two
    float s1 = turbulenceFBM(coords + pixel.xzz, 4, 0.5, 2.0);
    float s2 = turbulenceFBM(coords - pixel.xzz, 4, 0.5, 2.0);
    float s3 = turbulenceFBM(coords + pixel.zyz, 4, 0.5, 2.0);
    float s4 = turbulenceFBM(coords - pixel.zyz, 4, 0.5, 2.0);

    // The larger the random z value, the weaker the contribution of the x/y components
    vec3 normal = normalize(vec3(s1 - s2, s3 - s4, 0.001));

    // Hemi
    vec3 skyColour = vec3(0.0, 0.3, 0.6);
    vec3 groundColour = vec3(0.6, 0.3, 0.1);

    vec3 hemi = mix(groundColour, skyColour, remap(normal.y, -1.0, 1.0, 0.0, 1.0));

    // Diffuse lighting
    vec3 lightDir = normalize(vec3(1.0, 1.0, 1.0));
    vec3 lightColour = vec3(1.0, 1.0, 0.9);
    float dp = max(0.0, dot(lightDir, normal));

    vec3 diffuse = dp * lightColour;
    vec3 specular = vec3(0.0);

    // Specular
    vec3 r = normalize(reflect(-lightDir, normal));
    float phongValue = max(0.0, dot(vec3(0.0, 0.0, 1.0), r));
    phongValue = pow(phongValue, 32.0);

    specular += phongValue;

    vec3 baseColor = mix(
      vec3(1.0, 0.25, 0.25),
      vec3(1.0, 0.75, 0.0), smoothstep(0.0, 1.0, noiseSample));

    vec3 lighting = hemi * 0.125 + diffuse * 0.5;

    color = baseColor * lighting + specular;
    color = pow(color, vec3(1.0 / 2.2));
  }

  gl_FragColor = vec4(color, 1.0);
}