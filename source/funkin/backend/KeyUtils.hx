package funkin.backend;

import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import openfl.events.KeyboardEvent;
import openfl.events.Event;

using StringTools;

enum KeyEvent {
    JUST_PRESSED;
    PRESSED;
    JUST_RELEASED;
}

class KeyUtils {
    @:noPrivateAccess static var callbacks:Map<String, Event->Void> = [];

    public static function addCallback(event:KeyEvent, func:Int->Void):String {
        var settedKey:String = "__amoral_key_input_callback_" + event;
        var counter:Int = 0;
        for (i in callbacks.keys()) {
            if (i.startsWith(settedKey))
                counter++;
        }
        settedKey += counter;

        var callback:Event->Void = null;

        switch(event) {
            case JUST_PRESSED:
                callback = function(e:Event) {
                    func(cast(e, KeyboardEvent).keyCode);
                }
                FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, callback);
            case PRESSED:
                callback = function(e:Event) {
                    for (key in FlxKey.fromStringMap) {
                        if (FlxG.keys.anyPressed([key])) {
                            func(key);
                        }
                    }
                }
                FlxG.stage.addEventListener(Event.ENTER_FRAME, callback);
            case JUST_RELEASED:
                callback = function(e:Event) {
                    func(cast(e, KeyboardEvent).keyCode);
                }
                FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, callback);
        }

        callbacks.set(settedKey, callback);
        return settedKey;
    }

    public static function removeCallback(event:KeyEvent, key:String) {
        if (!callbacks.exists(key))
            return;

        switch(event) {
            case JUST_PRESSED:
                FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, callbacks.get(key));
            case PRESSED:
                FlxG.stage.addEventListener(Event.ENTER_FRAME, callbacks.get(key));
            case JUST_RELEASED:
                FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, callbacks.get(key));
        }
    }
}