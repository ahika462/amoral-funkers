package ui;

import shaderslmfao.ColorSwap;
import flixel.FlxG;
import flixel.FlxSprite;
import ui.MenuList.MenuTypedList;

class OptionsState extends MusicBeatState {
    public static var instance:OptionsState;

    var grpOptions:MenuTypedList<Alphabet>;
    static var lastSelected:Int = -1;

    var optionShit:Array<String> = [
        "Note Colors",
        "Controls",
        "Appearance",
    ];

    override function create() {
        instance = this;

        var bg:FlxSprite = new FlxSprite(Paths.image("menuDesat"));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

        grpOptions = new MenuTypedList<Alphabet>(lastSelected);
        grpOptions.checkBounds = true;
        grpOptions.onChange = function(step:Int = 0) {
            grpOptions.selectedIndex += step;

            if (grpOptions.selectedIndex >= length)
                grpOptions.selectedIndex = 0;
            if (grpOptions.selectedIndex < 0)
                grpOptions.selectedIndex = length - 1;

            grpOptions.forEach(function(spr:Alphabet) {
                spr.alpha = 0.6;
            });
            grpOptions.selectedItem.alpha = 1;

            lastSelected = grpOptions.selectedIndex;
        };
        grpOptions.onSelect = function() {
            switch(optionShit[grpOptions.selectedIndex]) {
                case "Note Colors":
                    openSubState(new ColorsOptionsPage());
            }
        }
        add(grpOptions);

        for (i in 0...optionShit.length) {
            var option:Alphabet = new Alphabet(optionShit[i], true);
            option.screenCenter();
            option.y += (100 * (i - (optionShit.length / 2))) + 50;
            option.alpha = 0.6;
            grpOptions.add(option);
        }

        grpOptions.change();

        super.create();
    }

    override function update(elapsed:Float) {
        if (controls.UI_UP_P) {
            FlxG.sound.play(Paths.sound("scrollMenu"));
            grpOptions.onChange(-1);
        }

        if (controls.UI_DOWN_P) {
            FlxG.sound.play(Paths.sound("scrollMenu"));
            grpOptions.onChange(1);
        }
        
        if (controls.ACCEPT) {
            FlxG.sound.play(Paths.sound("scrollMenu"));
            grpOptions.onSelect();

            persistentDraw = false;
		    persistentUpdate = false;
        }

        super.update(elapsed);
    }
}

class Page extends MusicBeatSubstate {
    var canExit:Bool = true;
    override function create() {
        var bg:FlxSprite = new FlxSprite(Paths.image("menuDesat"));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

        super.create();
    }

    override function update(elapsed:Float) {
        if (canExit && controls.BACK) {
            close();

            OptionsState.instance.persistentDraw = true;
		    OptionsState.instance.persistentUpdate = true;
        }

        super.update(elapsed);
    }
}