package modding.editors;

import flixel.math.FlxPoint;
import flixel.FlxG;
import haxe.Json;
import Character.CharacterFile;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxSprite;
import Song.SwagSong;

class ChartDebugger extends BaseDebugger {
    public var curSong(default, set):String = "test";
    public var json:SwagSong;

    public var player1Json(get, never):CharacterFile;
    public var player2Json(get, never):CharacterFile;

    inline public static var GRID_SIZE:Int = 40;
    var grid:FlxSprite;

    var leftIcon:HealthIcon;
    var rightIcon:HealthIcon;

    var curSection:Int = 0;

    public function new(song:String = "test") {
        super();
        curSong = song;

        leftIcon = new HealthIcon();
        add(leftIcon);
        rightIcon = new HealthIcon();
        add(rightIcon);

        reloadSection();
    }

    function set_curSong(value:String):String {
        json = Song.loadFromJson(value, value);
        return curSong = value;
    }

    function get_player1Json():CharacterFile {
        return cast Json.parse(Paths.getEmbedText("characters/" + json.player1 + ".json")).character;
    }

    function get_player2Json():CharacterFile {
        return cast Json.parse(Paths.getEmbedText("characters/" + json.player2 + ".json")).character;
    }

    function reloadSection(?id:Null<Int>) {
        if (id == null)
            id = curSection;

        curSection = id;

        var daLayer:Null<Int> = members.contains(grid) ? members.indexOf(grid) : null;
        remove(grid);
        grid = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * json.notes[curSection].lengthInSteps);
        grid.x = FlxG.width / 2;
        grid.y = FlxG.height / 2;
        if (daLayer == null)
            add(grid);
        else
            insert(daLayer, grid);

        /*var daLayer:Int = members.indexOf(leftIcon);
        remove(leftIcon);
        leftIcon = new HealthIcon(json.notes[curSection].mustHitSection ? player1Json.healthicon : player2Json.healthicon);
        leftIcon.setGraphicSize(0, 45);
        leftIcon.updateHitbox();
        rightIcon.setPosition(grid.x + grid.width / 4, grid.y - 100);
        insert(daLayer, leftIcon);

        daLayer = members.indexOf(rightIcon);
        remove(rightIcon);
        rightIcon = new HealthIcon(!json.notes[curSection].mustHitSection ? player1Json.healthicon : player2Json.healthicon);
        rightIcon.setGraphicSize(0, 45);
        rightIcon.updateHitbox();
        rightIcon.setPosition(grid.x + grid.width / 4 * 3, grid.y - 100);
        insert(daLayer, rightIcon);*/
    }
}