package funkin.gameplay;

import flixel.util.FlxColor;
import gifatlas.GifAtlas;
import animateatlas.AtlasFrameMaker;
import haxe.Json;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSort;
import haxe.io.Path;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var no_antialiasing:Bool;
	var image:String;
	var healthicon:String;
	var flip_x:Bool;
	var scale:Float;
	var healthbar_colors:Array<Int>;
	var position:Array<Float>;
	var camera_position:Array<Float>;
}

typedef AnimArray = {
	var offsets:Array<Float>;
	var loop:Bool;
	var fps:Int;
	var anim:String;
	var indices:Array<Int>;
	var name:String;
}

class Character extends FlxSprite {
	inline public static var DEFAULT_CHARACTER:String = "bf";

	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer(default, set):Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var holdTimer:Float = 0;

	public var healthIcon:String = "bf";
	public var specAnim:Bool = false;

	public var healthColor:FlxColor = FlxColor.WHITE;
	public var danceBeats:Int = 2;

	public var json:CharacterFile;

	public function new(x:Float, y:Float, ?character:String = DEFAULT_CHARACTER, ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = ClientPrefs.data.antialiasing;

		switch(curCharacter) {
			default:
				if (!Paths.embedExists("characters/" + character + ".json"))
					character = DEFAULT_CHARACTER;

				json = cast Json.parse(Paths.getEmbedText("characters/" + character + ".json")).character;
		
				if (Paths.exists("images/" + json.image + ".xml", TEXT))
					frames = Paths.getSparrowAtlas(json.image);
				else if (Paths.exists("images/" + json.image + ".txt", TEXT))
					frames = Paths.getPackerAtlas(json.image);
				else if (Paths.exists("images/" + json.image + "/Animation.json", TEXT))
					frames = AtlasFrameMaker.construct(json.image);
				else
					frames = GifAtlas.build(json.image);
		
				antialiasing = json.no_antialiasing ? false : ClientPrefs.data.antialiasing;

				healthIcon = json.healthicon;
				healthColor.red = json.healthbar_colors[0];
				healthColor.green = json.healthbar_colors[1];
				healthColor.blue = json.healthbar_colors[2];

				if (json.flip_x)
					flipX = !flipX;
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
					quickAnimAdd('idle', 'BF idle dance');
		}
		updateHitbox();

		if (animation.exists("idle"))
			playAnim("idle");
		else {
			danceBeats = 1;
			playAnim("danceLeft");
		}

		dance();
		animation.finish();
	}

	function set_isPlayer(value:Bool):Bool {
		if (isPlayer != value)
			flipX = !flipX;

		return isPlayer = value;
	}

	function sortAnims(val1:Array<Dynamic>, val2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, val1[0], val2[0]);
	}

	function quickAnimAdd(name:String, prefix:String)
	{
		animation.addByPrefix(name, prefix, 24, false);
	}

	override function update(elapsed:Float) {
		if (!isPlayer) {
			if (animation.curAnim != null && animation.curAnim.name.startsWith("sing"))
				holdTimer += elapsed;

			var dadVar:Float = 4;

			if (curCharacter == "dad")
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001) {
				dance();
				holdTimer = 0;
			}
		}

		if (animation.curAnim != null && animation.curAnim.finished && animation.exists(animation.curAnim.name + "-loop"))
			playAnim(animation.curAnim.name + "-loop");

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim != null && animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;
	public function dance()
	{
		if (!debugMode)
		{
			if (!specAnim || animation.curAnim != null && animation.curAnim.finished) {
				if (animation.exists("idle"))
					playAnim("idle");
				else if (animation.exists("danceLeft")) {
					if (animation.curAnim != null && !animation.curAnim.name.startsWith('hair')) {
						danced = !danced;
	
						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				}
				specAnim = false;
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf') {
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;

			if (AnimName.startsWith("hair"))
				specAnim = true;
		} 
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0) {
		animOffsets[name] = [x, y];
	}
}
