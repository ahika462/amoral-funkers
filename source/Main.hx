import flixel.FlxState;
import lime.app.Application;
#if sys
import Discord.DiscordClient;
import flixel.FlxG;
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import haxe.CallStack;
import openfl.events.UncaughtErrorEvent;
#end

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
		"AUTISM FUNKIN",
		"FEMBOY FUNKERS",
		"VS SEXISTS 2"
	];

	public static function main() {
		while (funnyTitles.length < 10)
			funnyTitles.push("AMORAL FUNKERS");

		funnyTitles.resize(10); // это если какой-то еблан сделает больше 10

		Application.current.window.title = funnyTitles[Math.floor(Math.random() * 10)];
		
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
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
		addChild(fpsCounter);
		#end

		#if sys
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	#if sys
	function onCrash(?e:UncaughtErrorEvent) {
		var errMsg:String = "";
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "'");
		var path:String = "./crashes/Crash_" + dateNow + ".txt";

		for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error;

		if (!FileSystem.exists("./crashes/"))
			FileSystem.createDirectory("./crashes/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

        FlxG.stage.application.window.alert(errMsg, "Error!");

		#if discord_rpc
		DiscordClient.shutdown();
		#end
		Sys.exit(1);
	}
	#end
}