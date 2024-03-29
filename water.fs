// A simple water shader. (c) Ajarus, viiDatetor@ajarus.com.
//
// Attribution-ShareAliiDatee CC License.

const float PI = 3.1415926535897932;

// play with these parameters to custimize the effect
// ==================================================
uniform float iTime;
vec2 hash2(vec2 p ) {
   return fract(sin(vec2(dot(p, vec2(123.4, 748.6)), dot(p, vec2(547.3, 659.3))))*5232.85324);   
}
float hash(vec2 p) {
  return fract(sin(dot(p, vec2(43.232, 75.876)))*4526.3257);   
}

//Based off of iq's described here: https://iquilezles.org/articles/voronoilines
float voronoi(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    float md = 5.0;
    vec2 m = vec2(0.0);
    for (int i = -1;i<=1;i++) {
        for (int j = -1;j<=1;j++) {
            vec2 g = vec2(i, j);
            vec2 o = hash2(n+g);
            o = 0.5+0.5*sin(iTime+5.038*o);
            vec2 r = g + o - f;
            float d = dot(r, r);
            if (d<md) {
              md = d;
              m = n+g+o;
            }
        }
    }
    return md;
}

float ov(vec2 p) {
    float v = 0.0;
    float a = 0.4;
    for (int i = 0;i<3;i++) {
        v+= voronoi(p)*a;
        p*=2.0;
        a*=0.5;
    }
    return v;
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec2 uv = screen_coords.xy / love_ScreenSize.xy;
	// vec2 uv = texture_coords.xy;
    vec4 a = vec4(0.2, 0.4, 1.0, 1.0);
    vec4 b = vec4(0.85, 0.9, 1.0, 1.0);
	return vec4(mix(a, b, smoothstep(0.0, 0.5, ov(uv*5.0))));
    
}