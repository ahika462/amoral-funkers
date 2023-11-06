import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class SaveVariables {
    public var censorNaughty:Bool = false;
    public var flashing:Bool = true;
    public var cameraZoom:Bool = true;
    public var fpsCounter:Bool = true;
    public var autoPause:Bool = false;
    public var arrowRGB:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
    ];
	public var arrowRGBPixel:Array<Array<FlxColor>> = [
		[0xFFE276FF, 0xFFFFF9FF, 0xFF60008D],
		[0xFF3DCAFF, 0xFFF4FFFF, 0xFF003060],
		[0xFF71E300, 0xFFF6FFE6, 0xFF003100],
		[0xFFFF884E, 0xFFFFFAF5, 0xFF6C0000]
    ];
    public var comboStacking:Bool = false;
    
    public var downscroll:Bool = false;
    public var middlescroll:Bool = false;
    public var opponentStrums:Bool = true;

    public var gpuRender:Bool = false;

    public var safeFrames:Float = 10;
    public var sickWindow:Int = 45;
    public var goodWindow:Int = 90;
	public var badWindow:Int = 135;

    public var ghostTapping:Bool = true;
    public var shaders:Bool = true;
    public var antialiasing:Bool = true;

    public var keyBinds:Map<String, Array<FlxKey>> = [
        "note_left"  => [A, LEFT],
        "note_down"  => [S, DOWN],
        "note_up"    => [W, UP],
        "note_right" => [D, RIGHT],

        "ui_left"    => [A, LEFT],
        "ui_down"    => [S, DOWN],
        "ui_up"      => [W, UP],
        "ui_right"   => [D, RIGHT],

        "reset"      => [R],
        "accept"     => [SPACE, ENTER],
        "pause"      => [ENTER, ESCAPE],
        "back"       => [ESCAPE, BACKSPACE]
    ];

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