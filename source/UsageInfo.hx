import openfl.filters.DropShadowFilter;
import flixel.FlxG;
import flixel.util.FlxColor;
import openfl.system.System;
import openfl.display.FPS;

class UsageInfo extends FPS {
    public function new(x:Float = 10, y:Float = 10) {
        super(x, y, 0xFFFFFFFF);
        width = FlxG.width;
        filters = [new DropShadowFilter(2, 45, 0xFF000000, 1, 3, 3)];
    }

    override function __enterFrame(deltaTime:Float) {
        super.__enterFrame(deltaTime);
        
        var currentMem:Float = Math.round(System.totalMemory / 1e+6);
        var currentGpu:Float = Math.round(FlxG.stage.context3D.totalGPUMemory / 1e+6);

        text = "FPS: " + currentFPS + "\n";
        text += "Memory: " + (currentMem < 0 ? "Leaking " : "") + Math.abs(currentMem) + " MB\n";
        text += "GPU Memory: " + (currentGpu < 0 ? "Leaking " : "") + Math.abs(currentGpu) + " MB\n";
        // text += "Memory: " + currentMem < 0 ? ("Leaking " + Math.abs(currentMem) + " MB\n") : (currentMem + " MB\n");
        // text += currentGpu < 0 ? ("GPU Memory: Leaking " + Math.abs(currentGpu) + " MB\n") : ("GPU Memory: " + currentGpu + " MB\n");
    }
}