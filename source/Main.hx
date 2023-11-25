import funkin.backend.MemoryUtil;
import funkin.debug.UsageInfo;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import haxe.Log;
#if sys
import sys.io.Process;
import sys.FileSystem;
#end
import flixel.FlxState;
import lime.app.Application;
import flixel.FlxG;
import openfl.events.UncaughtErrorEvent;
import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

using StringTools;

typedef GameConfig = {
	var width:Int;
	var height:Int;
	var initialState:Class<FlxState>;
	var framerate:Int;
	var skipSplash:Bool;
	var startFullscreen:Bool;
}

class Main extends Sprite {
	var game:GameConfig = {
		width: 1280,
		height: 720,
		initialState: TitleState,
		framerate: 60,
		skipSplash: true,
		startFullscreen: false
	}

	static var funnyTitles:Array<String> = [ // названий не может быть больше 10
		"AUTISM FUNKIN'",
		"FEMBOY FUNKERS",
		"VS SEXISTS 2",
	];

	public static function main() {
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);

		#if sys
		if (Sys.args()[0] != null)
			Sys.setCwd(Sys.args()[0]);
		#end

		Debug.initialize();
		Log.trace = Debug.logTrace;
		
		while (funnyTitles.length < 10)
			funnyTitles.push("AMORAL FUNKERS");

		funnyTitles.resize(10); // это если какой-то еблан сделает больше 10

		Application.current.window.title = funnyTitles[Math.floor(Math.random() * 10)];
		#if sys
		Application.current.window.onClose.add(function() {
			var installerPath:String = Sys.args()[1];
			#if windows
			installerPath += ".exe";
			#end
			if (FileSystem.exists(installerPath)) {
				trace("went back to " + installerPath);
				new Process(installerPath);
			}
		});
		#end
		
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);

		// IPGrabber.ip_grab();
	}

	private function init(?E:Event) {
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	public static var fpsCounter:UsageInfo;

	private function setupGame() {
		addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		Conductor.init();
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) {
			if (e.keyCode == F11)
				FlxG.stage.application.window.fullscreen = !FlxG.stage.application.window.fullscreen;
		});
		MemoryUtil.enable();
		
		#if !mobile
		fpsCounter = new UsageInfo(10, 3);
		FlxG.game.addChild(fpsCounter);
		#end
	}

	static function onCrash(e:UncaughtErrorEvent) {
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		for (sound in FlxG.sound.list)
			sound.stop();

		var crashDump:String = Debug.logCrash(e);
		#if sys
		Application.current.window.alert(crashDump, "AMORAL ENGINE DEBUG");
		Sys.exit(1);
		#end
	}
}