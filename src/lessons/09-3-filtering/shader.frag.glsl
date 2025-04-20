uniform int uFilterType;
uniform vec2 uResolution;
uniform int uTargetType;
uniform sampler2D uTexture;
uniform vec2 uTextureSize;

varying vec2 vUvs;

#pragma glslify: hash2d = require('../../shared/hash2d.glsl')

vec3 filterSample(sampler2D target, vec2 coords) {
  vec2 pixelCoord = coords * uTextureSize - 0.5; // OpenGL uses 0.5 as pixel centers
  vec2 baseCoord = floor(pixelCoord) + 0.5;

  // Sample the four corners surrounding the pixel we are interested in (1px offset)
  // We divide by the texture size to get a normalized UV coordinate.
  vec4 s1 = texture2D(target, (baseCoord + vec2(0.0, 0.0)) / uTextureSize);
  vec4 s2 = texture2D(target, (baseCoord + vec2(1.0, 0.0)) / uTextureSize);
  vec4 s3 = texture2D(target, (baseCoord + vec2(0.0, 1.0)) / uTextureSize);
  vec4 s4 = texture2D(target, (baseCoord + vec2(1.0, 1.0)) / uTextureSize);

  // Determine how far along the (x,y) axis the sample is
  vec2 f = fract(pixelCoord);
  if (uFilterType == 1) {
    f = smoothstep(0.0, 1.0, f); // smoothed linear filtering
  }

  // Lerps
  vec4 px1 = mix(s1, s2, f.x);
  vec4 px2 = mix(s3, s4, f.x);
  vec4 result = mix(px1, px2, f.y); // linear interpolation

  return result.rgb;
}

float noise2d(vec2 coords) {
  vec2 textureSize = vec2(1.0);
  vec2 pixelCoord = coords * textureSize;
  vec2 baseCoord = floor(pixelCoord);

  // Sample the hash2d function instead
  float s1 = hash2d((baseCoord + vec2(0.0, 0.0)) / textureSize);
  float s2 = hash2d((baseCoord + vec2(1.0, 0.0)) / textureSize);
  float s3 = hash2d((baseCoord + vec2(0.0, 1.0)) / textureSize);
  float s4 = hash2d((baseCoord + vec2(1.0, 1.0)) / textureSize);

  // Determine how far along the (x,y) axis the sample is
  vec2 f = fract(pixelCoord);
  if (uFilterType == 1) {
    f = smoothstep(0.0, 1.0, f); // smoothed linear filtering
  }

  // Lerps
  float px1 = mix(s1, s2, f.x);
  float px2 = mix(s3, s4, f.x);
  float result = mix(px1, px2, f.y); // linear interpolation

  return result;
}


void main() {
  vec3 color;
  if (uTargetType == 0) {
    vec2 coords = (vUvs - 0.5) * uResolution;
    color = vec3(noise2d(coords / 16.0));
  } else {
    color = filterSample(uTexture, vUvs);
  }

  gl_FragColor = vec4(color, 1.0);
}