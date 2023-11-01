import flixel.tweens.FlxEase;
import flixel.util.FlxGradient;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.addons.transition.TransitionData;
import flixel.FlxCamera;
import flixel.addons.transition.Transition;

class CustomFadeTransition extends Transition {
    public static var targetCamera:FlxCamera = null;

    public function new(isTransIn:Bool) {
        var data:TransitionData = isTransIn ? new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), null, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4)) : new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1), null, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

        super(data);

        if (targetCamera != null)
            cameras = [targetCamera];
        targetCamera = null;
    }
}