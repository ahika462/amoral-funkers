#pragma header

uniform float percent;

vec2 center = vec2(0.5);

vec4 vignette() {
    float OuterVig = 1;
	float InnerVig = 0.05;
    float dist  = distance(center, openfl_TextureCoordv) * 1.414213;
    float vig = clamp((OuterVig - dist) / (OuterVig - InnerVig), 0, 1);

    vec4 color = vec4(1, 0, 0, 1);
    color *= 1 - vig;

    return color;
}

vec4 funnyPixels() {
    vec2 blocks = openfl_TextureSize / 100;
	vec4 color = flixel_texture2D(bitmap, floor(openfl_TextureCoordv * blocks) / blocks);

    return color;
}

void main() {
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	
    vec4 funny = mix(funnyPixels(), vignette(), 1);

	gl_FragColor = mix(color, funny, percent);
}