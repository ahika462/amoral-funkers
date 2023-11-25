package funkin.editors.editors;

import funkin.gameplay.HealthIcon;
import funkin.gameplay.Note;
import haxe.Json;
import funkin.Conductor.BPMChangeEvent;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import funkin.Section.SwagSection;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.addons.display.FlxGridOverlay;
import flixel.sound.FlxSound;
import funkin.Song;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

using flixel.util.FlxStringUtil;
using StringTools;

class ChartDebugger extends BaseDebugger {
	public var undos:Array<SwagSong> = [];
	public var redos:Array<SwagSong> = [];

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
	var curRenderedEvents:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;

    public var json:SwagSong;

    var curSelectedNote:Array<Dynamic>;
	var curSelectedEvent:Array<Dynamic>;

    var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	// var waveform:Waveform;

    public function new(song:String = "Glasses") {
        super();

        curSection = lastSection;

        gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 9, GRID_SIZE * 16);
		gridBG.setPosition(FlxG.width / 2 - GRID_SIZE * 4, FlxG.height / 2);
		add(gridBG);

        leftIcon = new HealthIcon("bf");
		leftIcon.setGraphicSize(0, 45);
		leftIcon.updateHitbox();
		leftIcon.setPosition(gridBG.x + gridBG.width / 4 - leftIcon.width / 2, gridBG.y - leftIcon.height * 1.5);
		add(leftIcon);

		rightIcon = new HealthIcon("dad");
		rightIcon.setGraphicSize(0, 45);
		rightIcon.updateHitbox();
		rightIcon.setPosition(gridBG.x + gridBG.width / 4 - rightIcon.width / 2, gridBG.y - rightIcon.height * 1.5);
		add(rightIcon);

        leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

		// waveform = new Waveform(Paths.voices(song));

        var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + GRID_SIZE * 4 - 1, gridBG.y).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + GRID_SIZE * 8 - 1, gridBG.y).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

        if (PlayState.SONG != null)
			json = PlayState.SONG;
		else
            json = Song.loadFromJson(song, song);

		FlxG.save.bind('funkin', 'ninjamuffin99');

        addSection();

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedEvents = new FlxTypedGroup<FlxSprite>();

        updateGrid();

        loadSong(json.song);
		Conductor.bpm = json.bpm;
		Conductor.mapBPMChanges(json);
		// Conductor.followSound = FlxG.sound.music;
		Conductor.songPosition = 0;

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(gridBG.x, gridBG.y).makeGraphic(Std.int(gridBG.width), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedEvents);
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

		// Conductor.songPosition = FlxG.sound.music.time;

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

		var mouseY:Float = ModdingState.instance.camEditor.viewY + FlxG.mouse.y;

		if (FlxG.mouse.justPressed) {
			var overlappedNote:Note = null;
			curRenderedNotes.forEach(function(note:Note) {
				if (FlxG.mouse.x > note.x && FlxG.mouse.x < note.x + note.width && mouseY > note.y && mouseY < note.y + note.height)
					overlappedNote = note;
			});

			if (overlappedNote != null) {
				if (FlxG.keys.pressed.CONTROL)
					selectNote(overlappedNote);
				else {
					Debug.logTrace('tryin to delete note...');
					deleteNote(overlappedNote);
				}
			} else {
				if (FlxG.mouse.x > gridBG.x && FlxG.mouse.x < gridBG.x + gridBG.width && mouseY > gridBG.y && mouseY < gridBG.y + (GRID_SIZE * json.notes[curSection].lengthInSteps)) {
					FlxG.log.add('added note');
					addNote();
				}
			}
		}
		
		if (FlxG.mouse.x > gridBG.x && FlxG.mouse.x < gridBG.x + gridBG.width && mouseY > gridBG.y && mouseY < gridBG.y + (GRID_SIZE * json.notes[curSection].lengthInSteps)) {
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = mouseY;
			else
				dummyArrow.y = Math.floor(mouseY / GRID_SIZE) * GRID_SIZE;
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

		bpmTxt.text = "Time: " + (Conductor.songPosition / 1000).formatTime() + " / " + (FlxG.sound.music.length / 1000).formatTime() + "\n(" + Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2)) + " / " + Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2)) + ")\n\nSection: " + curSection;

		ModdingState.instance.camFollow.y = strumLine.y;

		if (curSelectedNote != null && curSelectedNote[2] != ModdingState.instance.chartUI.sustainStepper.value)
			curSelectedNote[2] = ModdingState.instance.chartUI.sustainStepper.value;

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
		if (curSelectedNote != null)
			ModdingState.instance.chartUI.sustainStepper.value = curSelectedNote[2];
	}

	public function updateGrid() {
		curRenderedNotes.clear();
		curRenderedSustains.clear();
		curRenderedEvents.clear();

		var sectionInfo:Array<Dynamic> = json.notes[curSection].sectionNotes;

		if (json.notes[curSection].changeBPM && json.notes[curSection].bpm > 0) {
			Conductor.bpm = json.notes[curSection].bpm;
			FlxG.log.add('CHANGED BPM!');
		} else {
			// get last bpm
			var daBPM:Float = json.bpm;
			for (i in 0...curSection)
				if (json.notes[i].changeBPM)
					daBPM = json.notes[i].bpm;
			Conductor.bpm = daBPM;
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

		if (json.events == null)
			json.events = [];

		for (i in json.events) {
			if (i[0] >= getSectionStartTime(Conductor.curSection) && i[0] < getSectionStartTime(Conductor.curSection + 1)) {
				var event:FlxSprite = new FlxSprite(Math.floor(gridBG.x + GRID_SIZE * 8), Math.floor(getYfromStrum((i[0] - sectionStartTime()) % (Conductor.stepCrochet * json.notes[curSection].lengthInSteps))), Paths.image("eventArrow"));
				curRenderedEvents.add(event);
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
		addUndo();

		for (i in json.notes[curSection].sectionNotes) {
			if (i[0] == note.strumTime && i[1] % 4 == note.noteData && i[1] < 4 == json.notes[curSection].mustHitSection ? note.mustPress : !note.mustPress) {
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
		addUndo();

		var noteStrum:Float = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData:Int = Math.floor((FlxG.mouse.x - gridBG.x) / GRID_SIZE);
		var noteSus:Float = 0;
		var noteAlt:Bool = false;

		if (noteData == 8) {
			json.events.push([noteStrum, "", "", ""]);
			curSelectedEvent = json.events[json.events.length - 1];
		} else {
			json.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteAlt]);
			curSelectedNote = json.notes[curSection].sectionNotes[json.notes[curSection].sectionNotes.length - 1];
			if (FlxG.keys.pressed.CONTROL)
			{
				json.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus, noteAlt]);
			}
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

	function addUndo() {
		var cont:SwagSong = {
			"song": json.song,
			"notes": json.notes,
			"events": json.events,
			"bpm": json.bpm,
			"needsVoices": json.needsVoices,
			"speed": json.speed,
			"stage": json.stage,

			"player1": json.player1,
			"player2": json.player2,
			"gfVersion": json.gfVersion,
			"validScore": json.validScore
		};
		undos.insert(0, cont);
	}

	function getSectionStartTime(sec:Int) {
		var doneSteps:Int = 0;
		for (i in 0...sec - 1) {
			if (json.notes[i].sectionBeats != null)
				doneSteps += json.notes[i].sectionBeats * 4;
			else
				doneSteps += json.notes[i].lengthInSteps;
		}

		return doneSteps * Conductor.stepCrochet;
	}
}