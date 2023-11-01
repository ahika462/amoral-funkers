import flixel.math.FlxPoint;
import openfl.events.MouseEvent;
import openfl.events.Event;
import lime.app.Application;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

class WindowOverlay extends FlxGroup {
    var background:FlxSprite;
    
    var pressedButton:FlxSprite;
    var closeButton:FlxSprite;
    var minimizeButton:FlxSprite;
    var optionsButton:FlxSprite;

    var startButton:FlxSprite;

    var buttonsArray:Array<FlxSprite> = [];
    
    public function new() {
        super();

        background = new FlxSprite().makeGraphic(FlxG.width, 40, 0xFF141414);
        add(background);

        var title:FlxText = new FlxText(10, 12, "AMORAL FUNKERS", 14);
        title.font = "assets/font.otf";
        // title.antialiasing = true;
        // title.bold = true;
        add(title);

        var version:FlxText = new FlxText(10 + title.width + 10, 12, "0.0.1", 14);
        version.font = "assets/font.otf";
        version.color = 0xFF434343;
        // version.antialiasing = true;
        add(version);

        closeButton = new FlxSprite(FlxG.width - 40).loadGraphic("assets/buttons/close.png", true, 40, 40);
        closeButton.animation.add("butt", [0, 1, 2], 0, false);
        closeButton.animation.play("butt");
        add(closeButton);
        buttonsArray.push(closeButton);

        minimizeButton = new FlxSprite(FlxG.width - 80).loadGraphic("assets/buttons/minimize.png", true, 40, 40);
        minimizeButton.animation.add("butt", [0, 1, 2], 0, false);
        minimizeButton.animation.play("butt");
        add(minimizeButton);
        buttonsArray.push(minimizeButton);

        optionsButton = new FlxSprite(FlxG.width - 120).loadGraphic("assets/buttons/options.png", true, 40, 40);
        optionsButton.animation.add("butt", [0, 1, 2], 0, false);
        optionsButton.animation.play("butt");
        add(optionsButton);
        buttonsArray.push(optionsButton);

        startButton = new FlxSprite(916, 616).loadGraphic("assets/start_gaysex.png", true, 239, 64);
        startButton.animation.add("butt", [0, 1, 2], 0, false);
        startButton.animation.play("butt");
        add(startButton);
        buttonsArray.push(startButton);
        
        FlxG.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        FlxG.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        Application.current.window.onLeave.add(onWindowLeave);
        Application.current.window.onMouseMove.add(onMouseMove);
    }

    var _totalElapsed:Float = 0;
    function onEnterFrame(e:Event) {
        @:privateAccess
        var elapsed:Float = (FlxG.game.getTimer() / 1000) - _totalElapsed;
        _totalElapsed += elapsed;
        enterFrame(elapsed);
    }

    var mouseLeaved(get, never):Bool;
    function get_mouseLeaved():Bool {
        return FlxG.mouse.screenX > Application.current.window.x && FlxG.mouse.screenX < Application.current.window.x + Application.current.window.width && FlxG.mouse.y > Application.current.window.y && FlxG.mouse.screenY > Application.current.window.y + Application.current.window.height;
    }

    function enterFrame(elapsed:Float) {
        if (!mouseLeaved) {
            for (i in buttonsArray) {
                if (FlxG.mouse.overlaps(i) && !FlxG.mouse.pressed) {
                    if (pressedButton == null) {
                        i.animation.curAnim.curFrame = 2;
                        if (i != closeButton && i != minimizeButton && i != optionsButton)
                            Application.current.window.cursor = POINTER;
                    }
                    else if (pressedButton != i && pressedButton != null)
                        i.animation.curAnim.curFrame = 0;
                } else {
                    if (pressedButton == i)
                        i.animation.curAnim.curFrame = 2;
                    else
                        i.animation.curAnim.curFrame = 0;
                }
            }
        }
    }

    function onMouseUp(e:MouseEvent) {
        if (pressedButton != null) {
            if (FlxG.mouse.overlaps(pressedButton)) {
                pressedButton.animation.curAnim.curFrame = 2;

                if (pressedButton == closeButton)
                    Application.current.window.close();
                else if (pressedButton == minimizeButton) {
                    pressedButton.animation.curAnim.curFrame = 0;
                    Application.current.window.minimized = true;
                } else if (pressedButton == optionsButton) {
                    // кек
                } else if (pressedButton == startButton) {
                    // кек x2
                }
            } else {
                pressedButton.animation.curAnim.curFrame = 0;

                /*if (pressedButton == startButton)
                    Application.current.window.cursor = DEFAULT;*/
            }

            pressedButton = null;
        }

        moving = false;
    }

    function onMouseDown(e:MouseEvent) {
        for (i in buttonsArray) {
            if (FlxG.mouse.overlaps(i))
                pressedButton = i;
        }

        if (pressedButton != null && FlxG.mouse.overlaps(pressedButton))
            pressedButton.animation.curAnim.curFrame = 1;

        var overlappedOnButton:Bool = false;
        for (i in buttonsArray) {
            if (FlxG.mouse.overlaps(i))
                overlappedOnButton = true;
        }

        if (!overlappedOnButton && FlxG.mouse.overlaps(background)) {
            moveOffset.set(FlxG.mouse.screenX - Application.current.window.x, FlxG.mouse.screenY - Application.current.window.y);
            moving = true;
        }
    }

    function onWindowLeave() {
        if (pressedButton != null) {
            if (FlxG.mouse.pressed)
                pressedButton.animation.curAnim.curFrame = 2;
            else
                pressedButton.animation.curAnim.curFrame = 0;
        }
    }

    var moveOffset:FlxPoint = new FlxPoint();
    var moving:Bool = false;

    function onMouseMove(x:Float, y:Float) {
        if (moving) {
            Application.current.window.x = Std.int(x) /*- Std.int(moveOffset.x / 2)*/;
            Application.current.window.y = Std.int(y) /*- Std.int(moveOffset.y / 2)*/;
        }

        if (mouseLeaved) {
            if (pressedButton != null) {
                if (FlxG.mouse.pressed)
                    pressedButton.animation.curAnim.curFrame = 2;
                else
                    pressedButton.animation.curAnim.curFrame = 0;
            }
        }
    }
}