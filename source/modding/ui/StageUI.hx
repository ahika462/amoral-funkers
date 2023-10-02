package modding.ui;

import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import modding.editors.StageDebugger;
import flixel.addons.ui.FlxUI;

class StageUI extends FlxUI {
    var zoomStepper:FlxUINumericStepper;

    var stageList:Array<String> = [];

    var debug:StageDebugger;

    public function new() {
        super();
        name = "Stages";
        debug = ModdingState.instance.stageDebug;
        
        stageList = CoolUtil.coolTextFile(Paths.txt("stageList"));
        var stagesDropdown:FlxUIDropDownMenu = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(stageList, true));
        add(stagesDropdown);

        var saveButton:FlxButton = new FlxButton(stagesDropdown.x + stagesDropdown.width + 10, stagesDropdown.y, "Save", function() {
            ModdingState.instance.saveFile(debug.json);
        });

        zoomStepper = new FlxUINumericStepper(10, saveButton.y + saveButton.height + 10, 0.1, debug.json.zoom, 0, 999, 1);
        add(zoomStepper);

        stagesDropdown.callback = function(choice:String) {
            ModdingState.instance.closeSubState();
            ModdingState.instance.stageDebug = new StageDebugger(stageList[Std.parseInt(choice)]);
            debug = ModdingState.instance.stageDebug;
            ModdingState.instance.openSubState(debug);

            zoomStepper.value = debug.json.zoom;
        }
    }

    override function update(elapsed:Float) {
        if (debug.camOverlay.scale.x != zoomStepper.value)
            debug.updateZoomShit(zoomStepper.value);

        if (!ModdingState.instance.anyFocused) {
            if (FlxG.keys.pressed.Q)
                ModdingState.instance.camEditor.zoom -= elapsed * 0.3;
            if (FlxG.keys.pressed.E)
                ModdingState.instance.camEditor.zoom += elapsed * 0.3;
        }

        super.update(elapsed);
    }
}