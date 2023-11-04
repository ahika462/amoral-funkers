package;

import flixel.util.FlxColor;
import openfl.display3D.textures.RectangleTexture;
import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import haxe.Json;
import lime.math.Rectangle;
import lime.utils.Assets;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	/**
		Lerps camera, but accountsfor framerate shit?
		Right now it's simply for use to change the followLerp variable of a camera during update
		TODO LATER MAYBE:
			Actually make and modify the scroll and lerp shit in it's own function
			instead of solely relying on changing the lerp on the fly
	 */
	public static function camLerpShit(lerp:Float):Float
	{
		return lerp * (FlxG.elapsed / (1 / 60));
	}

	/*
	* just lerp that does camLerpShit for u so u dont have to do it every time
	*/
	public static function coolLerp(a:Float, b:Float, ratio:Float):Float
	{
		return FlxMath.lerp(a, b, camLerpShit(ratio));
	}

	public static function coolOpenURL(url:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [
			url,
			"&"
		]);
		#else
		FlxG.openURL(url);
		#end
	}

	public static function floorDecimal(value:Float, decimals:Int):Float {
		if (decimals < 1)
			return Math.floor(value);

		var tempMult:Float = 1;
		tempMult *= (decimals * 10);
		
		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function loadByGPU(bmp:BitmapData):BitmapData {
		var texture:RectangleTexture = FlxG.stage.context3D.createRectangleTexture(bmp.width, bmp.height, BGRA, true);
		texture.uploadFromBitmapData(bmp);

		bmp.image.data = null;
		bmp.dispose();
		bmp.disposeImage();
		bmp = BitmapData.fromTexture(texture);

		return bmp;
	}

	public static function colorFromString(color:String):FlxColor {
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		/*if (color.startsWith("0x"))
			color = color.substring(color.length - 6);*/

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if (colorNum == null)
			colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : 0xFFFFFFFF;
	}
}