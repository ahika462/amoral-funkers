package modding.editors;

import haxe.Json;
import Conductor.BPMChangeEvent;
import flixel.text.FlxText;
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

	var bpmTxt:FlxText;

    var strumLine:FlxSprite;
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

	var waveform:Waveform;

    public function new(song:String = "Test") {
        super();

        curSection = lastSection;

        gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		gridBG.setPosition(FlxG.width / 2 - gridBG.width / 2, FlxG.height / 2);
		add(gridBG);

        leftIcon = new HealthIcon('bf');
		leftIcon.setGraphicSize(0, 45);
		leftIcon.updateHitbox();
		leftIcon.setPosition(gridBG.x + gridBG.width / 4 - leftIcon.width / 2, gridBG.y - leftIcon.height * 1.5);
		add(leftIcon);

		rightIcon = new HealthIcon('dad');
		rightIcon.setGraphicSize(0, 45);
		rightIcon.updateHitbox();
		rightIcon.setPosition(gridBG.x + gridBG.width / 4 - rightIcon.width / 2, gridBG.y - rightIcon.height * 1.5);
		add(rightIcon);

        leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

		waveform = new Waveform(Paths.voices(song));

        var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2 - 1, gridBG.y).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

        if (PlayState.SONG != null)
			json = PlayState.SONG;
		else
            json = Song.loadFromJson(song, song);

		FlxG.save.bind('funkin', 'ninjamuffin99');

        addSection();

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

        updateGrid();

        loadSong(json.song);
		Conductor.changeBPM(json.bpm);
		Conductor.mapBPMChanges(json);
		Conductor.followSound = FlxG.sound.music;
		Conductor.followSound.time = 0;

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(gridBG.x, gridBG.y).makeGraphic(Std.int(gridBG.width), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		add(curRenderedNotes);
		add(curRenderedSustains);
    }

	public function loadSong(daSong:String) {
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if (vocals != null)
			vocals.stop();

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
			changeSection(-1);
		};
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

	override function update(elapsed:Float) {
		Conductor.curStep = recalculateSteps();

		Conductor.songPosition = FlxG.sound.music.time;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * json.notes[curSection].lengthInSteps));

		if (FlxG.keys.justPressed.X)
			toggleAltAnimNote();

		if (Conductor.curBeat % 4 == 0 && Conductor.curStep >= 16 * (curSection + 1)) {
			Debug.logTrace(Conductor.curStep);
			Debug.logTrace((json.notes[curSection].lengthInSteps) * (curSection + 1));
			Debug.logTrace('DUMBSHIT');

			if (json.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', Conductor.curBeat);
		FlxG.watch.addQuick('daStep', Conductor.curStep);

		curRenderedNotes.forEach(function(note:Note) {
			if (note.strumTime > Conductor.songPosition) {
				note.alpha = 1;
				note.wasGoodHit = false;
			}
			else {
				note.alpha = 0.4;
				if (!note.wasGoodHit)
					FlxG.sound.play(Paths.sound("hitsound"));
				note.wasGoodHit = true;
			}
		});

		if (FlxG.mouse.justPressed) {
			if (FlxG.mouse.overlaps(curRenderedNotes)) {
				curRenderedNotes.forEach(function(note:Note) {
					if (FlxG.mouse.overlaps(note)) {
						if (FlxG.keys.pressed.CONTROL) {
							selectNote(note);
						}
						else {
							Debug.logTrace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else {
				if (FlxG.mouse.x > gridBG.x && FlxG.mouse.x < gridBG.x + gridBG.width && FlxG.mouse.y > gridBG.y && FlxG.mouse.y < gridBG.y + (GRID_SIZE * json.notes[curSection].lengthInSteps)) {
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x && FlxG.mouse.x < gridBG.x + gridBG.width && FlxG.mouse.y > gridBG.y && FlxG.mouse.y < gridBG.y + (GRID_SIZE * json.notes[curSection].lengthInSteps)) {
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER) {
			lastSection = curSection;

			PlayState.SONG = json;
			FlxG.sound.music.stop();
			vocals.stop();
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E)
			changeNoteSustain(Conductor.stepCrochet);
		if (FlxG.keys.justPressed.Q)
			changeNoteSustain(-Conductor.stepCrochet);

		if (!ModdingState.instance.anyFocused) {
			if (FlxG.keys.justPressed.SPACE) {
				if (FlxG.sound.music.playing) {
					FlxG.sound.music.pause();
					vocals.pause();
				}
				else {
					vocals.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R) {
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0) {
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = FlxG.sound.music.time;
			}

			if (!FlxG.keys.pressed.SHIFT) {
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S) {
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
						FlxG.sound.music.time -= daTime;
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
			else {
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S) {
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
						FlxG.sound.music.time -= daTime;
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
		}

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
			changeSection(curSection - shiftThing);

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2)) + " / " + Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2)) + "\nSection: " + curSection;

		super.update(elapsed);
	}

	function changeNoteSustain(value:Float) {
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function toggleAltAnimNote() {
		if (curSelectedNote != null) {
			if (curSelectedNote[3] != null) {
				Debug.logTrace('ALT NOTE SHIT');
				curSelectedNote[3] = !curSelectedNote[3];
				Debug.logTrace(curSelectedNote[3]);
			}
			else
				curSelectedNote[3] = true;
		}
	}

	function recalculateSteps():Int {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		Conductor.curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		Conductor.curBeat = Math.floor(Conductor.curStep / 4);

		return Conductor.curStep;
	}

	function resetSection(songBeginning:Bool = false) {
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		Conductor.update();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true) {
		Debug.logTrace('changing section' + sec);

		if (json.notes[sec] != null) {
			curSection = sec;

			updateGrid();

			if (updateMusic) {
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				Conductor.update();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1) {
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in json.notes[daSec - sectionNum].sectionNotes) {
			var strum = note[0] + Conductor.stepCrochet * (json.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			json.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI() {
		updateHeads();
	}

	public function updateHeads() {
		if (json.notes[curSection].mustHitSection) {
			leftIcon.changeIcon(json.player1);
			rightIcon.changeIcon(json.player2);
		}
		else {
			leftIcon.changeIcon(json.player2);
			rightIcon.changeIcon(json.player1);
		}
	}

	function updateNoteUI() {
		/*if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];*/
	}

	function updateGrid() {
		curRenderedNotes.clear();
		curRenderedSustains.clear();

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

		for (i in sectionInfo) {
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];

			var note:Note = new Note(daStrumTime, daNoteInfo % 4);
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(gridBG.x + daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * json.notes[curSection].lengthInSteps)));

			curRenderedNotes.add(note);

			if (daSus > 0) {
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2) - 4, note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
				curRenderedSustains.add(sustainVis);
			}
		}
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

	function selectNote(note:Note) {
		var swagNum:Int = 0;

		for (i in json.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % 4 == note.noteData)
			{
				curSelectedNote = json.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note) {
		for (i in json.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] % 4 == note.noteData)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				json.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection() {
		json.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong() {
		for (daSection in 0...json.notes.length)
			json.notes[daSection].sectionNotes = [];

		updateGrid();
	}

	private function addNote() {
		var noteStrum:Float = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData:Int = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus:Float = 0;
		var noteAlt:Bool = false;

		json.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteAlt]);

		curSelectedNote = json.notes[curSection].sectionNotes[json.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL)
		{
			json.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus, noteAlt]);
		}

		Debug.logTrace(noteStrum);
		Debug.logTrace(curSection);
		Debug.logTrace(noteData);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float {
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

    function getYfromStrum(strumTime:Float):Float {
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	private var daSpacing:Float = 0.3;

	function loadLevel() {
		Debug.logTrace(json.notes);
	}

	function getNotes():Array<Dynamic> {
		var noteData:Array<Dynamic> = [];

		for (i in json.notes)
			noteData.push(i.sectionNotes);

		return noteData;
	}

	public function loadJson(song:String) {
		ModdingState.instance.closeSubState();
		ModdingState.instance.chartDebug = new ChartDebugger(song.toLowerCase());
		ModdingState.instance.openSubState(ModdingState.instance.chartDebug);
	}

	public function loadAutosave() {
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		loadJson(null);
	}

	function autosaveSong() {
		FlxG.save.data.autosave = Json.stringify({
			"song": json
		});
		FlxG.save.flush();
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