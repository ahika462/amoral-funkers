package funkin.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class EditorSelectState extends MusicBeatState {
    static var curSelected:Int = 0;
    var grpMenuShit:FlxTypedGroup<Alphabet>;
    var menuItems:Array<String> = [
        "Character Editor",
        "Chart Editor",
        "Stage Editor"
    ];

    override function create() {
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF353535;
		add(bg);

        grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

        for (i in 0...menuItems.length) {
            var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
            songText.isMenuItem = true;
            songText.targetY = i;
            grpMenuShit.add(songText);
        }

        super.create();
    }

    function changeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound("scrollMenu"));

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}

    override function update(elapsed:Float) {
        if (controls.UI_UP_P)
            changeSelection(-1);
        if (controls.UI_DOWN_P)
            changeSelection(1);
        if (controls.ACCEPT) {
            switch(menuItems[curSelected]) {
                case "Character Editor":
                    FlxG.switchState(new CharacterEditorState());
            }
        }
        super.update(elapsed);
    }
}