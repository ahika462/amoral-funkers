package modding.ui;

import flixel.addons.ui.StrNameLabel;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import modding.editors.CharacterDebugger;
import Character.AnimArray;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.FlxG;
import flixel.addons.ui.FlxUICheckBox;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUI;

using StringTools;

class CharacterUI extends FlxUI {
    public var iconInputText:FlxUIInputText;
    public var imageInputText:FlxUIInputText;
    public var nameInputText:FlxUIInputText;
    public var animInputText:FlxUIInputText;
    public var indicesInputText:FlxUIInputText;

    var characterList:Array<String> = [];

    public var fpsStepper:FlxUINumericStepper;
    var loopCheckBox:FlxUICheckBox;

    var debug:CharacterDebugger;

    var colorShow:FlxUIInputText;
    public var redStepper:FlxUINumericStepper;
    public var greenStepper:FlxUINumericStepper;
    public var blueStepper:FlxUINumericStepper;

    public function new() {
        super();
        name = "Characters";
        debug = ModdingState.instance.characterDebug;

        characterList = CoolUtil.coolTextFile(Paths.txt("characterList"));
        var charactersDropdown:FlxUIDropDownMenu = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(characterList, true));
        add(charactersDropdown);

        var saveButton:FlxButton = new FlxButton(charactersDropdown.x + charactersDropdown.width + 10, 10, "Save", function() {
            debug.json.healthicon = iconInputText.text;
            debug.json.healthbar_colors = [colorShow.color.red, colorShow.color.green, colorShow.color.blue];
            ModdingState.instance.saveFile(debug.json);
        });
        add(saveButton);

        var editorOffset:Float = 100;

        iconInputText = new FlxUIInputText(10, editorOffset, 75, debug.character.json.healthicon);
        insert(0, iconInputText);

        var playerCheckBox:FlxUICheckBox = new FlxUICheckBox(iconInputText.x + iconInputText.width + 10, editorOffset, null, null, "Is Player");
        playerCheckBox.callback = function() {
            debug.character.isPlayer = playerCheckBox.checked;
        }
        insert(0, playerCheckBox);

        imageInputText = new FlxUIInputText(10, playerCheckBox.y + playerCheckBox.height + 10, 175, debug.json.image);
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

        // colorShow = new FlxSprite(10, flipCheckBox.y + flipCheckBox.height + 10).makeGraphic(30, 1, FlxColor.WHITE);

        colorShow = new FlxUIInputText(10, flipCheckBox.y + flipCheckBox.height + 10, 30, "");
        insert(0, colorShow);

        redStepper = new FlxUINumericStepper(colorShow.x + colorShow.width + 10, flipCheckBox.y + flipCheckBox.height + 10, 1, 255, 0, 255);
        insert(0, redStepper);

        greenStepper = new FlxUINumericStepper(redStepper.x + redStepper.width + 10, redStepper.y, 1, 255, 0, 255);
        insert(0, greenStepper);

        blueStepper = new FlxUINumericStepper(greenStepper.x + greenStepper.width + 10, greenStepper.y, 1, 255, 0, 255);
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
                for (ind in indicesInputText.text.split(",")) {
                    if (ind.replace(" ", "").length > 0 && Math.isNaN(Std.parseInt(ind)))
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

            var nextAnimID:Int = debug.character.getAnimNames().indexOf(debug.character.animation.curAnim.name) + 1;
            if (nextAnimID > debug.character.getAnimNames().length - 1)
                nextAnimID = 0;

            debug.character.playAnim(debug.character.getAnimNames()[nextAnimID]);
            
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

        nameInputText = new FlxUIInputText(10, animationsDropDown.y + 30, 175, "");
        insert(0, nameInputText);

        animInputText = new FlxUIInputText(10, nameInputText.y + nameInputText.height + 10, 175, "");
        insert(0, animInputText);

        indicesInputText = new FlxUIInputText(10, animInputText.y + animInputText.height + 10, 150, "");
        insert(0, indicesInputText);

        fpsStepper = new FlxUINumericStepper(indicesInputText.x + indicesInputText.width + 10, indicesInputText.y, 1, 24, 1);
        insert(0, fpsStepper);

        loopCheckBox = new FlxUICheckBox(fpsStepper.x + fpsStepper.width + 10, fpsStepper.y, null, null, "Loop");
        insert(0, loopCheckBox);

        charactersDropdown.callback = function(choice:String) {
            debug.curCharacter = characterList[Std.parseInt(choice)];

            iconInputText.text = debug.json.healthicon;
            imageInputText.text = debug.json.image;
            flipCheckBox.checked = debug.json.flip_x;

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