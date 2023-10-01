import haxe.Json;

using StringTools;

typedef WeekFile = {
    var songs:Array<Dynamic>;
	var weekCharacters:Array<String>;
	var storyName:String;
	var freeplayColor:Array<Int>;
	var startUnlocked:Bool;
}

class WeekData {
    public static var list:Array<WeekFile> = [];
    public static var unlocked:Array<Bool> = [true, true, true, true, true, true, true, true];

    public static function loadWeeks() {
        list = [];

        var weekList:Array<String> = Paths.getEmbedText("weeks/weekList.txt").trim().split("\n");
        for (i in 0...weekList.length)
            weekList[i] = weekList[i].trim();

        for (week in weekList) {
            if (Paths.embedExists("weeks/" + week + ".json"))
               list.push(cast Json.parse(Paths.getEmbedText("weeks/" + week + ".json")));
        }
    }
}