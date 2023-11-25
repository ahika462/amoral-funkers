package funkin.gameplay;

import openfl.utils.Assets;
import funkin.editors.ChartingState;
import funkin.backend.SwagCamera;
import funkin.CustomFadeTransition;
import funkin.backend.KeyUtils;
import funkin.data.WeekData;
import funkin.MusicBeatState;
import funkin.backend.Highscore;
import flixel.group.FlxSpriteGroup;
import funkin.gameplay.FunkinLua;
import flixel.math.FlxPoint;
import openfl.geom.Rectangle;
import funkin.backend.Screenshot;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.data.StageData;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.input.keyboard.FlxKey;
import funkin.Conductor.Rating;
import funkin.Section.SwagSection;
import funkin.Song;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;

import funkin.backend.Discord.DiscordClient;

using StringTools;

class PlayState extends MusicBeatState {
	public static var instance:PlayState;

	public var luaArray:Array<FunkinLua> = [];
	public var variables:Map<String, Dynamic> = [];
	public var modchartSprites:Map<String, ModchartSprite> = [];
	public var modchartTexts:Map<String, ModchartText> = [];
	public var modchartTweens:Map<String, FlxTween> = [];
	public var modchartTimers:Map<String, FlxTimer> = [];
	public var modchartSounds:Map<String, FlxSound> = [];

	public var BF_X:Float = 770;
	public var BF_Y:Float = 450;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	// public static var STRUM_X_MIDDLESCROLL = -271;

	public static var curStage:String = null;
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var deathCounter:Int = 0;
	public static var practiceMode:Bool = false;

	public var vocals:FlxSound;
	public var vocalsFinished:Bool = false;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;
	
	public var gfGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var boyfriendGroup:FlxSpriteGroup;

	public var gfMap:Map<String, Character> = [];
	public var dadMap:Map<String, Character> = [];
	public var boyfriendMap:Map<String, Boyfriend> = [];

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<Dynamic> = [];

	public var strumLine:FlxSprite;

	public var camFollow:FlxObject;
	public var camFollowPoint:FlxPoint;

	private static var prevCamFollow:FlxObject;
	private static var prevCamFollowPoint:FlxPoint;

	/*public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;*/

	public var strumLineNotes:FlxTypedSpriteGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;

	public var camZooming:Bool = false;
	public var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	public var healthLerp(default, null):Float;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public var camGame:SwagCamera = new SwagCamera();
	public var camTime:FlxCamera = new FlxCamera();
	public var camHUD:FlxCamera = new FlxCamera();
	public var camOther:FlxCamera = new FlxCamera();

	public var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	public static var seenCutscene:Bool = false;

	public var songScore:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;

	public var accuracy:Float = 0;
	public var noteHits:Int = 0;
	public var noteRatings:Float = 0;

	public var sickHits:Int = 0;
	public var goodHits:Int = 0;
	public var badHits:Int = 0;
	public var shitHits:Int = 0;
	public var ratingFC:String = "N/A";

	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	public var inCutscene:Bool = false;

	// Discord RPC variables
	var songLength:Float = 0;
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";

	public static var singAnims:Array<String> = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];

	public static var isPixelStage:Bool = false;

	public var timeSpectrum:TimeSpectrum;
	var amoralTxt:FlxText;

	var lastRatingCombo:FlxTypedGroup<FlxSprite>;
	var lastRatingOffsets:Map<FlxSprite, FlxPoint> = [];
	var lastRatingTimers:Map<FlxSprite, Float> = [];
	var lastRatingNotes:Map<FlxSprite, Note> = [];
	var lastRatingDisabled:Map<FlxSprite, Bool> = [];

	// да это пиздец отличается от модчарт хуёвин
	var pausingTweens:Array<FlxTween> = [];
	var pausingSounds:Array<FlxSound> = [];

	override public function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		instance = this;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		Paths.inst(PlayState.SONG.song);
		Paths.voices(PlayState.SONG.song);

		// var gameCam:FlxCamera = FlxG.camera;
		camTime.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camTime, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

		CustomFadeTransition.targetCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('glasses');
		if (SONG.events == null)
			SONG.events = [];

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;

		initDiscord();

		curStage = SONG.stage;
		if (curStage == null)
			curStage == "glasses";

		var stageFile:StageFile = StageData.get(curStage);
		defaultCamZoom = stageFile.zoom;
		isPixelStage = stageFile.pixel;
		BF_X += stageFile.boyfriend[0];
		BF_Y += stageFile.boyfriend[1];
		GF_X += stageFile.gf[0];
		GF_Y += stageFile.gf[1];
		DAD_X += stageFile.dad[0];
		DAD_Y += stageFile.dad[1];

		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);

		var gfVersion:String = SONG.gfVersion;

		if (!stageFile.hide_gf) {
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad);
		dadGroup.add(dad);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		if (prevCamFollowPoint != null) {
			camFollowPoint = prevCamFollowPoint;
			prevCamFollowPoint = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.08);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);

		/*gf.x += stageFile.gf[0] + gf.json.position[0];
		gf.y += stageFile.gf[1] + gf.json.position[1];

		dad.x += stageFile.dad[0] + dad.json.position[0];
		dad.y += stageFile.dad[1] + dad.json.position[1];
		
		boyfriend.x += stageFile.boyfriend[0] + boyfriend.json.position[0];
		boyfriend.y += stageFile.boyfriend[1] + boyfriend.json.position[1];*/

		add(gfGroup);
		add(dadGroup);
		add(boyfriendGroup);

		eventNotes = SONG.events != null ? SONG.events : [];
		eventNotes.sort(sortEventNotes);

		#if linc_luajit
		for (file in Paths.getEmbedFiles("scripts/")) {
			if (file.endsWith(".lua")) {
				var script:String = "";
				#if (final || !sys)
				script = Assets.getText(file);
				#else
				script = File.getContent(file);
				#end
				luaArray.push(new FunkinLua(file, script));
			}
		}
		for (file in Paths.getEmbedFiles("data/" + SONG.song.toLowerCase())) {
			if (file.endsWith(".lua")) {
				var script:String = "";
				#if (final || !sys)
				script = Assets.getText(file);
				#else
				script = File.getContent(file);
				#end
				luaArray.push(new FunkinLua(file, script));
			}
		};
		if (Paths.embedExists("stages/" + curStage + ".lua")) {
			var file:String = Paths.getEmbedShit("stages/" + curStage + ".lua");
			var script:String = "";
			#if (final || !sys)
			script = Assets.getText(file);
			#else
			script = File.getContent(file);
			#end
			luaArray.push(new FunkinLua(file, script));
		}
		
		var usedEvents:Array<String> = [];
		for (i in eventNotes) {
			var events:Array<Dynamic> = i[1];
			for (event in events) {
				if (!usedEvents.contains(event[0]))
					usedEvents.push(event[0]);
			}
		}
		for (event in usedEvents) {
			if (Paths.embedExists("events/" + event + ".lua")) {
				var file:String = Paths.getEmbedShit("events/" + event + ".lua");
				var script:String = "";
				#if (final || !sys)
				script = Assets.getText(file);
				#else
				script = File.getContent(file);
				#end
				luaArray.push(new FunkinLua(file, script));
			}
		}
		#end

		for (i in eventNotes) {
			var events:Array<Dynamic> = i[1];
			for (event in events) {
				eventPushed(event[0], event[1], event[2]);
			}
		}

		timeSpectrum = new TimeSpectrum();
		timeSpectrum.cameras = [camTime];
		add(timeSpectrum);

		amoralTxt = new FlxText(2, 0, FlxG.width, "AMORAL ENGINE 0.0.1 - " + SONG.song + " (" + CoolUtil.difficultyString() + ")");
		amoralTxt.setFormat(Paths.font("vcr.ttf"), 16, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
		amoralTxt.y = FlxG.height - amoralTxt.height;
		amoralTxt.cameras = [camOther];
		add(amoralTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);

		if (ClientPrefs.data.downscroll)
			strumLine.y = FlxG.height - 150; // 150 just random ass number lol

		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedSpriteGroup<StrumNote>(0, strumLine.y);
		add(strumLineNotes);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		var noteSplash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(noteSplash);
		noteSplash.alpha = 0.1;

		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<StrumNote>();
		opponentStrums = new FlxTypedGroup<StrumNote>();

		generateSong();

		// add(strumLine);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		if (ClientPrefs.data.downscroll)
			healthBarBG.y = FlxG.height * 0.1;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, "healthLerp", 0, 2);
		healthBar.scrollFactor.set();
		reloadHealthBarColors();
		add(healthBar);

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);
		recalculateRating();

		for (i in [
			grpNoteSplashes,
			strumLineNotes,
			notes,
			healthBar,
			healthBarBG,
			iconP1,
			iconP2,
			scoreTxt
		]) i.cameras = [camHUD];

		startingSong = true;

		if (SONG.notes[Conductor.curSection] != null)
			moveCamera(!SONG.notes[Conductor.curSection].mustHitSection);

		if (isStoryMode && !seenCutscene) {
			seenCutscene = true;

			switch (curSong.toLowerCase()) {
				default:
					startCountdown();
			}
		}
		else {
			switch (curSong.toLowerCase()) {
				default:
					startCountdown();
			}
		}

		justPressedKey = KeyUtils.addCallback(JUST_PRESSED, onKeyJustPressed);
		pressedKey = KeyUtils.addCallback(PRESSED, onKeyPressed);
		justReleasedKey = KeyUtils.addCallback(JUST_RELEASED, onKeyJustReleased);

		callOnLuas("onCreatePost", []);

		super.create();

		CustomFadeTransition.targetCamera = camOther;
	}

	function sortEventNotes(a:Dynamic, b:Dynamic):Int {
		if (a[0] >= b[0])
			return -1;
		else
			return 1;
	}

	function initDiscord() {
		storyDifficultyText = CoolUtil.difficultyString();
		iconRPC = SONG.player2;

		detailsText = isStoryMode ? "Story Mode: Week " + storyWeek : "Freeplay";
		detailsPausedText = "Paused - " + detailsText;

		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
	}

	var startTimer:FlxTimer = new FlxTimer();
	var perfectMode:Bool = false;

	public function startCountdown() {
		/*if (startedCountdown) {
			callOnLuas("onStartCountdown", []);
			return;
		}*/

		inCutscene = false;
		if (callOnLuas("onStartCountdown", [], false) != FunkinLua.Function_Stop) {
			camHUD.visible = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas("defaultPlayerStrumX" + i, playerStrums.members[i].x);
				setOnLuas("defaultPlayerStrumY" + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas("defaultOpponentStrumX" + i, opponentStrums.members[i].x);
				setOnLuas("defaultOpponentStrumY" + i, opponentStrums.members[i].y);
			}

			startedCountdown = true;
			setOnLuas("startedCountdown", true);
			callOnLuas("onCountdownStarted", []);

			var swagCounter:Int = 0;

			startTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (gf != null && swagCounter % Math.round(gf.danceBeats * gfSpeed) == 0)
					gf.dance();

				for (char in [dad, boyfriend]) {
					if (char.animation.curAnim != null && !char.animation.curAnim.name.startsWith("sing") && swagCounter % char.danceBeats == 0)
						char.dance();
				}

				if (generatedMusic)
					notes.sort(sortNotes, FlxSort.DESCENDING);

				var introSprites:Map<String, Array<String>> = [
					"default" => ["ready", "set", "go"],
					"pixel" => ["pixelUI/ready-pixel", "pixelUI/set-pixel", "pixelUI/date-pixel"]
				];
				var introSounds:Map<String, Array<String>> = [
					"default" => ["intro3", "intro2", "intro1", "introGo"],
					"pixel" => ["intro3-pixel", "intro2-pixel", "intro1-pixel", "introGo-pixel"]
				];

				if (FlxMath.inBounds(swagCounter, 1, 3))
					readySetGo(introSprites[isPixelStage ? "pixel" : "default"][swagCounter - 1]);

				if (swagCounter < 4)
					pausingSounds.push(FlxG.sound.play(Paths.sound(introSounds[isPixelStage ? "pixel" : "default"][swagCounter]), 0.6));
				else
 					startSong();

				callOnLuas("onCountdownTick", [swagCounter]);

				swagCounter += 1;
			}, 5);
		}
	}

	function readySetGo(path:String):Void
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(path));
		spr.scrollFactor.set();
		spr.antialiasing = isPixelStage ? false : ClientPrefs.data.antialiasing;

		if (isPixelStage)
			spr.setGraphicSize(Std.int(spr.width * daPixelZoom));

		spr.updateHitbox();
		spr.screenCenter();
		add(spr);
		pausingTweens.push(FlxTween.tween(spr, {y: spr.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				spr.destroy();
			}
		}));
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;

		if (!paused && !isDead)
			FlxG.sound.playMusic(Paths.inst(SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		// Conductor.followSound = FlxG.sound.music;
		vocals.play();

		songLength = FlxG.sound.music.length;
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		setOnLuas("songLength", songLength);
		callOnLuas("onSongStart", []);
	}

	private function generateSong():Void
	{
		var songData = SONG;
		Conductor.bpm = songData.bpm;

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song));
		else
			vocals = new FlxSound();

		vocals.onComplete = function()
		{
			vocalsFinished = true;
		};
		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		noteData = songData.notes;

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daNoteType:String = songNotes[3];

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.altNote = songNotes[3];
				swagNote.scrollFactor.set(0, 0);
				swagNote.noteType = daNoteType;

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					sustainNote.noteType = daNoteType;
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
						sustainNote.x += FlxG.width / 2; // general offset
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2; // general offset
			}
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	// Now you are probably wondering why I made 2 of these very similar functions
	// sortByShit(), and sortNotes(). sortNotes is meant to be used by both sortByShit(), and the notes FlxGroup
	// sortByShit() is meant to be used only by the unspawnNotes array.
	// and the array sorting function doesnt need that order variable thingie
	// this is good enough for now lololol HERE IS COMMENT FOR THIS SORTA DUMB DECISION LOL
	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return sortNotes(FlxSort.ASCENDING, Obj1, Obj2);
	}

	function sortNotes(order:Int = FlxSort.ASCENDING, Obj1:Note, Obj2:Note)
	{
		return FlxSort.byValues(order, Obj1.strumTime, Obj2.strumTime);
	}

	// ^ These two sorts also look cute together ^

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var targetAlpha:Float = 1;
			var babyArrow:StrumNote = new StrumNote(0, 0, i, player);
			babyArrow.scrollFactor.set();

			if (player == 0) {
				if (ClientPrefs.data.middlescroll)
					targetAlpha = 0.35;
				if (!ClientPrefs.data.opponentStrums)
					targetAlpha = 0;
			}

			if (!isStoryMode) {
				babyArrow.y = strumLineNotes.y - 10;
				babyArrow.alpha = 0;
				pausingTweens.push(FlxTween.tween(babyArrow, {y: strumLineNotes.y, alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)}));
			} else
				babyArrow.alpha = targetAlpha;

			babyArrow.x += ((FlxG.width / 2) * player);

			if (player == 1)
				playerStrums.add(babyArrow);
			else
				opponentStrums.add(babyArrow);

			strumLineNotes.add(babyArrow);
		}
		strumLineNotes.screenCenter(X);
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused || isDead) {
			if (FlxG.sound.music != null && !isDead) {
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;

			FlxG.camera.followLerp = 0;

			for (tween in modchartTweens)
				tween.active = false;
			for (timer in modchartTimers)
				timer.active = false;

			for (tween in pausingTweens) {
				if (tween != null)
					tween.active = false;
			}
			for (sound in pausingSounds) {
				if (sound != null)
					sound.pause();
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused) {
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (!startTimer.finished)
				startTimer.active = true;

			paused = false;
			callOnLuas("onResume", []);

			if (startTimer.finished)
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);

			FlxG.camera.followLerp = 0.04;

			for (tween in modchartTweens)
				tween.active = true;
			for (timer in modchartTimers)
				timer.active = true;

			for (tween in pausingTweens) {
				if (tween != null)
					tween.active = true;
			}
			for (sound in pausingSounds) {
				if (sound != null && sound.time < sound.length)
					sound.play();
			}
		}

		super.closeSubState();
	}

	override public function onFocus() {
		if (health > 0 && !paused && FlxG.autoPause) {
			if (Conductor.songPosition > 0.0)
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}

		super.onFocus();
	}

	override public function onFocusLost() {
		if (health > 0 && !paused && FlxG.autoPause)
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (_exiting)
			return;

		vocals.pause();
		FlxG.sound.music.play();

		if (vocalsFinished)
			return;

		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var paused:Bool = false;
	public var isDead:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		// makes the lerp non-dependant on the framerate
		// FlxG.camera.followLerp = CoolUtil.camLerpShit(0.04);

		#if !final
		if (FlxG.keys.justPressed.TWO) {
			daReset = true;
			endSong();
		}
		#else
		perfectMode = false;
		#end

		callOnLuas("onUpdate", [elapsed]);

		camFollow.setPosition(CoolUtil.coolLerp(camFollow.x, camFollowPoint.x, 0.08), CoolUtil.coolLerp(camFollow.y, camFollowPoint.y, 0.08));

		// do this BEFORE super.update() so songPosition is accurate
		if (!startingSong) {
			if (!paused && !isDead) {
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;
			}
		}

		healthLerp = CoolUtil.coolLerp(health, healthLerp, 0.25);

		if (eventNotes.length > 0) {
			var events:Array<Dynamic> = eventNotes[0][1];
			for (event in events) {
				if (eventNotes[0][0] - eventEarlyTrigger(event[0]) >= Conductor.songPosition) {
					triggerEventNote(event[0], event[1], event[2]);
					events.remove(event);
				}
			}
			if (eventNotes[0].length == 0)
				eventNotes.shift();
		}

		if (lastRatingCombo != null) {
			lastRatingCombo.forEach(function(spr:FlxSprite) {
				if (lastRatingDisabled.get(spr))
					return;

				if (lastRatingOffsets.exists(spr))
					spr.velocity.y = 0;
			});
		}

		super.update(elapsed);

		if (lastRatingCombo != null) {
			lastRatingCombo.forEach(function(spr:FlxSprite) {
				if (lastRatingDisabled.get(spr))
					return;
				
				if (!lastRatingOffsets.exists(spr) && spr.velocity.y >= 0) {
					lastRatingOffsets.set(spr, new FlxPoint(spr.x, spr.y + 15));
					lastRatingTimers.set(spr, 0);
				}
	
				if (!lastRatingOffsets.exists(spr))
					return;
	
				spr.velocity.y = 0;
				lastRatingTimers.set(spr, lastRatingTimers.get(spr) + elapsed);
				if (lastRatingTimers.get(spr) > 2)
					lastRatingTimers.set(spr, lastRatingTimers.get(spr) - 2);
	
				var timer:Float = lastRatingTimers.get(spr);
				if (timer >= 1)
					timer = -timer + 2;
				timer = FlxEase.quadInOut(timer);
	
				var offset:FlxPoint = lastRatingOffsets.get(spr);
				spr.y = CoolUtil.coolLerp(offset.y - 15, offset.y + 15, timer);

				if (lastRatingNotes.get(spr) == null)
					return;

				var strum:StrumNote = playerStrums.members[lastRatingNotes.get(spr).noteData];
				if (strum == null)
					return;

				if (strum.animation.curAnim.name != "confirm" || strum.animation.curAnim.finished) {
					lastRatingDisabled.set(spr, true);
					pausingTweens.push(FlxTween.tween(spr, {"alpha": 0}, 0.2, {"onComplete": function(tween:FlxTween) {
						spr.destroy();
					}}));
				}
			});
		}

		if (controls.PAUSE && startedCountdown && canPause && callOnLuas("onPause", [], false) != FunkinLua.Function_Stop) {
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			/*if (FlxG.random.bool(0.1)) {
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else*/ {
				var boyfriendPos = boyfriend.getScreenPosition();
				var pauseSubState = new PauseSubState(boyfriendPos.x, boyfriendPos.y);
				openSubState(pauseSubState);
				boyfriendPos.put();
			}

			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}

		if (FlxG.keys.justPressed.SEVEN) {
			FlxG.switchState(new ChartingState());

			DiscordClient.changePresence("Chart Editor", null, null, true);
		}

		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		#if (flixel >= "5.4.0")
		iconP1.setGraphicSize(CoolUtil.coolLerp(150, iconP1.width, 0.85));
		iconP2.setGraphicSize(CoolUtil.coolLerp(150, iconP2.width, 0.85));
		#else
		iconP1.setGraphicSize(Std.int(CoolUtil.coolLerp(150, iconP1.width, 0.85)));
		iconP2.setGraphicSize(Std.int(CoolUtil.coolLerp(150, iconP2.width, 0.85)));
		#end

		iconP1.width = Math.abs(iconP1.scale.x) * iconP1.frameWidth;
		iconP1.height = Math.abs(iconP1.scale.y) * iconP1.frameHeight;
		iconP1.offset.set(-0.5 * (iconP1.width - iconP1.frameWidth), -0.5 * (iconP1.height - iconP1.frameHeight));

		iconP2.width = Math.abs(iconP2.scale.x) * iconP2.frameWidth;
		iconP2.height = Math.abs(iconP2.scale.y) * iconP2.frameHeight;
		iconP2.offset.set(-0.5 * (iconP2.width - iconP2.frameWidth), -0.5 * (iconP2.height - iconP2.frameHeight));

		var iconOffset:Int = 26;

		iconP1.x = CoolUtil.coolLerp(healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset), iconP1.x, 0.25);
		iconP2.x = CoolUtil.coolLerp(healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset), iconP2.x, 0.25);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (camZooming) {
			FlxG.camera.zoom = CoolUtil.coolLerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = CoolUtil.coolLerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("sectionShit", Conductor.curSection);
		FlxG.watch.addQuick("beatShit", Conductor.curBeat);
		FlxG.watch.addQuick("stepShit", Conductor.curStep);

		// better streaming of shit

		if (!inCutscene && !_exiting)
		{
			if (controls.RESET)
			{
				health = 0;
				Debug.logTrace("RESET = True");
			}

			if (health <= 0 && !practiceMode && callOnLuas("onGameOver", [], false) != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = false;
				isDead = true;

				deathCounter += 1;

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}

		while (unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 1800 / SONG.speed)
		{
			var dunceNote:Note = unspawnNotes[0];
			notes.add(dunceNote);
			callOnLuas("onSpawnNote", [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);

			var index:Int = unspawnNotes.indexOf(dunceNote);
			unspawnNotes.shift();
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if ((ClientPrefs.data.downscroll && daNote.y < -daNote.height) || (!ClientPrefs.data.downscroll && daNote.y > FlxG.height)) {
					daNote.active = false;
					daNote.visible = false;
				}
				else {
					daNote.visible = true;
					daNote.active = true;
				}

				var strum:StrumNote = (daNote.mustPress ? playerStrums : opponentStrums).members[daNote.noteData];
				var angleDir:Float = strum.direction * Math.PI / 180;
				daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * SONG.speed * daNote.speedMult) * (ClientPrefs.data.downscroll ? 1 : -1);
				daNote.angle = strum.direction - 90 + strum.angle;
				daNote.x = strum.x + Math.cos(angleDir) * daNote.distance + daNote.offsetX;
				daNote.y = strum.y + Math.sin(angleDir) * daNote.distance;

				if (ClientPrefs.data.downscroll && daNote.isSustainNote) {
					if (daNote.animation.curAnim.name.endsWith('end')) {
						daNote.y += 10.5 * (Conductor.crochet / 400) * 1.5 * SONG.speed + (46 * (SONG.speed - 1));
						daNote.y -= 46 * (1 - (Conductor.crochet / 600)) * SONG.speed;
						if (isPixelStage)
							daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
						else
							daNote.y -= 19;
					}
					daNote.y += (Note.swagWidth / 2) - (60.5 * (SONG.speed - 1));
					daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (SONG.speed - 1);
				}

				if (daNote.copyAlpha)
					daNote.alpha = (daNote.mustPress ? playerStrums : opponentStrums).members[daNote.noteData].alpha;

				if (daNote.copyAngle)
					daNote.angle = (daNote.mustPress ? playerStrums : opponentStrums).members[daNote.noteData].angle;

				var strumLineMid = strumLine.y + Note.swagWidth / 2;

				if (ClientPrefs.data.downscroll)
				{
					daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

					if (daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith("end") && daNote.prevNote != null)
							daNote.y += daNote.prevNote.height;
						else
							daNote.y += daNote.height / 2;

						if ((!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= strumLineMid)
						{
							// clipRect is applied to graphic itself so use frame Heights
							var swagRect:FlxRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);

							swagRect.height = (strumLineMid - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;
							daNote.clipRect = swagRect;
						}
					}
				}
				else
				{
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

					if (daNote.isSustainNote
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))
						&& daNote.y + daNote.offset.y * daNote.scale.y <= strumLineMid)
					{
						var swagRect:FlxRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);

						swagRect.y = (strumLineMid - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;
						daNote.clipRect = swagRect;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
					opponentNoteHit(daNote);

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * SONG.speed));

				// removing this so whether the note misses or not is entirely up to Note class
				// var noteMiss:Bool = daNote.y < -daNote.height;

				// if (ClientPrefs.data.downscroll)
					// noteMiss = daNote.y > FlxG.height;

				if (daNote.isSustainNote && daNote.wasGoodHit)
				{
					if ((!ClientPrefs.data.downscroll && daNote.y < -daNote.height)
						|| (ClientPrefs.data.downscroll && daNote.y > FlxG.height))
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}
				else if (daNote.tooLate || daNote.wasGoodHit)
				{
					if (daNote.tooLate)
						noteMiss(daNote);

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		var holdArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true) && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.playAnim('idle');

		setOnLuas("cameraX", FlxG.camera.scroll.x);
		setOnLuas("cameraY", FlxG.camera.scroll.y);
		// setOnLuas("botPlay", cpuControlled);
		callOnLuas("onUpdatePost", [elapsed]);
	}

	function killCombo():Void
	{
		if (gf != null && combo > 5 && gf.animOffsets.exists('sad'))
			gf.playAnim('sad');
		if (combo != 0)
		{
			combo = 0;
			displayCombo();
		}
	}

	#if debug
	function changeSection(sec:Int):Void
	{
		FlxG.sound.music.pause();

		var daBPM:Float = SONG.bpm;
		var daPos:Float = 0;
		for (i in 0...(Std.int(Conductor.curSection + sec)))
		{
			if (SONG.notes[i].changeBPM)
			{
				daBPM = SONG.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		FlxG.sound.music.time = daPos;
		updateCurStep();
		resyncVocals();
	}
	#end

	var daReset:Bool = false;
	public function endSong() {
		if (daReset)
			return PauseSubState.restartSong();

		seenCutscene = false;
		deathCounter = 0;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
		}

		/* if (SONG.validScore && songScore > Highscore.getScore(SONG.song, storyDifficulty)) */ {
			// var funkin.backendRect:Rectangle = new Rectangle(healthBar.x - 200, healthBar.y - 200, healthBar.width + 400, healthBar.height + 400);

			var widthMult:Float = FlxG.stage.application.window.fullscreen ? (FlxG.stage.application.window.display.bounds.width / FlxG.width) : FlxG.stage.application.window.width / FlxG.width;

			var heightMult:Float = FlxG.stage.application.window.fullscreen ? (FlxG.stage.application.window.display.bounds.height / FlxG.height) : FlxG.stage.application.window.height / FlxG.height;

			var ssRect:Rectangle = new Rectangle();
			ssRect.height = (healthBar.height + (FlxG.height - (healthBar.y + healthBar.height)) * 2) * heightMult;
			ssRect.y = (healthBar.y - (ssRect.height - healthBar.height) / 2) * heightMult;
			ssRect.width = (healthBar.width + (ssRect.height - healthBar.height)) * widthMult;
			ssRect.x = (healthBar.x - (ssRect.width - healthBar.width) / 2) * widthMult;

			Screenshot.shot(ssRect);
		}

		if (callOnLuas("onEndSong", [], false) != FunkinLua.Function_Stop) {
			if (isStoryMode) {
				campaignScore += songScore;
	
				storyPlaylist.remove(storyPlaylist[0]);
	
				if (storyPlaylist.length <= 0) {
					FlxG.sound.playMusic(Paths.music("freakyMenu"));
	
					FlxG.switchState(new StoryMenuState());
	
					// if ()
					// WeekData.unlocked[Std.int(Math.min(storyWeek + 1, WeekData.unlocked.length - 1))] = true;
					WeekData.unlocked.set(WeekData.files[storyWeek], true);
	
					if (SONG.validScore)
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
	
					FlxG.save.data.weekUnlocked = WeekData.unlocked;
					FlxG.save.flush();
				} else {
					var difficulty:String = "";
	
					if (storyDifficulty == 0)
						difficulty = '-easy';
	
					if (storyDifficulty == 2)
						difficulty = '-hard';
	
					Debug.logTrace('LOADING NEXT SONG');
					Debug.logTrace(storyPlaylist[0].toLowerCase() + difficulty);
	
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
	
					FlxG.sound.music.stop();
					vocals.stop();
	
					prevCamFollow = camFollow;

					SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase() + difficulty, storyPlaylist[0]);
					LoadingState.loadAndSwitchState(new PlayState());
				}
			} else {
				Debug.logTrace('WENT BACK TO FREEPLAY??');
				FlxG.switchState(new FreeplayState());
			}
		}
	}

	// gives score and pops up rating
	private function popUpScore(daNote:Note):Void
	{
		vocals.volume = 1;

		var rating:FlxSprite = new FlxSprite();

		var daRating:Rating = Conductor.judgeNote(daNote, [
			new Rating("sick", ClientPrefs.data.sickWindow, 1, true),
			new Rating("good", ClientPrefs.data.goodWindow, 0.7, false),
			new Rating("bad", ClientPrefs.data.badWindow, 0.4, false),
			new Rating("shit", Std.int(Conductor.safeZoneOffset), 0, false)
		]);

		Reflect.setField(instance, daRating.name + "Hits", Reflect.field(instance, daRating.name + "Hits") + 1);

		noteHits++;
		noteRatings += daRating.rating;

		if (daRating.sick) {
			// var strum:StrumNote = playerStrums.members[daNote.noteData];
			var noteSplash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			noteSplash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
			// noteSplash.setupNoteSplash(strum.x, strum.y, daNote.noteData);
			grpNoteSplashes.add(noteSplash);
		}

		if (!practiceMode)
			songScore += daNote.score;

		var pixelShitPart1:String = isPixelStage ? "weeb/pixelUI/" : "";
		var pixelShitPart2:String = isPixelStage ? "-pixel" : "";

		if (lastRatingCombo == null) {
			lastRatingCombo = new FlxTypedGroup<FlxSprite>();
			add(lastRatingCombo);
		} else {
			remove(lastRatingCombo);
			if (!ClientPrefs.data.comboStacking)
				lastRatingCombo.clear();
			add(lastRatingCombo);
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.x = FlxG.width * 0.55 - 40;
		if (rating.x < FlxG.camera.scroll.x)
			rating.x = FlxG.camera.scroll.x;
		else if (rating.x > FlxG.camera.scroll.x + FlxG.camera.width - rating.width)
			rating.x = FlxG.camera.scroll.x + FlxG.camera.width - rating.width;

		rating.y = FlxG.camera.scroll.y + FlxG.camera.height * 0.4 - 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		lastRatingCombo.add(rating);

		if (isPixelStage)
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
		else {
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
		}
		rating.updateHitbox();

		/*pausingTweens.push(FlxTween.tween(rating, {"alpha": 0}, 0.2, {"onComplete": function(tween:FlxTween) {
			rating.destroy();
		}, "startDelay": Conductor.crochet * 0.001}));*/

		if (combo >= 10 || combo == 0)
			displayCombo();

		lastRatingCombo.forEach(function(spr:FlxSprite) {
			lastRatingNotes.set(spr, daNote);
			lastRatingDisabled.set(spr, false);
		});
	}

	function displayCombo():Void
	{
		var pixelShitPart1:String = isPixelStage ? "weeb/pixelUI/" : "";
		var pixelShitPart2:String = isPixelStage ? "-pixel" : "";

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + "combo" + pixelShitPart2));
		comboSpr.y = FlxG.camera.scroll.y + FlxG.camera.height * 0.4 + 80;
		comboSpr.x = FlxG.width * 0.55;
		if (comboSpr.x < FlxG.camera.scroll.x + 194)
			comboSpr.x = FlxG.camera.scroll.x + 194;
		else if (comboSpr.x > FlxG.camera.scroll.x + FlxG.camera.width - comboSpr.width)
			comboSpr.x = FlxG.camera.scroll.x + FlxG.camera.width - comboSpr.width;

		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.velocity.x += FlxG.random.int(1, 10);

		lastRatingCombo.add(comboSpr);

		if (isPixelStage)
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		else {
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		comboSpr.updateHitbox();

		/*pausingTweens.push(FlxTween.tween(comboSpr, {"alpha": 0}, 0.2, {"onComplete": function(tween:FlxTween) {
			comboSpr.destroy();
		}, "startDelay": Conductor.crochet * 0.001}));*/

		var seperatedScore:Array<Int> = [];
		var tempCombo:Int = combo;

		while (tempCombo != 0) {
			seperatedScore.push(tempCombo % 10);
			tempCombo = Std.int(tempCombo / 10);
		}
		while (seperatedScore.length < 3)
			seperatedScore.push(0);

		var daLoop:Int = 1;
		for (i in seperatedScore) {
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.y = comboSpr.y;

			if (isPixelStage)
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			else {
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			numScore.updateHitbox();

			numScore.x = comboSpr.x - (43 * daLoop); //- 90;
			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			lastRatingCombo.add(numScore);

			/*pausingTweens.push(FlxTween.tween(numScore, {"alpha": 0}, 0.2, {onComplete: function(tween:FlxTween) {
				numScore.destroy();
			}, "startDelay": Conductor.crochet * 0.002}));*/

			daLoop++;
		}
	}

	public function moveCamera(isDad:Bool) {
		var needX:Float = isDad ? (dad.getMidpoint().x + 150 + dad.json.camera_position[0]) : (boyfriend.getMidpoint().x - 100 - boyfriend.json.camera_position[0]);
		var needY:Float = isDad ? (dad.getMidpoint().y - 100 + dad.json.camera_position[1]) : (boyfriend.getMidpoint().y - 100 + boyfriend.json.camera_position[1]);

		if (camFollowPoint.x != needX || camFollowPoint.y != needY)
			camFollowPoint.set(needX, needY);

		callOnLuas("onMoveCamera", [isDad ? "dad" : "boyfriend"]);
	}

	var justPressedKey:String;
	var pressedKey:String;
	var justReleasedKey:String;

	function onKeyJustPressed(keyCode:Int) {
		if (keyCode == FlxKey.F2) {
			var bmp = openfl.display.BitmapData.fromImage(FlxG.stage.application.window.readPixels());
			File.saveBytes("pizdaNegra.png", bmp.encode(bmp.rect, new openfl.display.PNGEncoderOptions()));
		}

		if (keyCode == FlxKey.Y)
			Screenshot.shot();

		var keyID:Int = -1;
		var binds:Array<Array<FlxKey>> = [ClientPrefs.data.keyBinds["note_left"], ClientPrefs.data.keyBinds["note_down"], ClientPrefs.data.keyBinds["note_up"], ClientPrefs.data.keyBinds["note_right"]];
		for (i in 0...binds.length) {
			for (key in binds[i]) {
				if (keyCode == key)
					keyID = i;
			}
		}

		if (keyID >= 0 && /*!boyfriend.stunned && */ generatedMusic) {
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var possibleNotes:Array<Note> = []; // notes that can be hit
			var directionList:Array<Int> = []; // directions that can be hit
			var dumbNotes:Array<Note> = []; // notes to kill later

			notes.forEachAlive(function(daNote:Note) {
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					if (directionList.contains(daNote.noteData)) {
						for (coolNote in possibleNotes) {
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10) {
								// if it's the same note twice at < 10ms distance, just delete it
								// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
								dumbNotes.push(daNote);
								break;
							} else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime) {
								// if daNote is earlier than existing note (coolNote), replace
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					} else {
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}
				}
			});

			for (note in dumbNotes) {
				FlxG.log.add("killing dumb ass note at " + note.strumTime);
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			possibleNotes.sort(function(a:Dynamic, b:Dynamic):Int {
				return Std.int(a.strumTime - b.strumTime);
			});

			if (perfectMode)
				goodNoteHit(possibleNotes[0]);
			else if (possibleNotes.length > 0) {
				if (!directionList.contains(keyID))
					noteMissPress(keyID);

				for (coolNote in possibleNotes) {
					if (keyID == coolNote.noteData)
						goodNoteHit(coolNote);
				}
			}
			else {
				callOnLuas("onGhostTap", [keyID]);
				noteMissPress(keyID);
			}
		}

		var spr:StrumNote = playerStrums.members[keyID];

		if (spr == null)
			return;

		if (spr.animation.curAnim.name != "confirm")
			spr.playAnim("pressed");

		callOnLuas("onKeyPress", [keyID]);
	}

	function onKeyPressed(keyCode:Int) {
		var keyID:Int = -1;
		var binds:Array<Array<FlxKey>> = [ClientPrefs.data.keyBinds["note_left"], ClientPrefs.data.keyBinds["note_down"], ClientPrefs.data.keyBinds["note_up"], ClientPrefs.data.keyBinds["note_right"]];
		for (i in 0...binds.length) {
			for (key in binds[i]) {
				if (keyCode == key)
					keyID = i;
			}
		}

		if (/*!boyfriend.stunned && */ generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && daNote.noteData == keyID)
					goodNoteHit(daNote);
			});
		}

		var spr:StrumNote = playerStrums.members[keyID];

		if (spr == null)
			return;

		if (spr.animation.curAnim.name == "static")
			spr.playAnim("pressed");
	}

	function onKeyJustReleased(keyCode:Int) {
		var keyID:Int = -1;
		var binds:Array<Array<FlxKey>> = [ClientPrefs.data.keyBinds["note_left"], ClientPrefs.data.keyBinds["note_down"], ClientPrefs.data.keyBinds["note_up"], ClientPrefs.data.keyBinds["note_right"]];
		for (i in 0...binds.length) {
			for (key in binds[i]) {
				if (keyCode == key)
					keyID = i;
			}
		}

		var spr:StrumNote = playerStrums.members[keyID];
		
		if (spr == null)
			return;

		spr.playAnim("static", true);

		callOnLuas("onKeyRelease", [keyID]);
	}

	function noteMissPress(direction:Int = 1) {
		if (ClientPrefs.data.ghostTapping)
			return;

		// whole function used to be encased in if (!boyfriend.stunned)
		health -= 0.04;
		killCombo();
		songMisses++;
		noteHits++;

		if (!practiceMode)
			songScore -= 10;

		@:privateAccess {
			if (vocals._transform != null)
				vocals.volume = 0;
		}
		pausingSounds.push(FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2)));

		/* boyfriend.stunned = true;

		// get stunned for 5 seconds
		new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
		{
			boyfriend.stunned = false;
		}); */

		boyfriend.playAnim(singAnims[direction] + "miss", true);

		recalculateRating();

		callOnLuas("noteMissPress", [direction]);
	}

	function noteMiss(daNote:Note) {
		health -= daNote.missHealth;
		vocals.volume = 0;
		killCombo();
		songMisses++;
		noteHits++;

		daNote.active = false;
		daNote.visible = false;

		daNote.kill();
		notes.remove(daNote, true);
		daNote.destroy();

		boyfriend.playAnim(singAnims[daNote.noteData] + "miss", true);

		recalculateRating();

		callOnLuas("noteMiss", [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
			}

			health += note.hitHealth;

			var char:Character = note.noteType == "GF Sing" ? gf : boyfriend;

			if (char != null)
				char.playAnim(singAnims[note.noteData], true);

			strumPlayAnim(false, note.noteData);

			note.wasGoodHit = true;
			@:privateAccess {
				if (vocals._transform != null)
					vocals.volume = 1;
			}

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}

		recalculateRating();

		callOnLuas("goodNoteHit", [notes.members.indexOf(note), note.noteData, note.noteType, note.isSustainNote]);
	}

	function opponentNoteHit(daNote:Note) {
		if (SONG.song != 'Tutorial')
			camZooming = true;

		var altAnim:String = "";

		if (SONG.notes[Math.floor(Conductor.curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(Conductor.curStep / 16)].altAnim)
				altAnim = '-alt';
		}

		if (daNote.altNote)
			altAnim = '-alt';

		var char:Character = daNote.noteType == "GF Sing" ? gf : dad;

		if (char != null)
			char.playAnim(singAnims[daNote.noteData] + altAnim, true);

		var time:Float = 0.15;
		if (daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end'))
			time += 0.15;

		strumPlayAnim(true, daNote.noteData, time);

		if (char != null)
			char.holdTimer = 0;

		if (SONG.needsVoices) {
			@:privateAccess {
				if (vocals._transform != null)
					vocals.volume = 1;
			}
		}

		daNote.kill();
		notes.remove(daNote, true);
		daNote.destroy();

		callOnLuas("opponentNoteHit", [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	override function stepHit()
	{
		super.stepHit();

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20 || (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
			resyncVocals();
		
		setOnLuas("curStep", Conductor.curStep);
		callOnLuas("onStepHit", []);
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(sortNotes, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(Conductor.curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(Conductor.curStep / 16)].changeBPM)
			{
				Conductor.bpm = SONG.notes[Math.floor(Conductor.curStep / 16)].bpm;
				FlxG.log.add('CHANGED BPM!');
				// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
			}
		}
		
		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && !gf.animation.curAnim.name.startsWith("sing") && Conductor.curBeat % Math.round(gf.danceBeats * gfSpeed) == 0)
			gf.dance();

		for (char in [dad, boyfriend]) {
			if (!char.animation.curAnim.name.startsWith("sing") && Conductor.curBeat % char.danceBeats == 0)
				char.dance();
		}

		setOnLuas("curBeat", Conductor.curBeat);
		callOnLuas("onBeatHit", []);
	}

	override function sectionHit() {
		super.sectionHit();

		if (camZooming) {
			if (FlxG.camera.zoom < defaultCamZoom + 0.015)
				FlxG.camera.zoom += 0.015;
			if (camHUD.zoom < 1.03)
				camHUD.zoom += 0.03;
		}

		if (SONG.notes[Conductor.curSection] != null) {
			if (SONG.notes[Conductor.curSection].changeBPM) {
				Conductor.bpm = SONG.notes[Conductor.curSection].bpm;
				setOnLuas("curBpm", Conductor.bpm);
				setOnLuas("crochet", Conductor.crochet);
				setOnLuas("stepCrochet", Conductor.stepCrochet);
			}
			setOnLuas("mustHitSection", SONG.notes[Conductor.curSection].mustHitSection);
			setOnLuas("altAnim", SONG.notes[Conductor.curSection].altAnim);

			moveCamera(!SONG.notes[Conductor.curSection].mustHitSection);
		}

		setOnLuas("curSection", Conductor.curSection);
		callOnLuas("onSectionHit", []);
	}

	function strumPlayAnim(isDad:Bool, id:Int, time:Null<Float> = null, ?note:Note = null, ?isSustain:Bool = false) {
		var spr:StrumNote = null;
		if (isDad)
			spr = strumLineNotes.members[id];
		 else
			spr = playerStrums.members[id];

		if (spr != null) {
			spr.playAnim("confirm", true);
			if (time != null)
				spr.resetAnim = time;
		}
	}

	override function destroy() {
		for (script in luaArray) {
			script.call("onDestroy", []);
			script.stop();
		}
		luaArray = [];

		KeyUtils.removeCallback(JUST_PRESSED, justPressedKey);
		KeyUtils.removeCallback(PRESSED, pressedKey);
		KeyUtils.removeCallback(JUST_RELEASED, justReleasedKey);

		super.destroy();
	}

	function reloadHealthBarColors() {
		healthBar.createFilledBar(dad.healthColor, boyfriend.healthColor);
	}

	public function recalculateRating() {
		setOnLuas("score", songScore);
		setOnLuas("misses", songMisses);
		setOnLuas("hits", noteHits);

		if (callOnLuas("onRecalculateRating", [], false) == FunkinLua.Function_Stop)
			return;

		accuracy = Math.min(1, Math.max(0, noteRatings / noteHits));
		if (Math.isNaN(accuracy))
			accuracy = 0;

		ratingFC = "N/A";
		if (sickHits > 0)
			ratingFC = "SFC";
		if (goodHits > 0)
			ratingFC = "GFC";
		if (badHits > 0 || shitHits > 0)
			ratingFC = "FC";
		if (songMisses > 0)
			ratingFC = "SDCB";
		if (songMisses >= 10)
			ratingFC = "Clear";

		updateScore(); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnLuas("accuracy", accuracy);
		setOnLuas("ratingFC", ratingFC);
	}

	public function updateScore() {
		scoreTxt.text = "Score: " + songScore + " | " + "Misses: " + songMisses + " | " + "Accuracy: " + (accuracy == 0 ? "N/A" : Std.string(FlxMath.roundDecimal(accuracy * 100, 2)) + "%") + " | Rating: " + ratingFC;
		scoreTxt.screenCenter(X);

		callOnLuas("onUpdateScore", []);
	}

	function eventEarlyTrigger(eventName:String):Float {
		var returnVal:Dynamic = callOnLuas("eventEarlyTrigger", [eventName]);
		if (returnVal == !Math.isNaN(returnVal))
			returnVal = 0;

		return returnVal;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case "Add Camera Zoom":
				if (ClientPrefs.data.cameraZoom) {
					var gameZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					FlxG.camera.zoom += !Math.isNaN(gameZoom) ? gameZoom : 0.015;
					camHUD.zoom += !Math.isNaN(hudZoom) ? hudZoom : 0.03;
				}

			case "Set GF Speed":
				var newSpeed:Int = Std.parseInt(value1);
				if (Math.isNaN(newSpeed) || newSpeed < 1)
					newSpeed = 1;
				gfSpeed = newSpeed;

			case "Play Animation":
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case "bf" | "boyfriend":
						char = boyfriend;
					case "gf" | "girlfriend":
						char = gf;
					default:
						var charNum:Int = Std.parseInt(value2);
						if (Math.isNaN(charNum))
							charNum = 0;
						char = [dad, boyfriend, gf][charNum];
				}
				if (char != null) {
					char.playAnim(value1, true);
					char.specAnim = true;
				}

			case "Change Character":
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case "dad" | "opponent" | "0":
						charType = 1;
					case "gf" | "girlfriend" | "1":
						charType = 2;
					default:
						charType = Std.parseInt(value1);
						if (Math.isNaN(charType))
							charType = 0;
				}
				
				switch(charType) {
					case 0:
						if (boyfriend.curCharacter == value2)
							return;

						if (!boyfriendMap.exists(value2))
							addCharacterToList(value2, charType);

						var lastAlpha:Float = boyfriend.alpha;
						boyfriend.alpha = 0.00001;
						boyfriend = boyfriendMap.get(value2);
						boyfriend.alpha = lastAlpha;
						iconP1.changeIcon(boyfriend.healthIcon);

						setOnLuas("boyfriendName", boyfriend.curCharacter);

					case 1:
						if (dad.curCharacter == value2)
							return;

						if (!dadMap.exists(value2))
							addCharacterToList(value2, charType);

						var wasGf:Bool = dad.curCharacter.startsWith("gf");
						var lastAlpha:Float = dad.alpha;
						dad.alpha = 0.00001;
						dad = dadMap.get(value2);
						if(!dad.curCharacter.startsWith("gf")) {
							if (wasGf && gf != null)
								gf.visible = true;
						} else if (gf != null)
							gf.visible = false;

						dad.alpha = lastAlpha;
						iconP2.changeIcon(dad.healthIcon);

						setOnLuas("dadName", dad.curCharacter);

					case 2:
						if (gf == null || gf.curCharacter == value2)
							return;

						if (!gfMap.exists(value2))
							addCharacterToList(value2, charType);

						var lastAlpha:Float = gf.alpha;
						gf.alpha = 0.00001;
						gf = gfMap.get(value2);
						gf.alpha = lastAlpha;

						setOnLuas("gfName", gf.curCharacter);
				}
		}
		callOnLuas("onEvent", [eventName, value1, value2]);
	}

	function eventPushed(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case "Change Character":
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case "dad" | "opponent" | "0":
						charType = 1;
					case "gf" | "girlfriend" | "1":
						charType = 2;
					default:
						charType = Std.parseInt(value1);
						if (Math.isNaN(charType))
							charType = 0;
				}
				addCharacterToList(value2, charType);
		}
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops:Bool = true, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal = FunkinLua.Function_Continue;

		#if linc_luajit
		if (exclusions == null)
			exclusions = [];
		if (excludeValues == null)
			excludeValues = [];

		for (script in luaArray) {
			if (exclusions.contains(script.scriptName))
				continue;

			var myValue = script.call(event, args);
			if (myValue == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			if (myValue != null && myValue != FunkinLua.Function_Continue)
				returnVal = myValue;
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if linc_luajit
		if (exclusions == null)
			exclusions = [];

		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function initLuaShader(name:String, ?glslVersion:Int = 120):Bool {
		if (!ClientPrefs.data.shaders)
			return false;

		#if (!flash && sys)
		if(runtimeShaders.exists(name)) {
			Debug.logTrace("Shader " + name + " was already initialized");
			return true;
		}

		if (FileSystem.exists(Paths.getEmbedShit("shaders"))) {
			var frag:String = Paths.shaderFragment(name);
			var vert:String = Paths.shaderVertex(name);

			if (frag != null || vert != null) {
				runtimeShaders.set(name, [frag, vert]);
				return true;
			} else
				Debug.logError("Missing shader " + name + ".frag AND .vert files!");
		}
		#else
		Debug.logError("Platform unsupported for Runtime Shaders!");
		#end
		return false;
	}
	#end

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if (modchartSprites.exists(tag))
			return modchartSprites.get(tag);
		if (text && modchartTexts.exists(tag))
			return modchartTexts.get(tag);
		if (variables.exists(tag))
			return variables.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if (gfCheck && char.curCharacter.startsWith('gf')) {
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		char.x += char.json.position[0];
		char.y += char.json.position[1];
	}

	public function addCharacterToList(name:String, type:Int) {
		switch(type) {
			case 0:
				if (boyfriendMap.exists(name))
					return;

				var newBoyfriend:Boyfriend = new Boyfriend(0, 0, name);
				boyfriendMap.set(name, newBoyfriend);
				boyfriendGroup.add(newBoyfriend);
				startCharacterPos(newBoyfriend);
				newBoyfriend.alpha = 0.00001;

			case 1:
				var newDad:Character = new Character(0, 0, name);
				dadMap.set(name, newDad);
				dadGroup.add(newDad);
				startCharacterPos(newDad);
				newDad.alpha = 0.00001;

			case 2:
				if (gf == null)
					return;

				var newGf:Character = new Character(0, 0, name);
				gfMap.set(name, newGf);
				gfGroup.add(newGf);
				startCharacterPos(newGf);
				newGf.alpha = 0.00001;
		}
	}
}