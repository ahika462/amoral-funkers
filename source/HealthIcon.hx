package;

import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	inline public static var DEFAULT_ICON:String = "face";
	inline public static var DEFAULT_PLAYER:String = "slimeboy";
	inline public static var DEFAULT_OPPONENT:String = "minimaxfla";

	var char:String = '';
	var isPlayer:Bool = false;

	public function new(char:String = DEFAULT_ICON, isPlayer:Bool = false)
	{
		super();

		this.isPlayer = isPlayer;

		changeIcon(char);
		antialiasing = true;
		scrollFactor.set();
	}

	public var isOldIcon:Bool = false;

	public function swapOldIcon():Void
	{
		isOldIcon = !isOldIcon;

		if (isOldIcon)
			changeIcon('bf-old');
		else
			changeIcon(PlayState.SONG.player1);
	}

	public function changeIcon(newChar:String):Void
	{
		if (newChar != char)
		{
			if (animation.getByName(newChar) == null)
			{
				if (Paths.exists("images/icons/icon-" + newChar + ".png", IMAGE))
					loadGraphic(Paths.image("icons/icon-" + newChar), true, 150, 150);
				else
					loadGraphic(Paths.image("icons/icon-" + DEFAULT_ICON), true, 150, 150);

				animation.add(newChar, [0, 1], 0, false, isPlayer);
			}
			animation.play(newChar);
			char = newChar;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
