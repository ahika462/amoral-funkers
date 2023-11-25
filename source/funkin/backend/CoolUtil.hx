package funkin.backend;

import flixel.util.FlxColor;
import openfl.display3D.textures.RectangleTexture;
import openfl.display.BitmapData;
import flixel.math.FlxMath;
import flixel.FlxG;
import openfl.utils.Assets;

using StringTools;

class CoolUtil {
    public static var difficultyArray:Array<String> = ["EASY", "NORMAL", "HARD"];

    /**
     * Returns the current difficulty name
     * @return String
     */
    public static function difficultyString():String {
        return difficultyArray[PlayState.storyDifficulty];
    }

    /**
     * Returns an array from the file
     * @param path 
     * @return Array<String>
     */
    public static function coolTextFile(path:String):Array<String> {
        var returnVal:Array<String> = Assets.getText(path).trim().split("\n");
        for (i in 0...returnVal.length)
            returnVal[i] = returnVal[i].trim();

        return returnVal;
    }

    /**
     * Lerp accounts for framerate
     * @return Float
     */
    public static function camLerpShit(lerp:Float):Float {
        // return FlxMath.bound(FlxG.elapsed * lerp * 3, 0, 1);
        return lerp; // я хз блять
        return lerp / (60 / FlxG.updateFramerate);
    }

    /**
     * Automatically does a camLerpShit
     * @param a 
     * @param b 
     * @param ratio 
     * @return Float
     */
    public static function coolLerp(a:Float, b:Float, ratio:Float):Float {
        return FlxMath.lerp(a, b, camLerpShit(ratio));
    }

    /**
     * Opens the link in the browser
     * @param url 
     */
    public static function coolOpenURL(url:String) {
        #if linux
        Sys.command('/usr/bin/xdg-open', [url, "&"]);
        #else
        FlxG.openURL(url);
        #end
    }

    /**
     * Loads BitmapData using Context3D
     * @param bmp 
     * @return BitmapData
     */
    public static function loadByGPU(bmp:BitmapData):BitmapData {
		if (!ClientPrefs.data.gpuRender || bmp == null || bmp.image == null)
			return bmp;
		
		var texture:RectangleTexture = FlxG.stage.context3D.createRectangleTexture(bmp.width, bmp.height, BGRA, true);
		texture.uploadFromBitmapData(bmp);

		bmp.image.data = null;
		bmp.dispose();
		bmp = BitmapData.fromTexture(texture);

		return bmp;
	}

    /**
     * Reads the FlxColor from the string
     * @param color 
     * @return FlxColor
     */
    public static function colorFromString(color:String):FlxColor {
		var color:String = ~/[\t\n\r]/.split(color).join('').trim();

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if (colorNum == null)
			colorNum = FlxColor.fromString("#" + color);
		return colorNum != null ? colorNum : 0xFFFFFFFF;
	}
}