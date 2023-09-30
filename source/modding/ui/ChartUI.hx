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

        var save:FlxButton = new FlxButton(10, 10, "Save", function() {
            
        });

        nameInputText = new FlxUIInputText(10, 10, 200, debug.json.song);
        add(nameInputText);

        var reloadJsonButton:FlxButton = new FlxButton(nameInputText.x + nameInputText.width + 10, nameInputText.y, "Reload JSON", function() {
            // потом
            debug.loadJson(nameInputText.text);
            nameInputText.text = debug.json.song;
        });
        add(reloadJsonButton);

        var reloadAudioButton:FlxButton = new FlxButton(reloadJsonButton.x, reloadJsonButton.y + reloadJsonButton.height + 10, "Reload Audio", function() {
            debug.loadSong(nameInputText.text);
        });
        add(reloadAudioButton);
    }
}