package funkin.editors.ui;

import funkin.InputText;
import flixel.FlxG;
import flixel.addons.ui.StrNameLabel;
import flixel.util.FlxColor;
import funkin.editors.editors.CharacterDebugger;
import funkin.gameplay.Character.AnimArray;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUICheckBox;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUI;

using StringTools;

class CharacterUI extends FlxUI {
    public var iconInputText:InputText;
    public var imageInputText:InputText;
    public var nameInputText:InputText;
    public var animInputText:InputText;
    public var indicesInputText:InputText;

    var characterList:Array<String> = [];

    public var fpsStepper:FlxUINumericStepper;
    var loopCheckBox:FlxUICheckBox;

    public var scaleStepper:FlxUINumericStepper;

    var colorShow:FlxUIInputText;
    public var redStepper:FlxUINumericStepper;
    public var greenStepper:FlxUINumericStepper;
    public var blueStepper:FlxUINumericStepper;

    public var xStepper:FlxUINumericStepper;
    public var yStepper:FlxUINumericStepper;

    public var xCamStepper:FlxUINumericStepper;
    public var yCamStepper:FlxUINumericStepper;

    var debug:CharacterDebugger;

    public function new() {
        super();
        name = "Characters";
        debug = ModdingState.instance.characterDebug;

        characterList = CoolUtil.coolTextFile(Paths.getEmbedShit("characters/characterList.txt"));
        var charactersDropdown:FlxUIDropDownMenu = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(characterList, true));
        add(charactersDropdown);

        var saveButton:FlxButton = new FlxButton(charactersDropdown.x + charactersDropdown.width + 10, 10, "Save", function() {
            debug.json.healthicon = iconInputText.text;
            debug.json.healthbar_colors = [Std.int(redStepper.value), Std.int(greenStepper.value), Std.int(blueStepper.value)];
            debug.json.position = [xStepper.value, yStepper.value];
            ModdingState.instance.saveFile(debug.json, "character", debug.curCharacter);
        });
        add(saveButton);

        var editorOffset:Float = 100;

        iconInputText = new InputText(10, editorOffset, 75, debug.character.json.healthicon);
        insert(0, iconInputText);

        var playerCheckBox:FlxUICheckBox = new FlxUICheckBox(iconInputText.x + iconInputText.width + 10, editorOffset, null, null, "Is Player");
        playerCheckBox.callback = function() {
            debug.character.isPlayer = playerCheckBox.checked;
            debug.updateCrossPosition();
        }
        insert(0, playerCheckBox);

        imageInputText = new InputText(10, playerCheckBox.y + playerCheckBox.height + 10, 175, debug.json.image);
        insert(0, imageInputText);

        var reloadButton:FlxButton = new FlxButton(imageInputText.x + imageInputText.width + 10, imageInputText.y, "Reload", function() {
            debug.json.image = imageInputText.text;
            debug.character.updateCharacter();
        });
        add(reloadButton);

        var flipCheckBox:FlxUICheckBox = new FlxUICheckBox(10, imageInputText.y + imageInputText.height + 10, null, null, "Flip X");
        flipCheckBox.checked = debug.json.flip_x;
        flipCheckBox.callback = function() {
            debug.json.flip_x = flipCheckBox.checked;

            debug.character.flipX = debug.json.flip_x;
			if (debug.character.isPlayer)
                debug.character.flipX = !debug.character.flipX;
        }
        insert(0, flipCheckBox);

        scaleStepper = new FlxUINumericStepper(flipCheckBox.x + flipCheckBox.width + 10, flipCheckBox.y, 0.1, debug.json.scale, 0, 999, 1);
        insert(0, scaleStepper);

        colorShow = new FlxUIInputText(10, flipCheckBox.y + flipCheckBox.height + 10, 30, "");
        insert(0, colorShow);

        redStepper = new FlxUINumericStepper(colorShow.x + colorShow.width + 10, flipCheckBox.y + flipCheckBox.height + 10, 1, 255, debug.json.healthbar_colors[0], 255);
        insert(0, redStepper);

        greenStepper = new FlxUINumericStepper(redStepper.x + redStepper.width + 10, redStepper.y, 1, 255, debug.json.healthbar_colors[1], 255);
        insert(0, greenStepper);

        blueStepper = new FlxUINumericStepper(greenStepper.x + greenStepper.width + 10, greenStepper.y, 1, 255, debug.json.healthbar_colors[2], 255);
        insert(0, blueStepper);

        updateColor();

        editorOffset = 250;

        var daArray:Array<StrNameLabel> = [new StrNameLabel("-1", "")];
        for (anim in debug.character.getAnimNames())
            daArray.push(new StrNameLabel(Std.string(debug.character.getAnimNames().indexOf(anim)), anim));

        var animationsDropDown:FlxUIDropDownMenu = new FlxUIDropDownMenu(10, editorOffset, daArray, function(choice:String) {
            var anim:AnimArray = null;
            for (i in debug.json.animations) {
                if (i.anim == debug.character.getAnimNames()[Std.parseInt(choice)])
                    anim = i;
            }

            if (anim != null) {
                nameInputText.text = anim.anim;
                animInputText.text = anim.name;
                indicesInputText.text = Std.string(anim.indices).replace("[", "").replace("]", "");
                fpsStepper.value = anim.fps;
                loopCheckBox.checked = anim.loop;
            }
        });
        insert(0, animationsDropDown);

        var addButton:FlxButton = new FlxButton(animationsDropDown.x + animationsDropDown.width + 10, animationsDropDown.y, "Add/Update", function() {
            var animAnim:String = nameInputText.text;
            var animName:String = animInputText.text;
            var animIndices:Array<Int> = [
                for (ind in indicesInputText.text.trim().split(",")) {
                    if (Math.isNaN(Std.parseInt(ind)))
                        Std.parseInt(ind);
                }
            ];
            var animFps:Int = Std.int(fpsStepper.value);
            var animLoop:Bool = loopCheckBox.checked;

            var animIndex:Int = -1;
            for (anim in debug.json.animations) {
                if (anim.anim == nameInputText.text) {
                    animIndex = debug.json.animations.indexOf(anim);
                    debug.json.animations.remove(anim);
                }
            }

            if (animIndices.length > 0)
                debug.character.animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
            else
                debug.character.animation.addByPrefix(animAnim, animName, animFps, animLoop);

            if (animIndex == -1)
                debug.json.animations.push({
                    name: animName,
                    anim: animAnim,
                    indices: animIndices,
                    fps: animFps,
                    loop: animLoop,
                    offsets: [0, 0]
                });
            else
                debug.json.animations.insert(animIndex, {
                    name: animName,
                    anim: animAnim,
                    indices: animIndices,
                    fps: animFps,
                    loop: animLoop,
                    offsets: [0, 0]
                });

            debug.character.addOffset(animName);

            var daArray:Array<StrNameLabel> = [new StrNameLabel("-1", "")];
            for (anim in debug.character.getAnimNames())
                daArray.push(new StrNameLabel(Std.string(debug.character.getAnimNames().indexOf(anim)), anim));

            var daLayer:Int = members.indexOf(animationsDropDown);
            remove(animationsDropDown);
            animationsDropDown = new FlxUIDropDownMenu(animationsDropDown.x, animationsDropDown.y, daArray, animationsDropDown.callback);
            insert(daLayer, animationsDropDown);
        });
        insert(0, addButton);

        var removeButton:FlxButton = new FlxButton(addButton.x + addButton.width + 10, addButton.y, "Remove", function() {
            for (anim in debug.json.animations) {
                if (anim.anim == nameInputText.text)
                    debug.json.animations.remove(anim);
            }

            if (debug.character.getAnimNames().length > 0) {
                /*var nextAnimID:Int = debug.character.getAnimNames().indexOf(debug.character.animation.curAnim.name) + 1;
                if (nextAnimID > debug.character.getAnimNames().length - 1)
                    nextAnimID = 0;*/

                debug.character.playAnim(debug.character.getAnimNames()[0]);
            }
            
            var daArray:Array<StrNameLabel> = [new StrNameLabel("-1", "")];
            for (anim in debug.character.getAnimNames())
                daArray.push(new StrNameLabel(Std.string(debug.character.getAnimNames().indexOf(anim)), anim));

            var daLayer:Int = members.indexOf(animationsDropDown);
            remove(animationsDropDown);
            animationsDropDown = new FlxUIDropDownMenu(animationsDropDown.x, animationsDropDown.y, daArray, animationsDropDown.callback);
            insert(daLayer, animationsDropDown);

            debug.character.animation.remove(nameInputText.text);
        });
        insert(0, removeButton);

        nameInputText = new InputText(10, animationsDropDown.y + 30, 175, "");
        insert(0, nameInputText);

        animInputText = new InputText(10, nameInputText.y + nameInputText.height + 10, 175, "");
        insert(0, animInputText);

        indicesInputText = new InputText(10, animInputText.y + animInputText.height + 10, 150, "");
        insert(0, indicesInputText);

        fpsStepper = new FlxUINumericStepper(indicesInputText.x + indicesInputText.width + 10, indicesInputText.y, 1, 24, 1);
        insert(0, fpsStepper);

        loopCheckBox = new FlxUICheckBox(fpsStepper.x + fpsStepper.width + 10, fpsStepper.y, null, null, "Loop");
        insert(0, loopCheckBox);

        xStepper = new FlxUINumericStepper(10, loopCheckBox.y + loopCheckBox.height + 10, 1, debug.json.position[0], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY);
        insert(0, xStepper);

        yStepper = new FlxUINumericStepper(xStepper.x + xStepper.width + 10, xStepper.y, 1, debug.json.position[1], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY);
        insert(0, yStepper);

        xCamStepper = new FlxUINumericStepper(10, yStepper.y + yStepper.height + 10, 1, debug.json.camera_position[0], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY);
        insert(0, xCamStepper);

        yCamStepper = new FlxUINumericStepper(xCamStepper.x + xCamStepper.width + 10, xCamStepper.y, 1, debug.json.camera_position[1], Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY);
        insert(0, yCamStepper);

        charactersDropdown.callback = function(choice:String) {
            debug.curCharacter = characterList[Std.parseInt(choice)];

            iconInputText.text = debug.json.healthicon;
            imageInputText.text = debug.json.image;
            flipCheckBox.checked = debug.json.flip_x;
            scaleStepper.value = debug.json.scale;

            xStepper.value = debug.json.position[0];
            yStepper.value = debug.json.position[1];
            xCamStepper.value = debug.json.camera_position[0];
            yCamStepper.value = debug.json.camera_position[1];

            var daArray:Array<StrNameLabel> = [new StrNameLabel("-1", "")];
            for (anim in debug.character.getAnimNames())
                daArray.push(new StrNameLabel(Std.string(debug.character.getAnimNames().indexOf(anim)), anim));

            var daLayer:Int = members.indexOf(animationsDropDown);
            remove(animationsDropDown);
            animationsDropDown = new FlxUIDropDownMenu(animationsDropDown.x, animationsDropDown.y, daArray, animationsDropDown.callback);
            insert(daLayer, animationsDropDown);
        }
    }

    override function update(elapsed:Float) {
        updateColor();

        if (debug.json.scale != scaleStepper.value) {
            debug.json.scale = scaleStepper.value;
            debug.character.scale.set(scaleStepper.value, scaleStepper.value);
            debug.character.updateHitbox();
        }

        if (debug.json.camera_position[0] != xCamStepper.value || debug.json.camera_position[1] != yCamStepper.value) {
            debug.json.camera_position = [xCamStepper.value, yCamStepper.value];
            debug.updateCrossPosition();
        }

        if (!ModdingState.instance.anyFocused) {
            if (FlxG.keys.pressed.Q)
                FlxG.camera.zoom -= elapsed * 0.3;
            if (FlxG.keys.pressed.E)
                FlxG.camera.zoom += elapsed * 0.3;
        }

        super.update(elapsed);

        colorShow.hasFocus = false;
    }

    function updateColor() {
        var showColor:FlxColor = FlxColor.WHITE;
        showColor.red = Std.int(redStepper.value);
        showColor.green = Std.int(greenStepper.value);
        showColor.blue = Std.int(blueStepper.value);
        colorShow.backgroundColor = showColor;
    }
}