package ui;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import ui.MenuList.MenuTypedList;
import ui.OptionsState.Page;

class ColorsOptionsPage extends Page {
    static var lastSelected:Int = -1;
    var grpOptions:MenuTypedList<NoteOption>;

    override function create() {
        super.create();

        grpOptions = new MenuTypedList<NoteOption>(lastSelected);
        grpOptions.checkBounds = true;
        add(grpOptions);

        for (i in 0...4) {
            var option:NoteOption = new NoteOption(230, 165 * i + 35, i);
            grpOptions.add(option);
        }
    }

    override function update(elapsed:Float) {
        if (canExit) {
            if (controls.UI_UP_P) {
                var index:Int = grpOptions.selectedItem.numbers.selectedIndex;
                grpOptions.selectedItem.numbers.selectedIndex = -1;
                grpOptions.selectedItem.numbers.change(false);
                grpOptions.change(-1);
                grpOptions.selectedItem.numbers.selectedIndex = index;
                grpOptions.selectedItem.numbers.change();
            }
            if (controls.UI_DOWN_P) {
                var index:Int = grpOptions.selectedItem.numbers.selectedIndex;
                grpOptions.selectedItem.numbers.selectedIndex = -1;
                grpOptions.selectedItem.numbers.change(false);
                grpOptions.change(1);
                grpOptions.selectedItem.numbers.selectedIndex = index;
                grpOptions.selectedItem.numbers.change();
            }
            if (controls.ACCEPT) {
                canExit = false;
            }
            if (controls.UI_LEFT_P)
                grpOptions.selectedItem.numbers.change(-1);
            if (controls.UI_RIGHT_P)
                grpOptions.selectedItem.numbers.change(1);
        } else {
            if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
                var mult:Float = controls.UI_RIGHT_P ? 0.1 : -0.1;
                switch(grpOptions.selectedItem.numbers.selectedIndex) {
                    case 0:
                        grpOptions.selectedItem.note.colorSwap.hue += elapsed * mult;
                    case 1:
                        grpOptions.selectedItem.note.colorSwap.saturation += elapsed * mult;
                    case 2:
                        grpOptions.selectedItem.note.colorSwap.brightness += elapsed * mult;
                }
            }

            if (controls.BACK)
                canExit = true;
        }
        super.update(elapsed);
    }
}

class NoteOption extends FlxGroup {
    public var note:Note;
    public var numbers:MenuTypedList<Alphabet>;

    public function new(x:Float = 0, y:Float = 0, data:Int = 0) {
        super();

        note = new Note(0, data);
        note.setPosition(x, y);
        add(note);

        numbers = new MenuTypedList<Alphabet>();
        numbers.checkBounds = true;
        numbers.onChange = function(step:Int) {
            numbers.forEach(function(spr:Alphabet) {
                spr.alpha = 0.6;
            });

            if (numbers.selectedIndex >= 0)
                numbers.selectedItem.alpha = 1;
        }
        add(numbers);

        for (i in 0...3) {
            var number:Alphabet = new Alphabet(x + 225 * i + 250, y + 60, Std.string(ClientPrefs.data.arrowHSB[data][i]));
            number.alpha = 0.6;
            numbers.add(number);
        }

        numbers.change();
    }
}