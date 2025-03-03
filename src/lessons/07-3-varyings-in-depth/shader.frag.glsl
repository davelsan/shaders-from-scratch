
uniform vec3 uModelColor;
uniform samplerCube uSpecMap;

varying vec4 vColor;
varying vec3 vNormal;
varying vec3 vPosition;

const vec3 black = vec3(0.0, 0.0, 0.0);
const vec3 blue = vec3(0.0, 0.0, 1.0);
const vec3 red = vec3(1.0, 0.0, 0.0);
const vec3 yellow = vec3(1.0, 1.0, 0.0);

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

void main() {
  vec3 modelColor = vColor.rgb;

  float lineDivider = smoothstep(0.0, 0.003, abs(vPosition.y));
  modelColor = mix(black, modelColor, lineDivider);

  // Fragment line: interpolated position.x (t from vPosition.x)
  if (vPosition.y > 0.0) { // vPosition.y = [-0.5, 0.5]

    float t = remap(vPosition.x, -0.5, 0.5, 0.0, 1.0); // (fragment) position.x to [0.0, 1.0]
    t = pow(t, 2.0);

    modelColor = mix(red, blue, t); // this colors the top half
    // modelColor = vec3(0.0);

    float lineFragT = smoothstep(0.0, 0.003, abs(vPosition.y - mix(0.0, 0.5, t)));
    modelColor = mix(yellow, modelColor, lineFragT);
  } else {
    // modelColor = mix(red, blue, vColor.w); // this is equivalent to vColor.rgb
    // modelColor = vec3(0.0);

    // Vertex line: non-interpolated position.x (t from localSpacePosition.x)
    float lineVertexT = smoothstep(0.0, 0.003, abs(vPosition.y - mix(-0.5, 0.0, vColor.w))); // mix(x0, x1, v_position.x)
    modelColor = mix(yellow, modelColor, lineVertexT);
  }



  // PREV LESSON------------------------------------------------------------

  vec3 lighting = vec3(0.0);

  vec3 normal = normalize(vNormal);
  vec3 viewDir = normalize(cameraPosition - vPosition);

  // Ambient
  vec3 ambient = vec3(1.0);

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
  float phongValue = max(0.0, dot(viewDir, r));
  phongValue = pow(phongValue, 32.0);

  specular += phongValue * 0.15;

  // IBL Specular
  vec3 iblCoord = normalize(reflect(-viewDir, normal));
  vec3 iblSample = textureCube(uSpecMap, iblCoord).xyz;

  specular += iblSample * 0.5;

  // Fresnel
  float fresnel = 1.0 - max(0.0, dot(viewDir, normal));
  fresnel = pow(fresnel, 2.0);

  specular *= fresnel;

  // Combine lighting
  lighting = hemi * 0.1 + diffuse;

  vec3 colour = modelColor * lighting + specular;

  gl_FragColor = vec4(pow(colour, vec3(1.0 / 2.2)), 1.0);
}