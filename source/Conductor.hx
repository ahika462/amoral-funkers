import flixel.sound.FlxSound;
import openfl.events.Event;
import openfl.Lib;
import Song.SwagSong;
import flixel.util.FlxSignal;

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor {
    public static var bpm:Float = 100;
    public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
    
    public static var songPosition:Float;
	public static var lastSongPos:Float;
    public static var followSound:FlxSound = null;

	public static var offset:Float = 0;

    public static var safeZoneOffset(get, never):Float;
	public static function get_safeZoneOffset():Float {
		return (ClientPrefs.data.safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds
	}

    public static var bpmChangeMap:Array<BPMChangeEvent> = [];

    public static var curStep:Int = 0;
    public static var curBeat:Int = 0;
    public static var onStepHit:FlxSignal = new FlxSignal();
    public static var onBeatHit:FlxSignal = new FlxSignal();

    public static function mapBPMChanges(song:SwagSong) {
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

    public static function changeBPM(newBpm:Float) {
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}

	public static function judgeNote(note:Note, ratings:Array<Rating>) {
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		for (i in ratings) {
			if (noteDiff < i.window)
				return i;
		}

		return ratings[ratings.length - 1];
	}

    public static function init() {
        Lib.current.stage.addEventListener(Event.ENTER_FRAME, function(?e:Event) {
            update();
        });
    }

    public static function update() {
        if (followSound != null && followSound.playing)
            songPosition = followSound.time + offset;

        var oldStep:Int = curStep;

        var lastChange:BPMChangeEvent = {
            stepTime: 0,
            songTime: 0,
            bpm: 0
        }
        for (i in 0...bpmChangeMap.length)
        {
            if (songPosition >= bpmChangeMap[i].songTime)
                lastChange = bpmChangeMap[i];
        }

        curStep = lastChange.stepTime + Math.floor((songPosition - lastChange.songTime) / stepCrochet);
        curBeat = Math.floor(curStep / 4);

        if (oldStep != curStep && curStep >= 0) {
            onStepHit.dispatch();
            if (curStep % 4 == 0)
                onBeatHit.dispatch();
        }
    }
}

class Rating {
	public var name:String;
	public var image:String;
	public var window:Int;
	public var sick:Bool;
	
	public function new(name:String, window:Int, sick:Bool) {
		this.name = name;
		this.image = name;
		this.window = window;
		this.sick = sick;
	}
}