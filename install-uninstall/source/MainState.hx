import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.FlxSprite;
import flixel.FlxState;

class MainState extends FlxState {
    var startButton:FlxSprite;

    var buttons:Array<FlxSprite> = [];
    var selects:Array<FlxSprite> = [];
    var tweens:Array<FlxTween> = [];

    override function create() {
        var bg:FlxSprite = new FlxSprite(0, 40, AssetPaths.background__png);
        bg.setGraphicSize(1280, 690);
        bg.updateHitbox();
        bg.antialiasing = true;
        add(bg);

        var bar:FlxSprite = new FlxSprite(1204, 40).makeGraphic(76, 690, 0xFF000000);
        bar.alpha = 0.2;
        add(bar);
        
        add(new OverlayUI());

        /*Install.install(function(percent:Float) {
            trace(percent);
        }, function(file:String, e:Dynamic) {
            trace("file: " + file +  " // error:" + e);
        }, function() {
            trace("pizdec");
        });*/

        var mouseEvent:FlxMouseEventManager = new FlxMouseEventManager();
        add(mouseEvent);

        for (i in 0...8) {
            var button:FlxSprite = new FlxSprite(1221, 75 + 70 * i, AssetPaths.yandex__png);
            add(button);
            buttons.push(button);
            tweens.push(null);

            var select:FlxSprite = new FlxSprite(1221, 75 + 70 * i, AssetPaths.yandex_selected__png);
            select.alpha = 0;
            add(select);
            selects.push(button);

            mouseEvent.add(button, null, function(spr:FlxSprite) {
                #if linux
                Sys.command('/usr/bin/xdg-open', [
                    "https://browser.yandex.ru",
                    "&"
                ]);
                #else
                FlxG.openURL("https://browser.yandex.ru");
                #end
            }, function(spr:FlxSprite) {
                if (tweens[buttons.indexOf(spr)] != null)
                    tweens[buttons.indexOf(spr)].cancel();

                tweens[buttons.indexOf(spr)] = FlxTween.tween(selects[buttons.indexOf(spr)], {alpha: 1}, 0.1 * (1 - selects[buttons.indexOf(spr)].alpha), {ease: FlxEase.sineIn});
            }, function(spr:FlxSprite) {
                if (tweens[buttons.indexOf(spr)] != null)
                    tweens[buttons.indexOf(spr)].cancel();

                tweens[buttons.indexOf(spr)] = FlxTween.tween(selects[buttons.indexOf(spr)], {alpha: 0}, 0.1 * (1 - selects[buttons.indexOf(spr)].alpha), {ease: FlxEase.sineIn});
            });
        }

        super.create();
    }
}