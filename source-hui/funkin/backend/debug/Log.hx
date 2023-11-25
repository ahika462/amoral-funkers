package funkin.backend.debug;

import haxe.PosInfos;
#if (/*final && */ sys)
import sys.FileSystem;
#end

using StringTools;

class Log {
    @:noPrivateAccess static var initialized:Bool = false;
    @:noPrivateAccess inline static var logFolder:String = "logs/";
    @:noPrivateAccess static var logName:String = null;
    @:noPrivateAccess static var logContent:String = "";

    public static function initialize() {
        if (initialized)
            return;

        #if (/*final &&*/ sys)
        if (!FileSystem.exists(logFolder))
            FileSystem.createDirectory(logFolder);

        logName = Std.string(Date.now()).replace(" ", "_").replace(":", "'") + ".txt";
        #end
        initialized = true;
    }

    public static function trace(v:Dynamic, ?infos:PosInfos) {
        log(format(v, infos));
    }

    public static function format(v:Dynamic, infos:PosInfos):String {
        var str:String = Std.string(v);
		if (infos == null)
			return str;
		var pstr:String = infos.fileName + ":" + infos.lineNumber;
		if (infos.customParams != null)
			for (v in infos.customParams)
				str += ", " + Std.string(v);
		return pstr + ": " + str;
    }

    public static function log(v:String) {
        initialize();

        logContent += v + "\n";

        #if js
		if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
			(untyped console).log(v);
		#elseif lua
		untyped __define_feature__("use._hx_print", _hx_print(v));
		#elseif sys
		Sys.println(v);
		#else
		throw new haxe.exceptions.NotImplementedException()
		#end
    }
}