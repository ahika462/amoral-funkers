import openfl.display.BitmapData;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

using flixel.util.FlxSpriteUtil;

class TimeSpectrum extends FlxSprite {
    @:noPrivateAccess var elapsed:Float = 0;
    @:noPrivateAccess var previous:Int = 0;

    public var maxHeight:Float = 0;

    var barShit:FlxSprite;

    public var barWidth:Float = 15;
    public var barSpacing:Float = 20;

    public function new() {
        super();

        makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);

        maxHeight = FlxG.height / 6;
        barShit = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
    }

    override function update(elapsed:Float) {
        this.elapsed += elapsed;
        if (FlxG.sound.music != null && FlxG.sound.music.playing) {
            if (previous != Math.floor(this.elapsed * 2048)) {
                updateSamples();
                updateWaveform(elapsed);
            }
        }
        previous = Math.floor(this.elapsed * 2048);

        super.update(elapsed);
    }

    public var spectrum:Array<Float> = [];
    public var lerpSpectrum:Array<Float> = [];
    public function updateSamples() {
        @:privateAccess {
            var index:Int = Math.floor(Conductor.songPosition * (FlxG.sound.music._sound.__buffer.sampleRate / 1000));

            spectrum = [];

            for (i in index...index + 2048) {
                if (i >= 0) {
                    var byte:Int = FlxG.sound.music._sound.__buffer.data.buffer.getUInt16(i * FlxG.sound.music._sound.__buffer.channels * 2);

                    if (byte > 65535 / 2)
                        byte -= 65535;

                    spectrum.push(Math.abs(byte / 65535));
                }
            }
        }
    }

    public function updateWaveform(elapsed:Float) {
        barShit.scale.x = (Conductor.songPosition / FlxG.sound.music.length) * FlxG.width;
        barShit.updateHitbox();

        loadGraphic(CoolUtil.loadByGPU(new BitmapData(FlxG.width, FlxG.height, FlxColor.TRANSPARENT)));
        // makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);

        for (i in 0...Std.int(FlxG.width / barSpacing)) {
            var spec:Float = spectrum[Math.floor(i * barSpacing)];
            lerpSpectrum[i] = FlxMath.lerp(spec, lerpSpectrum[i], 0.8);

            var barHeight:Float = lerpSpectrum[i] * 1000;
            if (barHeight > maxHeight)
                barHeight = maxHeight;

            var emptyColor:FlxColor = FlxColor.BLACK;
            emptyColor.alphaFloat = 0.35;

            var fillColor:FlxColor = FlxColor.WHITE;
            fillColor.alphaFloat = 0.75;

            var isThis:Bool = (barShit.width > barSpacing * i) && (barShit.width < barSpacing * i + barWidth);
            if (isThis) {
                this.drawRect(barSpacing * i + (barShit.width - barSpacing * i), 0, (barSpacing * i + barWidth) - barShit.width, barHeight, emptyColor);
                this.drawRect(barSpacing * i, 0, barWidth - ((barSpacing * i + barWidth) - barShit.width), barHeight, fillColor);
            } else
                this.drawRect(barSpacing * i, 0, barWidth, barHeight, (barShit.width < barSpacing * i) ? emptyColor : fillColor);
        }
    }
}