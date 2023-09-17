import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import Type.ValueType;

#if linc_luajit
import llua.Convert;
import llua.Lua;
import llua.LuaL;
import llua.State;
#end

using StringTools;

class LuaScript {
    public static var Function_Stop:Dynamic = "#amoral_lua_stop";
	public static var Function_Continue:Dynamic = "#amoral_lua_continue";
	public static var Function_StopLua:Dynamic = "#amoral_lua_stoplua";

    #if linc_luajit
	public var lua:State = null;
	#end
    public var scriptName:String = "";

    public function new(script:String) {
        #if linc_luajit
        lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

        try {
            var result:Dynamic = LuaL.dofile(lua, script);
			var resultStr:String = Lua.tostring(lua, result);
			if (resultStr != null && result != 0) {
				trace("Error on lua script! " + resultStr);
				lua = null;
				return;
			}
        } catch(e) {
            trace(e);
			return;
        }
        #end
        scriptName = script;

        #if linc_luajit
        addCalllback("getField", function(field:String) {
            var result:Dynamic = null;
			var killMe:Array<String> = field.split('.');
			if(killMe.length > 1)
				result = getVarInArray(getFieldLoopThingWhatever(killMe), killMe[killMe.length-1]);
			else
				result = getVarInArray(PlayState.instance, field);

			if (result == null)
                Lua.pushnil(lua);
			return result;
        });
        addCalllback("setField", function(field:String, value:Dynamic) {
            var killMe:Array<String> = field.split('.');
			if (killMe.length > 1) {
				setVarInArray(getFieldLoopThingWhatever(killMe), killMe[killMe.length-1], value);
				return true;
			}
			setVarInArray(PlayState.instance, field, value);
			return true;
        });

        Lua_helper.add_callback(lua, "getGroupField", function(obj:String, index:Int, variable:Dynamic) {
			var shitMyPants:Array<String> = obj.split('.');
			var realObject:Dynamic = Reflect.field(PlayState.instance, obj);
			if (shitMyPants.length>1)
				realObject = getFieldLoopThingWhatever(shitMyPants, true, false);


			if (Std.isOfType(realObject, FlxTypedGroup) || Std.isOfType(realObject, FlxTypedSpriteGroup)) {
				var result:Dynamic = getGroupStuff(realObject.members[index], variable);
				if (result == null)
                    Lua.pushnil(lua);
				return result;
			}


			var leArray:Dynamic = realObject[index];
			if (leArray != null) {
				var result:Dynamic = null;
				if (Type.typeof(variable) == ValueType.TInt)
					result = leArray[variable];
				else
					result = getGroupStuff(leArray, variable);

				if (result == null)
                    Lua.pushnil(lua);
				return result;
			}
			trace("getGroupField: Object #" + index + " from group: " + obj + " doesn't exist!");
			Lua.pushnil(lua);
			return null;
		});
		Lua_helper.add_callback(lua, "setGroupField", function(obj:String, index:Int, variable:Dynamic, value:Dynamic) {
			var shitMyPants:Array<String> = obj.split('.');
			var realObject:Dynamic = Reflect.field(PlayState.instance, obj);
			if (shitMyPants.length>1)
				realObject = getFieldLoopThingWhatever(shitMyPants, true, false);

			if (Std.isOfType(realObject, FlxTypedGroup) || Std.isOfType(realObject, FlxTypedSpriteGroup)) {
				setGroupStuff(realObject.members[index], variable, value);
				return;
			}

			var leArray:Dynamic = realObject[index];
			if (leArray != null) {
				if (Type.typeof(variable) == ValueType.TInt) {
					leArray[variable] = value;
					return;
				}
				setGroupStuff(leArray, variable, value);
			}
		});
        #end
    }

    public function set(variable:String, data:Dynamic) {
		#if linc_luajit
		if (lua == null)
			return;

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
		#end
	}

    var lastCalledFunction:String = "";
	public function call(func:String, args:Array<Dynamic>):Dynamic {
		#if linc_luajit
		lastCalledFunction = func;
		try {
			if(lua == null) return Function_Continue;

			Lua.getglobal(lua, func);
			var type:Int = Lua.type(lua, -1);

			if (type != Lua.LUA_TFUNCTION) {
				if (type > Lua.LUA_TNIL)
					trace("ERROR (" + func + "): attempt to call a " + typeToString(type) + " value");

				Lua.pop(lua, 1);
				return Function_Continue;
			}

			for (arg in args) Convert.toLua(lua, arg);
			var status:Int = Lua.pcall(lua, args.length, 1, 0);

			// Checks if it's not successful, then show a error.
			if (status != Lua.LUA_OK) {
				var error:String = getErrorMessage(status);
				trace("ERROR (" + func + "): " + error);
				return Function_Continue;
			}

			// If successful, pass and then return the result.
			var result:Dynamic = cast Convert.fromLua(lua, -1);
			if (result == null) result = Function_Continue;

			Lua.pop(lua, 1);
			return result;
		}
		catch (e:Dynamic) {
			trace(e);
		}
		#end
		return Function_Continue;
	}

    public function addCalllback(name:String, func:Dynamic) {
        Lua_helper.add_callback(lua, name, func);
    }

    function typeToString(type:Int):String {
		#if linc_luajit
		switch(type) {
			case Lua.LUA_TBOOLEAN: return "boolean";
			case Lua.LUA_TNUMBER: return "number";
			case Lua.LUA_TSTRING: return "string";
			case Lua.LUA_TTABLE: return "table";
			case Lua.LUA_TFUNCTION: return "function";
		}
		if (type <= Lua.LUA_TNIL) return "nil";
		#end
		return "unknown";
	}

    function getErrorMessage(status:Int):String {
		#if linc_luajit
		var v:String = Lua.tostring(lua, -1);
		Lua.pop(lua, 1);

		if (v != null) v = v.trim();
		if (v == null || v == "") {
			switch(status) {
				case Lua.LUA_ERRRUN: return "Runtime Error";
				case Lua.LUA_ERRMEM: return "Memory Allocation Error";
				case Lua.LUA_ERRERR: return "Critical Error";
			}
			return "Unknown Error";
		}

		return v;
		#end
		return null;
	}

    public static function setVarInArray(instance:Dynamic, variable:String, value:Dynamic):Dynamic {
		var shit:Array<String> = variable.split('[');
		if(shit.length > 1) {
			var blah:Dynamic = Reflect.field(instance, shit[0]);

			for (i in 1...shit.length) {
				var leNum:Dynamic = shit[i].substr(0, shit[i].length - 1);
				if (i >= shit.length-1) //Last array
					blah[leNum] = value;
				else //Anything else
					blah = blah[leNum];
			}
			return blah;
		}

		Reflect.setProperty(instance, variable, value);
		return true;
	}

	public static function getVarInArray(instance:Dynamic, variable:String):Dynamic {
		var shit:Array<String> = variable.split('[');
		if (shit.length > 1) {
			var blah:Dynamic = null;
			blah = Reflect.field(instance, shit[0]);

			for (i in 1...shit.length) {
				var leNum:Dynamic = shit[i].substr(0, shit[i].length - 1);
				blah = blah[leNum];
			}
			return blah;
		}

		return Reflect.field(instance, variable);
	}

    public static function getFieldLoopThingWhatever(killMe:Array<String>, ?checkForTextsToo:Bool = true, ?getProperty:Bool=true):Dynamic {
		var coverMeInPiss:Dynamic = getObjectDirectly(killMe[0], checkForTextsToo);
		var end = killMe.length;
		if (getProperty)
            end = killMe.length-1;

		for (i in 1...end)
			coverMeInPiss = getVarInArray(coverMeInPiss, killMe[i]);

		return coverMeInPiss;
	}

	public static function getObjectDirectly(objectName:String, ?checkForTextsToo:Bool = true):Dynamic {
		var coverMeInPiss:Dynamic = PlayState.instance.getLuaObject(objectName, checkForTextsToo);
		if (coverMeInPiss == null)
			coverMeInPiss = getVarInArray(PlayState.instance, objectName);

		return coverMeInPiss;
	}

    function getGroupStuff(leArray:Dynamic, variable:String) {
		var killMe:Array<String> = variable.split('.');
		if (killMe.length > 1) {
			var coverMeInPiss:Dynamic = Reflect.field(leArray, killMe[0]);

			for (i in 1...killMe.length-1)
				coverMeInPiss = Reflect.field(coverMeInPiss, killMe[i]);

			switch(Type.typeof(coverMeInPiss)) {
				case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
					return coverMeInPiss.get(killMe[killMe.length-1]);
				default:
					return Reflect.field(coverMeInPiss, killMe[killMe.length-1]);
			};
		}
		switch(Type.typeof(leArray)) {
			case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
				return leArray.get(variable);
			default:
				return Reflect.field(leArray, variable);
		};
	}

    function setGroupStuff(leArray:Dynamic, variable:String, value:Dynamic) {
		var killMe:Array<String> = variable.split('.');
		if (killMe.length > 1) {
			var coverMeInPiss:Dynamic = Reflect.field(leArray, killMe[0]);
            
			for (i in 1...killMe.length-1)
				coverMeInPiss = Reflect.field(coverMeInPiss, killMe[i]);

			Reflect.setField(coverMeInPiss, killMe[killMe.length-1], value);
			return;
		}
		Reflect.setField(leArray, variable, value);
	}
}