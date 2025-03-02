uniform bool uAmbient;
uniform float uAmbientIntensity;

uniform bool uHemisphere;
uniform float uHemisphereIntensity;

uniform bool uLambert;
uniform float uLambertIntensity;

uniform bool uSpecPhong;
uniform float uSpecPhongIntensity;

uniform samplerCube uSpecMap;
uniform bool uSpecMapEnabled;
uniform float uSpecMapIntensity;

uniform bool uFresnel;
uniform float uFresnelFalloff;

varying vec3 vNormal;
varying vec3 vPosition;

#pragma glslify: remap = require('../../shared/remap.glsl');
#pragma glslify: linearTosRGB = require('../../shared/linear_to_srgb.glsl');

void main() {
  vec3 baseColor = vec3(0.0);
  vec3 lighting = vec3(0.0);

  // Normalize to make sure interpolated normals are of length = 1
  vec3 normal = normalize(vNormal); // v -- frag -- v
  vec3 viewDirection = normalize(cameraPosition - vPosition);

  // Ambient
  if (uAmbient == true) {
    vec3 ambient = vec3(0.5);
    lighting = ambient * uAmbientIntensity;
  }

  // Hemisphere
  if (uHemisphere == true) {
    vec3 skyColor = vec3(0.0, 0.3, 0.6);
    vec3 groundColor = vec3(0.6, 0.3, 0.1);

    float hemiMix = remap(normal.y, -1.0, 1.0, 0.0, 1.0);
    vec3 hemiColor = mix(groundColor, skyColor, hemiMix);

    lighting = lighting + hemiColor * uHemisphereIntensity;
  }

  // Lambertian (directional light)
  vec3 specular = vec3(0.0);
  if (uLambert == true) {
    vec3 lambertDirection = normalize(vec3(1.0, 1.0, 1.0));
    vec3 lambertColor = vec3(1.0, 1.0, 0.9);
    float lambertDot = max(0.0, dot(lambertDirection, normal));

    vec3 lambert = lambertColor * lambertDot;

    lighting = lighting + lambert * uLambertIntensity;

    // Phong (specular highlight)
    if (uSpecPhong == true) {
      vec3 r = normalize(reflect(-lambertDirection, normal));
      float specularDot = max(0.0, dot(r, viewDirection));
      float specularValue = pow(specularDot, uSpecPhongIntensity);
      specular = vec3(specularValue);
    }

    // IBL (specular reflection)
    if (uSpecMapEnabled == true) {
      vec3 iblCoord = normalize(reflect(-viewDirection, normal));
      vec3 iblSample = textureCube(uSpecMap, iblCoord).rgb;
      specular += iblSample * uSpecMapIntensity;
    }

    // Fresnel (specular at angles, subdued from front)
    if (uFresnel == true) {
      float fresnel = 1.0 - max(0.0, dot(viewDirection, normal));
      fresnel = pow(fresnel, uFresnelFalloff); // increase the fall-off
      specular *= fresnel;
    }
  }

  vec3 color = baseColor * lighting + specular;

  // Convert to SRGB color space
  color = linearTosRGB(color);
  // color = pow(color, vec3(1.0 / 2.2)); // gamma correction approximation

  gl_FragColor = vec4(color, 1.0);
}