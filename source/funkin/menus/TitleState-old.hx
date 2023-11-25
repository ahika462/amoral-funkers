package funkin.menus;

import funkin.backend.PlayerSettings;
import funkin.data.WeekData;
import funkin.Alphabet;
import funkin.MusicBeatState;
import funkin.backend.Highscore;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.ui.Window;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.AsyncErrorEvent;
import openfl.events.AsyncErrorEvent;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.NetStatusEvent;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;
import funkin.shaders.ColorSwap;

using StringTools;

import funkin.backend.Discord.DiscordClient;
#if desktop
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;
#end

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;
	var startedIntro:Bool;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];
	var wackyImage:FlxSprite;
	var lastBeat:Int = 0;
	var swagShader:ColorSwap;
	var thingie:FlxSprite;

	var video:Video;
	var netStream:NetStream;
	private var overlay:Sprite;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		startedIntro = false;

		FlxG.game.focusLostFramerate = 60;

		swagShader = new ColorSwap();

		FlxG.sound.muteKeys = [ZERO];

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();
		PlayerSettings.init();
		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (WeekData.unlocked.length < 4)
				WeekData.unlocked.insert(0, true);

			WeekData.unlocked[0] = true;
		}

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		/*#elseif ANIMATE
		FlxG.switchState(new CutsceneAnimTestState());*/
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		/* 
			#elseif web


			if (!initialized)
			{

				video = new Video();
				FlxG.stage.addChild(video);

				var netConnection = new NetConnection();
				netConnection.connect(null);

				netStream = new NetStream(netConnection);
				netStream.client = {onMetaData: client_onMetaData};
				netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, netStream_onAsyncError);
				netConnection.addEventListener(NetStatusEvent.NET_STATUS, netConnection_onNetStatus);
				// netStream.addEventListener(NetStatusEvent.NET_STATUS) // netStream.play(Paths.file('music/kickstarterTrailer.mp4'));

				overlay = new Sprite();
				overlay.graphics.beginFill(0, 0.5);
				overlay.graphics.drawRect(0, 0, 1280, 720);
				overlay.addEventListener(MouseEvent.MOUSE_DOWN, overlay_onMouseDown);

				overlay.buttonMode = true;
				// FlxG.stage.addChild(overlay);

			}
		 */

		// netConnection.addEventListener(MouseEvent.MOUSE_DOWN, overlay_onMouseDown);
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end

		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
	}

	private function client_onMetaData(metaData:Dynamic)
	{
		video.attachNetStream(netStream);

		video.width = video.videoWidth;
		video.height = video.videoHeight;
		// video.
	}

	private function netStream_onAsyncError(event:AsyncErrorEvent):Void
	{
		Debug.logTrace("Error loading video");
	}

	private function netConnection_onNetStatus(event:NetStatusEvent):Void
	{
		if (event.info.code == 'NetStream.Play.Complete')
		{
			// netStream.dispose();
			// FlxG.stage.removeChild(video);

			startIntro();
		}

		Debug.logTrace(event.toString());
	}

	private function overlay_onMouseDown(event:MouseEvent):Void
	{
		netStream.soundTransform.volume = 0.2;
		netStream.soundTransform.pan = -1;
		// netStream.play(Paths.file('music/kickstarterTrailer.mp4'));

		FlxG.stage.removeChild(overlay);
	}

	var logoBl:FlxSprite;

	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.bpm = 102;
		// Conductor.followSound = FlxG.sound.music;
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = true;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();

		add(bg);

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');

		logoBl.updateHitbox();

		logoBl.shader = swagShader.shader;

		// Debug.logTrace();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);

		gfDance.shader = swagShader.shader;

		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		/*var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = true;
		add(logo);*/

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		// var atlasBullShit:FlxSprite = new FlxSprite();
		// atlasBullShit.frames = CoolUtil.fromAnimate(Paths.image('money'), Paths.file('images/money.json'));
		// credGroup.add(atlasBullShit);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52, Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		startedIntro = true;
		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				pressedEnter = true;
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.onComplete = null;
			// netStream.play(Paths.file('music/kickstarterTrailer.mp4'));

			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(1, function(tmr:FlxTimer) {
				FlxG.switchState(new MainMenuState());
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro && initialized)
			skipIntro();
		/* 
			#if web
			if (!initialized && controls.ACCEPT)
			{
				// netStream.dispose();
				// FlxG.stage.removeChild(video);

				startIntro();
				skipIntro();
			}
			#end
		 */

		// if (FlxG.keys.justPressed.SPACE)
		// swagShader.hasOutline = !swagShader.hasOutline;

		if (controls.UI_LEFT)
			swagShader.hue -= elapsed * 0.1;

		if (controls.UI_RIGHT)
			swagShader.hue += elapsed * 0.1;

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	var isRainbow:Bool = false;

	override function beatHit()
	{
		super.beatHit();
		
		if (!startedIntro)
			return ;

		if (skippedIntro)
		{
			logoBl.animation.play('bump', true);

			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}
		else
		{
			FlxG.log.add(Conductor.curBeat);
			// if the user is draggin the window some beats will
			// be missed so this is just to compensate
			if (Conductor.curBeat > lastBeat)
			{
				for (i in lastBeat...Conductor.curBeat)
				{
					switch (i + 1)
					{
						case 1:
							createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
						// credTextShit.visible = true;
						case 3:
							addMoreText('present');
						// credTextShit.text += '\npresent...';
						// credTextShit.addText();
						case 4:
							deleteCoolText();
						// credTextShit.visible = false;
						// credTextShit.text = 'In association \nwith';
						// credTextShit.screenCenter();
						case 5:
							createCoolText(['In association', 'with']);
						case 7:
							addMoreText('newgrounds');
							ngSpr.visible = true;
						// credTextShit.text += '\nNewgrounds';
						case 8:
							deleteCoolText();
							ngSpr.visible = false;
						// credTextShit.visible = false;

						// credTextShit.text = 'Shoutouts Tom Fulp';
						// credTextShit.screenCenter();
						case 9:
							createCoolText([curWacky[0]]);
						// credTextShit.visible = true;
						case 11:
							addMoreText(curWacky[1]);
						// credTextShit.text += '\nlmao';
						case 12:
							deleteCoolText();
						// credTextShit.visible = false;
						// credTextShit.text = "Friday";
						// credTextShit.screenCenter();
						case 13:
							addMoreText('Friday');
						// credTextShit.visible = true;
						case 14:
							addMoreText('Night');
						// credTextShit.text += '\nNight';
						case 15:
							addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

						case 16:
							skipIntro();
					}
				}
			}
			lastBeat = Conductor.curBeat;
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}