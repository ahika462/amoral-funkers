package modding.ui;

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
        
        stageList = CoolUtil.coolTextFile(Paths.txt("characterList"));
        var stagesDropdown:FlxUIDropDownMenu = new FlxUIDropDownMenu(FlxUIDropDownMenu.makeStrIdLabelArray(stageList, true));
    }
}