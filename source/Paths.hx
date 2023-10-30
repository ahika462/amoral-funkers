package;

import lime.utils.Bytes;
import openfl.display3D.textures.RectangleTexture;
import openfl.display.BitmapData;
#if (!final && sys)
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:String)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline public static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String, ?gpuRender:Bool = true)
	{
		var path:String = getPath('images/$key.png', IMAGE, library);

		if (FlxG.bitmap.get(path) != null)
			return FlxG.bitmap.get(path);

		var bitmap:BitmapData = OpenFlAssets.getBitmapData(path);

		if (gpuRender) {
			var texture:RectangleTexture = FlxG.stage.context3D.createRectangleTexture(bitmap.width, bitmap.height, BGRA, true);
			texture.uploadFromBitmapData(bitmap);
			bitmap.image.data = null;
			bitmap.dispose();
			bitmap.disposeImage();
			bitmap = BitmapData.fromTexture(texture);
		}

		return FlxG.bitmap.add(bitmap, false, path);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	public static function getTextFromFile(key:String, ?library:String) {
		return OpenFlAssets.getText(getPath(key, TEXT, library));
	}

	public static function exists(key:String, type:AssetType, ?library:String) {
		return OpenFlAssets.exists(getPath(key, type, library));
	}

	public static function getEmbedShit(key:String):String {
		return "embed/" + key;
	}

	public static function getEmbedText(key:String):String {
		#if (final || !sys)
		return OpenFlAssets.getText(getEmbedShit(key));
		#else
		return File.getContent(getEmbedShit(key));
		#end
	}

	public static function getEmbedFiles(key:String, ?type:AssetType):Array<String> {
		if (!key.endsWith("/"))
			key += "/";

		var returnVal:Array<String> = [];
		
		#if (final || !sys)
		returnVal = OpenFlAssets.list(type);
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
		return OpenFlAssets.exists(getEmbedShit(key), type);
		#else
		return FileSystem.exists(getEmbedShit(key));
		#end
	}

	public static function clear(cache:Bool = true, unused:Bool = true) {
		if (cache)
			FlxG.bitmap.clearCache();
		if (unused)
			FlxG.bitmap.clearUnused();
	}

	public static function shaderFragment(key:String):String {
		return embedExists("shaders/" + key + ".frag", TEXT) ? getEmbedText("shaders/" + key + ".frag") : null;
	}

	public static function shaderVertex(key:String):String {
		return embedExists("shaders/" + key + ".vert", TEXT) ? getEmbedText("shaders/" + key + ".vert") : null;
	}
}
