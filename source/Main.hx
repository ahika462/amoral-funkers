package;

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
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;

using StringTools;

class Main extends Sprite {
	var game = {
		width: 1280,
		height: 720,
		initialState: TitleState,
		framerate: 60,
		skipSplash: true,
		startFullscreen: false
	}

	public static function main() {
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

	public static var fpsCounter:FPS;

	private function setupGame() {
		addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		#if !mobile
		fpsCounter = new FPS(10, 3, 0xFFFFFF);
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

		/*new Process("crash-dialog.exe", [Std.string(e.error),
			Std.string(Std.int(FlxG.stage.application.window.display.bounds.width / 5)),
			Std.string(Std.int(FlxG.stage.application.window.display.bounds.height / 2)),
		path]);*/

		#if discord_rpc
		DiscordClient.shutdown();
		#end
		Sys.exit(1);
	}
	#end
}
