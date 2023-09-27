import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.graphics.FlxGraphic;
import openfl.geom.Rectangle;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxAtlasFrames;

class CombinedAtlas {
    public function combine(atlases:Array<FlxAtlasFrames>):FlxAtlasFrames {
        var atlasDatas:Array<{atlas:FlxAtlasFrames, startX:Int}> = [];

        var bitmapWidth:Int = 0;
        var bitmapHeight:Int = 0;

        for (atlas in atlases) {
            atlasDatas.push({atlas: atlas, startX: bitmapWidth});
            bitmapWidth += atlas.parent.width;
            if (atlas.parent.height > bitmapHeight)
                bitmapHeight = atlas.parent.height;
        }

        var bitmap:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, FlxColor.TRANSPARENT);
        for (data in atlasDatas) {
            bitmap.setPixels(new Rectangle(data.startX, 0, data.atlas.parent.width, data.atlas.parent.height), data.atlas.parent.bitmap.getPixels(data.atlas.parent.bitmap.rect));
        }
        
        var frames:FlxAtlasFrames = new FlxAtlasFrames(FlxGraphic.fromBitmapData(bitmap));

        for (data in atlasDatas) {
            for (frame in data.atlas.frames) {
                frames.addAtlasFrame(new FlxRect(frame.frame.x + data.startX, frame.frame.y, frame.frame.width, frame.frame.height), new FlxPoint(bitmap.width, bitmap.height), new FlxPoint(), frame.name, frame.angle, frame.flipX, frame.flipY, frame.duration);
            }
        }

        return frames;
    }
}