package shaderslmfao;

import flixel.addons.display.FlxRuntimeShader;

class ReplaceColor extends FlxRuntimeShader {
    public function new() {
        super(Paths.getAmoralText("shaders/replaceColor.frag"));
    }
}