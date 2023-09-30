package modding.editors;

import flixel.math.FlxMath;
import Section.SwagSection;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.addons.display.FlxGridOverlay;
import flixel.sound.FlxSound;
import Song.SwagSong;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

class ChartDebugger extends BaseDebugger {
    var curSection:Int = 0;
    public static var lastSection:Int = 0;

    var strumLine:FlxSprite;
	var curSong:String = "Test";
	var amountSteps:Int = 0;

    var highlight:FlxSprite;

    inline public static var GRID_SIZE:Int = 40;

    var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;

    public var json:SwagSong;

    var curSelectedNote:Array<Dynamic>;

    var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

    public function new(song:String = "Test") {
        super();

        curSection = lastSection;

        gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);

        leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('dad');
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

        leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

        leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

        var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

        curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

        if (PlayState.SONG != null)
			json = PlayState.SONG;
		else
            json = Song.loadFromJson(song, song);

		FlxG.save.bind('funkin', 'ninjamuffin99');

        addSection();

        updateGrid();

        loadSong(json.song);
    }

    function addSection(lengthInSteps:Int = 16) {
        var sec:SwagSection = {
            lengthInSteps: lengthInSteps,
            bpm: json.bpm,
            changeBPM: false,
            mustHitSection: true,
            sectionNotes: [],
            typeOfSection: 0,
            altAnim: false
        };

        json.notes.push(sec);
    }

    function updateGrid() {
		while (curRenderedNotes.members.length > 0)
			curRenderedNotes.remove(curRenderedNotes.members[0], true);

		while (curRenderedSustains.members.length > 0)
			curRenderedSustains.remove(curRenderedSustains.members[0], true);

		var sectionInfo:Array<Dynamic> = json.notes[curSection].sectionNotes;

		if (json.notes[curSection].changeBPM && json.notes[curSection].bpm > 0) {
			Conductor.changeBPM(json.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		} else {
			// get last bpm
			var daBPM:Float = json.bpm;
			for (i in 0...curSection)
				if (json.notes[i].changeBPM)
					daBPM = json.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		for (i in sectionInfo) {
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];

			var note:Note = new Note(daStrumTime, daNoteInfo % 4);
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * json.notes[curSection].lengthInSteps)));

			curRenderedNotes.add(note);

			if (daSus > 0) {
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2), note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
				curRenderedSustains.add(sustainVis);
			}
		}
	}

    function getYfromStrum(strumTime:Float):Float {
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

    function sectionStartTime():Float {
		var daBPM:Float = json.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection) {
			if (json.notes[i].changeBPM)
				daBPM = json.notes[i].bpm;
            
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

    public function loadSong(daSong:String) {
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.playMusic(Paths.inst(daSong), 0.6);

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function() {
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

    function changeSection(sec:Int = 0, ?updateMusic:Bool = true) {
		trace('changing section' + sec);

		if (json.notes[sec] != null) {
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				Conductor.update();
			}

			updateGrid();
			updateSectionUI();
		}
	}

    function updateSectionUI() {
        
    }

	public function loadJson(song:String) {
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		LoadingState.loadAndSwitchState(new ChartingState());
	}
}

/*import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.math.FlxPoint;
import flixel.FlxG;
import haxe.Json;
import Character.CharacterFile;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxSprite;
import Song.SwagSong;

class ChartDebugger extends BaseDebugger {
    public var curSong:String = "test";
    public var json(get, set):SwagSong;

    public var player1Json(get, never):CharacterFile;
    public var player2Json(get, never):CharacterFile;

    inline public static var GRID_SIZE:Int = 40;
    public var grid:FlxSprite;

    var leftIcon:HealthIcon;
    var rightIcon:HealthIcon;

    var curSection:Int = 0;

    var vocals:FlxSound;

    var notes:Array<Note> = [];

    public function new(song:String = "test") {
        super();
        curSong = song;
        loadJson(song);
        vocals = new FlxSound().loadEmbedded(Paths.voices(json.song.toLowerCase()));

        grid = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
        grid.x = FlxG.width / 2;
        grid.y = FlxG.height / 2;
        add(grid);

        leftIcon = new HealthIcon();
        leftIcon.setGraphicSize(0, 45);
        leftIcon.updateHitbox();
        leftIcon.setPosition(grid.x + grid.width / 4 - leftIcon.width / 2, grid.y - leftIcon.height / 2 - 30);
        add(leftIcon);
        
        rightIcon = new HealthIcon();
        rightIcon.setGraphicSize(0, 45);
        rightIcon.updateHitbox();
        rightIcon.setPosition(grid.x + grid.width / 4 * 3 - rightIcon.width / 2, grid.y - rightIcon.height / 2 - 30);
        add(rightIcon);

        reloadSection();
    }

    function get_json():SwagSong {
        return PlayState.SONG;
    }

    function set_json(value:SwagSong):SwagSong {
        return PlayState.SONG = value;
    }

    function get_player1Json():CharacterFile {
        return cast Json.parse(Paths.getEmbedText("characters/" + json.player1 + ".json")).character;
    }

    function get_player2Json():CharacterFile {
        return cast Json.parse(Paths.getEmbedText("characters/" + json.player2 + ".json")).character;
    }

    function reloadSection(step:Int = 0, force:Bool = false) {
        curSection = step + (force ? 0 : curSection);

        leftIcon.changeIcon(json.notes[curSection].mustHitSection ? player1Json.healthicon : player2Json.healthicon);
        rightIcon.changeIcon(!json.notes[curSection].mustHitSection ? player1Json.healthicon : player2Json.healthicon);

        for (i in json.notes[curSection].sectionNotes) {
            var daNoteData:Int = i[1];
			var daStrumTime:Float = i[0];
			var daSus:Float = i[2];

            var note:EditorNote = new EditorNote(daNoteData, daStrumTime, daSus);
        }
    }

    public function loadJson(song:String) {
        var songFile:SwagSong = Song.loadFromJson(song, song);
        json = songFile;
    }

    public function loadSong(song:String) {

    }
}*/