import flixel.FlxG;
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

    public static var crochet(get, never):Float; // beats in milliseconds
	public static var stepCrochet(get, never):Float; // steps in milliseconds

	static function get_crochet():Float {
		return (60 / bpm) * 1000;
	}

	static function get_stepCrochet():Float {
		return crochet / 4;
	}
    
    public static var songPosition(get, set):Float;
	public static var lastSongPos:Float;

	public static var offset:Float = 0;

    public static var safeZoneOffset(get, never):Float;
	public static function get_safeZoneOffset():Float {
		return (ClientPrefs.data.safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds
	}

    public static var bpmChangeMap:Array<BPMChangeEvent> = [];

    public static var curStep:Int = 0;
    public static var curBeat:Int = 0;
	public static var curSection:Int = 0;
	
    public static var onStepHit:FlxSignal = new FlxSignal();
    public static var onBeatHit:FlxSignal = new FlxSignal();
	public static var onSectionHit:FlxSignal = new FlxSignal();

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
		Debug.logTrace("new BPM map BUDDY " + bpmChangeMap);
	}

	/*static function set_bpm(value:Float):Float {
		bpm = value;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;

		return value;
	}*/

	public static function judgeNote(note:Note, ratings:Array<Rating>) {
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		for (i in ratings) {
			if (noteDiff <= i.window /*/ 2*/)
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
        
		if (oldStep != curStep && curStep >= 0) {
			curBeat = Std.int(curStep / 4);
			
			var oldSection:Int = curSection;
			curSection = -1;
			
			var stepsToDo:Int = 0;
			while (curStep >= stepsToDo && curStep > 0) {
				if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) {
					if (PlayState.SONG.notes[curSection].sectionBeats != null)
						stepsToDo += PlayState.SONG.notes[curSection].sectionBeats * 4;
					else
						stepsToDo += PlayState.SONG.notes[curSection].lengthInSteps;
				} else
					stepsToDo += 16;

				curSection++;
			}

            onStepHit.dispatch();
            if (curStep % 4 == 0)
                onBeatHit.dispatch();
			if (oldSection != curSection)
				onSectionHit.dispatch();
        }
    }

	static function get_songPosition():Float {
		if (FlxG.sound.music != null)
			return FlxG.sound.music.time;

		return 0;
	}

	static function set_songPosition(value:Float):Float {
		if (FlxG.sound.music != null)
			return FlxG.sound.music.time = value;

		return value;
	}
}

class Rating {
	public var name:String;
	public var image:String;
	public var window:Int;
	public var rating:Float;
	public var sick:Bool;
	
	public function new(name:String, window:Int, rating:Float, sick:Bool) {
		this.name = name;
		this.image = name;
		this.window = window;
		this.rating = rating;
		this.sick = sick;
	}
}