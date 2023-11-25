package funkin.data;

import flixel.FlxG;
import haxe.Json;

using StringTools;

typedef WeekFile = {
    var songs:Array<Dynamic>;
	var weekCharacters:Array<String>;
	var storyName:String;
	var freeplayColor:Array<Int>;
	var startUnlocked:Bool;
    var hideStoryMode:Bool;
    var hideFreeplay:Bool;
}

class WeekData {
    public static var list:Array<WeekFile> = [];
    public static var files:Array<String> = [];
    public static var unlocked:Map<String, Bool> = [];

    public static function loadWeeks() {
        list = [];

        var weekList:Array<String> = Paths.getEmbedText("weeks/weekList.txt").trim().split("\n");
        for (i in 0...weekList.length)
            weekList[i] = weekList[i].trim();

        for (week in weekList) {
            if (Paths.embedExists("weeks/" + week + ".json")) {
                var json:WeekFile = cast Json.parse(Paths.getEmbedText("weeks/" + week + ".json"));
                list.push(json);
                files.push(week);

                var unlockedMap:Map<String, Bool> = FlxG.save.data.weekUnlocked;
                if (unlockedMap == null)
                    unlockedMap = [];

                if (!unlockedMap.exists(week)) {
                    unlockedMap.set(week, json.startUnlocked);
                    continue;
                }

                if (unlockedMap.exists(week))
                    unlockedMap.set(week, unlockedMap.get(week));
                else
                    unlocked.set(week, json.startUnlocked);

                FlxG.save.data.weekUnlocked = unlockedMap;
            }
        }
        unlocked = FlxG.save.data.weekUnlocked;
    }
}