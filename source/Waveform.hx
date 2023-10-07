import flixel.FlxG;
import openfl.geom.Rectangle;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import openfl.media.Sound;
import openfl.utils.Assets;
import flixel.system.FlxAssets.FlxSoundAsset;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import flixel.FlxSprite;

class Waveform extends FlxSprite {
    var buffer:AudioBuffer;
    var data:Bytes;

    public var length(default, null):Int;

    public function new(x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0, sound:FlxSoundAsset) {
        super(x, y);

        if (sound is String)
            sound = Assets.getSound(sound);
        else if (sound is Class)
            sound = Type.createInstance(sound, []);

        @:privateAccess {
            var bufferSource:Sound = cast sound;
            buffer = bufferSource.__buffer;
        }
        data = buffer.data.toBytes();

        var trackDurationSeconds = (data.length / (buffer.bitsPerSample / 8) / buffer.channels) / buffer.sampleRate;
		var pixelsPerCollumn:Int = Math.floor(1280 / (trackDurationSeconds / 1000));
		var totalSamples = (data.length / (buffer.bitsPerSample / 8) / buffer.channels);

        length = Math.round(totalSamples / pixelsPerCollumn);
        Debug.logTrace(length + " - calculated height");

        makeGraphic(width, length, FlxColor.TRANSPARENT);
    }

    public function drawWaveform() {
        var index:Int = 0, drawIndex:Int = 0;
        var totalSamples:Int = Math.round(data.length / (buffer.bitsPerSample / 8) / buffer.channels);
        var min:Float = 0, max:Float = 0;

        for (i in 0...totalSamples) {
            var byte:Int = data.getUInt16(i);
            if (byte > 32767.5)
                byte -= 65535;

            var sample:Float = (byte / 65535);
            if (sample > 0) {
                if (sample > max)
                    max = sample;
            }
            else if (sample < 0) {
                if (sample < min)
                    min = sample;
            }

            trace("sample " + index);

            var pixelsMin:Float = Math.abs(min * 300), pixelsMax:Float = max * 300;

			pixels.fillRect(new Rectangle(drawIndex, 0, 1, 720), 0xFF000000);
			pixels.fillRect(new Rectangle(drawIndex, (FlxG.height / 2) - pixelsMin, 1, pixelsMin + pixelsMax), FlxColor.GRAY);
			pixels.fillRect(new Rectangle(drawIndex, (FlxG.height / 2) - pixelsMin, 1, -(pixelsMin + pixelsMax)), FlxColor.GRAY);
			drawIndex += 1;

            min = max = 0;
        }
    }
}