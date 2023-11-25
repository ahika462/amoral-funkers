package funkin.menus;

import funkin.backend.beat.Conductor;
import flixel.FlxG;
import funkin.backend.Paths;
import flixel.FlxSprite;
import funkin.backend.beat.MusicBeatState;

class TitleState extends MusicBeatState {
    var gf:FlxSprite;
    var logo:FlxSprite;
    var enter:FlxSprite;

    override function create() {
        Paths.memory.clearStored();
		Paths.memory.clearUnused();

        if (FlxG.sound.music == null)
            FlxG.sound.playMusic(Paths.assets.music("freakyMenu"));

        Conductor.bpm = 102;

        gf = new FlxSprite();
        gf.frames = Paths.atlas.sparrow("gfDanceTitle");
        gf.animation.addByIndices("danceLeft", "gfDance", [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
        gf.animation.addByIndices("danceRight", "gfDance", [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gf.antialiasing = true;
		add(gf);
    }

    override function beatHit() {
        gf.animation.play(["danceLeft", "danceRight"][curBeat % 2]);
    }

    override function update(elapsed:Float) {
        Conductor.songPosition = FlxG.sound.music.time;
        super.update(elapsed);
    }
}