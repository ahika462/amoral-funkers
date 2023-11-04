import sys.io.Process;
import openfl.events.MouseEvent;
import openfl.events.Event;
import lime.app.Application;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

class OverlayUI extends FlxGroup {
    var background:FlxSprite;
    
    var pressedButton:FlxSprite;
    var closeButton:FlxSprite;
    var minimizeButton:FlxSprite;
    var optionsButton:FlxSprite;

    var startButton:FlxSprite;

    var buttonsArray:Array<FlxSprite> = [];

    var optionsMenu:DropdownMenu = null;
    
    public function new() {
        super();

        background = new FlxSprite().makeGraphic(FlxG.width, 40, 0xFF141414);
        add(background);

        var title:FlxText = new FlxText(10, 12, "AMORAL FUNKERS", 14);
        title.font = AssetPaths.font__otf;
        // title.antialiasing = true;
        // title.bold = true;
        add(title);

        var version:FlxText = new FlxText(10 + title.width + 10, 12, "0.0.1", 14);
        version.font = AssetPaths.font__otf;
        version.color = 0xFF434343;
        // version.antialiasing = true;
        add(version);

        closeButton = new FlxSprite(FlxG.width - 40).loadGraphic(AssetPaths.close__png, true, 40, 40);
        closeButton.animation.add("butt", [0, 1, 2], 0, false);
        closeButton.animation.play("butt");
        add(closeButton);
        buttonsArray.push(closeButton);

        minimizeButton = new FlxSprite(FlxG.width - 80).loadGraphic(AssetPaths.minimize__png, true, 40, 40);
        minimizeButton.animation.add("butt", [0, 1, 2], 0, false);
        minimizeButton.animation.play("butt");
        add(minimizeButton);
        buttonsArray.push(minimizeButton);

        optionsButton = new FlxSprite(FlxG.width - 120).loadGraphic(AssetPaths.options__png, true, 40, 40);
        optionsButton.animation.add("butt", [0, 1, 2], 0, false);
        optionsButton.animation.play("butt");
        add(optionsButton);
        buttonsArray.push(optionsButton);

        startButton = new FlxSprite(916, 616).loadGraphic(AssetPaths.start_gaysex__png, true, 239, 64);
        startButton.animation.add("butt", [0, 1, 2], 0, false);
        startButton.animation.play("butt");
        add(startButton);
        buttonsArray.push(startButton);

        optionsMenu = new DropdownMenu(FlxG.width - 100, 20, ["Uninstall"]);
        optionsMenu.callback = function(choice:String) {
            if (choice == "Uninstall") {
                var uninstallPath:String = "uninstall";
                #if windows
                uninstallPath += ".exe";
                #end
                if (sys.FileSystem.exists("./" + uninstallPath)) {
                    trace("uninstalling by " + uninstallPath);
                    #if linux
                    uninstallPath = "./" + uninstallPath;
                    #end
                    new Process(uninstallPath);
                }
            }
        }
        optionsMenu.deactivate();
        add(optionsMenu);
        
        FlxG.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        FlxG.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        Application.current.window.onLeave.add(onWindowLeave);
        Application.current.window.onMouseMoveRelative.add(onMouseMove);
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
                if (FlxG.mouse.overlaps(i)) {
                    if (!FlxG.mouse.pressed) {
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

        if (moving && moveOffset.length == 2) {
            Application.current.window.x += Math.floor(FlxG.mouse.deltaScreenX * elapsed * 2);
            Application.current.window.y += Math.floor(FlxG.mouse.deltaScreenY * elapsed);

            /*if (Application.current.window.x != FlxG.mouse.screenX - moveOffset[0])
                Application.current.window.x += Math.floor(FlxG.mouse.deltaScreenX * elapsed);
            else if (Application.current.window.x != FlxG.mouse.deltaScreenX - moveOffset[0])
                Application.current.window.x -= Math.floor(FlxG.mouse.deltaScreenX * elapsed);

            if (Application.current.window.x != FlxG.mouse.screenY - moveOffset[1])
                Application.current.window.x += Math.floor(FlxG.mouse.deltaScreenY * elapsed);
            else if (Application.current.window.x != FlxG.mouse.deltaScreenY - moveOffset[1])
                Application.current.window.x -= Math.floor(FlxG.mouse.deltaScreenY * elapsed);*/

            if (Application.current.window.y != FlxG.mouse.deltaScreenY - moveOffset[1]) {
                // Application.current.window.y = (FlxG.mouse.screenY - moveOffset[1]);

                // var addY:Int = FlxG.mouse.deltaScreenY - moveOffset[1] - Application.current.window.y;
                // Application.current.window.y += addY;

                // Application.current.window.y += Math.floor(FlxG.mouse.deltaScreenY * (FlxG.mouse.deltaScreenY > 0 ? elapsed : -elapsed));
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
                    optionsMenu.setPosition(FlxG.mouse.x, FlxG.mouse.y);
                    optionsMenu.activate();
                    /*if (optionsMenu == null) {
                        optionsMenu = new DropdownMenu(FlxG.mouse.x, FlxG.mouse.y, ["Uninstall"]);
                        optionsMenu.callback = function(choice:String) {
                            if (choice == "Uninstall") {
                                var uninstallPath:String = "uninstall";
                                #if windows
                                uninstallPath += ".exe";
                                #end
                                if (sys.FileSystem.exists("./" + uninstallPath)) {
                                    trace("uninstalling by " + uninstallPath);
                                    #if linux
                                    uninstallPath = "./" + uninstallPath;
                                    #end
                                    new sys.io.Process(uninstallPath);
                                }
                            }
                        }
                        add(optionsMenu);
                    }*/
                } else if (pressedButton == startButton) {
                    var gamePath:String = "C:/Games/AMORAL FUNKERS/Funkin";
                    #if windows
                    gamePath += ".exe";
                    #end
                    if (sys.FileSystem.exists(gamePath)) {
                        trace("launching " + gamePath);
                        new Process(gamePath, [gamePath.substr(0, gamePath.lastIndexOf("/")), Sys.getCwd() + "AMORAL FUNKERS"]);
                    }
                    Application.current.window.close();
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

        if (!moving && !overlappedOnButton && FlxG.mouse.overlaps(background) && !FlxG.mouse.overlaps(optionsMenu)) {
            moveOffset = [FlxG.mouse.screenX - Application.current.window.x, FlxG.mouse.screenY - Application.current.window.y];
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

    var moveOffset:Array<Int> = [];
    var moving:Bool = false;

    function onMouseMove(x:Float, y:Float) {
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