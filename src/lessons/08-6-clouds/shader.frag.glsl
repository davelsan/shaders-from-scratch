uniform vec2 uResolution;
uniform float uTime;

varying vec2 vUvs;

vec3 black = vec3(0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);
vec3 gray = vec3(0.5);
vec3 green = vec3(0.0, 1.0, 0.0);
vec3 purple = vec3(1.0, 0.25, 1.0);
vec3 red = vec3(1.0, 0.0, 0.0);
vec3 yellow = vec3(1.0, 1.0, 0.0);

#pragma glslify: easeOutBounce = require('../../shared/ease_out_bounce.glsl');
#pragma glslify: easeOutExp = require('../../shared/ease_out_exp.glsl');
#pragma glslify: inverseLerp = require('../../shared/inverse_lerp.glsl')
#pragma glslify: opSubtraction = require('../../shared/sdf_subtraction.glsl');
#pragma glslify: remap = require('../../shared/remap.glsl');
#pragma glslify: rotate2d = require('../../shared/rotate2d.glsl');
#pragma glslify: sdfCircle = require('../../shared/sdf_circle.glsl');
#pragma glslify: sdfUnion = require('../../shared/sdf_union.glsl');

vec3 backgroundGradient(float dayLength, float dayTime) {
  vec3 morning = mix(
    vec3(0.44, 0.64, 0.84),
    vec3(0.34, 0.51, 0.94),
    smoothstep(0.0, 1.0, pow(vUvs.x * vUvs.y, 0.5))
  );

  vec3 midday = mix(
    vec3(0.42, 0.58, 0.75),
    vec3(0.36, 0.46, 0.82),
    smoothstep(0.0, 1.0, pow(vUvs.x * vUvs.y, 0.5))
  );

  vec3 evening = mix(
    vec3(0.82, 0.51, 0.25),
    vec3(0.88, 0.71, 0.39),
    smoothstep(0.0, 1.0, pow(vUvs.x * vUvs.y, 0.5))
  );

  vec3 night = mix(
    vec3(0.07, 0.01, 0.19),
    vec3(0.19, 0.2, 0.29),
    smoothstep(0.0, 1.0, pow(vUvs.x * vUvs.y, 0.5))
  );

  vec3 color;
  if (dayTime < dayLength * 0.25) {
    color = mix(morning, midday, smoothstep(0.0, dayLength * 0.25, dayTime));
  } else if (dayTime < dayLength * 0.5) {
    color = mix(midday, evening, smoothstep(dayLength * 0.25, dayLength * 0.5, dayTime));
  } else if (dayTime < dayLength * 0.75) {
    color = mix(evening, night, smoothstep(dayLength * 0.5, dayLength * 0.75, dayTime));
  } else {
    color = mix(night, morning, smoothstep(dayLength * 0.75, dayLength, dayTime));
  }

  return color;
}

float hash(vec2 v) {
  float t = dot(v, vec2(36.5323, 73.945));
  return sin(t);
}

float saturate(float t) {
  return clamp(t, 0.0, 1.0);
}

float sdfCloud(vec2 pixelCoords) {
  float puffCenter = sdfCircle(pixelCoords, 100.0);
  float puffLeft = sdfCircle(pixelCoords - vec2(120.0, -10.0), 75.0);
  float puffRight = sdfCircle(pixelCoords + vec2(120.0, 10.0), 75.0);

  return sdfUnion(puffCenter, sdfUnion(puffLeft, puffRight));
}

float sdfMoon(float dayTime, float dayLength, vec2 pixelCoords) {
  vec2 moonOffset = uResolution * 0.8;

  // Sun transition. Use saturate so after 1s is clamped to 1.0
  if (dayTime <= dayLength * 0.9) { // moonrise
    float t = saturate(inverseLerp(dayTime, dayLength * 0.5, dayLength * 0.5 + 1.5));
    moonOffset += mix( vec2(0.0, 400.0), vec2(0.0), easeOutBounce(t));
  } else { // moonset
    float t = saturate(inverseLerp(dayTime, dayLength * 0.9, dayLength * 0.95));
    moonOffset += mix( vec2(0.0), vec2(0.0, 400.0), t);
  }

  vec2 moonPos = pixelCoords - moonOffset;
  moonPos = moonPos * rotate2d(3.14159 * 0.2);

  float d = opSubtraction(
    sdfCircle(moonPos + vec2(50.0, 0.0), 80.0),
    sdfCircle(moonPos, 80.0)
  );

  return d;
}

float sdfSun(float dayTime, float dayLength, vec2 pixelCoords) {
  vec2 sunOffset = vec2(200.0, uResolution.y * 0.8);

  // Sun transition. Use saturate so after 1s is clamped to 1.0
  if (dayTime <= dayLength * 0.5) { // sunrise
    float t = saturate(inverseLerp(dayTime, 0.0, 1.0));
    sunOffset += mix( vec2(0.0, 400.0), vec2(0.0), easeOutExp(t, 5.0));
  } else { // sunset
    float t = saturate(inverseLerp(dayTime, dayLength * 0.5, dayLength * 0.5 + 1.0));
    sunOffset += mix( vec2(0.0), vec2(0.0, 400.0), t);
  }

  vec2 sunPos = pixelCoords - sunOffset;
  float sun = sdfCircle(sunPos, 100.0);

  return sun;
}

float sdfStar5(in vec2 p, in float r, in float rf) {
    const vec2 k1 = vec2(0.809016994375, -0.587785252292);
    const vec2 k2 = vec2(-k1.x,k1.y);
    p.x = abs(p.x);
    p -= 2.0*max(dot(k1,p),0.0)*k1;
    p -= 2.0*max(dot(k2,p),0.0)*k2;
    p.x = abs(p.x);
    p.y -= r;
    vec2 ba = rf*vec2(-k1.y,k1.x) - vec2(0,1);
    float h = clamp( dot(p,ba)/dot(ba,ba), 0.0, r );
    return length(p-ba*h) * sign(p.y*ba.x-p.x*ba.y);
}



const float NUM_CLOUDS = 8.0;
const float NUM_STARS = 24.0;

void main() {
  // Compute pixel coordinates
  // - [0.0, resolution]
  vec2 pixelCoords = vUvs * uResolution;

  float dayLength = 20.0; // 20 seconds
  float dayTime = mod(uTime + 8.0, dayLength);

  // Base color
  vec3 color = backgroundGradient(dayLength, dayTime);

  // Sun
  if (dayTime < dayLength * 0.75) {
    float sun = sdfSun(dayTime, dayLength, pixelCoords);
    color = mix(vec3(0.84, 0.62, 0.26), color, smoothstep(0.0, 2.0, sun));

    // Sun glow (fog equation)
    float s = max(0.001, sun);
    float p = saturate(exp(-0.001 * s * s));
    color += 0.5 * mix(vec3(0.0), vec3(0.9, 0.85, 0.47), p);
  }

  // Moon
  if (dayTime > dayLength * 0.5) {
    float moonShadow = sdfMoon(dayTime, dayLength, pixelCoords + vec2(15.0));
    color = mix(vec3(0.0), color, smoothstep(-40.0, 10.0, moonShadow)); // blur shadow

    float moon = sdfMoon(dayTime, dayLength, pixelCoords);
    color = mix(vec3(1.0), color, smoothstep(0.0, 2.0, moon));

    float moonGlow = sdfMoon(dayTime, dayLength, pixelCoords);
    color += 0.1 * mix(vec3(1.0), vec3(0.0), smoothstep(-10.0, 15.0, moonGlow));
  }

   // Stars
   for (float i = 0.0; i < NUM_STARS; i += 1.0) {
    float hashSample = hash(vec2(i * 13.0)) * 0.5 + 0.5; // randomize size

    float t = saturate(
      inverseLerp(
        dayTime + hashSample * 0.5, // randomize for each star
        dayLength * 0.5,
        dayLength * 0.5 + 1.5
      )
    );

    float fade = 0.0;
    if (dayTime > dayLength * 0.9) {
      fade = saturate(
        inverseLerp(
          dayTime - hashSample * 0.25,
          dayLength * 0.9, // lower bound
          dayLength * 0.95 // upper bound
        )
      );
    }

    float size = mix(2.0, 1.0, hash(vec2(i, i + 1.0)));
    vec2 offset = vec2(i * 85.0, 0.0) + 150.0 * hash(vec2(i)); // random spacing
    offset += mix(vec2(0.0, 600.0), vec2(0.0), easeOutBounce(t));

    float rot = mix(-3.14159, 3.14159, hashSample);

    vec2 pos = pixelCoords - offset;
    pos.x = mod(pos.x, uResolution.x);
    pos = pos - uResolution * vec2(0.5, 0.75); // upper 2/4 of the screen
    pos = rotate2d(rot) * pos;
    pos *= size;

    float star = sdfStar5(pos, 10.0, 2.0);
    vec3 starColor = mix(vec3(1.0), color, smoothstep(0.0, 2.0, star));
    starColor += mix(0.2, 0.0, pow(smoothstep(-5.0, 15.0, star), 0.25));

    color = mix(starColor, color, fade);
  }

  for (float i = 0.0; i < NUM_CLOUDS; i += 1.0) {
    float size = mix(2.0, 1.0, i / NUM_CLOUDS + 0.1 * hash(vec2(i))); // [half-size, full-size]; 2.0 is half-size due to reverse scale behavior in SDFs
    float speed = size * 0.25;

    vec2 offset = vec2(i * 200.0, 200.0 * hash(vec2(i))); // [0.0, 800.0]
    vec2 pos = pixelCoords - offset; // [-800.0, resolution - 800.0];

    pos.x -= uTime * 100.0 * speed; // Animate clouds horizontally
    pos = mod(pos, uResolution); // repeat every screen size
    pos -= uResolution * 0.5; // center coordinates, so the SDFs work as intended

    float cloudShadow = sdfCloud(pos * size + vec2(25.0)) - 40.0;
    float cloud = sdfCloud(pos * size);

    color = mix(color, vec3(0.0),  smoothstep(0.0, -100.0, cloudShadow) * 0.5);
    color = mix(vec3(1.0), color, smoothstep(0.0, 1.0, cloud));
  }


  gl_FragColor = vec4(color, 1.0);
}