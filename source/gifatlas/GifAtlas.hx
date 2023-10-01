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
        var folder:String = "assets/shared/images/" + path + "/";
        var files:Array<String> = FileSystem.readDirectory(folder);

        var bitmaps:Array<FlxAtlasFrames> = [];

        for (file in files) {
            var gif:Gif = GifDecoder.parseByteArray(ByteArray.fromFile(folder + file));

            for (frame in gif.frames) {
                var atlas:FlxAtlasFrames = new FlxAtlasFrames(FlxGraphic.fromBitmapData(frame.data));
                atlas.addAtlasFrame(new FlxRect(0, 0, frame.data.width, frame.data.height), new FlxPoint(frame.data.width, frame.data.height), new FlxPoint(), file + funnyNum(gif.frames.indexOf(frame)));

                bitmaps.push(atlas);
            }
        }

        var frames:FlxAtlasFrames = new FlxAtlasFrames(null);
        frames.frames = bitmaps[0].frames;
        for (bitmap in bitmaps)
            frames.frames = frames.frames.concat(bitmap.frames);

        return frames;
    }

    static function funnyNum(num:Int):String {
        var returnVal:String = Std.string(num);

        while (returnVal.length < 4)
            returnVal = "0" + returnVal;

        return returnVal;
    }
}