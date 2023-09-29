package modding.ui;

import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import modding.editors.ChartDebugger;
import flixel.addons.ui.FlxUI;

class ChartUI extends FlxUI {
    public var nameInputText:FlxUIInputText;
    
    var debug:ChartDebugger;

    public function new() {
        super();
        name = "Charts";
        debug = ModdingState.instance.chartDebug;

        nameInputText = new FlxUIInputText(10, 10, 200, debug.json.song);
        add(nameInputText);

        var reloadJsonButton:FlxButton = new FlxButton(nameInputText.x + nameInputText.width + 10, nameInputText.y, "Reload JSON", function() {
            ModdingState.instance.closeSubState();
            ModdingState.instance.chartDebug = new ChartDebugger(nameInputText.text);
            debug = ModdingState.instance.chartDebug;

            nameInputText.text = debug.json.song;
        });
        add(reloadJsonButton);

        var reloadAudioButton:FlxButton = new FlxButton(reloadJsonButton.x, reloadJsonButton.y + reloadJsonButton.height + 10, "Reload Audio", function() {
            var time:Float = Conductor.songPosition;
            
            FlxG.sound.playMusic(Paths.inst(nameInputText.text.toLowerCase()));

            if (time > FlxG.sound.music.length)
                time = FlxG.sound.music.length;

            FlxG.sound.music.time = time;
        });
        add(reloadAudioButton);
    }
}