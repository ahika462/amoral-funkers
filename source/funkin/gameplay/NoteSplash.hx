package funkin.gameplay;

import funkin.shaders.RGBPalette;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class NoteSplash extends FlxSprite
{
	public var rgbShader:RGBShaderReference;

	public function new(x:Float, y:Float, noteData:Int = 0):Void
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('noteSplashes');

		animation.addByPrefix('note1-0', 'note splash blue 1', 24, false);
		animation.addByPrefix('note2-0', 'note splash green 1', 24, false);
		animation.addByPrefix('note0-0', 'note splash purple 1', 24, false);
		animation.addByPrefix('note3-0', 'note splash red 1', 24, false);
		animation.addByPrefix('note1-1', 'note splash blue 2', 24, false);
		animation.addByPrefix('note2-1', 'note splash green 2', 24, false);
		animation.addByPrefix('note0-1', 'note splash purple 2', 24, false);
		animation.addByPrefix('note3-1', 'note splash red 2', 24, false);

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
		angle = FlxG.random.float(-30, 30);

		// offset.set(width * 0.3, height * 0.3);

		rgbShader = new RGBShaderReference(this, Note.createGlobalRGB(noteData));
		shader = rgbShader.parent.shader;

		/*colorSwap.hue = ClientPrefs.data.arrowHSB[noteData][0];
		colorSwap.saturation = ClientPrefs.data.arrowHSB[noteData][1];
		colorSwap.brightness = ClientPrefs.data.arrowHSB[noteData][2];*/
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim == null || animation.curAnim.finished)
			kill();
		else { // да, спиздил оффсеты, и?
			if (animation.curAnim.name.endsWith("0"))
				offset.set(28, 18);
			else if (animation.curAnim.name.endsWith("1"))
				offset.set(12, 12);
		}
		offset.add(70, 70);

		super.update(elapsed);
	}
}
