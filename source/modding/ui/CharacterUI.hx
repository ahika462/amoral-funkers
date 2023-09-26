package modding.ui;

import flixel.FlxG;
import flixel.addons.ui.FlxUICheckBox;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUI;

class CharacterUI extends FlxUI {
    public var iconInputText:FlxUIInputText;
    public var imageInputText:FlxUIInputText;

    var characterList:Array<String> = [];

    var animations:Array<String> = [];
    var currentAnimation:Int = 0;

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

        var animationsDropDown:FlxUIDropDownMenu = new FlxUIDropDownMenu(10, editorOffset, FlxUIDropDownMenu.makeStrIdLabelArray(animations, true), function(choice:String) {
            currentAnimation = Std.parseInt(choice);
        });
        add(animationsDropDown);
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