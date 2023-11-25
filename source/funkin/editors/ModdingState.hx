package funkin.editors;

import funkin.MusicBeatState;
import flixel.FlxObject;
import funkin.editors.ui.*;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUICheckBox;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import haxe.Json;
import flixel.ui.FlxButton;
import flixel.FlxCamera;
import flixel.addons.ui.FlxUIDropDownMenu;
import funkin.editors.editors.*;
import flixel.addons.ui.FlxUI;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.addons.ui.FlxUITabMenu;
import flixel.FlxSprite;

using StringTools;

class ModdingState extends MusicBeatState {
    public static var instance:ModdingState;

    public var mainTabUI:FlxUITabMenu;

    var camBG:FlxCamera = new FlxCamera();
    public var camEditor:FlxCamera = new FlxCamera();
    var camHUD:FlxCamera = new FlxCamera();

    public var characterDebug:CharacterDebugger;
    public var chartDebug:ChartDebugger;
    public var stageDebug:StageDebugger;

    var characterUI:CharacterUI;
    public var chartUI:ChartUI;
    var stageUI:StageUI;

    public var bg:FlxSprite;

    public var camFollow:FlxObject = new FlxObject();

    override function create() {
        instance = this;

        FlxG.sound.music.stop();
        FlxG.mouse.visible = true;

        persistentDraw = true;
		persistentUpdate = true;

        camEditor.bgColor.alpha = 0;
        camHUD.bgColor.alpha = 0;
        FlxG.cameras.reset(camBG);
        FlxG.cameras.add(camEditor, true);
        FlxG.cameras.add(camHUD, false);
        FlxG.cameras.setDefaultDrawTarget(camBG, false);

        bg = new FlxSprite(Paths.image("menuDesat"));
        bg.scrollFactor.set();
        bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.color = 0xff58227A;
        bg.cameras = [camBG];
        add(bg);

        camFollow.screenCenter();
        camEditor.follow(camFollow);
        
        mainTabUI = new FlxUITabMenu([
            {name: "Characters", label: "Characters"},
            {name: "Charts", label: "Charts"},
            {name: "Stages", label: "Stages"},
            {name: "Weeks", label: "Weeks"}
        ], true);
        mainTabUI.setPosition(10, 10);
        mainTabUI.resize(FlxG.width / 4 - mainTabUI.x * 2 + 20, FlxG.height - mainTabUI.y * 2);
        mainTabUI.cameras = [camHUD];
        add(mainTabUI);

        characterDebug = cast initDebugger(new CharacterDebugger());
        chartDebug = cast initDebugger(new ChartDebugger());
        stageDebug = cast initDebugger(new StageDebugger());

        addCharacterUI();
        addChartUI();
        addStageUI();
        addWeekUI();

        super.create();
    }

    function initDebugger(debug:BaseDebugger):BaseDebugger {
        add(debug);
        remove(debug);
        return debug;
    }

    function addCharacterUI() {
        characterUI = new CharacterUI();
        mainTabUI.addGroup(characterUI);

        inputTexts.push(characterUI.iconInputText);
        inputTexts.push(characterUI.imageInputText);
        inputTexts.push(characterUI.nameInputText);
        inputTexts.push(characterUI.animInputText);
        inputTexts.push(characterUI.indicesInputText);
        @:privateAccess {
            inputTexts.push(cast characterUI.fpsStepper.text_field);
            inputTexts.push(cast characterUI.scaleStepper.text_field);
            inputTexts.push(cast characterUI.redStepper.text_field);
            inputTexts.push(cast characterUI.greenStepper.text_field);
            inputTexts.push(cast characterUI.blueStepper.text_field);
            inputTexts.push(cast characterUI.xStepper.text_field);
            inputTexts.push(cast characterUI.yStepper.text_field);
            inputTexts.push(cast characterUI.xCamStepper.text_field);
            inputTexts.push(cast characterUI.yCamStepper.text_field);
        }
    }
    
    function addChartUI() {
        chartUI = new ChartUI();
        mainTabUI.addGroup(chartUI);

        inputTexts.push(chartUI.nameInputText);
        @:privateAccess {
            inputTexts.push(cast chartUI.speedStepper.text_field);
            inputTexts.push(cast chartUI.bpmStepper.text_field);
            inputTexts.push(cast chartUI.sustainStepper.text_field);
        }
    }

    function addStageUI() {
        stageUI = new StageUI();
        mainTabUI.addGroup(stageUI);
        @:privateAccess {
            inputTexts.push(cast stageUI.zoomStepper.text_field);
        }
    }

    function addWeekUI() {

    }

    override function destroy() {
        FlxG.mouse.visible = false;

        super.destroy();
    }

    var inputTexts:Array<FlxUIInputText> = [];
    public var anyFocused(get, never):Bool;
    function get_anyFocused():Bool {
        var returnVal:Bool = false;
        for (text in inputTexts) {
            if (text.hasFocus)
                returnVal = true;
        }
        return returnVal;
    }

    var exiting:Bool = false;
    override function update(elapsed:Float) {
        var keys:Array<FlxKey> = [ESCAPE];
        if (!anyFocused)
            keys.push(BACKSPACE);

        if (FlxG.keys.anyJustPressed(keys)) {
            exiting = true;
            FlxG.switchState(new MainMenuState());
        }

        if (!exiting)
            updateEditor();

        super.update(elapsed);
    }

    function updateEditor() {
        var requestedDebug:BaseDebugger = switch(mainTabUI.selected_tab_id) {
            case "Characters": characterDebug;
            case "Charts": chartDebug;
            case "Stages": stageDebug;
            default: null;
        }

        if (requestedDebug == stageDebug)
            bg.color = 0xff000000;
        else {
            bg.color = 0xff58227A;
            camEditor.zoom = 1;
        }

        camFollow.screenCenter();

        if (requestedDebug != null) {
            if (subState != requestedDebug)
                openSubState(requestedDebug);
        } else
            closeSubState();
    }

    var fileReference:FileReference;

    public function saveFile(data:Dynamic, type:String, name:String) {
        var json:Dynamic = {};
        Reflect.setProperty(json, type, data);
        var content:String = Json.stringify(json);

        if (content != null && content.length > 0) {
            fileReference = new FileReference();
            fileReference.addEventListener(Event.COMPLETE, onSaveComplete);
            fileReference.addEventListener(Event.CANCEL, onSaveCancel);
            fileReference.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            fileReference.save(content.trim(), name + ".json");
        }
    }
    
    function onSaveComplete(?e:Event) {
        fileReference.removeEventListener(Event.COMPLETE, onSaveComplete);
        fileReference.removeEventListener(Event.CANCEL, onSaveCancel);
        fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        fileReference = null;
        FlxG.log.notice("Successfully saved LEVEL DATA.");
    }

    function onSaveCancel(?e:Event) {
        fileReference.removeEventListener(Event.COMPLETE, onSaveComplete);
        fileReference.removeEventListener(Event.CANCEL, onSaveCancel);
        fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        fileReference = null;
    }

    function onSaveError(?e:IOErrorEvent) {
        fileReference.removeEventListener(Event.COMPLETE, onSaveComplete);
        fileReference.removeEventListener(Event.CANCEL, onSaveCancel);
        fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        fileReference = null;
        FlxG.log.error("Problem saving Level data");
    }
}