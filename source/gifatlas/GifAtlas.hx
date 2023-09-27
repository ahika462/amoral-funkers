package gifatlas;

import flixel.graphics.FlxGraphic;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import com.yagp.GifDecoder;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.display.BitmapData;
import com.yagp.Gif;
import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;

class GifAtlas {
    public static function build(path:String):FlxAtlasFrames {
        var folder:String = "assets/amoral/images/" + path + "/";
        var files:Array<String> = FileSystem.readDirectory(folder);

        var bitmapWidth:Int = 0;
        var bitmapHeight:Int = 0;

        var bitmaps:Array<Dynamic> = []; // [x, bitmap, name, num]

        for (file in files) {
            var gif:Gif = GifDecoder.parseBytes(ByteArray.fromFile(folder + file));

            for (frame in gif.frames) {
                bitmaps.push([bitmapWidth, frame.data, file, gif.frames.indexOf(frame)]);
                bitmapWidth += frame.data.width;

                if (frame.data.height > bitmapHeight)
                    bitmapHeight = frame.data.height;
            }
        }

        var bitmapData:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0x00000000);

        for (data in bitmaps) {
            var x:Int = data[0];
            var bitmap:BitmapData = data[1];

            bitmapData.setPixels(new Rectangle(x, 0, bitmap.width, bitmap.height), bitmap.getPixels(bitmap.rect));
        }

        trace("frames found: " + bitmaps.length);

        var frames:FlxAtlasFrames = new FlxAtlasFrames(FlxGraphic.fromBitmapData(bitmapData));
        for (i in 0...bitmaps.length) {
            var x:Int = bitmaps[i][0];
            var bitmap:BitmapData = bitmaps[i][1];
            var name:String = bitmaps[i][2].substring(0, bitmaps[i][2].lastIndexOf(".")) + funnyNum(bitmaps[i][3]);

            frames.addAtlasFrame(new FlxRect(x, 0, bitmap.width, bitmap.height), new FlxPoint(bitmap.width, bitmap.height), new FlxPoint(), name);
        }

        return frames;
    }

    public static function buildSpritesheet(path:String):BitmapData {
        var folder:String = "assets/amoral/images/" + path + "/";
        var files:Array<String> = FileSystem.readDirectory(folder);

        var bitmapWidth:Int = 0;
        var bitmapHeight:Int = 0;

        var bitmaps:Array<Dynamic> = [];

        for (file in files) {
            var gif:Gif = GifDecoder.parseBytes(ByteArray.fromFile(folder + file));

            for (frame in gif.frames) {
                bitmaps.push([bitmapWidth, frame.data, gif]);
                bitmapWidth += frame.data.width;
            }
            bitmapWidth += gif.width;

            if (gif.height > bitmapHeight)
                bitmapHeight = gif.height;
        }

        var bitmapData:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0x00000000);

        for (data in bitmaps) {
            var x:Int = data[0];
            var bitmap:BitmapData = data[1];

            bitmapData.setPixels(new Rectangle(x, 0, bitmap.width, bitmap.height), bitmap.getPixels(new Rectangle(0, 0, bitmap.width, bitmap.height)));
        }

        return bitmapData;
    }

    static function funnyNum(num:Int):String {
        var returnVal:String = Std.string(num);

        while (returnVal.length < 4)
            returnVal = "0" + returnVal;

        return returnVal;
    }
}