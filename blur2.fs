const float blurSize = 0.01;

vec4 effect(vec4 color, Image texture, vec2 vTexCoord, vec2 pixel_coords)
{
    vec4 sum = vec4(0.0);
    sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y - 4.0*blurSize)) * 0.05;
    sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y - 3.0*blurSize)) * 0.09;
    sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y - 2.0*blurSize)) * 0.12;
    sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y- blurSize)) * 0.15;
    sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y)) * 0.16;
    sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y + blurSize)) * 0.15;
    sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y + 2.0*blurSize)) * 0.12;
    sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y + 3.0*blurSize)) * 0.09;
    sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y + 4.0*blurSize)) * 0.05;

    sum += texture2D(texture, vec2(vTexCoord.x - 4.0*blurSize, vTexCoord.y)) * 0.05;
    sum += texture2D(texture, vec2(vTexCoord.x - 3.0*blurSize, vTexCoord.y)) * 0.09;
    sum += texture2D(texture, vec2(vTexCoord.x - 2.0*blurSize, vTexCoord.y)) * 0.12;
    sum += texture2D(texture, vec2(vTexCoord.x - blurSize, vTexCoord.y)) * 0.15;
    sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y)) * 0.16;
    sum += texture2D(texture, vec2(vTexCoord.x + blurSize, vTexCoord.y)) * 0.15;
    sum += texture2D(texture, vec2(vTexCoord.x + 2.0*blurSize, vTexCoord.y)) * 0.12;
    sum += texture2D(texture, vec2(vTexCoord.x + 3.0*blurSize, vTexCoord.y)) * 0.09;
    sum += texture2D(texture, vec2(vTexCoord.x + 4.0*blurSize, vTexCoord.y)) * 0.05;

    return sum;
}