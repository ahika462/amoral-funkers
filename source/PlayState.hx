package;

import flixel.addons.display.FlxRuntimeShader;
import flixel.math.FlxPoint;
import openfl.geom.Rectangle;
import screenshot.Screenshot;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import StageData.StageFile;
import haxe.PosInfos;
import sys.FileSystem;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.Transition;
import Conductor.Rating;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.utils.Assets;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import shaderslmfao.BuildingShaders.BuildingShader;
import shaderslmfao.BuildingShaders;
import shaderslmfao.ColorSwap;

#if discord_rpc
import Discord.DiscordClient;
#end

using StringTools;

class PlayState extends MusicBeatState implements IHScriptable {
	public static var instance:PlayState;
	public var hscripts:Array<HScript> = [];

	// public static var STRUM_X_MIDDLESCROLL = -271;

	public static var curStage:String = '';
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
	var healthLerp:Float;

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

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var foregroundSprites:FlxTypedGroup<BGSprite>;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var gfCutsceneLayer:FlxGroup;
	var bfTankCutsceneLayer:FlxGroup;
	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;

	public var talking:Bool = true;

	public var songScore:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;

	public var accuracy(get, never):Float;
	public var noteHits:Int = 0;
	public var noteRatings:Float = 0;

	public var sickHits:Int = 0;
	public var goodHits:Int = 0;
	public var badHits:Int = 0;
	public var shitHits:Int = 0;
	public var ratingFC(get, never):String;

	function get_accuracy():Float {
		var returnVal:Float = CoolUtil.floorDecimal(Math.min(1, Math.max(0, noteRatings / noteHits)) * 100, 2);
		if (returnVal < 0)
			returnVal = 0;
		
		return returnVal;
	}

	function get_ratingFC():String {
		var returnVal:String = "N/A";
		
		if (sickHits > 0)
			returnVal = "SFC";
		if (goodHits > 0)
			returnVal = "GFC";
		if (badHits > 0 || shitHits > 0)
			returnVal = "FC";
		if (songMisses > 0)
			returnVal = "SDCB";
		if (songMisses >= 10)
			returnVal = "Clear";

		return returnVal;
	}

	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	public var inCutscene:Bool = false;

	#if discord_rpc
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	var lightFadeShader:BuildingShaders;

	public static var singAnims:Array<String> = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];

	public static var isPixelStage:Bool = false;

	#if AMORAL
	var missEffect:MissEffect;
	#end

	var timeSpectrum:TimeSpectrum;

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
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;

		foregroundSprites = new FlxTypedGroup<BGSprite>();

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		#if discord_rpc
		initDiscord();
		#end

		curStage = switch(SONG.song.toLowerCase()) {
			case "spookeez" | "south" | "monster": "spooky";
			case "pico" | "philly" | "blammed": "philly";
			case "satin-panties" | "high" | "milf": "limo";
			case "cocoa" | "eggnog": "mall";
			case "winter-horrorland": "mallEvil";
			case "senpai"| "roses": "school";
			case "thorns": "schoolEvil";
			case "ugh" | "guns" | "stress": "tank";
			default: "stage";
		}
		var stageFile:StageFile = StageData.get(curStage);
		defaultCamZoom = stageFile.zoom;
		isPixelStage = stageFile.pixel;

		switch(curStage) {
			case "philly":

				/*var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);*/

				var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				lightFadeShader = new BuildingShaders();
				phillyCityLights = new FlxTypedGroup<FlxSprite>();

				add(phillyCityLights);

				for (i in 0...5)
				{
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = true;
					light.shader = lightFadeShader.shader;
					phillyCityLights.add(light);
				}

				var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
				add(streetBehind);

				phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

				var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
				add(street);
			case "limo":
				var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
				skyBG.scrollFactor.set(0.1, 0.1);
				add(skyBG);

				var bgLimo:FlxSprite = new FlxSprite(-200, 480);
				bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.scrollFactor.set(0.4, 0.4);
				add(bgLimo);

				grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
				add(grpLimoDancers);

				for (i in 0...5)
				{
					var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
					dancer.scrollFactor.set(0.4, 0.4);
					grpLimoDancers.add(dancer);
				}

				var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
				overlayShit.alpha = 0.5;
				// add(overlayShit);
				// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);
				// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);
				// overlayShit.shader = shaderBullshit;

				limo = new FlxSprite(-120, 550);
				limo.frames = Paths.getSparrowAtlas('limo/limoDrive');
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = true;

				fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
			// add(limo);

			case "mall":
				var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				upperBoppers = new FlxSprite(-240, -90);
				upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
				upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
				upperBoppers.antialiasing = true;
				upperBoppers.scrollFactor.set(0.33, 0.33);
				upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
				upperBoppers.updateHitbox();
				add(upperBoppers);

				var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
				bgEscalator.antialiasing = true;
				bgEscalator.scrollFactor.set(0.3, 0.3);
				bgEscalator.active = false;
				bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
				bgEscalator.updateHitbox();
				add(bgEscalator);

				var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
				tree.antialiasing = true;
				tree.scrollFactor.set(0.40, 0.40);
				add(tree);

				bottomBoppers = new FlxSprite(-300, 140);
				bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
				bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
				bottomBoppers.antialiasing = true;
				bottomBoppers.scrollFactor.set(0.9, 0.9);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
				fgSnow.active = false;
				fgSnow.antialiasing = true;
				add(fgSnow);

				santa = new FlxSprite(-840, 150);
				santa.frames = Paths.getSparrowAtlas('christmas/santa');
				santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
				santa.antialiasing = true;
				add(santa);

			case "mallEvil":
				var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
				evilTree.antialiasing = true;
				evilTree.scrollFactor.set(0.2, 0.2);
				add(evilTree);

				var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
				evilSnow.antialiasing = true;
				add(evilSnow);

			case "school":
				// defaultCamZoom = 0.9;

				var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
				bgSky.scrollFactor.set(0.1, 0.1);
				add(bgSky);

				var repositionShit = -200;

				var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
				bgSchool.scrollFactor.set(0.6, 0.90);
				add(bgSchool);

				var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
				bgStreet.scrollFactor.set(0.95, 0.95);
				add(bgStreet);

				var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
				fgTrees.scrollFactor.set(0.9, 0.9);
				add(fgTrees);

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				var treetex = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.frames = treetex;
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);

				var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
				treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
				treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				treeLeaves.animation.play('leaves');
				treeLeaves.scrollFactor.set(0.85, 0.85);
				add(treeLeaves);

				var widShit = Std.int(bgSky.width * 6);

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				fgTrees.setGraphicSize(Std.int(widShit * 0.8));
				treeLeaves.setGraphicSize(widShit);

				fgTrees.updateHitbox();
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				treeLeaves.updateHitbox();

				bgGirls = new BackgroundGirls(-100, 190);
				bgGirls.scrollFactor.set(0.9, 0.9);

				if (SONG.song.toLowerCase() == 'roses')
				{
					bgGirls.getScared();
				}

				bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
				bgGirls.updateHitbox();
				add(bgGirls);
				
			case "schoolEvil":
				var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
				var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

				var posX = 400;
				var posY = 200;

				var bg:FlxSprite = new FlxSprite(posX, posY);
				bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
				bg.animation.addByPrefix('idle', 'background 2', 24);
				bg.animation.play('idle');
				bg.scrollFactor.set(0.8, 0.9);
				bg.scale.set(6, 6);
				add(bg);

			/* 
				var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
				bg.scale.set(6, 6);
				// bg.setGraphicSize(Std.int(bg.width * 6));
				// bg.updateHitbox();
				add(bg);

				var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
				fg.scale.set(6, 6);
				// fg.setGraphicSize(Std.int(fg.width * 6));
				// fg.updateHitbox();
				add(fg);

				wiggleShit.effectType = WiggleEffectType.DREAMY;
				wiggleShit.waveAmplitude = 0.01;
				wiggleShit.waveFrequency = 60;
				wiggleShit.waveSpeed = 0.8;
			 */

			// bg.shader = wiggleShit.shader;
			// fg.shader = wiggleShit.shader;

			/* 
				var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
				var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

				// Using scale since setGraphicSize() doesnt work???
				waveSprite.scale.set(6, 6);
				waveSpriteFG.scale.set(6, 6);
				waveSprite.setPosition(posX, posY);
				waveSpriteFG.setPosition(posX, posY);

				waveSprite.scrollFactor.set(0.7, 0.8);
				waveSpriteFG.scrollFactor.set(0.9, 0.8);

				// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
				// waveSprite.updateHitbox();
				// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
				// waveSpriteFG.updateHitbox();

				add(waveSprite);
				add(waveSpriteFG);
			 */

			case "tank":
				var bg:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
				add(bg);

				var tankSky:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
				tankSky.active = true;
				tankSky.velocity.x = FlxG.random.float(5, 15);
				add(tankSky);

				var tankMountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
				tankMountains.setGraphicSize(Std.int(tankMountains.width * 1.2));
				tankMountains.updateHitbox();
				add(tankMountains);

				var tankBuildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.30, 0.30);
				tankBuildings.setGraphicSize(Std.int(tankBuildings.width * 1.1));
				tankBuildings.updateHitbox();
				add(tankBuildings);

				var tankRuins:BGSprite = new BGSprite('tankRuins', -200, 0, 0.35, 0.35);
				tankRuins.setGraphicSize(Std.int(tankRuins.width * 1.1));
				tankRuins.updateHitbox();
				add(tankRuins);

				var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
				add(smokeLeft);

				var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
				add(smokeRight);

				// tankGround.

				tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
				add(tankWatchtower);

				tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5, ['BG tank w lighting'], true);
				add(tankGround);
				// tankGround.active = false;

				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);

				var tankGround:BGSprite = new BGSprite('tankGround', -420, -150);
				tankGround.setGraphicSize(Std.int(tankGround.width * 1.15));
				tankGround.updateHitbox();
				add(tankGround);

				moveTank();

				// smokeLeft.screenCenter();

				var fgTank0:BGSprite = new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']);
				foregroundSprites.add(fgTank0);

				var fgTank1:BGSprite = new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']);
				foregroundSprites.add(fgTank1);

				// just called 'foreground' just cuz small inconsistency no bbiggei
				var fgTank2:BGSprite = new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']);
				foregroundSprites.add(fgTank2);

				var fgTank4:BGSprite = new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']);
				foregroundSprites.add(fgTank4);

				var fgTank5:BGSprite = new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']);
				foregroundSprites.add(fgTank5);

				var fgTank3:BGSprite = new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']);
				foregroundSprites.add(fgTank3);
		}

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school' | 'schoolEvil':
				gfVersion = 'gf-pixel';
			case 'tank':
				gfVersion = 'gf-tankmen';
		}

		if (SONG.song.toLowerCase() == 'stress')
			gfVersion = 'pico-speaker';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		switch (gfVersion)
		{
			case 'pico-speaker':
				var tempTankman:TankmenBG = new TankmenBG(20, 500, true);
				tempTankman.strumTime = 10;
				tempTankman.resetShit(20, 600, true);
				tankmanRun.add(tempTankman);

				for (i in 0...TankmenBG.animationNotes.length)
				{
					if (FlxG.random.bool(16))
					{
						var tankman:TankmenBG = tankmanRun.recycle(TankmenBG);
						// new TankmenBG(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
						tankman.strumTime = TankmenBG.animationNotes[i][0];
						tankman.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
						tankmanRun.add(tankman);
					}
				}
		}

		dad = new Character(100, 100, SONG.player2);

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

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camFollow.x += 600;
					tweenCamIn();
				}
			case 'dad':
				camFollow.x += 400;
			case 'pico':
				camFollow.x += 600;
			case 'senpai' | 'senpai-angry':
				camFollow.setPosition(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				camFollow.setPosition(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		gf.x += stageFile.gf[0] + gf.json.position[0];
		gf.y += stageFile.gf[1] + gf.json.position[1];

		dad.x += stageFile.dad[0] + dad.json.position[0];
		dad.y += stageFile.dad[1] + dad.json.position[1];
		
		boyfriend.x += stageFile.boyfriend[0] + boyfriend.json.position[0];
		boyfriend.y += stageFile.boyfriend[1] + boyfriend.json.position[1];

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				resetFastCar();
				add(fastCar);
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);
			case "tank":
				if (gfVersion != 'pico-speaker')
				{
					gf.x -= 170;
					gf.y -= 75;
				}
		}

		add(gf);

		gfCutsceneLayer = new FlxGroup();
		add(gfCutsceneLayer);

		bfTankCutsceneLayer = new FlxGroup();
		add(bfTankCutsceneLayer);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		add(foregroundSprites);

		for (file in Paths.getEmbedFiles("scripts")) {
			if (file.endsWith(".hx"))
				hscripts.push(new HScript(file, instance));
		}

		if (Paths.embedExists("scripts/stages/" + curStage + ".hx"))
            hscripts.push(new HScript(Paths.getEmbedShit("scripts/stages/" + curStage + ".hx"), instance));

		callOnScripts("pre_create");

		timeSpectrum = new TimeSpectrum();
		timeSpectrum.cameras = [camTime];
		add(timeSpectrum);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

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
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);
		recalculateRatings();

		grpNoteSplashes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode && !seenCutscene)
		{
			seenCutscene = true;

			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					schoolIntro(doof);
				case 'ugh':
					ughIntro();
				case 'stress':
					stressIntro();
				case 'guns':
					gunsIntro();

				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				// REMOVE THIS LATER
				// case 'ugh':
				// 	ughIntro();
				// case 'stress':
				// 	stressIntro();
				// case 'guns':
				// 	gunsIntro();

				default:
					startCountdown();
			}
		} 

		// input fix
		justPressedKey = KeyUtils.addCallback(JUST_PRESSED, onKeyJustPressed);
		pressedKey = KeyUtils.addCallback(PRESSED, onKeyPressed);
		justReleasedKey = KeyUtils.addCallback(JUST_RELEASED, onKeyJustReleased);

		/*eventNotes = SONG.events;
		eventNotes.sort(sortEventNotes);*/

		#if AMORAL
		missEffect = new MissEffect();
		// add(missEffect);

		// FlxG.camera.setFilters([new ShaderFilter(missEffect.shader)]);
		#end

		callOnScripts();

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

	function startCountdown():Void
	{
		if (callOnScripts("pre_startCountdown") != HScript.Function_Stop) {
			inCutscene = false;
			camHUD.visible = true;

			generateStaticArrows(0);
			generateStaticArrows(1);

			talking = false;
			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;

			callOnScripts();

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

		callOnScripts([path]);
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		if (callOnScripts() != HScript.Function_Stop) {
			startingSong = false;

			previousFrameTime = FlxG.game.ticks;

			if (!paused && !isDead)
				FlxG.sound.playMusic(Paths.inst(SONG.song), 1, false);
			FlxG.sound.music.onComplete = endSong;
			Conductor.followSound = FlxG.sound.music;
			vocals.play();

			#if discord_rpc
			// Song duration in a float, useful for the time left feature
			songLength = FlxG.sound.music.length;

			// Updating Discord Rich Presence (with Time Left)
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
			#end
		}
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
		if (callOnScripts([SubState]) != HScript.Function_Stop) {
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
	}

	override function closeSubState()
	{
		if (callOnScripts() != HScript.Function_Stop) {
			if (paused) {
				if (FlxG.sound.music != null && !startingSong)
					resyncVocals();
	
				if (!startTimer.finished)
					startTimer.active = true;
				paused = false;
	
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

		callOnScripts("pre_update", [elapsed]);

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

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}

				lightFadeShader.update((Conductor.crochet / 1000) * FlxG.elapsed * 1.5);
			// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;

			case 'tank':
				moveTank();
		}

		healthLerp = FlxMath.lerp(health, healthLerp, 0.25);

		while (eventNotes.length > 0 && eventNotes[0][0] >= Conductor.songPosition) {
			triggerEventNote(eventNotes[0][1], eventNotes[0][2], eventNotes[0][3]);
			eventNotes.shift();
		}

		super.update(elapsed);

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			/*if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else*/
			{
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

			if (health <= 0 && !practiceMode)
			{
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

				if (daNote.copyX)
					daNote.x = (daNote.mustPress ? playerStrums : opponentStrums).members[daNote.noteData].x + daNote.offsetX;

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

		callOnScripts([elapsed]);
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

	function endSong():Void
	{
		if (callOnScripts() != HScript.Function_Stop) {
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

			if (isStoryMode)
			{
				campaignScore += songScore;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					switch (PlayState.storyWeek)
					{
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
				}
				else
				{
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

					if (SONG.song.toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;
						inCutscene = true;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'), function()
						{
							// no camFollow so it centers on horror tree
							SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase() + difficulty, storyPlaylist[0]);
							LoadingState.loadAndSwitchState(new PlayState());
						});
					}
					else
					{
						prevCamFollow = camFollow;

						SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase() + difficulty, storyPlaylist[0]);
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
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

		lastRatingCombo.add(rating);

		if (isPixelStage)
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
		else {
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
		}
		rating.updateHitbox();

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween) {
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
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

		lastRatingCombo.add(comboSpr);

		if (isPixelStage)
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		else {
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		comboSpr.updateHitbox();

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween) {
				comboSpr.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

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

			lastRatingCombo.add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween) {
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
	}

	var cameraRightSide:Bool = false;

	function cameraMovement()
	{
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


		callOnScripts([cameraRightSide]);
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

			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

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
			else
				noteMissPress(keyID);
		}

		var spr:StrumNote = playerStrums.members[keyID];

		if (spr == null)
			return;

		if (spr.animation.curAnim.name != "confirm")
			spr.playAnim("pressed");

		callOnScripts([keyCode]);
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

		callOnScripts([keyCode]);
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

		callOnScripts([keyCode]);
	}

	function noteMissPress(direction:Int = 1) {
		if (ClientPrefs.data.ghostTapping)
			return;
		
		#if AMORAL
		missEffect.percent = 0.5;
		#end

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

		recalculateRatings();

		callOnScripts([direction]);
	}

	function noteMiss(daNote:Note) {
		#if AMORAL
		// missEffect.percent = 0.5;
		#end
		
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

		recalculateRatings();

		callOnScripts([daNote]);
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

		recalculateRatings();

		callOnScripts([note]);
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

		recalculateRatings();

		callOnScripts([daNote]);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	function moveTank():Void
	{
		if (!inCutscene)
		{
			var daAngleOffset:Float = 1;
			tankAngle += FlxG.elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;

			tankGround.x = tankX + Math.cos(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1500;
			tankGround.y = 1300 + Math.sin(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1100;
		}
	}

	var tankResetShit:Bool = false;
	var tankMoving:Bool = false;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX:Float = 400;

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	override function stepHit()
	{
		super.stepHit();

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}
		
		callOnScripts();
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
		wiggleShit.update(Conductor.crochet);

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

		foregroundSprites.forEach(function(spr:BGSprite)
		{
			spr.dance();
		});

		// boppin friends
		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (Conductor.curBeat % 4 == 0)
				{
					lightFadeShader.reset();

					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (Conductor.curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
			case 'tank':
				tankWatchtower.dance();
		}

		callOnScripts();
	}

	override function sectionHit() {
		super.sectionHit();

		if (camZooming) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		callOnScripts();
	}

	var curLight:Int = 0;

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

		callOnScripts();
		for (hscript in hscripts)
			hscript.destroy();

		super.destroy();
	}

	function reloadHealthBarColors() {
		healthBar.createFilledBar(dad.healthColor, boyfriend.healthColor);
	}

	function recalculateRatings() {
		scoreTxt.text = "Score:" + songScore + " | " + "Misses: " + songMisses + " | " + "Accuracy: " + accuracy + "% | Rating: " + ratingFC;
		scoreTxt.screenCenter(X);

		callOnScripts();
	}

	public function callOnScripts(?name:String = null, ?args:Array<Dynamic> = null, allowNull:Bool = false, ?pos:PosInfos):Dynamic {
		var returnVal:Dynamic = HScript.Function_Continue;

		for (hscript in hscripts) {
			var funcReturn:Dynamic = hscript.call(name, args, pos);
			if (funcReturn != HScript.Function_Continue) {
				if (funcReturn != null || allowNull)
					returnVal = funcReturn;
			}
		}

		return returnVal;
	}

	public function setOnHScripts(name:String, value:Dynamic):Dynamic {
		for (hscript in hscripts)
			hscript.set(name, value);

		return value;
	}

	public function triggerEventNote(name:String, value1:String, value2:String) {
		switch(name) {
			case "Add Camera Zoom":
				var gameZoom:Dynamic = Std.parseFloat(value1);
				var hudZoom:Dynamic = Std.parseFloat(value2);
				FlxG.camera.zoom += Math.isNaN(gameZoom) ? gameZoom : 0;
				camHUD.zoom += Math.isNaN(hudZoom) ? hudZoom : 0;
		}
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
}