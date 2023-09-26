package modding;

import modding.ui.*;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUICheckBox;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import haxe.Json;
import flixel.ui.FlxButton;
import modding.editors.BaseDebugger;
import flixel.FlxCamera;
import flixel.addons.ui.FlxUIDropDownMenu;
import modding.editors.CharacterDebugger;
import flixel.addons.ui.FlxUI;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.addons.ui.FlxUITabMenu;
import flixel.FlxSprite;

using StringTools;

class ModdingState extends MusicBeatState {
    public static var instance:ModdingState;

    var mainTabUI:FlxUITabMenu;

    var camEditor:FlxCamera = new FlxCamera();
    var camHUD:FlxCamera = new FlxCamera();

    public var characterDebug:CharacterDebugger;

    var characterUI:CharacterUI;

    var charIconInputText:FlxUIInputText;
    var charImageInputText:FlxUIInputText;

    override function create() {
        instance = this;

        FlxG.mouse.visible = true;

        persistentDraw = true;
		persistentUpdate = true;

        camHUD.bgColor.alpha = 0;
        FlxG.cameras.reset(camEditor);
        FlxG.cameras.add(camHUD, false);
        FlxG.cameras.setDefaultDrawTarget(camEditor, true);

        var bg:FlxSprite = new FlxSprite(Paths.image("menuDesat"));
        bg.scrollFactor.set();
        bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.color = 0xff58227A;
        add(bg);
        
        mainTabUI = new FlxUITabMenu([
            {name: "Characters", label: "Characters"},
            {name: "Songs", label: "Songs"},
            {name: "Weeks", label: "Weeks"}
        ], true);
        mainTabUI.setPosition(10, 10);
        mainTabUI.resize(FlxG.width / 4 - mainTabUI.x * 2, FlxG.height - mainTabUI.y * 2);
        mainTabUI.cameras = [camHUD];
        add(mainTabUI);

        characterDebug = cast init(new CharacterDebugger());

        addCharacterUI();
        addStageUI();
        addSongUI();
        addWeekUI();

        super.create();
    }

    function init(debug:BaseDebugger):BaseDebugger {
        add(debug);
        return cast remove(debug);
    }

    var characterList:Array<String> = [];
    function addCharacterUI() {
        characterUI = new CharacterUI();
        mainTabUI.addGroup(characterUI);

        inputTexts.push(characterUI.iconInputText);
        inputTexts.push(characterUI.imageInputText);
    }

    function addStageUI() {

    }
    
    function addSongUI() {

    }

    function addWeekUI() {

    }

    override function destroy() {
        FlxG.mouse.visible = false;

        super.destroy();
    }

    var inputTexts:Array<FlxUIInputText> = [];
    var anyFocused:Bool = false;

    var exiting:Bool = false;
    override function update(elapsed:Float) {
        for (text in inputTexts) {
            if (text.hasFocus)
                anyFocused = true;
        }
        
        var keys:Array<FlxKey> = [ESCAPE];
        if (!anyFocused)
            keys.push(BACKSPACE);

        anyFocused = false;

        if (FlxG.keys.anyJustPressed(keys)) {
            exiting = true;
            FlxG.switchState(new MainMenuState());
        }

        if (!exiting)
            updateEditor();

        super.update(elapsed);
    }

    function updateEditor() {
        var requestedDebug:BaseDebugger = null;
        switch(mainTabUI.selected_tab_id) {
            case "Characters":
                requestedDebug = characterDebug;
        }

        switch(mainTabUI.selected_tab_id) {
            case "Characters":
                if (subState != characterDebug) {
                    closeSubState();
                    openSubState(characterDebug);
                }
            case "Songs":
                closeSubState();
            case "Weeks":
                closeSubState();
        }
    }

    var fileReference:FileReference;

    public function saveFile(data:Dynamic) {
        var json:Dynamic = {
            "character": data
        };
        var content:String = Json.stringify(json);

        if (content != null && content.length > 0) {
            fileReference = new FileReference();
            fileReference.addEventListener(Event.COMPLETE, onSaveComplete);
            fileReference.addEventListener(Event.CANCEL, onSaveCancel);
            fileReference.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            fileReference.save(content.trim(), characterDebug.curCharacter + ".json");
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