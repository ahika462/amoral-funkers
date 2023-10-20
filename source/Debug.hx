#if sys
import sys.io.File;
import sys.FileSystem;
#end
import haxe.Log;
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
        #if sys
        if (!FileSystem.exists(logFolder))
            FileSystem.createDirectory(logFolder);

        logName = "Log_" + Std.string(Date.now()).replace(" ", "_").replace(":", "'") + ".txt";
        #end
        initialized = true;
    }

    public static function logTrace(input:Dynamic, ?pos:PosInfos) {
        log(TRACE + buildPosInfo(pos) + ": " + Std.string(input));
    }

    public static function logError(input:Dynamic, ?pos:PosInfos) {
        log(ERROR + buildPosInfo(pos) + ": " + Std.string(input));
    }

    public static function logCrash(input:Dynamic, ?pos:PosInfos) {
        log(CRASH + Std.string(input));
    }

    public static function log(input:Dynamic) {
        if (!initialized)
            initialize();

        var inputStr:String = Std.string(input);

        logContent += inputStr + "\n";
        #if sys
        Sys.println(inputStr);
        File.saveContent(logFolder + logName, logContent);
        #else
        Log.trace(inputStr, null);
        #end
    }

    static function buildPosInfo(pos:PosInfos):String {
        return "(" + pos.className + ":" + pos.lineNumber + ":" + pos.methodName + ")";

        // return pos.className + "::" + pos.methodName + " " + pos.fileName.substr("source/".length) + " line " + pos.lineNumber;
    }
}