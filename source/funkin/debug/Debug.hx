package funkin.debug;

import haxe.exceptions.NotImplementedException;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import haxe.PosInfos;

using StringTools;

enum abstract LogStyle(String) from String to String {
    var TRACE = "[TRACE] ";
    var ERROR = "[ERROR] ";
    var CRASH = "\n[GAME WAS CRASHED]\n\n";
}

class Debug {
    static var logFolder:String = "./logs/";
    static var logName:String;
    static var logContent:String = "";

    static var initialized(default, null):Bool = false;

    public static function initialize() {
        #if (!final && sys)
        if (!FileSystem.exists(logFolder))
            FileSystem.createDirectory(logFolder);

        logName = "Log_" + Std.string(Date.now()).replace(" ", "_").replace(":", "'") + ".txt";
        #end
        initialized = true;

        // DebugOutput.init();
    }

    public static function logTrace(input:Dynamic, ?pos:PosInfos):String {
        return log(TRACE + buildPosInfo(pos) + ": " + Std.string(input));
    }

    public static function logError(input:Dynamic, ?pos:PosInfos):String {
        return log(ERROR + buildPosInfo(pos) + ": " + Std.string(input));
    }

    public static function logCrash(e:UncaughtErrorEvent):String {
        // log(CRASH + Std.string(input));
        return log(CRASH + buildErrorInfo(e));
    }

    public static function log(input:Dynamic):String {
        if (!initialized)
            initialize();

        var returnVal:String = Std.string(input);

        var inputStr:String = Std.string(input);
        logContent += inputStr + "\n";
        
        #if js
		if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
			(untyped console).log(inputStr);
		#elseif lua
		untyped __define_feature__("use._hx_print", _hx_print(inputStr));
		#elseif sys
		Sys.println(inputStr);
        #if !final
        try {
            File.saveContent(logFolder + logName, logContent);
        }
        #end
		#else
		throw new NotImplementedException()
		#end

        return returnVal;
    }

    static function buildPosInfo(pos:PosInfos):String {
        return "(" + pos.fileName + ":" + pos.lineNumber + ")";
    }

    static function buildErrorInfo(e:UncaughtErrorEvent):String {
        var returnVal:String = "";
        var callstack:Array<Dynamic> = CallStack.exceptionStack(true);
        while (callstack.length > 0) {
            switch(callstack[0]) {
                case FilePos(s, file, line, column):
                    returnVal += "[CRASH] (" + file + ":" + line + ")\n";
                    callstack.shift();

                default: // я хз зачем и почему
                    var raw:String = Std.string(callstack[0]).substr("Called from ".length);
                    var file:String = raw.split(" ")[1];
                    var line:Int = Std.parseInt(raw.split(" ")[3]);
                    callstack.shift();
                    callstack.insert(0, FilePos(null, file, line, 0));
            }
        }
		returnVal += "\n" + Std.string(e.error) + "\n";

        return returnVal;
    }
}