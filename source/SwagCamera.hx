package;

import flixel.FlxG;
import openfl.geom.Matrix;
import flixel.math.FlxPoint;
import flixel.FlxCamera;

class SwagCamera extends FlxCamera
{
	public var rotationOffset(default, set):FlxPoint = FlxPoint.get(0.5, 0.5);
	var viewOffset:FlxPoint = FlxPoint.get();

	override function update(elapsed:Float) {
		super.update(elapsed);
		fixRotatedView();
	}

	public function set_rotationOffset(newValue:FlxPoint):FlxPoint {
		rotationOffset = newValue;
		fixRotatedView();
		return newValue;
	}

	public function fixRotatedView() {
		flashSprite.x -= _flashOffset.x;
		flashSprite.y -= _flashOffset.y;
		
		var matrix:Matrix = new Matrix();
		// matrix.concat(canvas.transform.matrix); // DON'T EVEN THINK ABOUT IT.
		matrix.translate(-width * rotationOffset.x, -height * rotationOffset.y);
		matrix.scale(scaleX, scaleY);
		matrix.rotate(angle * (Math.PI / 180));
		matrix.translate(width * rotationOffset.x, height * rotationOffset.y);
		matrix.translate(flashSprite.x, flashSprite.y);
		matrix.scale(FlxG.scaleMode.scale.x, FlxG.scaleMode.scale.y);
		canvas.transform.matrix = matrix;

		flashSprite.x = width * 0.5 * FlxG.scaleMode.scale.x;
		flashSprite.y = height * 0.5 * FlxG.scaleMode.scale.y;
		flashSprite.rotation = 0;
	}
}