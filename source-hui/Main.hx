import haxe.CallStack;
import funkin.backend.controls.PlayerSettings;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import funkin.backend.debug.DisplayUsage;
import flixel.FlxGame;
import funkin.backend.Utils;
#if sys
import sys.io.Process;
import sys.FileSystem;
#end
import funkin.backend.beat.Conductor;
import openfl.events.UncaughtErrorEvent;
import flixel.FlxG;
import funkin.backend.debug.Log;
import flixel.FlxState;

class Main {
    static var game:{width:Int, height:Int, initialState:Class<FlxState>, framerate:Int, skipSplash:Bool, startFullscreen:Bool} = {
        width: 1280,
        height: 720,
        initialState: funkin.menus.TitleState,
        framerate: 60,
        skipSplash: true,
        startFullscreen: false
    };

    static function main() {
        haxe.Log.trace = Log.trace;
        FlxG.stage.loaderInfo.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);

        #if sys
        function doSys() {
            var args:Array<String> = Sys.args();
            if (args == null || args.length == 0)
                return;
            
            if (args[0] != null)
                Sys.setCwd(args[0]);
    
            FlxG.stage.application.window.onClose.add(function() {
                var installerPath:String = args[1];
                #if windows
                installerPath += ".exe";
                #end
                if (FileSystem.exists(installerPath))
                    new Process(installerPath);
            });
        }
		#end

        FlxG.stage.application.window.title = Utils.array.resize([
            "AUTISM FUNKIN'",
            "FEMBOY FUNKERS",
            "VS SEXISTS 2",
        ], 10, "AMORAL FUNKERS")[FlxG.random.int(0, 10)];

        FlxG.stage.addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
        FlxG.game.addChild(new DisplayUsage(10, 3, 0xFFFFFFFF));

        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) {
			if (e.keyCode == F11)
				FlxG.stage.application.window.fullscreen = !FlxG.stage.application.window.fullscreen;
		});

        PlayerSettings.init();
    }

    static function onUncaughtError(e:UncaughtErrorEvent) {
        if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		for (sound in FlxG.sound.list)
			sound.stop();

        var errMsg:String = "";
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
        for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Log.log(Std.string(stackItem));
			}
		}
        errMsg += "\nUncaught Error: " + e.error;

        FlxG.stage.application.window.alert(errMsg, "Error!");

        Log.log(errMsg);
        Sys.exit(1);
    }
}