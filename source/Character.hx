package;

import animateatlas.AtlasFrameMaker;
import haxe.Json;
import Section.SwagSection;
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
}

typedef AnimArray = {
	var offsets:Array<Float>;
	var loop:Bool;
	var fps:Int;
	var anim:String;
	var indices:Array<Int>;
	var name:String;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var animationNotes:Array<Dynamic> = [];

	public var healthIcon:String = "face";
	public var specAnim:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = true;

		switch(curCharacter) {
			default:
				var json:CharacterFile = cast Json.parse(Paths.getEmbedText("characters/" + character + ".json"));
		
				if (Paths.exists("images/" + json.image + ".xml", TEXT))
					frames = Paths.getSparrowAtlas(json.image);
				else if (Paths.exists("images/" + json.image + ".txt", TEXT))
					frames = Paths.getPackerAtlas(json.image);
				else if (Paths.exists("images/" + json.image + "/Animation.json", TEXT))
					frames = AtlasFrameMaker.construct(json.image);
		
				antialiasing = json.no_antialiasing ? false : ClientPrefs.data.antialiasing;
				healthIcon = json.healthicon;
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
		else
			playAnim("danceLeft");

		if (character == "pico-speaker") {
			playAnim("shoot" + FlxG.random.int(1, 4) + "-loop");
			loadMappedAnims();
		}

		dance();
		animation.finish();

		if (isPlayer)
			flipX = !flipX;
	}

	public function loadMappedAnims()
	{
		var swagshit = Song.loadFromJson('picospeaker', 'stress');

		var notes = swagshit.notes;

		for (section in notes)
		{
			for (idk in section.sectionNotes)
			{
				animationNotes.push(idk);
			}
		}

		TankmenBG.animationNotes = animationNotes;

		animationNotes.sort(sortAnims);
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
			if (animation.curAnim.name.startsWith("sing"))
				holdTimer += elapsed;

			var dadVar:Float = 4;

			if (curCharacter == "dad")
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001) {
				dance();
				holdTimer = 0;
			}
		}

		if (animation.curAnim.finished && animation.exists(animation.curAnim.name + "-loop"))
			playAnim(animation.curAnim.name + "-loop");

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
			case "pico-speaker":
				// for pico??
				if (animationNotes.length > 0)
				{
					if (Conductor.songPosition > animationNotes[0][0])
					{
						var shootAnim:Int = 1;

						if (animationNotes[0][1] >= 2)
							shootAnim = 3;

						shootAnim += FlxG.random.int(0, 1);

						playAnim('shoot' + shootAnim, true);
						animationNotes.shift();
					}
				}

				if (animation.curAnim.finished)
				{
					playAnim(animation.curAnim.name, false, false, animation.curAnim.numFrames - 3);
				}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			if (!specAnim || animation.curAnim.finished) {
				if (animation.exists("idle"))
					playAnim("idle");
				else if (animation.exists("danceLeft")) {
					if (!animation.curAnim.name.startsWith('hair')) {
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
