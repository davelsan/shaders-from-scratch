uniform float uAmbientIntensity;
uniform float uHemisphereIntensity;
uniform float uLambertIntensity;

varying vec3 vNormal;
varying vec3 vPosition;

#pragma glslify: remap = require('../../shared/remap.glsl');
#pragma glslify: linearTosRGB = require('../../shared/linear_to_srgb.glsl');

void main() {
  vec3 modelColor = vec3(0.5);
  vec3 lighting = vec3(0.0);

  // Normalize to make sure interpolated normals are of length = 1
  vec3 normal = normalize(vNormal); // v -- frag -- v
  vec3 viewDirection = normalize(cameraPosition - vPosition);

  // Ambient
  vec3 ambient = vec3(1.0);

  // Hemisphere
  vec3 skyColor = vec3(0.0, 0.3, 0.6);
  vec3 groundColor = vec3(0.6, 0.3, 0.1);
  float hemiMix = remap(normal.y, -1.0, 1.0, 0.0, 1.0);
  vec3 hemiColor = mix(groundColor, skyColor, hemiMix);

  // Lambertian (directional light)
  vec3 lightDirection = normalize(vec3(1.0, 1.0, 1.0));
  vec3 lightColor = vec3(1.0, 1.0, 0.9); // sun
  float lightDotProduct = max(0.0, dot(lightDirection, normal));

  // Toon Shading
  // lightDotProduct = step(0.5, lightDotProduct); // hard edges
  // lightDotProduct *= step(0.5, lightDotProduct); // soft edges
  // lightDotProduct *= smoothstep(0.5, 0.505, lightDotProduct); // softer edges
  // lightDotProduct *= min(1.0, max(0.0, (step(0.3, lightDotProduct) - 0.5)) + step(0.6, lightDotProduct)); // three-tone
  // lightDotProduct *= min(1.0, max(0.0, (smoothstep(0.3, 0.31, lightDotProduct) - 0.5)) + smoothstep(0.6, 0.61, lightDotProduct)); // three-tone softer
  lightDotProduct = mix(0.5, 1.0, step(0.65, lightDotProduct)) * step(0.5, lightDotProduct); // three-tone solution

  vec3 lambert = lightColor * lightDotProduct;

  // Phong Specular (highlight)
  vec3 r = normalize(reflect(-lightDirection, normal));
  float phongDot = max(0.0, dot(r, viewDirection));
  float phongValue = pow(phongDot, 128.0);

  // Fresnel (rim lighting)
  float fresnel = 1.0 - max(0.0, dot(viewDirection, normal));
  fresnel = pow(fresnel, 2.0);
  fresnel = step(0.6, fresnel);

  lighting = ambient * uAmbientIntensity;
  lighting += hemiColor * (uHemisphereIntensity + fresnel);
  lighting += lambert * uLambertIntensity;

  vec3 specular = vec3(0.0);
  specular += vec3(phongValue);
  specular = smoothstep(0.5, 0.51, specular); // define specular edges

  vec3 color = modelColor * lighting + specular;
  color = linearTosRGB(color);

  gl_FragColor = vec4(color, 1.0);
}