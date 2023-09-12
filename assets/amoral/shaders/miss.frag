#pragma header

uniform float percent;

vec4 funnyPixels(vec2 coord) {
    return vec4(
        fract(sin(dot(vec2(1), vec2(12.9898, 78.233))) * 43758.5453 * coord.x * coord.y),
        0, // fract(sin(dot(vec2(1), vec2(12.9898, 78.233))) * 43758.5453),
        0, // fract(sin(dot(vec2(1), vec2(12.9898, 78.233))) * 43758.5453),
        fract(sin(dot(vec2(1), vec2(12.9898, 78.233))) * 43758.5453 * coord.x * coord.y)
    );
}

void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

    gl_FragColor = mix(color, funnyPixels(openfl_TextureCoordv), percent);
}