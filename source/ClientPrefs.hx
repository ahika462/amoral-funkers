import flixel.FlxG;

class SaveVariables {
    public var censorNaughty:Bool = false;
    public var downscroll:Bool = false;
    public var flashing:Bool = true;
    public var cameraZoom:Bool = true;
    public var fpsCounter:Bool = true;
    public var autoPause:Bool = false;
    public var arrowHSB:Array<Array<Float>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]; 

    public var safeFrames:Float = 10;
    public var sickWindow:Int = 45;
    public var goodWindow:Int = 90;
	public var badWindow:Int = 135;

    public var ghostTapping:Bool = true;
    public var shaders:Bool = true;
    public var antialiasing:Bool = true;

    public function new() {}
}

class ClientPrefs {
    public static var data:SaveVariables = new SaveVariables();
    public static var defaults:SaveVariables = new SaveVariables();

    public static function loadPrefs() {
        if (FlxG.save != null) {
            for (field in Reflect.fields(FlxG.save.data)) {
                if (Reflect.hasField(data, field))
                    Reflect.setField(data, field, Reflect.field(FlxG.save.data, field));
            }
        }
    }

    public static function saveSettings() {
        if (FlxG.save != null) {
            for (field in Reflect.fields(data))
                Reflect.setField(FlxG.save.data, field, Reflect.field(data, field));
        }

        FlxG.save.flush();
    }

    public static function resetOptions() {
        for (field in Reflect.fields(defaults))
            Reflect.setField(data, field, Reflect.field(defaults, field));

        FlxG.save.flush();
    }
}