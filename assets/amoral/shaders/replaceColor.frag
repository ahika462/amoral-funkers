#pragma header

uniform vec4 colorToReplace;
uniform vec4 newColor;

const float amplitude = 0.2;

void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

    if (color.r < colorToReplace.r + amplitude && color.g < colorToReplace.g + amplitude && color.b < colorToReplace.b + amplitude
    && color.r > colorToReplace.r - amplitude && color.g > colorToReplace.g - amplitude && color.b > colorToReplace.b - amplitude)
        color = newColor;

    gl_FragColor = color;
}