#pragma header

uniform float alphaShit;

void main() {
    gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);

    if (gl_FragColor.a >= alphaShit)
        gl_FragColor -= alphaShit;
}