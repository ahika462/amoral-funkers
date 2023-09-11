import shaderslmfao.ColorSwap;
import flixel.FlxSprite;

class StrumNote extends FlxSprite {
    public var colorSwap:ColorSwap;

    private var noteData:Int = 0;
    private var player:Int;
    public var downscroll:Bool = false;

    public var direction:Float = 90;//plan on doing scroll directions soon -bb

    public var texture(default, set):String = "NOTE_assets";

    public function new(x:Float, y:Float, noteData:Int, player:Int) {
        super(x, y);

        this.noteData = noteData;
        this.player = player;

        texture = "NOTE_assets";

        colorSwap = new ColorSwap();
        shader = colorSwap.shader;
    }

    public function set_texture(value:String):String {
        if (PlayState.isPixelStage) {
            loadGraphic(Paths.image("weeb/pixelUI/" + value), true, 17, 17);
            setGraphicSize(Std.int(width * PlayState.daPixelZoom));

            switch (Math.abs(noteData)) {
                case 0:
                    x += Note.swagWidth * 0;
                    animation.add('static', [0]);
                    animation.add('pressed', [4, 8], 12, false);
                    animation.add('confirm', [12, 16], 24, false);
                case 1:
                    x += Note.swagWidth * 1;
                    animation.add('static', [1]);
                    animation.add('pressed', [5, 9], 12, false);
                    animation.add('confirm', [13, 17], 24, false);
                case 2:
                    x += Note.swagWidth * 2;
                    animation.add('static', [2]);
                    animation.add('pressed', [6, 10], 12, false);
                    animation.add('confirm', [14, 18], 12, false);
                case 3:
                    x += Note.swagWidth * 3;
                    animation.add('static', [3]);
                    animation.add('pressed', [7, 11], 12, false);
                    animation.add('confirm', [15, 19], 24, false);
            }
        } else {
            frames = Paths.getSparrowAtlas(value);
            antialiasing = true;
            setGraphicSize(Std.int(width * 0.7));

            switch (Math.abs(noteData)) {
                case 0:
                    x += Note.swagWidth * 0;
                    animation.addByPrefix('static', 'arrow static instance 1');
                    animation.addByPrefix('pressed', 'left press', 24, false);
                    animation.addByPrefix('confirm', 'left confirm', 24, false);
                case 1:
                    x += Note.swagWidth * 1;
                    animation.addByPrefix('static', 'arrow static instance 2');
                    animation.addByPrefix('pressed', 'down press', 24, false);
                    animation.addByPrefix('confirm', 'down confirm', 24, false);
                case 2:
                    x += Note.swagWidth * 2;
                    animation.addByPrefix('static', 'arrow static instance 4');
                    animation.addByPrefix('pressed', 'up press', 24, false);
                    animation.addByPrefix('confirm', 'up confirm', 24, false);
                case 3:
                    x += Note.swagWidth * 3;
                    animation.addByPrefix('static', 'arrow static instance 3');
                    animation.addByPrefix('pressed', 'right press', 24, false);
                    animation.addByPrefix('confirm', 'right confirm', 24, false);
            }
        }

        updateHitbox();

        return texture = value;
    }

    public var resetAnim:Float = 0;
    override function update(elapsed:Float) {
        if (resetAnim > 0) {
			resetAnim -= elapsed;
			if (resetAnim <= 0) {
				playAnim("static");
				resetAnim = 0;
			}
		}

        if (animation.curAnim != null && animation.curAnim.name != "static") {
            colorSwap.hue = ClientPrefs.data.arrowHSB[noteData][0];
            colorSwap.saturation = ClientPrefs.data.arrowHSB[noteData][1];
            colorSwap.brightness = ClientPrefs.data.arrowHSB[noteData][2];
        } else {
            colorSwap.hue = 0;
            colorSwap.saturation = 0;
            colorSwap.brightness = 0;
        }

        super.update(elapsed);
    }

    public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
        centerOffsets();
        if (!PlayState.isPixelStage && animation.curAnim != null && animation.curAnim.name == "confirm")
            offset.add(-13, -13);
	}
}