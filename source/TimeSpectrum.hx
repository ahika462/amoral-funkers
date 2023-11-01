import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class TimeSpectrum extends FlxSpriteGroup {
    @:noPrivateAccess var elapsed:Float = 0;
    @:noPrivateAccess var previous:Int = 0;

    public var numBars(get, never):Int;
    public var maxHeight:Float = 0;

    var barShit:FlxSprite;

    public function new() {
        super();

        maxHeight = FlxG.height / 6;

        barShit = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        this.elapsed += elapsed;
        if (Conductor.followSound != null && Conductor.followSound.playing) {
            if (previous != Math.floor(this.elapsed * 2048)) {
                updateSamples();
                updateWaveform(elapsed);
            }
        }
        previous = Math.floor(this.elapsed * 2048);
    }

    public var spectrum:Array<Float> = [];
    public var lerpSpectrum:Array<Float> = [];
    public function updateSamples() {
        @:privateAccess {
            var index:Int = Math.floor(Conductor.followSound.time * (Conductor.followSound._sound.__buffer.sampleRate / 1000));

            spectrum = [];

            for (i in index...index + numBars) {
                if (i >= 0) {
                    var byte:Int = Conductor.followSound._sound.__buffer.data.buffer.getUInt16(i * Conductor.followSound._sound.__buffer.channels * 2);

                    if (byte > 65535 / 2)
                        byte -= 65535;

                    spectrum.push(Math.abs(byte / 65535));
                }
            }
        }
    }

    public function updateWaveform(elapsed:Float) {
        barShit.scale.x = (Conductor.songPosition / Conductor.followSound.length) * FlxG.width;
        barShit.updateHitbox();

        clear();

        for (i in 0...Std.int(FlxG.width / 19)) {
            var spec:Float = spectrum[Math.floor((i * 19))];

            // if (spec > lerpSpectrum[i])
                lerpSpectrum[i] = FlxMath.lerp(spec, lerpSpectrum[i], 0.8);
            // else
                // lerpSpectrum[i] = FlxMath.lerp(spec, lerpSpectrum[i], 1);
            
            var barHeight:Float = lerpSpectrum[i] * 1000;
            /*if (barHeight > maxHeight)
                barHeight = maxHeight;*/

            var emptyColor:FlxColor = FlxColor.BLACK;
            emptyColor.alphaFloat = 0.35;

            var fillColor:FlxColor = FlxColor.WHITE;
            fillColor.alphaFloat = 0.75;

            var isThis:Bool = (barShit.width > i * 20) && (barShit.width < i * 20 + 15);
            var spr:FlxSprite = new FlxSprite(i * 20).makeGraphic(15, 1, (barShit.width < i * 20 + 15) ? emptyColor : fillColor);
            spr.scale.y = barHeight;
            spr.updateHitbox();
            add(spr);

            if (isThis) {
                spr.clipRect = new FlxRect(barShit.width - spr.x, 0, (spr.x + spr.width) - barShit.width, spr.height);
                
                var spr2:FlxSprite = new FlxSprite(spr.x).makeGraphic(1, 1, fillColor);
                spr2.scale.set(spr.width - spr.clipRect.width, barHeight);
                spr2.updateHitbox();
                add(spr2);
            }
        }
    }

    function get_numBars():Int {
        var n:Int = 2048;
        var m:Float = n;
        while (true) {
            m = n;
            while (m % 2 == 0)
                m /= 2;
            while (m % 3 == 0)
                m /= 3;
            while (m % 5 == 0)
                m /= 5;
            if (m <= 1)
                break;
            n++;
        }
        return n;
    }
}