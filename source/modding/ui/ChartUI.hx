package modding.ui;

import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import modding.editors.ChartDebugger;
import flixel.addons.ui.FlxUI;

class ChartUI extends FlxUI {
    public var nameInputText:FlxUIInputText;

    public var speedStepper:FlxUINumericStepper;
    public var bpmStepper:FlxUINumericStepper;
    
    var debug:ChartDebugger;

    public function new() {
        super();
        name = "Charts";
        debug = ModdingState.instance.chartDebug;

        nameInputText = new FlxUIInputText(10, 10, 200, debug.json.song);
        add(nameInputText);

        var saveButton:FlxButton = new FlxButton(nameInputText.x + nameInputText.width + 10, nameInputText.y, "Save", function() {
            ModdingState.instance.saveFile(debug.json, "song", debug.json.song.toLowerCase() + ".json");
        });
        add(saveButton);

        var reloadSongButton:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function() {
            debug.loadSong(debug.json.song);
        });
        add(reloadSongButton);

        var reloadJsonButton:FlxButton = new FlxButton(reloadSongButton.x, reloadSongButton.y + reloadSongButton.height + 10, "Reload JSON", function() {
            debug.loadJson(nameInputText.text);
        });
        add(reloadJsonButton);

        var autosaveButton:FlxButton = new FlxButton(reloadJsonButton.x, reloadJsonButton.y + reloadJsonButton.height + 10, "Load Autosave", debug.loadAutosave);
        add(autosaveButton);

        speedStepper = new FlxUINumericStepper(10, autosaveButton.y + autosaveButton.height + 10, 0.1, debug.json.speed, 0.1, 10, 2);
        add(speedStepper);
        
        bpmStepper = new FlxUINumericStepper(speedStepper.x + speedStepper.width + 10, speedStepper.height, 1, debug.json.bpm, 1, Math.POSITIVE_INFINITY, 3);
        add(bpmStepper);

        var characterList:Array<String> = CoolUtil.coolTextFile(Paths.txt("characterList"));

        var player1Dropdown:FlxUIDropDownMenu = new FlxUIDropDownMenu(10, bpmStepper.y + bpmStepper.height + 10, FlxUIDropDownMenu.makeStrIdLabelArray(characterList, true), function(choice:String) {
            debug.json.player1 = characterList[Std.parseInt(choice)];
			debug.updateHeads();
        });
        add(player1Dropdown);

        var player2Dropdown:FlxUIDropDownMenu = new FlxUIDropDownMenu(player1Dropdown.x + player1Dropdown.width + 10, player1Dropdown.y, FlxUIDropDownMenu.makeStrIdLabelArray(characterList, true), function(choice:String) {
            debug.json.player2 = characterList[Std.parseInt(choice)];
			debug.updateHeads();
        });
        insert(0, player2Dropdown);
    }
}