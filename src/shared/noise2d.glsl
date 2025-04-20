#pragma glslify: hash2d = require('./hash2d.glsl')

float noise2d( in vec2 p )
{
  vec2 i = floor( p );
  vec2 f = fract( p );

  vec2 u = f*f*(3.0-2.0*f);

  float s1 = hash2d( i + vec2(0.0,0.0) );
  float s2 = hash2d( i + vec2(1.0,0.0) );
  float s3 = hash2d( i + vec2(0.0,1.0) );
  float s4 = hash2d( i + vec2(1.0,1.0) );

  float px1 = mix( s1, s2, u.x);
  float px2 = mix( s3, s4, u.x);

  return mix( px1, px2, u.y);
}

#pragma glslify: export(noise2d)