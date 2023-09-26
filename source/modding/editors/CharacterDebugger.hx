package modding.editors;

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

    public function new(char:String = "bf") {
        super();

        var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
        add(bg);

        var stageFront:BGSprite = new BGSprite("stagefront", -650, 600, 0.9, 0.9);
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        add(stageFront);
        
        var stageCurtains:BGSprite = new BGSprite("stagecurtains", -500, -300, 1.3, 1.3);
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
        stageCurtains.updateHitbox();
        add(stageCurtains);

        character = new EditorCharacter(400, 130, cast Json.parse(Paths.getEmbedText("characters/" + curCharacter + ".json")).character, false);
        add(character);

        curCharacter = char;
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
}