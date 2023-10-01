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

    public function new(script:String) {
        try {
            interp.execute(parser.parseString(Assets.getText(script)));
        } catch(e:Dynamic) {
            Debug.logError(e);
        }
        scriptName = script;

        set("Function_Continue", Function_Continue);
        set("Function_Stop", Function_Stop);

        set("Conductor", Conductor);
        set("ClientPrefs", ClientPrefs);
        set("Debug", Debug);
    }

    public function call(?name:String = null, ?args:Array<Dynamic> = null, ?pos:PosInfos):Dynamic {
        var funcName:String = name != null ? name : pos.methodName;
        var funcArgs:Array<Dynamic> = args != null ? args : [];

        Debug.logTrace("calling function \"" + funcName + "\" in script \"" + scriptName + "\" with arguments: " + funcArgs);

        if (!interp.variables.exists(funcName))
            return Function_Continue;

        // сука блять нахуй блять

        /*var pavapepeGemabody:Dynamic = {};
        Reflect.setProperty(pavapepeGemabody, funcName, interp.variables[funcName]);

        return Reflect.callMethod(pavapepeGemabody, Reflect.getProperty(pavapepeGemabody, funcName), funcArgs);*/

        return Function_Continue;
    }

    public function set(name:String, value:Dynamic):Dynamic {
        interp.variables.set(name, value);

        return value;
    }
}