uniform int uFilterType;
uniform vec2 uResolution;
uniform int uTargetType;
uniform sampler2D uTexture;
uniform vec2 uTextureSize;

varying vec2 vUvs;

// The MIT License
// Copyright © 2013 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// https://www.youtube.com/c/InigoQuilez
// https://iquilezles.org/
//
// https://www.shadertoy.com/view/lsf3WH
// Renamed function to "mathRandom" from "hash"
float mathRandom(vec2 p)  // replace this by something better
{
  p  = 50.0*fract( p*0.3183099 + vec2(0.71,0.113));
  return -1.0+2.0*fract( p.x*p.y*(p.x+p.y) );
}

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

float noise(vec2 coords) {
  vec2 textureSize = vec2(1.0);
  vec2 pixelCoord = coords * textureSize;
  vec2 baseCoord = floor(pixelCoord);

  // Sample the mathRandom function instead
  float s1 = mathRandom((baseCoord + vec2(0.0, 0.0)) / textureSize);
  float s2 = mathRandom((baseCoord + vec2(1.0, 0.0)) / textureSize);
  float s3 = mathRandom((baseCoord + vec2(0.0, 1.0)) / textureSize);
  float s4 = mathRandom((baseCoord + vec2(1.0, 1.0)) / textureSize);

  // // Determine how far along the (x,y) axis the sample is
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
    color = vec3(noise(coords / 16.0));
  } else {
    color = filterSample(uTexture, vUvs);
  }

  gl_FragColor = vec4(color, 1.0);
}