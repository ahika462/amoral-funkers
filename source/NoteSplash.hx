package;

import shaderslmfao.ColorSwap;
import flixel.FlxG;
import flixel.FlxSprite;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap;

	public function new(x:Float, y:Float, noteData:Int = 0):Void
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('noteSplashes');

		animation.addByPrefix('note1-0', 'note impact 1  blue', 24, false);
		animation.addByPrefix('note2-0', 'note impact 1 green', 24, false);
		animation.addByPrefix('note0-0', 'note impact 1 purple', 24, false);
		animation.addByPrefix('note3-0', 'note impact 1 red', 24, false);
		animation.addByPrefix('note1-1', 'note impact 2 blue', 24, false);
		animation.addByPrefix('note2-1', 'note impact 2 green', 24, false);
		animation.addByPrefix('note0-1', 'note impact 2 purple', 24, false);
		animation.addByPrefix('note3-1', 'note impact 2 red', 24, false);

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, noteData);

		// alpha = 0.75;
	}

	public function setupNoteSplash(x:Float, y:Float, noteData:Int = 0)
	{
		setPosition(x, y);
		alpha = 0.6;

		animation.play('note' + noteData + '-' + FlxG.random.int(0, 1), true);
		/*#if (flixel >= "5.4.0")
		animation.timeScale += FlxG.random.float(-2 / 24, 2 / 24);
		#else
		animation.curAnim.frameRate += FlxG.random.int(-2, 2);
		#end*/
		updateHitbox();

		offset.set(width * 0.3, height * 0.3);

		colorSwap.hue = ClientPrefs.data.arrowHSB[noteData][0];
		colorSwap.saturation = ClientPrefs.data.arrowHSB[noteData][1];
		colorSwap.brightness = ClientPrefs.data.arrowHSB[noteData][2];
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
}
