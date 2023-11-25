package funkin.backend;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#elseif sys
import openfl.system.System;
#end

class MemoryUtil {
	public static function enable() {
		#if (cpp || hl)
		Gc.enable(true);
		#end
	}

	public static function disable() {
		#if (cpp || hl)
		Gc.enable(false);
		#end
	}

	public static function clearMinor() {
		#if (cpp || java || neko)
		Gc.run(false);
		#end
	}

	public static function clearMajor() {
		#if cpp
		Gc.run(true);
		Gc.compact();
		#elseif hl
		Gc.major();
		#elseif (java || neko)
		Gc.run(true);
		#end
	}

	public static var currentMemUsage(get, never):Float;
	static function get_currentMemUsage():Float {
		#if cpp
		return Gc.memInfo64(Gc.MEM_INFO_USAGE);
		#elseif sys
		return cast(cast(System.totalMemory, UInt), Float);
		#else
		return 0;
		#end
	}

	private static var _nb:Int = 0;
	private static var _nbD:Int = 0;
	private static var _zombie:Dynamic;

	public static function destroyFlixelZombies() {
		#if cpp
		// Gc.enterGCFreeZone();

		while ((_zombie = Gc.getNextZombie()) != null) {
			_nb++;
			if (_zombie is flixel.util.FlxDestroyUtil.IFlxDestroyable) {
				flixel.util.FlxDestroyUtil.destroy(cast(_zombie, flixel.util.FlxDestroyUtil.IFlxDestroyable));
				_nbD++;
			}
		}
		Sys.println('Zombies: ${_nb}; IFlxDestroyable Zombies: ${_nbD}');

		// Gc.exitGCFreeZone();
		#end
	}
}