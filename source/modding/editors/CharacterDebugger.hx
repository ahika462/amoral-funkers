package modding.editors;

import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import gifatlas.GifAtlas;
import animateatlas.AtlasFrameMaker;
import flixel.FlxSprite;
import haxe.Json;
import Character;

class CharacterDebugger extends BaseDebugger {
    public var curCharacter(default, set):String = "bf";
    public var character:EditorCharacter;

    public var json(get, set):CharacterFile;

    var offsetTxt:FlxText;

    public function new(char:String = "bf") {
        super();

        var bg:FlxSprite = FlxGridOverlay.create(10, 10);
        bg.scrollFactor.set(0.5, 0.5);
        add(bg);

        character = new EditorCharacter(400, 130, cast Json.parse(Paths.getEmbedText("characters/" + curCharacter + ".json")).character, false);
        add(character);

        curCharacter = char;

        offsetTxt = new FlxText(ModdingState.instance.mainTabUI.x + ModdingState.instance.mainTabUI.width + 10, 10, FlxG.width, "");
        offsetTxt.setFormat(Paths.font("vcr.ttf"), 16, OUTLINE, FlxColor.BLACK);
        add(offsetTxt);

        for (anim in character.animation.getNameList())
            offsetTxt.text += anim + ": " + character.animOffsets[anim] + "\n";
    }

    override function update(elapsed:Float) {
        offsetTxt.text = "";
        for (anim in character.getAnimNames())
            offsetTxt.text += anim + ": " + character.animOffsets[anim] + "\n";

        if (!ModdingState.instance.anyFocused) {
            if (FlxG.keys.pressed.J)
                character.velocity.x = 300;
            else if (FlxG.keys.pressed.L)
                character.velocity.x = -300;
            else
                character.velocity.x = 0;
    
            if (FlxG.keys.pressed.I)
                character.velocity.y = 300;
            else if (FlxG.keys.pressed.K)
                character.velocity.y = -300;
            else
                character.velocity.y = 0;

            if (character.animation.curAnim != null) {
                if (FlxG.keys.justPressed.W) {
                    var curAnim:Int = character.animation.getNameList().indexOf(character.animation.curAnim.name);
                    curAnim--;
                    if (curAnim < 0)
                        curAnim = character.animation.getNameList().length - 1;
                    else if (curAnim > character.animation.getNameList().length - 1)
                        curAnim = 0;
        
                    character.playAnim(character.animation.getNameList()[curAnim]);
                }
                
                if (FlxG.keys.justPressed.S) {
                    var curAnim:Int = character.animation.getNameList().indexOf(character.animation.curAnim.name);
                    curAnim++;
                    if (curAnim < 0)
                        curAnim = character.animation.getNameList().length - 1;
                    else if (curAnim > character.animation.getNameList().length - 1)
                        curAnim = 0;
        
                    character.playAnim(character.animation.getNameList()[curAnim]);
                }

                var offsetAdd:Int = FlxG.keys.pressed.SHIFT ? 10 : 1;
                if (FlxG.keys.justPressed.UP)
                    character.animOffsets[character.animation.curAnim.name][1] += offsetAdd;
                if (FlxG.keys.justPressed.DOWN)
                    character.animOffsets[character.animation.curAnim.name][1] -= offsetAdd;
                if (FlxG.keys.justPressed.LEFT)
                    character.animOffsets[character.animation.curAnim.name][0] += offsetAdd;
                if (FlxG.keys.justPressed.RIGHT)
                    character.animOffsets[character.animation.curAnim.name][0] -= offsetAdd;

                if (FlxG.keys.anyJustPressed([UP, DOWN, LEFT, RIGHT]))
                    character.playAnim(character.animation.curAnim.name);
            } else {
                if (FlxG.keys.anyJustPressed([W, S])) {
                    var animToPlay:String = character.getAnimNames()[0];
                    if (character.animation.exists(animToPlay))
                        character.animation.play(animToPlay);
                }
            }
        }
        super.update(elapsed);
    }

    function set_curCharacter(value:String):String {
        character.json = cast Json.parse(Paths.getEmbedText("characters/" + value + ".json")).character;
        this.curCharacter = value;
        character.updateCharacter();

        return curCharacter = value;
    }

    function set_json(value:CharacterFile):CharacterFile {
        return character.json = value;
    }

    function get_json():CharacterFile {
        return character.json;
    }
}

class EditorCharacter extends FlxSprite {
    public var json:CharacterFile = null;
    public var isPlayer(default, set):Bool = false;
    public var animOffsets:Map<String, Array<Float>> = [];

    public function new(x:Float = 0, y:Float = 0, json:CharacterFile, isPlayer:Bool) {
        super(x, y);
        this.json = json;
        this.isPlayer = isPlayer;
        updateCharacter();
    }

    public function updateCharacter() {
        
        if (Paths.exists("images/" + json.image + ".xml", TEXT))
            frames = Paths.getSparrowAtlas(json.image);
        else if (Paths.exists("images/" + json.image + ".txt", TEXT))
            frames = Paths.getPackerAtlas(json.image);
        else if (Paths.exists("images/" + json.image + "/Animation.json", TEXT))
            frames = AtlasFrameMaker.construct(json.image);
        else
            frames = GifAtlas.build(json.image);

        antialiasing = json.no_antialiasing ? false : ClientPrefs.data.antialiasing;
        flipX = isPlayer ? !json.flip_x : json.flip_x;
        scale.set(json.scale, json.scale);

        var animationsArray:Array<AnimArray> = json.animations;
        if (animationsArray != null && animationsArray.length > 0) {
            for (anim in animationsArray) {
                var animAnim:String = "" + anim.anim;
                var animName:String = "" + anim.name;
                var animFps:Int = anim.fps;
                var animLoop:Bool = !!anim.loop; //Bruh
                var animIndices:Array<Int> = anim.indices;

                if (animIndices != null && animIndices.length > 0)
                    animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
                else
                    animation.addByPrefix(animAnim, animName, animFps, animLoop);

                if (anim.offsets != null && anim.offsets.length > 1)
                    addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
            }
        } else
            animation.addByPrefix("idle", "BF idle dance", 24, false);

        updateHitbox();

        playAnim(animation.getNameList()[0]);
    }

    public function addOffset(anim:String, x:Float = 0, y:Float = 0) {
        animOffsets.set(anim, [x, y]);
    }

    function set_isPlayer(value:Bool):Bool {
        if (isPlayer != value)
            flipX = !flipX;

        return isPlayer = value;
    }

    public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0) {
        animation.play(AnimName, Force, Reversed, Frame);

        var daOffset = animOffsets.get(AnimName);
        if (animOffsets.exists(AnimName))
        {
            offset.set(daOffset[0], daOffset[1]);
        }
        else
            offset.set(0, 0);
    }

    public function getAnimNames():Array<String> {
        return [
            for (anim in json.animations)
                anim.anim
        ];
    }
}