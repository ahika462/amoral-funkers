// мегабесполезная хрень, но мне так удобнее

import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.FlxG;
import openfl.events.Event;

enum KeyEvent {
    JUST_PRESSED;
    PRESSED;
    JUST_RELEASED;
}

class KeyUtils {
    public static function addCallback(event:KeyEvent, func:Int->Void) {
        switch(event) {
            case JUST_PRESSED:
                FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) {
                    func(e.keyCode);
                });
            case PRESSED:
                FlxG.stage.addEventListener(Event.ENTER_FRAME, function(e:Event) {
                    for (key in FlxKey.fromStringMap) {
                        if (FlxG.keys.anyPressed([key]))
                            func(key);
                    }
                });
            case JUST_RELEASED:
                FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent) {
                    func(e.keyCode);
                });
        }
    }

    public static function removeCallback(event:KeyEvent, func:Int->Void) {
        switch(event) {
            case JUST_PRESSED:
                FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) {
                    func(e.keyCode);
                });
            case PRESSED:
                FlxG.stage.addEventListener(Event.ENTER_FRAME, function(e:Event) {
                    for (key in FlxKey.fromStringMap) {
                        if (FlxG.keys.anyPressed([key]))
                            func(key);
                    }
                });
            case JUST_RELEASED:
                FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent) {
                    func(e.keyCode);
                });
        }
    }
}