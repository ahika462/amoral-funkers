package funkin.debug;

import funkin.backend.MemoryUtil;
import openfl.filters.DropShadowFilter;
import flixel.FlxG;
import openfl.display.FPS;

class UsageInfo extends FPS {
    public function new(x:Float = 10, y:Float = 10) {
        super(x, y, 0xFFFFFFFF);
        width = FlxG.width;
        filters = [new DropShadowFilter(2, 45, 0xFF000000, 1, 3, 3)];
    }

    override function __enterFrame(deltaTime:Float) {
        super.__enterFrame(deltaTime);
        
        var currentMem:Float = Math.round((MemoryUtil.currentMemUsage / 1024) / 1000);
        var currentGpu:Float = Math.round((FlxG.stage.context3D.totalGPUMemory / 1024) / 1000);

        text = "FPS: " + currentFPS + "\n";
        text += "Memory: " + (currentMem < 0 ? "Leaking " : "") + Math.abs(currentMem) + " MB\n";
        text += "GPU: " + (currentGpu < 0 ? "Leaking " : "") + Math.abs(currentGpu) + " MB (" + getRenderProgram() + ")\n";
    }

    // эндер69 шарм
    function getRenderProgram():String {
        @:privateAccess {
            if (FlxG.stage == null)
                return "N/A";
            if (FlxG.stage.context3D == null)
                return "N/A";
            if (FlxG.stage.context3D.__state == null)
                return "N/A";
            if (FlxG.stage.context3D.__state.program == null)
                return "N/A";
            return Std.string(FlxG.stage.context3D.__state.program.__format).toUpperCase();
        }
    }
}