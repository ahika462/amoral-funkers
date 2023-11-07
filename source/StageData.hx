import haxe.Json;

typedef StageFile = {
    var zoom:Null<Float>;
    var pixel:Null<Bool>;
    var gf:Array<Float>;
    var dad:Array<Float>;
    var boyfriend:Array<Float>;
    var hide_gf:Null<Bool>;
}

class StageData {
    inline public static var DEFAULT_STAGE:String = "glasses";
    
    public static function get(name:String):StageFile {
        var json:StageFile = cast Json.parse(Paths.getEmbedText("stages/" + name + ".json")).stage;
        if (json.zoom == null)
            json.zoom = 1.05;
        if (json.pixel == null)
            json.pixel = false;
        if (json.gf == null)
            json.gf = [0, 0];
        if (json.dad == null)
            json.dad = [0, 0];
        if (json.boyfriend == null)
            json.boyfriend = [0, 0];
        if (json.hide_gf == null)
            json.hide_gf = false;

        return json;
    }
}