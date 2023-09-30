import openfl.system.System;
import openfl.display.FPS;

class MemFPS extends FPS {
    override function __enterFrame(deltaTime:Float) {
        super.__enterFrame(deltaTime);
        
        var currentMem:Float = Math.round(System.totalMemory / (1e+6));

        text = "FPS: " + currentFPS + "\n";
        text += currentMem < 0 ? "Memory: Leaking " + Math.abs(currentMem) + " MB\n" : "Memory: " + currentMem + " MB\n";
    }
}