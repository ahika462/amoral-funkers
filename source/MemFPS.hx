import flixel.FlxG;
import flixel.util.FlxColor;
import openfl.system.System;
import openfl.display.FPS;

class MemFPS extends FPS {
    public function new(x:Float = 10, y:Float = 10, color:FlxColor = FlxColor.BLACK) {
        super(x, y, color);
        width = FlxG.width;
    }

    override function __enterFrame(deltaTime:Float) {
        super.__enterFrame(deltaTime);
        
        var currentMem:Float = Math.round(System.totalMemory / (1e+6));

        text = "FPS: " + currentFPS + "\n";
        text += currentMem < 0 ? ("Memory: Leaking " + Math.abs(currentMem) + " MB\n") : ("Memory: " + currentMem + " MB\n");
    }
}