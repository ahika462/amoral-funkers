package modding.ui;

import flixel.addons.ui.FlxUINumericStepper;
import flixel.FlxG;
import flixel.addons.ui.FlxUICheckBox;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUI;

class CharacterUI extends FlxUI {
    public var iconInputText:FlxUIInputText;
    public var imageInputText:FlxUIInputText;
    public var nameInputText:FlxUIInputText;
    public var animInputText:FlxUIInputText;
    public var indicesInputText:FlxUIInputText;

    var characterList:Array<String> = [];

    var animations:Array<String> = [];
    var currentAnimation:Int = 0;
    var selectedAnim:String = "";

    var fpsStepper:FlxUINumericStepper;
    var loopCheckBox:FlxUICheckBox;

    public function new() {
        super();
        name = "Characters";

        characterList = CoolUtil.coolTextFile(Paths.txt("characterList"));
        var charactersDropdown:FlxUIDropDownMenu = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(characterList, true), function(choice:String) {
            ModdingState.instance.characterDebug.curCharacter = characterList[Std.parseInt(choice)];
        });
        add(charactersDropdown);

        var saveButton:FlxButton = new FlxButton(charactersDropdown.x + charactersDropdown.width + 10, 10, "Save", function() {
            ModdingState.instance.characterDebug.json.healthicon = iconInputText.text;
            ModdingState.instance.saveFile(ModdingState.instance.characterDebug.json);
        });
        add(saveButton);

        var editorOffset:Float = 100;

        iconInputText = new FlxUIInputText(10, editorOffset, 75, ModdingState.instance.characterDebug.character.json.healthicon);
        insert(0, iconInputText);

        var playerCheckBox:FlxUICheckBox = new FlxUICheckBox(iconInputText.x + iconInputText.width + 10, editorOffset, null, null, "Is Player");
        playerCheckBox.callback = function() {
            ModdingState.instance.characterDebug.character.isPlayer = playerCheckBox.checked;
        }
        insert(0, playerCheckBox);

        imageInputText = new FlxUIInputText(10, playerCheckBox.y + playerCheckBox.height + 10, 175, ModdingState.instance.characterDebug.json.image);
        insert(0, imageInputText);

        var reloadButton:FlxButton = new FlxButton(imageInputText.x + imageInputText.width + 10, imageInputText.y, "Reload", function() {
            ModdingState.instance.characterDebug.json.image = imageInputText.text;
            ModdingState.instance.characterDebug.character.updateCharacter();
        });
        add(reloadButton);

        var flipCheckBox:FlxUICheckBox = new FlxUICheckBox(10, imageInputText.y + imageInputText.height + 10, null, null, "Flip X");
        flipCheckBox.checked = ModdingState.instance.characterDebug.json.flip_x;
        flipCheckBox.callback = function() {
            ModdingState.instance.characterDebug.json.flip_x = flipCheckBox.checked;

            ModdingState.instance.characterDebug.character.flipX = ModdingState.instance.characterDebug.json.flip_x;
			if (ModdingState.instance.characterDebug.character.isPlayer)
                ModdingState.instance.characterDebug.character.flipX = !ModdingState.instance.characterDebug.character.flipX;
        }
        insert(0, flipCheckBox);

        editorOffset = 200;

        animations = [
            for (anim in ModdingState.instance.characterDebug.json.animations)
                anim.name
        ];
        selectedAnim = animations[0];

        var animationsDropDown:FlxUIDropDownMenu = new FlxUIDropDownMenu(10, editorOffset, FlxUIDropDownMenu.makeStrIdLabelArray(animations, true), function(choice:String) {
            selectedAnim = animations[Std.parseInt(choice)];
        });
        insert(0, animationsDropDown);

        var addButton:FlxButton = new FlxButton(animationsDropDown.x + animationsDropDown.width + 10, animationsDropDown.y, "Add/Update", function() {
            var animName:String = nameInputText.text;
            var animAnim:String = animInputText.text;
            var animIndices:Array<Int> = [
                for (ind in indicesInputText.text.split(","))
                    Std.parseInt(ind)
            ];
            var animFps:Int = Std.int(fpsStepper.value);
            var animLoop:Bool = loopCheckBox.checked;

            if (animIndices.length > 0)
                ModdingState.instance.characterDebug.character.animation.addByIndices(animName, animAnim, animIndices, "", animFps, animLoop);
            else
                ModdingState.instance.characterDebug.character.animation.addByPrefix(animName, animAnim, animFps, animLoop);

            ModdingState.instance.characterDebug.json.animations.push({
                name: animName,
                anim: animAnim,
                indices: animIndices,
                fps: animFps,
                loop: animLoop,
                offsets: [0, 0]
            });
            ModdingState.instance.characterDebug.character.addOffset(animName);
        });

        nameInputText = new FlxUIInputText(10, animationsDropDown.y + 30, 175);
        insert(0, nameInputText);

        animInputText = new FlxUIInputText(10, nameInputText.y + nameInputText.height + 10, 175);
        insert(0, animInputText);

        indicesInputText = new FlxUIInputText(10, animInputText.y + animInputText.height + 10, 150);
        insert(0, indicesInputText);

        fpsStepper = new FlxUINumericStepper(indicesInputText.x + indicesInputText.width + 10, indicesInputText.y, 1, 24, 1);
        insert(0, fpsStepper);

        loopCheckBox = new FlxUICheckBox(fpsStepper.x + fpsStepper.width + 10, fpsStepper.y, null, null, "Loop");
        insert(0, loopCheckBox);
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.W) {
            currentAnimation--;
            if (currentAnimation < 0)
                currentAnimation = animations.length - 1;
            else if (currentAnimation > animations.length - 1)
                currentAnimation = 0;

            ModdingState.instance.characterDebug.character.playAnim(animations[currentAnimation]);
        }
        
        if (FlxG.keys.justPressed.S) {
            currentAnimation++;
            if (currentAnimation < 0)
                currentAnimation = animations.length - 1;
            else if (currentAnimation > animations.length - 1)
                currentAnimation = 0;

            ModdingState.instance.characterDebug.character.playAnim(animations[currentAnimation]);
        }

        super.update(elapsed);
    }
}