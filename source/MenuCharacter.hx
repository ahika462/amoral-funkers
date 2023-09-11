package;

import haxe.Json;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

typedef MenuCharacterFile = {
	var image:String;
	var position:Array<Float>;
	var scale:Float;
	var idle_anim:String;
	var confirm_anim:String;
}

class MenuCharacter extends FlxSprite
{
	public var character(default, set):String;

	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		this.character = character;

		animation.play(character);
		updateHitbox();
	}

	public function set_character(value:String):String {
		if (character == value)
			return character;

		antialiasing = ClientPrefs.data.antialiasing;
		visible = true;

		scale.set(1, 1);
		updateHitbox();

		switch(value) {
			case "":
				visible = false;

			default:
				var json:MenuCharacterFile = cast Json.parse(Paths.getEmbedText("menucharacters/" + value + ".json"));

				frames = Paths.getSparrowAtlas("menucharacters/" + json.image);
				offset.set(json.position[0], json.position[1]);
				scale.set(json.scale, json.scale);
				animation.addByPrefix(value, json.idle_anim, 24, true);
				animation.addByPrefix("bfConfirm", json.confirm_anim, 24, false);
				animation.play(value);
		
				updateHitbox();
		}

		return character = value;
	}
}
