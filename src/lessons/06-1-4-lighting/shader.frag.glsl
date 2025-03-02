uniform bool uAmbient;
uniform float uAmbientIntensity;

uniform bool uFresnel;
uniform float uFresnelFalloff;

uniform bool uHemisphere;
uniform float uHemisphereIntensity;

uniform bool uLambert;
uniform float uLambertIntensity;

uniform vec3 uModelColor;

uniform bool uSpecEnabled;
uniform int uSpecType;
uniform float uSpecIntensity;

uniform samplerCube uSpecMap;
uniform bool uSpecMapEnabled;
uniform float uSpecMapIntensity;

varying vec3 vNormal;
varying vec3 vPosition;

#pragma glslify: remap = require('../../shared/remap.glsl');
#pragma glslify: linearTosRGB = require('../../shared/linear_to_srgb.glsl');

void main() {
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

    // Specular (highlight)
    if (uSpecEnabled == true) {
      if (uSpecType == 0) {
        // Phong
        vec3 r = normalize(reflect(-lambertDirection, normal));
        float specularDot = max(0.0, dot(r, viewDirection));
        float specularValue = pow(specularDot, uSpecIntensity);
        specular = vec3(specularValue);
      } else if (uSpecType == 1) {
        // Blinn–Phong
        vec3 halfDir = normalize(lambertDirection + viewDirection);
        float angle = max(0.0, dot(halfDir, normal));
        specular = vec3(pow(angle, uSpecIntensity));
      }
    }


    // IBL specular (reflection)
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

  vec3 color = uModelColor * lighting + specular;

  // Convert to SRGB color space
  color = linearTosRGB(color);
  // color = pow(color, vec3(1.0 / 2.2)); // gamma correction approximation

  gl_FragColor = vec4(color, 1.0);
}