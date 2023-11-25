package funkin.backend;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.media.Sound;
import funkin.backend.debug.Gc;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import haxe.io.Path;
import openfl.utils.Assets as DaAssets;
import openfl.utils.AssetType;

class Paths {
    public static var memory:Memory = new Memory();
    public static var assets:Assets = new Assets();
    public static var atlas:Atlases = new Atlases();

    inline public static var SOUND_EXT:String = #if web ".mp3" #else ".ogg" #end;

    public static var currentLevel(null, default):String = null;

    public static function getPath(key:String, type:AssetType, library:String = null):String {
        if (library != null)
            return getLibraryPath(key, library);

        if (currentLevel != null) {
            var levelPath:String = getLibraryPathForce(key, currentLevel);
            if (DaAssets.exists(levelPath, type))
                return levelPath;

            levelPath = getLibraryPathForce(key, "shared");
            if (DaAssets.exists(levelPath, type))
                return levelPath;
        }

        return getPreloadPath(key);
    }

    public static function getLibraryPath(key:String, library:String = "preload"):String {
        return switch(library) {
            case "preload" | "default": getPreloadPath(key);
            default: getLibraryPathForce(key, library);
        }
    }

    public static function getLibraryPathForce(key:String, library:String):String {
        return library + ":" + getPreloadPath(Path.join([library, key]));
    }

    public static function getPreloadPath(key:String):String {
        return Path.join(["assets", key]);
    }
}

@:allow(funkin.backend.Paths)
private class Memory {
    function new() {}

    private var localTrackedAssets:Array<String> = [];
    var currentTrackedImages(get, never):Map<String, FlxGraphic>;
    var currentTrackedSounds:Map<String, Dynamic> = [];

    function get_currentTrackedImages():Map<String, FlxGraphic> {
        @:privateAccess {
            return FlxG.bitmap._cache;
        }
    }
    
    public function clearStored() {
        for (path => asset in currentTrackedImages) {
            if (asset == null || localTrackedAssets.contains(path))
                continue;

            DaAssets.cache.removeBitmapData(path);
            currentTrackedImages.remove(path);
            asset.destroy();
        }

        for (path => asset in currentTrackedSounds) {
            if (asset == null || localTrackedAssets.contains(path))
                continue;

            DaAssets.cache.removeSound(path);
            currentTrackedSounds.remove(path);
        }

        localTrackedAssets = [];
        DaAssets.cache.clear("songs");

        Gc.minor();
    }

    public function clearUnused() {
        for (path => asset in currentTrackedImages) {
            if (asset == null || localTrackedAssets.contains(path))
                continue;

            DaAssets.cache.removeBitmapData(path);
            currentTrackedImages.remove(path);
            asset.destroy();
        }
        
        Gc.major();
    }
}

@:allow(funkin.backend.Paths)
private class Assets {
    function new() {}

    public function image(key:String, library:String = null):FlxGraphic {
        var path:String = Paths.getPath(Path.join(["images", key]) + ".png", IMAGE, library);

        Paths.memory.localTrackedAssets.push(path);

        if (Paths.memory.currentTrackedImages.exists(path))
            return Paths.memory.currentTrackedImages.get(path);

        var asset:FlxGraphic = FlxGraphic.fromBitmapData(DaAssets.getBitmapData(path));
        asset.persist = true;
		asset.destroyOnNoUse = false;

        return asset;
    }

    public function sound(key:String, library:String = null):Sound {
        var path:String = Paths.getPath(Path.join(["sounds", key]) + Paths.SOUND_EXT, SOUND, library);

        Paths.memory.localTrackedAssets.push(path);

        if (Paths.memory.currentTrackedSounds.exists(path))
            return Paths.memory.currentTrackedSounds.get(path);

        var asset:Sound = DaAssets.getSound(path);
        Paths.memory.currentTrackedSounds.set(path, asset);

        return asset;
    }

    public function music(key:String, library:String = null):Sound {
        var path:String = Paths.getPath(Path.join(["music", key]) + Paths.SOUND_EXT, SOUND, library);

        Paths.memory.localTrackedAssets.push(path);

        if (Paths.memory.currentTrackedSounds.exists(path))
            return Paths.memory.currentTrackedSounds.get(path);

        var asset:Sound = DaAssets.getSound(path);
        Paths.memory.currentTrackedSounds.set(path, asset);

        return asset;
    }
}

private class Atlases {
    public function new() {}

    public function sparrow(key:String, library:String = null):FlxAtlasFrames {
        return FlxAtlasFrames.fromSparrow(Paths.assets.image(key, library), Paths.getPath(Path.join(["images", key]) + ".xml", TEXT, library));
    }

    public function packer(key:String, library:String = null):FlxAtlasFrames {
        return FlxAtlasFrames.fromSpriteSheetPacker(Paths.assets.image(key, library), Paths.getPath(Path.join(["images", key]) + ".txt", TEXT, library));
    }
}