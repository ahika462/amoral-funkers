import flixel.sound.FlxSound;
import flixel.addons.display.FlxRuntimeShader;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import gifatlas.GifAtlas;
import animateatlas.AtlasFrameMaker;
import flixel.FlxSprite;
#if (!final && sys)
import sys.io.File;
#end
import openfl.utils.Assets;
import haxe.PosInfos;
import flixel.FlxCamera;
import hscript.Parser;
import hscript.Interp;

class HScript {
    inline public static var Function_Continue:Dynamic = "__amoral_hscript_return_continue";
    inline public static var Function_Stop:Dynamic = "__amoral_hscript_return_stop";

    public var interp:Interp = new Interp();
    public var parser:Parser = new Parser();

    public var scriptName:String;
    public var camTarget:FlxCamera;

    public var lastCalledFunction:String = null;

    public var debug:HScriptDebug;

    public function new(script:String, instance:IHScriptable) {
        debug = new HScriptDebug(this);

        try {
            #if (final || !sys)
            interp.execute(parser.parseString(Assets.getText(script)));
            #else
            interp.execute(parser.parseString(File.getContent(script)));
            #end
        } catch(e:Dynamic) {
            debug.logError(e, {
                fileName: null,
                className: script,
                lineNumber: -1,
                methodName: null
            });
        }
        scriptName = script;

        set("Function_Continue", Function_Continue);
        set("Function_Stop", Function_Stop);

        set("Conductor", Conductor);
        set("ClientPrefs", ClientPrefs);
        set("Debug", debug);
        set("SONG", PlayState.SONG);

        set("isStoryMode", PlayState.isStoryMode);
        set("difficulty", PlayState.storyDifficulty);
        set("difficultyName", CoolUtil.difficultyString());

        set("screenWidth", FlxG.width);
        set("screenHeight", FlxG.height);

        set("getScore", function():Int {
            return PlayState.instance.songScore;
        });
        set("getMisses", function():Int {
            return PlayState.instance.songMisses;
        });
        set("getHits", function():Int {
            return PlayState.instance.noteHits;
        });

        set("getRating", function():Float {
            return PlayState.instance.ratingPercent;
        });

        set("inGameOver", false);
        set("buildTarget",
            #if windows "windows"
            #elseif linux "linux"
            #elseif max "mac"
            #elseif web "browser"
            #elseif android "android"
            #else "unknown" #end
        );

        set("add", instance.add);
        set("insert", instance.insert);
        set("remove", instance.remove);

        set("addBehindGf", instance.addBehindGf);
        set("addBehindDad", instance.addBehindDad);
        set("addBehindBoyfriend", instance.addBehindBoyfriend);

        set("RuntimeGroup", RuntimeGroup);
        set("RuntimeSprite", RuntimeSprite);

        set("random", FlxG.random);
        set("playSound", function(sound:String, volume:Float = 1):FlxSound {
            return FlxG.sound.play(Paths.sound(sound), volume);
        });

        set("gf", instance.gf);
        set("dad", instance.dad);
        set("boyfriend", instance.boyfriend);
    }

    public function call(name:String = null, args:Array<Dynamic> = null, ?pos:PosInfos):Dynamic {
        if (destroyed)
            return Function_Continue;

        var funcName:String = name != null ? name : pos.methodName;
        var funcArgs:Array<Dynamic> = args != null ? args : pos.customParams;

        lastCalledFunction = funcName;

        if (!interp.variables.exists(funcName))
            return Function_Continue;

        var pavapepeGemabody:Dynamic = {
            "func": interp.variables.get(funcName)
        };

        return Reflect.callMethod(pavapepeGemabody, Reflect.getProperty(pavapepeGemabody, "func"), funcArgs);
    }

    public function set(name:String, value:Dynamic):Dynamic {
        if (!destroyed)
            interp.variables.set(name, value);

        return value;
    }

    var destroyed:Bool = false;
    public function destroy() {
        interp = null;
        parser = null;
        debug = null;
        destroyed = true;
    }

    public static var runtimeShaders:Map<String, Array<String>> = [];
    #if (!android)
	public static function initRuntimeShader(name:String, ?glslVersion:Int = 120)
	{
		if (!ClientPrefs.data.shaders)
			return false;

		if (runtimeShaders.exists(name)) {
			Debug.logTrace('Shader $name was already initialized!');
			return true;
		}

		var frag:String = Paths.shaderFragment(name);
		var vert:String = Paths.shaderVertex(name);

		if (frag == null && vert == null) {
			Debug.logTrace('Missing shader $name .frag AND .vert files!');
			return false;
		}

		runtimeShaders.set(name, [frag, vert]);
		return true;
	}
	#end
}

private class HScriptDebug {
    public var hscript:HScript;
    public function new(hscript:HScript) {
        this.hscript = hscript;
    }

    public function logTrace(input:Dynamic, ?pos:PosInfos) {
        if (pos == null)
            pos = getPosInfos();

        Debug.logTrace(input, pos);
    }

    public function logError(input:Dynamic, ?pos:PosInfos) {
        if (pos == null)
            pos = getPosInfos();

        Debug.logError(input, pos);
    }

    public function log(input:Dynamic) {
        Debug.log(input);
    }

    public function getPosInfos():PosInfos {
        var returnVal:PosInfos = hscript.interp.posInfos();
        returnVal.className = hscript.scriptName;
        returnVal.methodName = hscript.lastCalledFunction;

        return returnVal;
    }
}

class RuntimeGroup extends FlxSpriteGroup {

}

class RuntimeSprite extends FlxSprite {
    public function new(image:String = null, x:Float = 0, y:Float = 0) {
        super(x, y, image);
        antialiasing = ClientPrefs.data.antialiasing;
    }

    override function loadGraphic(image:String, animated:Bool = false, frameWidth:Int = 0, frameHeight:Int = 0, unique:Bool = false, key:String = null):FlxSprite {
        return super.loadGraphic(Paths.image(image), animated, frameWidth, frameHeight, false, null);
    }

    public function loadFrames(image:String) {
        if (Paths.exists("images/" + image + ".xml", TEXT))
            frames = Paths.getSparrowAtlas(image);
        else if (Paths.exists("images/" + image + ".txt", TEXT))
            frames = Paths.getPackerAtlas(image);
        else if (Paths.exists("images/" + image + "/Animation.json", TEXT))
            frames = AtlasFrameMaker.construct(image);
        else
            frames = GifAtlas.build(image);
    }

    public function setScale(x:Float = 1, y:Null<Float> = null, needUpdateHitbox:Bool = true) {
        if (y == null)
            y = x;

        scale.set(x, y);

        if (needUpdateHitbox)
            updateHitbox();
    }
}

class RuntimeShader extends FlxRuntimeShader {
    public function new(name:String, glslVersion:Int = 120) {
        if (!ClientPrefs.data.shaders) {
            super();
            return;
        }

        #if !android
        if (!HScript.runtimeShaders.exists(name) && !HScript.initRuntimeShader(name)) {
			Debug.logTrace("Shader " + name + " is missing!");
            super();
			return ;
		}

		var arr:Array<String> = HScript.runtimeShaders.get(name);
        super(arr[0], arr[1]);
        #else
        super();
        #end
    }
}