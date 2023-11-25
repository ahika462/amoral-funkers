package funkin.backend;

import flixel.FlxG;
import funkin.data.WeekData;

class Highscore {
    public static var songScores:Map<String, Int> = [];

    /**
     * Saves song score on the current difficulty
     * @param song 
     * @param score 
     * @param diff 
     */
    public static function saveScore(song:String, score:Int = 0, diff:Int = 0) {
        var songPath:String = formatSong(song, diff);

        if (!songScores.exists(songPath) || songScores.get(songPath) < score)
            setScore(songPath, score);
    }

    /**
     * Saves week score on the current difficulty
     * @param week 
     * @param score 
     * @param diff 
     */
    public static function saveWeekScore(week:Int = 0, score:Int = 0, diff:Int = 0) {
        WeekData.loadWeeks();
        var songPath:String = formatSong(WeekData.files[week], diff);
        if (!songScores.exists(songPath) || songScores.get(songPath) < score)
            setScore(songPath, score);
    }

    @:noPrivateAccess static function setScore(songPath:String, score:Int) {
        songScores.set(songPath, score);
        FlxG.save.data.songScores = songScores;
        FlxG.save.flush();
    }

    /**
     * Returns song score on the current difficulty
     * @param song 
     * @param diff 
     * @return Int
     */
    public static function getScore(song:String, diff:Int):Int {
        var songPath:String = formatSong(song, diff);
        if (!songScores.exists(songPath))
            setScore(songPath, 0);

        return songScores.get(songPath);
    }

    /**
     * Returns week score on the current difficulty
     * @param week 
     * @param diff 
     * @return Int
     */
    public static function getWeekScore(week:Int, diff:Int):Int {
        WeekData.loadWeeks();
        var songPath:String = formatSong(WeekData.files[week], diff);
        if (!songScores.exists(songPath))
            setScore(songPath, 0);

        return songScores.get(songPath);
    }

    public static function load() {
        if (FlxG.save.data.songScores != null)
            songScores = FlxG.save.data.songScores;
    }

    /**
     * Returns the name of the chart file
     * @param song 
     * @param diff 
     * @return String
     */
    public static function formatSong(song:String, diff:Int):String {
        return song + ["-easy", "", "-hard"][diff];
    }
}