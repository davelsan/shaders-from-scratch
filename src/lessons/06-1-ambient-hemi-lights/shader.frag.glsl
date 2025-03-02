uniform bool uAmbient;
uniform float uAmbientIntensity;

uniform bool uHemisphere;
uniform float uHemisphereIntensity;

uniform bool uLambert;
uniform float uLambertIntensity;

varying vec3 vNormal;

#pragma glslify: remap = require('../../shared/remap.glsl');

void main() {
  vec3 baseColor = vec3(0.5);
  vec3 lighting = vec3(0.0);

  // Normalize to make sure interpolated normals are of length = 1
  vec3 normal = normalize(vNormal);

  // Ambient
    vec3 ambient = vec3(0.5);

  // Hemisphere
  vec3 skyColor = vec3(0.0, 0.3, 0.6);
  vec3 groundColor = vec3(0.6, 0.3, 0.1);

  float hemiMix = remap(normal.y, -1.0, 1.0, 0.0, 1.0);
  vec3 hemiColor = mix(groundColor, skyColor, hemiMix);

  // Lambertian (directional light)
  vec3 lambertDirection = normalize(vec3(1.0, 1.0, 1.0));
  vec3 lambertColor = vec3(1.0, 1.0, 0.9);
  float lambertDot = max(0.0, dot(lambertDirection, normal));
  vec3 lambert = lambertColor * lambertDot;

  if (uAmbient == true) {
    lighting = ambient * uAmbientIntensity;
  }

  if (uHemisphere == true) {
    lighting = lighting + hemiColor * uHemisphereIntensity;
  }

  if (uLambert == true) {
    lighting = lighting + lambert * uLambertIntensity;
  }

  vec3 color = baseColor * lighting;

  gl_FragColor = vec4(color, 1.0);
}