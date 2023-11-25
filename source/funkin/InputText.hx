package funkin;

import lime.system.Clipboard;
import flixel.FlxG;
import flixel.addons.ui.FlxInputText;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.addons.ui.FlxUIInputText;

class InputText extends FlxUIInputText {
    inline public static var INSERT_ACTION:String = "insert";

    override function onKeyDown(e:KeyboardEvent) {
		var key:FlxKey = e.keyCode;

		if (hasFocus) {
			if (key == SHIFT || key == CONTROL || key == BACKSLASH || key == ESCAPE)
				return;
			else if (key == LEFT) {
				if (caretIndex > 0) {
					caretIndex--;
					text = text;
				}
			} else if (key == RIGHT) {
				if (caretIndex < text.length) {
					caretIndex++;
					text = text;
				}
			} else if (key == END) {
				caretIndex = text.length;
				text = text;
			} else if (key == HOME) {
				caretIndex = 0;
				text = text;
			} else if (key == BACKSPACE) {
				if (caretIndex > 0) {
					caretIndex--;
					text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);
					onChange(FlxInputText.BACKSPACE_ACTION);
				}
			} else if (key == DELETE) {
				if (text.length > 0 && caretIndex < text.length) {
					text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);
					onChange(FlxInputText.DELETE_ACTION);
				}
			} else if (key == ENTER)
				onChange(FlxInputText.ENTER_ACTION);
            else if (key == V) {
                if (FlxG.keys.pressed.CONTROL) {
                    var newText:String = filter(Clipboard.text);

                    if (newText.length > 0 && (maxLength == 0 || (text.length + newText.length) < maxLength)) {
                        text += insertSubstring(text, newText, caretIndex);
                        caretIndex += newText.length;
                        onChange(INSERT_ACTION);
                    }
                }
            } else {
				if (e.charCode == 0)
					return;

				var newText:String = filter(String.fromCharCode(e.charCode));

				if (newText.length > 0 && (maxLength == 0 || (text.length + newText.length) < maxLength)) {
					text = insertSubstring(text, newText, caretIndex);
					caretIndex++;
					onChange(FlxInputText.INPUT_ACTION);
				}
			}
		}
	}
}