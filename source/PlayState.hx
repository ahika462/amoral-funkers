package;

import flixel.group.FlxSpriteGroup;
import FunkinLua;
import flixel.math.FlxPoint;
import openfl.geom.Rectangle;
import screenshot.Screenshot;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import StageData.StageFile;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.input.keyboard.FlxKey;
import Conductor.Rating;
import Section.SwagSection;
import Song.SwagSong;
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
import shaderslmfao.BuildingShaders;

#if discord_rpc
import Discord.DiscordClient;
#end

using StringTools;

class PlayState extends MusicBeatState {
	public static var instance:PlayState;

	public var luaArray:Array<FunkinLua> = [];
	public var variables:Map<String, Dynamic> = [];
	/*public var modchartSprites:Map<String, ModchartSprite> = [];
	public var modchartTexts:Map<String, ModchartText> = [];
	public var modchartTweens:Map<String, FlxTween> = [];
	public var modchartTimers:Map<String, FlxTimer> = [];
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();*/
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();

	public var BF_X:Float = 770;
	public var BF_Y:Float = 450;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var gfGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var boyfriendGroup:FlxSpriteGroup;

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

	var songLength:Float = 0;
	#if discord_rpc
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	var lightFadeShader:BuildingShaders;

	public static var singAnims:Array<String> = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];

	public static var isPixelStage:Bool = false;

	public var timeSpectrum:TimeSpectrum;
	var amoralTxt:FlxText;

	var lastRatingCombo:FlxTypedGroup<FlxSprite>;

	override public function create()
	{
		instance = this;
		Paths.clear();

		Conductor.followSound = null;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.cache(Paths.inst(PlayState.SONG.song));
		FlxG.sound.cache(Paths.voices(PlayState.SONG.song));

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

		#if discord_rpc
		initDiscord();
		#end

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

		var gfVersion:String = "minimaxfla";

		gf = new Character(0, 0, gfVersion);
		startCharacterPos(gf);
		gf.scrollFactor.set(0.95, 0.95);
		gfGroup.add(gf);

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

		timeSpectrum = new TimeSpectrum();
		timeSpectrum.cameras = [camTime];
		add(timeSpectrum);

		amoralTxt = new FlxText(2, 0, FlxG.width, "AMORAL ENGINE 0.0.1 - " + SONG.song + " (" + CoolUtil.difficultyString() + ")");
		amoralTxt.setFormat(Paths.font("vcr.ttf"), 16, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
		amoralTxt.borderSize = 1.25;
		amoralTxt.borderQuality = 2;
		amoralTxt.y = FlxG.height - amoralTxt.height;
		amoralTxt.cameras = [camOther];
		add(amoralTxt);

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);

		if (ClientPrefs.data.downscroll)
			strumLine.y = FlxG.height - 150; // 150 just random ass number lol

		strumLine.scrollFactor.set();

		/*strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);*/

		strumLineNotes = new FlxTypedSpriteGroup<StrumNote>(0, strumLine.y);
		add(strumLineNotes);

		// fake notesplash cache type deal so that it loads in the graphic?

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
		// healthBar
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

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

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

		// input fix
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

	function ughIntro()
	{
		inCutscene = true;

		var blackShit:FlxSprite = new FlxSprite(-200, -200).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		blackShit.scrollFactor.set();
		add(blackShit);

		var vid:FlxVideo = new FlxVideo('music/ughCutscene.mp4');
		vid.finishCallback = function()
		{
			remove(blackShit);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.crochet / 1000) * 5, {ease: FlxEase.quadInOut});
			startCountdown();
			cameraMovement();
		};

		FlxG.camera.zoom = defaultCamZoom * 1.2;

		camFollow.x += 100;
		camFollow.y += 100;

		/* 
			FlxG.sound.playMusic(Paths.music('DISTORTO'), 0);
			FlxG.sound.music.fadeIn(5, 0, 0.5);

			dad.visible = false;
			var tankCutscene:TankCutscene = new TankCutscene(-20, 320);
			tankCutscene.frames = Paths.getSparrowAtlas('cutsceneStuff/tankTalkSong1');
			tankCutscene.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
			tankCutscene.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
			tankCutscene.animation.play('wellWell');
			tankCutscene.antialiasing = true;
			gfCutsceneLayer.add(tankCutscene);

			camHUD.visible = false;

			FlxG.camera.zoom *= 1.2;
			camFollow.y += 100;

			tankCutscene.startSyncAudio = FlxG.sound.load(Paths.sound('wellWellWell'));

			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				camFollow.x += 800;
				camFollow.y += 100;
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 0.27, {ease: FlxEase.quadInOut});

				new FlxTimer().start(1.5, function(bep:FlxTimer)
				{
					boyfriend.playAnim('singUP');
					// play sound
					FlxG.sound.play(Paths.sound('bfBeep'), function()
					{
						boyfriend.playAnim('idle');
					});
				});

				new FlxTimer().start(3, function(swaggy:FlxTimer)
				{
					camFollow.x -= 800;
					camFollow.y -= 100;
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 0.5, {ease: FlxEase.quadInOut});
					tankCutscene.animation.play('killYou');
					FlxG.sound.play(Paths.sound('killYou'));
					new FlxTimer().start(6.1, function(swagasdga:FlxTimer)
					{
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.crochet / 1000) * 5, {ease: FlxEase.quadInOut});

						FlxG.sound.music.fadeOut((Conductor.crochet / 1000) * 5, 0);

						new FlxTimer().start((Conductor.crochet / 1000) * 5, function(money:FlxTimer)
						{
							dad.visible = true;
							gfCutsceneLayer.remove(tankCutscene);
						});

						cameraMovement();

						startCountdown();
						camHUD.visible = true;
					});
				});
		});*/
	}

	function gunsIntro()
	{
		inCutscene = true;

		var blackShit:FlxSprite = new FlxSprite(-200, -200).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		blackShit.scrollFactor.set();
		add(blackShit);

		var vid:FlxVideo = new FlxVideo('music/gunsCutscene.mp4');
		vid.finishCallback = function()
		{
			remove(blackShit);

			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.crochet / 1000) * 5, {ease: FlxEase.quadInOut});
			startCountdown();
			cameraMovement();
		};

		/*
			camHUD.visible = false;

			FlxG.sound.playMusic(Paths.music('DISTORTO'), 0);
			FlxG.sound.music.fadeIn(5, 0, 0.5);

			camFollow.y += 100;

			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.3}, 4, {ease: FlxEase.quadInOut});

			dad.visible = false;
			var tankCutscene:TankCutscene = new TankCutscene(20, 320);
			tankCutscene.frames = Paths.getSparrowAtlas('cutsceneStuff/tankTalkSong2');
			tankCutscene.animation.addByPrefix('tankyguy', 'TANK TALK 2', 24, false);
			tankCutscene.animation.play('tankyguy');
			tankCutscene.antialiasing = true;
			gfCutsceneLayer.add(tankCutscene); // add();

			tankCutscene.startSyncAudio = FlxG.sound.load(Paths.sound('tankSong2'));

			new FlxTimer().start(4.1, function(ugly:FlxTimer)
			{
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.4}, 0.4, {ease: FlxEase.quadOut});
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.3}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0.45});

				gf.playAnim('sad');
			});

			new FlxTimer().start(11, function(tmr:FlxTimer)
			{
				FlxG.sound.music.fadeOut((Conductor.crochet / 1000) * 5, 0);

				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.crochet * 5) / 1000, {ease: FlxEase.quartIn});
				startCountdown();
				new FlxTimer().start((Conductor.crochet * 25) / 1000, function(daTim:FlxTimer)
				{
					dad.visible = true;
					gfCutsceneLayer.remove(tankCutscene);
				});

				camHUD.visible = true;
		});*/
	}

	/**
	 * [
	 * 	[0, function(){blah;}],
	 * 	[4.6, function(){blah;}],
	 * 	[25.1, function(){blah;}],
	 * 	[30.7, function(){blah;}]
	 * ]
	 * SOMETHING LIKE THIS
	 */
	// var cutsceneFunctions:Array<Dynamic> = [];

	function stressIntro()
	{
		inCutscene = true;

		var blackShit:FlxSprite = new FlxSprite(-200, -200).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		blackShit.scrollFactor.set();
		add(blackShit);

		var vid:FlxVideo = new FlxVideo('music/stressCutscene.mp4');
		vid.finishCallback = function()
		{
			remove(blackShit);

			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.crochet / 1000) * 5, {ease: FlxEase.quadInOut});
			startCountdown();
			cameraMovement();
		};

		/* camHUD.visible = false;

			var dummyLoaderShit:FlxGroup = new FlxGroup();

			add(dummyLoaderShit);

			for (i in 0...7)
			{
				var dummyLoader:FlxSprite = new FlxSprite();
				dummyLoader.loadGraphic(Paths.image('cutsceneStuff/gfHoldup-' + i));
				dummyLoaderShit.add(dummyLoader);
				dummyLoader.alpha = 0.01;
				dummyLoader.y = FlxG.height - 20;
				// dummyLoader.drawFrame(true);
			}

			dad.visible = false;

			// gf.y += 300;
			gf.alpha = 0.01;

			var gfTankmen:FlxSprite = new FlxSprite(210, 70);
			gfTankmen.frames = Paths.getSparrowAtlas('characters/gfTankmen');
			gfTankmen.animation.addByPrefix('loop', 'GF Dancing at Gunpoint', 24, true);
			gfTankmen.animation.play('loop');
			gfTankmen.antialiasing = true;
			gfCutsceneLayer.add(gfTankmen);

			var tankCutscene:TankCutscene = new TankCutscene(-70, 320);
			tankCutscene.frames = Paths.getSparrowAtlas('cutsceneStuff/tankTalkSong3-pt1');
			tankCutscene.animation.addByPrefix('tankyguy', 'TANK TALK 3 P1 UNCUT', 24, false);
			// tankCutscene.animation.addByPrefix('weed', 'sexAmbig', 24, false);
			tankCutscene.animation.play('tankyguy');

			tankCutscene.antialiasing = true;
			bfTankCutsceneLayer.add(tankCutscene); // add();

			var alsoTankCutscene:FlxSprite = new FlxSprite(20, 320);
			alsoTankCutscene.frames = Paths.getSparrowAtlas('cutsceneStuff/tankTalkSong3-pt2');
			alsoTankCutscene.animation.addByPrefix('swagTank', 'TANK TALK 3 P2 UNCUT', 24, false);
			alsoTankCutscene.antialiasing = true;

			bfTankCutsceneLayer.add(alsoTankCutscene);

			alsoTankCutscene.y = FlxG.height + 100;

			camFollow.setPosition(gf.x + 350, gf.y + 560);
			FlxG.camera.focusOn(camFollow.getPosition());

			boyfriend.visible = false;

			var fakeBF:Character = new Character(boyfriend.x, boyfriend.y, 'bf', true);
			bfTankCutsceneLayer.add(fakeBF);

			// var atlasCutscene:Animation
			// var animAssets:AssetManager = new AssetManager();

			// var url = 'images/gfDemon';

			// // animAssets.enqueueSingle(Paths.file(url + "/spritemap1.png"));
			// // animAssets.enqueueSingle(Paths.file(url + "/spritemap1.json"));
			// // animAssets.enqueueSingle(Paths.file(url + "/Animation.json"));

			// animAssets.loadQueue(function(asssss:AssetManager)
			// {
			// 	var daAnim:Animation = asssss.createAnimation('GF Turnin Demon W Effect');
			// 	FlxG.addChildBelowMouse(daAnim);
			// });

			var bfCatchGf:FlxSprite = new FlxSprite(boyfriend.x - 10, boyfriend.y - 90);
			bfCatchGf.frames = Paths.getSparrowAtlas('cutsceneStuff/bfCatchesGF');
			bfCatchGf.animation.addByPrefix('catch', 'BF catches GF', 24, false);
			bfCatchGf.antialiasing = true;
			add(bfCatchGf);
			bfCatchGf.visible = false;

			if (ClientPrefs.data.censorNaughty)
				tankCutscene.startSyncAudio = FlxG.sound.play(Paths.sound('stressCutscene'));
			else
			{
				tankCutscene.startSyncAudio = FlxG.sound.play(Paths.sound('song3censor'));
				// cutsceneSound.loadEmbedded(Paths.sound('song3censor'));

				var censor:FlxSprite = new FlxSprite();
				censor.frames = Paths.getSparrowAtlas('cutsceneStuff/censor');
				censor.animation.addByPrefix('censor', 'mouth censor', 24);
				censor.animation.play('censor');
				add(censor);
				censor.visible = false;
				//

				new FlxTimer().start(4.6, function(censorTimer:FlxTimer)
				{
					censor.visible = true;
					censor.setPosition(dad.x + 160, dad.y + 180);

					new FlxTimer().start(0.2, function(endThing:FlxTimer)
					{
						censor.visible = false;
					});
				});

				new FlxTimer().start(25.1, function(censorTimer:FlxTimer)
				{
					censor.visible = true;
					censor.setPosition(dad.x + 120, dad.y + 170);

					new FlxTimer().start(0.9, function(endThing:FlxTimer)
					{
						censor.visible = false;
					});
				});

				new FlxTimer().start(30.7, function(censorTimer:FlxTimer)
				{
					censor.visible = true;
					censor.setPosition(dad.x + 210, dad.y + 190);

					new FlxTimer().start(0.4, function(endThing:FlxTimer)
					{
						censor.visible = false;
					});
				});

				new FlxTimer().start(33.8, function(censorTimer:FlxTimer)
				{
					censor.visible = true;
					censor.setPosition(dad.x + 180, dad.y + 170);

					new FlxTimer().start(0.6, function(endThing:FlxTimer)
					{
						censor.visible = false;
					});
				});
			}

			// new FlxTimer().start(0.01, function(tmr) cutsceneSound.play()); // cutsceneSound.play();
			// cutsceneSound.play();
			// tankCutscene.startSyncAudio = cutsceneSound;
			// tankCutscene.animation.curAnim.curFrame

			FlxG.camera.zoom = defaultCamZoom * 1.15;

			camFollow.x -= 200;

			// cutsceneSound.onComplete = startCountdown;

			// Cunt 1
			new FlxTimer().start(31.5, function(cunt:FlxTimer)
			{
				camFollow.x += 400;
				camFollow.y += 150;
				FlxG.camera.zoom = defaultCamZoom * 1.4;
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.1}, 0.5, {ease: FlxEase.elasticOut});
				FlxG.camera.focusOn(camFollow.getPosition());
				boyfriend.playAnim('singUPmiss');
				boyfriend.animation.finishCallback = function(animFinish:String)
				{
					camFollow.x -= 400;
					camFollow.y -= 150;
					FlxG.camera.zoom /= 1.4;
					FlxG.camera.focusOn(camFollow.getPosition());

					boyfriend.animation.finishCallback = null;
				};
			});

			new FlxTimer().start(15.1, function(tmr:FlxTimer)
			{
				camFollow.y -= 170;
				camFollow.x += 200;
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom * 1.3}, 2.1, {
					ease: FlxEase.quadInOut
				});

				new FlxTimer().start(2.2, function(swagTimer:FlxTimer)
				{
					// FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.7, {ease: FlxEase.elasticOut});
					FlxG.camera.zoom = 0.8;
					// camFollow.y -= 100;
					boyfriend.visible = false;
					bfCatchGf.visible = true;
					bfCatchGf.animation.play('catch');

					bfTankCutsceneLayer.remove(fakeBF);

					bfCatchGf.animation.finishCallback = function(anim:String)
					{
						bfCatchGf.visible = false;
						boyfriend.visible = true;
					};

					new FlxTimer().start(3, function(weedShitBaby:FlxTimer)
					{
						camFollow.y += 180;
						camFollow.x -= 80;
					});

					new FlxTimer().start(2.3, function(gayLol:FlxTimer)
					{
						bfTankCutsceneLayer.remove(tankCutscene);
						alsoTankCutscene.y = 320;
						alsoTankCutscene.animation.play('swagTank');
						// tankCutscene.animation.play('weed');
					});
				});

				gf.visible = false;
				var cutsceneShit:CutsceneCharacter = new CutsceneCharacter(210, 70, 'gfHoldup');
				gfCutsceneLayer.add(cutsceneShit);
				gfCutsceneLayer.remove(gfTankmen);

				cutsceneShit.onFinish = function()
				{
					gf.alpha = 1;
					gf.visible = true;
				};

				// add(cutsceneShit);
				new FlxTimer().start(20, function(alsoTmr:FlxTimer)
				{
					dad.visible = true;
					bfTankCutsceneLayer.remove(alsoTankCutscene);
					startCountdown();
					remove(dummyLoaderShit);
					dummyLoaderShit.destroy();
					dummyLoaderShit = null;

					gfCutsceneLayer.remove(cutsceneShit);
				});
		});*/
	}

	#if discord_rpc
	function initDiscord():Void
	{
		storyDifficultyText = CoolUtil.difficultyString();
		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		detailsText = isStoryMode ? "Story Mode: Week " + storyWeek : "Freeplay";
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
	}
	#end

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * daPixelZoom));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += senpaiEvil.width / 5;

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
			else
				FlxG.sound.play(Paths.sound('ANGRY'));
			// moved senpai angry noise in here to clean up cutscene switch case lol
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
				tmr.reset(0.3);
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
								swagTimer.reset();
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
						add(dialogueBox);
				}
				else
					startCountdown();

				remove(black);
			}
		});
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
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnLuas("startedCountdown", true);
			callOnLuas("onCountdownStarted", []);

			var swagCounter:Int = 0;

			startTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				// this just based on beatHit stuff but compact
				if (swagCounter % gfSpeed == 0)
					gf.dance();
				if (swagCounter % 2 == 0)
				{
					if (boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith("sing"))
						boyfriend.playAnim('idle');
					if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith("sing"))
						dad.dance();
				}
				else if (dad.curCharacter == 'spooky' && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith("sing"))
					dad.dance();
				if (generatedMusic)
					notes.sort(sortNotes, FlxSort.DESCENDING);

				var introSprPaths:Array<String> = ["ready", "set", "go"];
				var altSuffix:String = "";

				if (curStage.startsWith("school"))
				{
					altSuffix = '-pixel';
					introSprPaths = ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel'];
				}

				var introSndPaths:Array<String> = ["intro3" + altSuffix, "intro2" + altSuffix,
					"intro1" + altSuffix, "introGo" + altSuffix];

				if (swagCounter > 0)
					readySetGo(introSprPaths[swagCounter - 1]);
				FlxG.sound.play(Paths.sound(introSndPaths[swagCounter]), 0.6);

				/* switch (swagCounter)
				{
					case 0:
						
					case 1:
						
					case 2:
						
					case 3:
						
				} */
				callOnLuas("onCountdownTick", [swagCounter]);

				swagCounter += 1;
			}, 4);
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
		FlxTween.tween(spr, {y: spr.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				spr.destroy();
			}
		});
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
		Conductor.followSound = FlxG.sound.music;
		vocals.play();

		songLength = FlxG.sound.music.length;
		#if discord_rpc
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
		setOnLuas("songLength", songLength);
		callOnLuas("onSongStart", []);
	}

	private function generateSong():Void
	{
		// FlxG.log.add(ChartParser.parse());

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

		// NEW SHIT
		noteData = songData.notes;

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

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

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
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
			/*var babyArrow:StrumNote = new StrumNote(STRUM_X, strumLine.y, i, player);
			babyArrow.scrollFactor.set();*/

			/*if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}*/

			/*babyArrow.ID = i;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
				opponentStrums.add(babyArrow);

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);*/

			var babyArrow:StrumNote = new StrumNote(0, 0, i, player);
			babyArrow.scrollFactor.set();

			if (player == 1)
				playerStrums.add(babyArrow);
			else
				opponentStrums.add(babyArrow);

			babyArrow.animation.play("static");
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
		strumLineNotes.screenCenter(X);
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
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

			#if discord_rpc
			if (startTimer.finished)
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end

			FlxG.camera.followLerp = 0.04;
		}

		super.closeSubState();
	}

	#if discord_rpc
	override public function onFocus():Void
	{
		if (health > 0 && !paused && FlxG.autoPause)
		{
			if (Conductor.songPosition > 0.0)
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (health > 0 && !paused && FlxG.autoPause)
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);

		super.onFocusLost();
	}
	#end

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

		#if !debug
		perfectMode = false;
		#end

		callOnLuas("onUpdate", [elapsed]);

		camFollow.setPosition(FlxMath.lerp(camFollow.x, camFollowPoint.x, 0.08), FlxMath.lerp(camFollow.y, camFollowPoint.y, 0.08));

		// do this BEFORE super.update() so songPosition is accurate
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time + Conductor.offset; // 20 is THE MILLISECONDS??
			// Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused && !isDead)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// Debug.logTrace('MISSED FRAME');
				}
			}
			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		healthLerp = FlxMath.lerp(health, healthLerp, 0.25);

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

		/*while (eventNotes.length > 0 && eventNotes[0][0] >= Conductor.songPosition) {
			var events:Array<Dynamic> = eventNotes[0][1];
			for (event in events)
				triggerEventNote(event[0], event[1], event[2]);

			eventNotes.shift();
		}*/

		super.update(elapsed);

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

			#if discord_rpc
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if discord_rpc
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.85)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.85)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		// iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		// iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		iconP1.x = FlxMath.lerp(healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset), iconP1.x, 0.25);
		iconP2.x = FlxMath.lerp(healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset), iconP2.x, 0.25);

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

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		if (FlxG.keys.justPressed.EIGHT)
		{
			/* 	 8 for opponent char
			   SHIFT+8 for player char
				 CTRL+SHIFT+8 for gf   */
			if (FlxG.keys.pressed.SHIFT)
				if (FlxG.keys.pressed.CONTROL)
					FlxG.switchState(new AnimationDebug(gf.curCharacter));
				else 
					FlxG.switchState(new AnimationDebug(SONG.player1));
			else
				FlxG.switchState(new AnimationDebug(SONG.player2));
		}
		if (FlxG.keys.justPressed.PAGEUP)
			changeSection(1);
		if (FlxG.keys.justPressed.PAGEDOWN)
			changeSection(-1);
		#end

		if (generatedMusic && SONG.notes[Std.int(Conductor.curStep / 16)] != null)
		{
			cameraRightSide = SONG.notes[Std.int(Conductor.curStep / 16)].mustHitSection;

			cameraMovement();
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", Conductor.curBeat);
		FlxG.watch.addQuick("stepShit", Conductor.curStep);

		if (curSong == 'Fresh')
		{
			switch (Conductor.curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (Conductor.curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		if (!inCutscene && !_exiting)
		{
			// RESET = Quick Game Over Screen
			if (controls.RESET)
			{
				health = 0;
				Debug.logTrace("RESET = True");
			}

			#if CAN_CHEAT // brandon's a pussy
			if (controls.CHEAT)
			{
				health += 1;
				Debug.logTrace("User is cheating!");
			}
			#end

			if (health <= 0 && !practiceMode && callOnLuas("onGameOver", [], false) != FunkinLua.Function_Stop) {
				// boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				isDead = true;

				// unloadAssets();

				deathCounter += 1;

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if discord_rpc
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
				#end
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
				var angleDir = strum.direction * Math.PI / 180;
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

				/*if (daNote.copyX)
					daNote.x = (daNote.mustPress ? playerStrums : opponentStrums).members[daNote.noteData].x + daNote.offsetX;*/

				/*if (ClientPrefs.data.downscroll)
					daNote.y = ((daNote.mustPress ? playerStrums : opponentStrums).members[daNote.noteData].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * SONG.speed);
				else
					daNote.y = ((daNote.mustPress ? playerStrums : opponentStrums).members[daNote.noteData].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * SONG.speed);*/

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
		if (combo > 5 && gf.animOffsets.exists('sad'))
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
		for (i in 0...(Std.int(curStep / 16 + sec)))
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

	public function endSong() {
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
			// var screenshotRect:Rectangle = new Rectangle(healthBar.x - 200, healthBar.y - 200, healthBar.width + 400, healthBar.height + 400);

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
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
	
					switch (PlayState.storyWeek) {
						case 7:
							FlxG.switchState(new VideoState());
						default:
							FlxG.switchState(new StoryMenuState());
					}
	
					// if ()
					WeekData.unlocked[Std.int(Math.min(storyWeek + 1, WeekData.unlocked.length - 1))] = true;
	
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
	
					if (SONG.song.toLowerCase() == 'eggnog') {
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;
						inCutscene = true;
	
						FlxG.sound.play(Paths.sound('Lights_Shut_off'), function() {
							// no camFollow so it centers on horror tree
							SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase() + difficulty, storyPlaylist[0]);
							LoadingState.loadAndSwitchState(new PlayState());
						});
					}
					else {
						prevCamFollow = camFollow;
	
						SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase() + difficulty, storyPlaylist[0]);
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			} else {
				Debug.logTrace('WENT BACK TO FREEPLAY??');
				// unloadAssets();
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
			var noteSplash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			noteSplash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
			grpNoteSplashes.add(noteSplash);
		}

		if (!practiceMode)
			songScore += daNote.score;

		var pixelShitPart1:String = isPixelStage ? "weeb/pixelUI/" : "";
		var pixelShitPart2:String = isPixelStage ? "-pixel" : "";

		if (lastRatingCombo == null) {
			lastRatingCombo = new FlxTypedGroup();
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
		// rating.angle = FlxG.random.int(-5, 5);

		lastRatingCombo.add(rating);

		if (isPixelStage)
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
		else {
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
		}
		rating.updateHitbox();

		FlxTween.tween(rating, {"alpha": 0}, 0.2, {onComplete: function(tween:FlxTween) {
			rating.destroy();
		}, startDelay: Conductor.crochet * 0.001});
		// FlxTween.tween(rating, {"scale.x": 0.5, "scale.y": 0.5, "angle": FlxG.random.int(-30, 30)}, 0.15, {startDelay: (0.05 + Conductor.crochet * 0.001)}); // привет анимания

		if (combo >= 10 || combo == 0)
			displayCombo();
	}

	function displayCombo():Void
	{
		var pixelShitPart1:String = isPixelStage ? "weeb/pixelUI/" : "";
		var pixelShitPart2:String = isPixelStage ? "-pixel" : "";

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + "combo" + pixelShitPart2));
		comboSpr.y = FlxG.camera.scroll.y + FlxG.camera.height * 0.4 + 80;
		comboSpr.x = FlxG.width * 0.55;
		// make sure combo is visible lol!
		// 194 fits 4 combo digits
		if (comboSpr.x < FlxG.camera.scroll.x + 194)
			comboSpr.x = FlxG.camera.scroll.x + 194;
		else if (comboSpr.x > FlxG.camera.scroll.x + FlxG.camera.width - comboSpr.width)
			comboSpr.x = FlxG.camera.scroll.x + FlxG.camera.width - comboSpr.width;

		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.velocity.x += FlxG.random.int(1, 10);
		// comboSpr.angle = FlxG.random.int(-2, 2);

		lastRatingCombo.add(comboSpr);

		if (isPixelStage)
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		else {
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		comboSpr.updateHitbox();

		FlxTween.tween(comboSpr, {"alpha": 0 /*, "scale.x": 0.6, "scale.y": 0.6*/}, 0.2, {"onComplete": function(tween:FlxTween) {
				comboSpr.destroy();
			}, "startDelay": Conductor.crochet * 0.001});

		// FlxTween.tween(comboSpr, {"scale.x": 0.5, "scale.y": 0.5, "angle": FlxG.random.int(-8, 8)}, 0.15, {"startDelay": (0.05 + Conductor.crochet * 0.001)});

		var seperatedScore:Array<Int> = [];
		var tempCombo:Int = combo;

		while (tempCombo != 0) {
			seperatedScore.push(tempCombo % 10);
			tempCombo = Std.int(tempCombo / 10);
		}
		while (seperatedScore.length < 3)
			seperatedScore.push(0);

		// seperatedScore.reverse();

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
			// numScore.angle = FlxG.random.int(-3, 3);

			lastRatingCombo.add(numScore);

			FlxTween.tween(numScore, {"alpha": 0}, 0.2, {
				onComplete: function(tween:FlxTween) {
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});
			// FlxTween.tween(numScore, {"scale.x": 0.2, "scale.y": 0.2, "angle": FlxG.random.int(-20, 20)}, 0.15, {startDelay: (0.05 + Conductor.crochet * 0.001)});

			daLoop++;
		}
	}

	public var cameraRightSide:Bool = false;
	public function cameraMovement() {
		var needX:Float = !cameraRightSide ? (dad.getMidpoint().x + 150 + dad.json.camera_position[0]) : (boyfriend.getMidpoint().x - 100 - boyfriend.json.camera_position[0]);
		var needY:Float = !cameraRightSide ? (dad.getMidpoint().y - 100 + dad.json.camera_position[1]) : (boyfriend.getMidpoint().y - 100 + boyfriend.json.camera_position[1]);

		if (camFollowPoint.x != needX || camFollowPoint.y != needY) {
			camFollowPoint.set(needX, needY);

			if (SONG.song.toLowerCase() == "tutorial") {
				if (!cameraRightSide)
					tweenCamIn();
				else
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
			}
		}

		callOnLuas("onMoveCamera", [cameraRightSide ? "boyfriend" : "dad"]);
	}

	var justPressedKey:String;
	var pressedKey:String;
	var justReleasedKey:String;

	function onKeyJustPressed(keyCode:Int) {
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

		if (spr.animation.curAnim.name != "confirm" && spr.animation.curAnim.name != "pressed")
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
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

		/* boyfriend.stunned = true;

		// get stunned for 5 seconds
		new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
		{
			boyfriend.stunned = false;
		}); */

		boyfriend.playAnim(singAnims[direction] + "miss", true);

		recalculateRating(true);

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

		recalculateRating(true);

		callOnLuas("noteMiss", [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	/* not used anymore lol

	function badNoteHit()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var leftP = controls.NOTE_LEFT_P;
		var downP = controls.NOTE_DOWN_P;
		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	} */

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

			boyfriend.playAnim(singAnims[note.noteData], true);

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

		dad.playAnim(singAnims[daNote.noteData] + altAnim, true);

		var time:Float = 0.15;
		if (daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end'))
			time += 0.15;

		strumPlayAnim(true, daNote.noteData, time);

		dad.holdTimer = 0;

		if (SONG.needsVoices)
			@:privateAccess {
				if (vocals._transform != null)
					vocals.volume = 1;
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
			}
			// else
			// Conductor.bpm = SONG.bpm;
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		// HARDCODING FOR MILF ZOOMS!

		if (ClientPrefs.data.cameraZoom)
		{
			if (curSong.toLowerCase() == 'milf' && Conductor.curBeat >= 168 && Conductor.curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (Conductor.curBeat % gfSpeed == 0)
			gf.dance();

		if (Conductor.curBeat % 2 == 0)
		{
			if (!boyfriend.animation.curAnim.name.startsWith("sing"))
				boyfriend.playAnim('idle');
			if (!dad.animation.curAnim.name.startsWith("sing"))
				dad.dance();
		}
		else if (dad.curCharacter == 'spooky')
		{
			if (!dad.animation.curAnim.name.startsWith("sing"))
				dad.dance();
		}

		if (Conductor.curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (Conductor.curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && Conductor.curBeat > 16 && Conductor.curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		setOnLuas("curBeat", Conductor.curBeat);
		callOnLuas("onBeatHit", []);
	}

	override function sectionHit() {
		super.sectionHit();

		if (camZooming) {
			FlxG.camera.zoom += 0.015;
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
		KeyUtils.removeCallback(JUST_PRESSED, justPressedKey);
		KeyUtils.removeCallback(PRESSED, pressedKey);
		KeyUtils.removeCallback(JUST_RELEASED, justReleasedKey);

		super.destroy();
	}

	function reloadHealthBarColors() {
		healthBar.createFilledBar(dad.healthColor, boyfriend.healthColor);
	}

	public function recalculateRating(badHit:Bool = false) {
		setOnLuas("score", songScore);
		setOnLuas("misses", songMisses);
		setOnLuas("hits", noteHits);

		if (callOnLuas("onRecalculateRating", [], false) != FunkinLua.Function_Stop) {
			accuracy = Math.min(1, Math.max(0, noteRatings / noteHits));
			if (Std.string(accuracy) == "-nan(ind)")
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
		} 
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnLuas("accuracy", accuracy);
		setOnLuas("ratingFC", ratingFC);
	}

	public function updateScore(miss:Bool = false) {
		scoreTxt.text = "Score:" + songScore + " | " + "Misses: " + songMisses + " | " + "Accuracy: " + (accuracy == 0 ? "N/A" : Std.string(FlxMath.roundDecimal(accuracy * 100, 2)) + "%") + " | Rating: " + ratingFC;
		scoreTxt.screenCenter(X);

		callOnLuas("onUpdateScore", [miss]);
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
				var gameZoom:Dynamic = Std.parseFloat(value1);
				var hudZoom:Dynamic = Std.parseFloat(value2);
				FlxG.camera.zoom += Math.isNaN(gameZoom) ? gameZoom : 0;
				camHUD.zoom += Math.isNaN(hudZoom) ? hudZoom : 0;
		}
		callOnLuas("onEvent", [eventName, value1, value2]);
	}

	public function addBehindGf(obj:FlxBasic):FlxBasic {
		return insert(members.indexOf(gf), obj);
	}

	public function addBehindDad(obj:FlxBasic):FlxBasic {
		return insert(members.indexOf(dad), obj);
	}

	public function addBehindBoyfriend(obj:FlxBasic):FlxBasic {
		return insert(members.indexOf(boyfriend), obj);
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

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function killNotes() {
		while (notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if (gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			// char.danceEveryNumBeats = 2;
		}
		char.x += char.json.position[0];
		char.y += char.json.position[1];
	}
}