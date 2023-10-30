import flixel.addons.display.FlxRuntimeShader;
import flixel.FlxBasic;

class MissEffect extends FlxBasic {
    public var shader:FlxRuntimeShader;

    public var percent(get, set):Float;

    public function new() {
        super();
        shader = new FlxRuntimeShader(Paths.getEmbedText("shaders/miss.frag"));
        percent = 0;
    }

    public function get_percent():Float {
        return shader.getFloat("percent");
    }

    public function set_percent(value:Float):Float {
        shader.setFloat("percent", value);
        return value;
    }

    override function update(elapsed:Float) {
        if (percent > 0)
            percent -= elapsed;
        if (percent < 0)
            percent = 0;

        super.update(elapsed);
    }
}