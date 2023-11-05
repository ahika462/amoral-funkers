package modding.ui;

import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import modding.editors.ChartDebugger;
import flixel.addons.ui.FlxUI;

class ChartUI extends FlxUI {
    public var nameInputText:InputText;

    public var speedStepper:FlxUINumericStepper;
    public var bpmStepper:FlxUINumericStepper;

    public var sustainStepper:FlxUINumericStepper;
    
    var debug:ChartDebugger;

    public function new() {
        super();
        name = "Charts";
        debug = ModdingState.instance.chartDebug;

        var undoButton:FlxButton = new FlxButton(10, 10, "Undo", undo);
        add(undoButton);

        var redoButton:FlxButton = new FlxButton(undoButton.x + undoButton.width + 10, undoButton.y, "Redo", redo);
        add(redoButton);

        nameInputText = new InputText(10, redoButton.y + redoButton.height + 10, 200, debug.json.song);
        add(nameInputText);

        var saveButton:FlxButton = new FlxButton(nameInputText.x + nameInputText.width + 10, nameInputText.y, "Save", function() {
            ModdingState.instance.saveFile(debug.json, "song", debug.json.song.toLowerCase() + ".json");
        });
        add(saveButton);

        var reloadSongButton:FlxButton = new FlxButton(10, saveButton.y + saveButton.height + 10, "Reload Audio", function() {
            debug.loadSong(debug.json.song);
        });
        add(reloadSongButton);

        var reloadJsonButton:FlxButton = new FlxButton(reloadSongButton.x + reloadSongButton.width + 10, reloadSongButton.y, "Reload JSON", function() {
            debug.loadJson(nameInputText.text);
        });
        add(reloadJsonButton);

        var autosaveButton:FlxButton = new FlxButton(reloadJsonButton.x + reloadJsonButton.width + 10, reloadJsonButton.y, "Load Autosave", debug.loadAutosave);
        add(autosaveButton);

        speedStepper = new FlxUINumericStepper(10, autosaveButton.y + autosaveButton.height + 10, 0.1, debug.json.speed, 0.1, 10, 2);
        add(speedStepper);
        
        bpmStepper = new FlxUINumericStepper(speedStepper.x + speedStepper.width + 10, speedStepper.y, 1, debug.json.bpm, 1, Math.POSITIVE_INFINITY, 3);
        add(bpmStepper);

        var characterList:Array<String> = CoolUtil.coolTextFile(Paths.getEmbedShit("characters/characterList.txt"));

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

        var editorOffset:Float = 400;

        sustainStepper = new FlxUINumericStepper(10, editorOffset, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
        add(sustainStepper);
    }

    function undo() {
        if (debug.undos.length > 0) {
            debug.redos.insert(0, debug.json);
            debug.json = debug.undos[0];
            debug.undos.shift();

            debug.updateGrid();
        } else
            Debug.logTrace("cannot undo");
    }

    function redo() {
        if (debug.redos.length > 0) {
            debug.undos.insert(0, debug.json);
            debug.json = debug.redos[0];
            debug.redos.shift();

            debug.updateGrid();
        } else
            Debug.logTrace("cannot redo");
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.pressed.CONTROL) {
            if (FlxG.keys.justPressed.Z)
                undo();
            if (FlxG.keys.justPressed.Y)
                redo();
        }

        super.update(elapsed);
    }
}