package modding.editors;

import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.math.FlxPoint;
import flixel.FlxG;
import haxe.Json;
import Character.CharacterFile;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxSprite;
import Song.SwagSong;

class ChartDebugger extends BaseDebugger {
    public var curSong:String = "test";
    public var json(get, set):SwagSong;

    public var player1Json(get, never):CharacterFile;
    public var player2Json(get, never):CharacterFile;

    inline public static var GRID_SIZE:Int = 40;
    public var grid:FlxSprite;

    var leftIcon:HealthIcon;
    var rightIcon:HealthIcon;

    var curSection:Int = 0;

    var vocals:FlxSound;

    public function new(song:String = "test") {
        super();
        curSong = song;
        loadJson(song);
        vocals = new FlxSound().loadEmbedded(Paths.voices(json.song.toLowerCase()));

        grid = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
        grid.x = FlxG.width / 2;
        grid.y = FlxG.height / 2;
        add(grid);

        leftIcon = new HealthIcon();
        leftIcon.setGraphicSize(0, 45);
        leftIcon.updateHitbox();
        leftIcon.setPosition(grid.x + grid.width / 4 - leftIcon.width / 2, grid.y - leftIcon.height / 2 - 30);
        add(leftIcon);
        
        rightIcon = new HealthIcon();
        rightIcon.setGraphicSize(0, 45);
        rightIcon.updateHitbox();
        rightIcon.setPosition(grid.x + grid.width / 4 * 3 - rightIcon.width / 2, grid.y - rightIcon.height / 2 - 30);
        add(rightIcon);

        reloadSection();
    }

    function get_json():SwagSong {
        return PlayState.SONG;
    }

    function set_json(value:SwagSong):SwagSong {
        return PlayState.SONG = value;
    }

    function get_player1Json():CharacterFile {
        return cast Json.parse(Paths.getEmbedText("characters/" + json.player1 + ".json")).character;
    }

    function get_player2Json():CharacterFile {
        return cast Json.parse(Paths.getEmbedText("characters/" + json.player2 + ".json")).character;
    }

    function reloadSection(step:Int = 0, force:Bool = false) {
        curSection = step + (force ? 0 : curSection);

        leftIcon.changeIcon(json.notes[curSection].mustHitSection ? player1Json.healthicon : player2Json.healthicon);
        rightIcon.changeIcon(!json.notes[curSection].mustHitSection ? player1Json.healthicon : player2Json.healthicon);

        for (i in json.notes[curSection].sectionNotes) {
            var daNoteData:Int = i[1];
			var daStrumTime:Float = i[0];
			var daSus:Float = i[2];

            var note:EditorNote = new EditorNote(daNoteData, daStrumTime, daSus);
        }
    }

    public function loadJson(song:String) {
        var songFile:SwagSong = Song.loadFromJson(song, song);
        json = songFile;
    }

    public function loadSong(song:String) {

    }
}

class EditorNote extends FlxSpriteGroup {
    public function new(data:Int, time:Float, susLength:Float = 0) {
        super(ModdingState.instance.chartDebug.grid.x + ChartDebugger.GRID_SIZE * data, FlxMath.remapToRange(time, 0, 16 * Conductor.stepCrochet, ModdingState.instance.chartDebug.grid.y, ModdingState.instance.chartDebug.grid.y + ModdingState.instance.chartDebug.grid.height));

        var body:FlxSprite = new FlxSprite();
        body.frames = Paths.getSparrowAtlas('NOTE_assets');
        body.animation.addByPrefix('greenScroll', 'green instance');
        body.animation.addByPrefix('redScroll', 'red instance');
        body.animation.addByPrefix('blueScroll', 'blue instance');
        body.animation.addByPrefix('purpleScroll', 'purple instance');
        body.animation.play(["purpleScroll", "blueScroll", "greenScroll", "redScroll"][data]);
        body.setGraphicSize(ChartDebugger.GRID_SIZE, ChartDebugger.GRID_SIZE);
        body.antialiasing = ClientPrefs.data.antialiasing;
    }
}