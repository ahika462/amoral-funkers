import flixel.math.FlxPoint;
import lime.app.Application;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.Lib;

class Main {
    static function main() {
        Lib.current.addChild(new FlxGame(1280, 730, MainState, 60, 60, true, false));
        FlxG.mouse.useSystemCursor = true;
        FlxG.autoPause = false;

        Application.current.window.onFullscreen.add(function() {
            Application.current.window.minimized = true;
            Application.current.window.fullscreen = false;
        });
    }
}