package funkin.backend.data;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class ClientSave {
    public var framerate:Int = 60;

    public var keyBinds:Map<String, Array<FlxKey>> = [
        "note_left" => [A, LEFT],
        "note_down" => [S, DOWN],
        "note_up" => [W, UP],
        "note_right" => [D, RIGHT],

        "ui_left" => [A, LEFT],
        "ui_down" => [S, DOWN],
        "ui_up" => [W, UP],
        "ui_right" => [D, RIGHT],

        "reset" => [R],
        "accept" => [SPACE, ENTER],
        "pause" => [ENTER, ESCAPE],
        "back" => [ESCAPE, BACKSPACE]
    ];
    public var gamepadBinds:Map<String, Array<FlxGamepadInputID>> = [
        "note_left" => [DPAD_LEFT, X, LEFT_STICK_DIGITAL_LEFT, RIGHT_STICK_DIGITAL_LEFT],
        "note_down" => [DPAD_DOWN, A, LEFT_STICK_DIGITAL_DOWN, RIGHT_STICK_DIGITAL_DOWN],
        "note_up" => [DPAD_UP, Y, LEFT_STICK_DIGITAL_UP, RIGHT_STICK_DIGITAL_UP],
        "note_right" => [DPAD_RIGHT, B, LEFT_STICK_DIGITAL_RIGHT, RIGHT_STICK_DIGITAL_RIGHT],

        "ui_left" => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
        "ui_down" => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
        "ui_up" => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
        "ui_right" => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],

        "reset" => [Y],
        "accept" => [#if switch B #else A #end],
        "pause" => [START],
        "back" => [#if switch A #else B #end, FlxGamepadInputID.BACK]
    ];

    public function new() {}
}

class ClientPrefs {
    public static var data:ClientSave = new ClientSave();
    public static var defaults:ClientSave = new ClientSave();

    public static function loadPrefs() {
        if (FlxG.save != null) {
            for (field in Reflect.fields(FlxG.save.data)) {
                if (Reflect.hasField(data, field))
                    Reflect.setField(data, field, Reflect.field(FlxG.save.data, field));
            }
        }

        if (data.framerate >= FlxG.drawFramerate) {
			FlxG.updateFramerate = data.framerate;
			FlxG.drawFramerate = data.framerate;
        } else {
			FlxG.drawFramerate = data.framerate;
			FlxG.updateFramerate = data.framerate;
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