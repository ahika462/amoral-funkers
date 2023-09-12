package modcore;

import sys.io.File;
import haxe.Json;
import sys.FileSystem;

typedef ModScanParams = {
    var path:String;
    @:optional var exclusions:Array<String>;
}

typedef ModMetadata = {
    var name:String;
    var path:String;
}

class ModCore {
    public static var list:Array<ModMetadata> = [];
    public static var current:ModMetadata = null;

    public static function scan(params:ModScanParams) {
        for (file in FileSystem.readDirectory(params.path)) {
            if (FileSystem.isDirectory(file)) {
                var data:Dynamic = cast Json.parse(File.getContent(params.path + "/" + file + "/pack.json"));
                data.path = params.path + "/" + file;

                list.push(cast data);
            }
        }
    }

    public static function getByName(name:String):ModMetadata {
        for (mod in list) {
            if (mod.name == name)
                return mod;
        }
        return null;
    }
}