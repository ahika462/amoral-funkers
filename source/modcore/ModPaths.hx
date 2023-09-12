package modcore;

import sys.io.File;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.text.Font;
import openfl.display.BitmapData;
import flixel.FlxG;
import openfl.media.Sound;
import sys.FileSystem;
import modcore.ModCore.ModMetadata;

class ModPaths {
    static var currentLevel:String;

    public static function setCurrentLevel(name:String) {
        currentLevel = name.toLowerCase();
    }

    public static function getPath(file:String, ?library:String):String {
        if (library != null)
            return getLibraryPath(file, library);

        if (currentLevel != null) {
            var levelPath:String = getLibraryPathForce(file, currentLevel);
            if (FileSystem.exists(levelPath))
                return levelPath;

            levelPath = getLibraryPathForce(file, "shared");
            if (FileSystem.exists(levelPath))
                return levelPath;
        }

        return getPreloadPath(file, mod);
    }

    public static function getLibraryPath(file:String, library:String = "preload"):String {
        return (library == "preload" || library == "default") ? getPreloadPath(file) : getLibraryPathForce(file, library);
    }

    public static function getLibraryPathForce(file:String, library:String = "preload"):String {
        return ModCore.current.path + "/assets/" + library + "/" + file;
    }

    public static function getPreloadPath(file:String,):String {
        return ModCore.current.path + "/assets/" + file;
    }

    public static function file(file:String, ?library:String):String {
        return getPath(file, library);
    }

    public static function txt(key:String, ?library:String):String {
        return getPath("data/" + key + ".txt", library);
    }

    public static function xml(key:String, ?library:String):String {
        return getPath("data/" + key + ".xml", library);
    }

    public static function json(key:String, ?library:String):String {
        return getPath("data/" + key + ".json", library);
    }

    public static function sound(key:String, ?library:String):Sound {
        return Sound.fromFile(getPath("sounds/" + key + "." + Paths.SOUND_EXT, library));
    }

    public static function soundRandom(key:String, min:Int, max:Int, ?library:String):Sound {
        return sound(key + FlxG.random.int(min, max), library);
    }

    public static function music(key:String, library:String):Sound {
        return Sound.fromFile(getPath("music/" + key + "." + Paths.SOUND_EXT, library));
    }

    public static function voices(song:String):Sound {
        return Sound.fromFile(ModCore.current.path + "assets/songs/" + song.toLowerCase() + "/Voices." + Paths.SOUND_EXT);
    }

    public static function inst(song:String):Sound {
        return Sound.fromFile(ModCore.current.path + "assets/songs/" + song.toLowerCase() + "/Inst." + Paths.SOUND_EXT);
    }

    public static function image(key:String, ?library:String):BitmapData {
        return BitmapData.fromFile(getPath("images/" + key + ".png", library));
    }

    public static function font(key:String) {
        return Font.fromFile(ModCore.current.path + "/assets/fonts/" + key);
    }

    public static function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames {
        return FlxAtlasFrames.fromSparrow(image(key, library), file("images/" + key + ".xml", library));
    }

    public static function getPackerAtlas(key:String, ?library:String):FlxAtlasFrames {
        return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file("images/" + key + ".txt", library));
    }

    public static function getTextFromFile(key:String, ?library:String):String {
        return File.getContent(getPath(key, library));
    }

    public static function exists(key:String, ?library:String):Bool {
        return FileSystem.exists(getPath(key, library));
    }
}