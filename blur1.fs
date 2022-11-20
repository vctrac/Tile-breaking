uniform float time;
uniform float Width;
uniform float Height;
float WblurSize = 10.0/Width;
float HblurSize = 10.0/Height;
const float intensity = 1.5;

vec4 effect( vec4 color, Image texture, vec2 tc, vec2 screen_coords)
{
   vec4 sum = vec4(0.0);
   // blur in x (horizontal)
   // take nine samples, with the distance WblurSize between them
   sum += texture2D(texture, vec2(tc.x - 4.0*WblurSize, tc.y)) * 0.05;
   sum += texture2D(texture, vec2(tc.x - 3.0*WblurSize, tc.y)) * 0.09;
   sum += texture2D(texture, vec2(tc.x - 2.0*WblurSize, tc.y)) * 0.12;
   sum += texture2D(texture, vec2(tc.x - WblurSize, tc.y)) * 0.15;
   sum += texture2D(texture, vec2(tc.x, tc.y)) * 0.16;
   sum += texture2D(texture, vec2(tc.x + WblurSize, tc.y)) * 0.15;
   sum += texture2D(texture, vec2(tc.x + 2.0*WblurSize, tc.y)) * 0.12;
   sum += texture2D(texture, vec2(tc.x + 3.0*WblurSize, tc.y)) * 0.09;
   sum += texture2D(texture, vec2(tc.x + 4.0*WblurSize, tc.y)) * 0.05;
	
	// blur in y (vertical)
   // take nine samples, with the distance blurSize between them
   sum += texture2D(texture, vec2(tc.x, tc.y - 4.0*HblurSize)) * 0.05;
   sum += texture2D(texture, vec2(tc.x, tc.y - 3.0*HblurSize)) * 0.09;
   sum += texture2D(texture, vec2(tc.x, tc.y - 2.0*HblurSize)) * 0.12;
   sum += texture2D(texture, vec2(tc.x, tc.y- HblurSize)) * 0.15;
   sum += texture2D(texture, vec2(tc.x, tc.y)) * 0.16;
   sum += texture2D(texture, vec2(tc.x, tc.y + HblurSize)) * 0.15;
   sum += texture2D(texture, vec2(tc.x, tc.y + 2.0*HblurSize)) * 0.12;
   sum += texture2D(texture, vec2(tc.x, tc.y + 3.0*HblurSize)) * 0.09;
   sum += texture2D(texture, vec2(tc.x, tc.y + 4.0*HblurSize)) * 0.05;

   //increase blur with intensity!
   return sum*time + texture2D(texture, tc); 
}