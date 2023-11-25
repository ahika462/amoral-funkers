package funkin.backend.beat;

typedef BPMChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor {
    public static var bpm(default, set):Float = 100;

    public static var crochet:Float = (60 / bpm) * 1000;
    public static var stepCrochet:Float = crochet / 4;
    public static var sectionCrochet:Float = crochet * 4;

    @:noPrivateAccess static function set_bpm(value:Float):Float {
        crochet = (60 / value) * 1000;
        /*stepCrochet = crochet / 4;
        sectionCrochet = crochet * 4;*/

        return bpm = value;
    }

    public static var songPosition:Float;

    public static var safeZoneOffset(get, never):Float;
	@:noPrivateAccess static function get_safeZoneOffset():Float {
		return (/*ClientPrefs.data.safeFrames*/ 10 / 60) * 1000;
	}

    public static var bpmChangeMap:Array<BPMChangeEvent> = [];
}