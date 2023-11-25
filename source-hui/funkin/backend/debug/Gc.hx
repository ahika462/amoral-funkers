package funkin.backend.debug;

import openfl.system.System;

typedef DaGc = 
#if cpp cpp.vm.Gc
#elseif hl hl.Gc
#elseif java java.vm.Gc
#elseif neko neko.vm.Gc
#else Dynamic #end;

class Gc {
	public static function enable() {
		#if (cpp || hl)
		DaGc.enable(true);
		#end
	}

	public static function disable() {
		#if (cpp || hl)
		DaGc.enable(false);
		#end
	}

	public static function minor() {
		#if (cpp || java || neko)
		DaGc.run(false);
		#end
	}

	public static function major() {
		#if cpp
		DaGc.run(true);
		DaGc.compact();
		#elseif hl
		DaGc.major();
		#elseif (java || neko)
		DaGc.run(true);
		#end
	}

	public static var currentMemUsage(get, never):Float;
	static function get_currentMemUsage():Float {
		#if cpp
		return DaGc.memInfo64(DaGc.MEM_INFO_USAGE);
		#elseif sys
		return cast(cast(System.totalMemory, UInt), Float);
		#else
		return 0;
		#end
	}
}