package funkin.backend;

#if sys
import sys.FileSystem;
import sys.io.File;
#end
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import openfl.media.Sound;
import openfl.utils.Assets;
import openfl.utils.AssetType;

using StringTools;

class Paths {
	inline public static var SOUND_EXT:String = #if web ".mp3" #else ".ogg" #end;

	static var currentLevel:String;

	public static function setCurrentLevel(name:String) {
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, library:String = null):String {
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null) {
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (Assets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (Assets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	public static function getLibraryPath(file:String, library:String = "preload"):String {
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	public static function getLibraryPathForce(file:String, library:String):String {
		return library + ":" + getPreloadPath(library + "/" + file);
	}

	public static function getPreloadPath(file:String):String {
		return "assets/" + file;
	}

	public static function file(file:String, type:AssetType = TEXT, library:String = null) {
		return getPath(file, type, library);
	}

	public static function txt(key:String, library:String = null) {
		return getPath("data/" + key + ".txt", TEXT, library);
	}

	public static function xml(key:String, library:String = null) {
		return getPath("data/" + key + ".xml", TEXT, library);
	}

	public static function json(key:String, library:String = null) {
		return getPath("data/" + key + ".json", TEXT, library);
	}

	public static function sound(key:String, library:String = null):Sound {
		var path:String = getPath("sounds/" + key + SOUND_EXT, SOUND, library);

		localTrackedAssets.push(path);

		if (!Assets.exists(path))
			return null;

		if (currentTrackedSounds.exists(path))
			return currentTrackedSounds.get(path);

		var asset:Sound = Assets.getSound(path);
		currentTrackedSounds.set(path, asset);

		return asset;
	}

	public static function soundRandom(key:String, min:Int, max:Int, library:String = null) {
		return sound(key + FlxG.random.int(min, max), library);
	}

	public static function music(key:String, library:String = null):Sound {
		var path:String = getPath("music/" + key + SOUND_EXT, SOUND, library);

		localTrackedAssets.push(path);

		if (!Assets.exists(path))
			return null;

		if (currentTrackedSounds.exists(path))
			return currentTrackedSounds.get(path);

		var asset:Sound = Assets.getSound(path);
		currentTrackedSounds.set(path, asset);

		return asset;
	}

	public static function voices(song:String):Sound {
		var path:String = getLibraryPathForce(song.toLowerCase() + "/Voices" + SOUND_EXT, "songs");

		localTrackedAssets.push(path);

		if (!Assets.exists(path))
			return null;

		if (currentTrackedSounds.exists(path))
			return currentTrackedSounds.get(path);

		var asset:Sound = Assets.getSound(path);
		currentTrackedSounds.set(path, asset);

		return asset;
	}

	public static function inst(song:String):Sound {
		var path:String = getLibraryPathForce(song.toLowerCase() + "/Inst" + SOUND_EXT, "songs");

		localTrackedAssets.push(path);

		if (!Assets.exists(path))
			return null;

		if (currentTrackedSounds.exists(path))
			return currentTrackedSounds.get(path);

		var asset:Sound = Assets.getSound(path);
		currentTrackedSounds.set(path, asset);

		return asset;
	}

	public static function image(key:String, library:String = null):FlxGraphic {
		var path:String = getPath("images/" + key + ".png", IMAGE, library);

		localTrackedAssets.push(path);

		if (!Assets.exists(path))
			return null;

		if (currentTrackedAssets.exists(path))
			return currentTrackedAssets.get(path);

		var asset:FlxGraphic = FlxGraphic.fromBitmapData(CoolUtil.loadByGPU(Assets.getBitmapData(path)));
		asset.persist = true;
		asset.destroyOnNoUse = false;
		currentTrackedAssets.set(path, asset);

		return asset;
	}

	public static function font(key:String):String {
		return "assets/fonts/" + key;
	}

	public static function getSparrowAtlas(key:String, library:String = null):FlxAtlasFrames {
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	public static function getPackerAtlas(key:String, library:String = null):FlxAtlasFrames {
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	public static function getTextFromFile(key:String, library:String = null):String {
		return Assets.getText(getPath(key, TEXT, library));
	}

	public static function exists(key:String, type:AssetType, library:String = null) {
		return Assets.exists(getPath(key, type, library));
	}

	public static function getEmbedShit(key:String):String {
		return "embed/" + key;
	}

	public static function getEmbedText(key:String):String {
		#if (final || !sys)
		return Assets.getText(getEmbedShit(key));
		#else
		return File.getContent(getEmbedShit(key));
		#end
	}

	public static function getEmbedFiles(key:String, ?type:AssetType):Array<String> {
		if (!key.endsWith("/"))
			key += "/";

		var returnVal:Array<String> = [];
		
		#if (final || !sys)
		returnVal = Assets.list(type);
		for (file in returnVal) {
			if (!file.startsWith(getEmbedShit(key)))
				returnVal.remove(file);
		}
		#else
		returnVal = FileSystem.readDirectory(getEmbedShit(key));
		if (returnVal == null)
			returnVal = [];

		for (i in 0...returnVal.length) {
			returnVal[i] = getEmbedShit(key) + returnVal[i];
			if (FileSystem.isDirectory(returnVal[i]))
				returnVal = returnVal.concat(getEmbedFiles(returnVal[i]));
		}
		#end

		return returnVal;
	}

	public static function embedExists(key:String, ?type:AssetType):Bool {
		#if (final || !sys)
		return Assets.exists(getEmbedShit(key), type);
		#else
		return FileSystem.exists(getEmbedShit(key));
		#end
	}

	public static function shaderFragment(key:String):String {
		return embedExists("shaders/" + key + ".frag", TEXT) ? getEmbedText("shaders/" + key + ".frag") : null;
	}

	public static function shaderVertex(key:String):String {
		return embedExists("shaders/" + key + ".vert", TEXT) ? getEmbedText("shaders/" + key + ".vert") : null;
	}

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static var localTrackedAssets:Array<String> = [];

	public static function clearUnusedMemory() {
		for (key => asset in currentTrackedAssets) {
			if (localTrackedAssets.contains(key))
				continue;

			if (asset == null) {
				currentTrackedAssets.remove(key);
				continue;
			}

			@:privateAccess {
				Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				asset.destroy();
				currentTrackedAssets.remove(key);
			}
		}
		MemoryUtil.clearMajor();
		MemoryUtil.destroyFlixelZombies();
	}

	public static function clearStoredMemory() {
		// clear anything not in the tracked assets list
		@:privateAccess {
			for (key => asset in FlxG.bitmap._cache) {
				if (asset == null || localTrackedAssets.contains(key))
					continue;

				Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				asset.destroy();
			}
		}

		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys()) {
			if (localTrackedAssets.contains(key) || key == null)
				continue;
			
			Assets.cache.clear(key);
			currentTrackedSounds.remove(key);
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		Assets.cache.clear("songs");

		MemoryUtil.clearMinor();
	}
}