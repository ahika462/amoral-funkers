#if sys
import sys.io.FileOutput;
#end
import flixel.FlxG;
import flixel.system.debug.log.LogStyle as FlxLogStyle;
import haxe.PosInfos;
import haxe.Log;

using StringTools;
using flixel.util.FlxStringUtil;

enum abstract LogStyle(String) from String to String {
    var ERROR = "ERROR";
    var TRACE = "TRACE";
}

class Debug {
    static var FLX_LOG_ERROR:FlxLogStyle = new FlxLogStyle("[ERROR] ", "FF8888", 12, true, false, false, "flixel/sounds/beep", true);
    static var FLX_LOG_TRACE:FlxLogStyle = new FlxLogStyle("[TRACE] ", "5CF878", 12, false);

    static var initialized:Bool = false;
    static function initialize() {
        Log.trace = function(data:Dynamic, ?info:PosInfos) {
            var paramArray:Array<Dynamic> = [data];

			if (info != null)
			{
				if (info.customParams != null)
				{
					for (i in info.customParams)
					{
						paramArray.push(i);
					}
				}
			}

			logTrace(paramArray, info);
        }

        initialized = true;
    }

    static function writeToFlxGLog(data:Array<Dynamic>, logStyle:FlxLogStyle) {
		if (FlxG != null && FlxG.game != null && FlxG.log != null)
			FlxG.log.advanced(data, logStyle);
	}

    static function writeToLogFile(data:Array<Dynamic>, logLevel:String = "TRACE") {
		if (logFileWriter != null && logFileWriter.isActive())
			logFileWriter.write(data, logLevel);
	}

    static function formatOutput(input:Dynamic, pos:PosInfos):Array<Dynamic> {
		// This code is junk but I kept getting Null Function References.
		var inArray:Array<Dynamic> = null;
		if (input == null)
			inArray = ['<NULL>'];
		else if (!Std.isOfType(input, Array))
			inArray = [input];
		else
			inArray = input;

		if (pos == null)
			return inArray;

		// Format the position ourselves.
		var output:Array<Dynamic> = ['(${pos.className}/${pos.methodName}#${pos.lineNumber}): '];

		return output.concat(inArray);
	}

    public static function logTrace(input:Dynamic, ?pos:PosInfos) {
        if (!initialized)
            initialize();
        if (input == null)
            return;

        var output = formatOutput(input, pos);
        writeToFlxGLog(output, FLX_LOG_TRACE);
        writeToLogFile(output, TRACE);
    }
}

@:allow(Debug)
class DebugLogWriter {
    #if sys
    static var file:FileOutput;
    #end

    static function getTime(abs:Bool = false):Float {
        #if sys
        return Sys.time();
        #else
        return Date.now().getTime();
        #end
    }

    public static function write(input:Array<Dynamic>, logStyle:LogStyle = TRACE) {
        var ts:String = getTime().formatTime(true);
        var msg:String = ts + " [" + logStyle.rpad(" ", 5) + "] " + input.join("");

        #if sys
        if (file != null) {
            file.writeString(msg + "\n");
            file.flush();
        }
        #end

		printDebug(msg);
    }

    static function printDebug(msg:String) {
		#if sys
		Sys.println(msg);
		#else
		Log.trace(msg, null);
		#end
	}
}