import flixel.FlxSprite;
import flixel.FlxState;

class MainState extends FlxState {
    var startButton:FlxSprite;

    override function create() {
        var bg:FlxSprite = new FlxSprite(0, 40, "assets/background.png");
        bg.setGraphicSize(1280, 690);
        bg.updateHitbox();
        bg.antialiasing = true;
        add(bg);
        
        add(new WindowOverlay());

        /*Install.install(function(percent:Float) {
            trace(percent);
        }, function(file:String, e:Dynamic) {
            trace("file: " + file +  " // error:" + e);
        }, function() {
            trace("pizdec");
        });*/

        super.create();
    }
}