package gifatlas;

import openfl.utils.Assets;
import flixel.graphics.FlxGraphic;
import openfl.utils.ByteArray;
import com.yagp.GifDecoder;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import com.yagp.Gif;
import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class GifAtlas {
    public static function build(path:String, ?library:String):FlxAtlasFrames {
        var folder:String = getPath("images/" + path + "/", library);
        var files:Array<String> = FileSystem.readDirectory(folder);

        var atlases:Array<FlxAtlasFrames> = [];

        if (files == null)
            return null;

        for (file in files) {
            var gif:Gif = GifDecoder.parseByteArray(ByteArray.fromFile(folder + file));

            for (frame in gif.frames) {
                var atlas:FlxAtlasFrames = new FlxAtlasFrames(FlxGraphic.fromBitmapData(frame.data));
                atlas.addAtlasFrame(new FlxRect(0, 0, frame.data.width, frame.data.height), new FlxPoint(frame.data.width, frame.data.height), new FlxPoint(), file + funnyNum(gif.frames.indexOf(frame)));

                atlases.push(atlas);
            }
        }

        var frames:FlxAtlasFrames = new FlxAtlasFrames(null);
        frames.frames = [];
        for (atlas in atlases)
            frames.frames = frames.frames.concat(atlas.frames);

        return frames;
    }

    static function getPath(folder:String, ?library:String):String {
        if (library != null)
			return Paths.getLibraryPath(folder, library);

        @:privateAccess {
            if (Paths.currentLevel != null) {
                var levelPath = "assets/" + Paths.currentLevel + "/" + folder;
                if (folderExists(levelPath))
                    return levelPath;
    
                levelPath = "assets/shared/" + folder;
                if (folderExists(levelPath))
                    return levelPath;
            }
        }

		return Paths.getPreloadPath(folder);
    }

    static function folderExists(folder:String):Bool {
        folder = folder.substr(folder.indexOf(":") + 1);
        Debug.logTrace(folder);

        var returnVal:Bool = false;

        var files:Array<String> = Assets.list(IMAGE);
        for (file in files) {
            var fileExt:String = file.substr(file.lastIndexOf("."));
            var filePath:String = file.substring(0, file.lastIndexOf("/"));
            var fileFuckedPath:String = file.substring(0, file.lastIndexOf("/") + 1);

            if (fileExt == ".gif" && (filePath.endsWith(folder) || fileFuckedPath.endsWith(folder)))
                returnVal = true;
        }

        return returnVal;
    }

    static function funnyNum(num:Int):String {
        var returnVal:String = Std.string(num);

        while (returnVal.length < 4)
            returnVal = "0" + returnVal;

        return returnVal;
    }
}