#if sys
import sys.io.Process;
import sys.FileSystem;
#end
import flixel.FlxState;
import lime.app.Application;
#if discord_rpc
import Discord.DiscordClient;
#end
import flixel.FlxG;
import haxe.io.Path;
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
		#if sys
		if (Sys.args()[0] != null)
			Sys.setCwd(Sys.args()[0]);
		#end

		Debug.initialize();
		
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

	public static var fpsCounter:MemFPS;

	private function setupGame() {
		Conductor.init();

		addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		#if !mobile
		fpsCounter = new MemFPS(10, 3, 0xFFFFFF);
		FlxG.game.addChild(fpsCounter);
		#end

		#if sys
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	function onCrash(e:UncaughtErrorEvent) {
		var crashDump:String = Debug.logCrash(e);
		#if sys
		Application.current.window.alert(crashDump, "AMORAL ENGINE DEBUG");
		Sys.exit(1);
		#end
	}
}