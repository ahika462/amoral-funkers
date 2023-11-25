package funkin.menus;

import flixel.tweens.FlxTween;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import funkin.backend.Discord.DiscordClient;
import flixel.util.FlxTimer;
import funkin.data.WeekData;
import funkin.backend.Highscore;
import funkin.backend.PlayerSettings;
import flixel.FlxG;
import funkin.shaders.ColorSwap;

class TitleState extends MusicBeatState {
    static var initialized:Bool = false;
    var startedIntro:Bool = false;
    var skippedIntro:Bool = false;
    var transitioning:Bool = false;

    var swagShader:ColorSwap;

    var curWacky:Array<String> = [];

    override function create() {
        Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

        FlxG.game.focusLostFramerate = 60;

        swagShader = new ColorSwap();

        FlxG.sound.muteKeys = [ZERO];

        var fullWacky:Array<Array<String>> = [
            for (wacky in CoolUtil.coolTextFile(Paths.txt("introText")))
                wacky.split("--")
        ];
        curWacky = FlxG.random.getObject(fullWacky);

        super.create();

        FlxG.save.bind("funkin", "ninjamuffin99");
        ClientPrefs.loadPrefs();
        PlayerSettings.init();
        Highscore.load();
        WeekData.loadWeeks();

        #if FREEPLAY
        FlxG.switchState(new FreeplayState());
        #elseif CHARTING
        // FlxG.switchState(new ChartingState());
        #end

        new FlxTimer().start(1, function(tmr:FlxTimer) {
            startIntro();
        });

        DiscordClient.initialize();
        FlxG.stage.application.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
    }

    var gfDance:FlxSprite;
    var logoBl:FlxSprite;
    var titleText:FlxSprite;

    var danceLeft:Bool = false;
    var titleColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleAlphas:Array<Float> = [1, 0.64];

    var credGroup:FlxGroup;
    var textMap:Map<Alphabet, Float> = [];
    var blackScreen:FlxSprite;
    var ngSpr:FlxSprite;

    function startIntro() {
        if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
			FlxG.sound.playMusic(Paths.music("freakyMenu"), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}
        Conductor.bpm = 102;
        persistentUpdate = true;

        gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
        gfDance.frames = Paths.getSparrowAtlas("gfDanceTitle");
        gfDance.animation.addByIndices("danceLeft", "gfDance", [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
        gfDance.animation.addByIndices("danceRight", "gfDance", [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = ClientPrefs.data.antialiasing;
        gfDance.shader = swagShader.shader;
		add(gfDance);

        logoBl = new FlxSprite(-150, -100);
        logoBl.frames = Paths.getSparrowAtlas("logoBumpin");
        logoBl.animation.addByPrefix("bump", "logo bumpin", 24);
        logoBl.antialiasing = ClientPrefs.data.antialiasing;
        logoBl.updateHitbox();
        logoBl.shader = swagShader.shader;
        add(logoBl);

        titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas("titleEnter");
		titleText.animation.addByPrefix("idle", "ENTER IDLE", 24);
		titleText.animation.addByPrefix("press", "ENTER PRESSED", 24);
        titleText.animation.play("idle");
		titleText.antialiasing = true;
		titleText.updateHitbox();
		add(titleText);

        credGroup = new FlxGroup();
        add(credGroup);

        blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        credGroup.add(blackScreen);

        ngSpr = new FlxSprite(0, FlxG.height * 0.52, Paths.image("newgrounds_logo"));
		#if (flixel >= "5.4.0")
        ngSpr.setGraphicSize(ngSpr.width * 0.8);
        #else
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
        #end
        ngSpr.updateHitbox();
        ngSpr.visible = false;
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.data.antialiasing;
        add(ngSpr);

        FlxG.mouse.visible = false;

        if (initialized)
			skipIntro();
		else
			initialized = true;

        startedIntro = true;
    }

    var titleTimer:Float = 0;
    var pressedEnter:Bool = false;

    override function update(elapsed:Float) {
        if (controls.UI_LEFT)
            swagShader.hue -= elapsed * 0.1;
		if (controls.UI_RIGHT)
            swagShader.hue += elapsed * 0.1;

        var pressedEnter:Bool = FlxG.keys.justPressed.ENTER #if mobile || FlxG.touches.justStarted().length > 0 #end;
        var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
        if (gamepad != null) {
            if (gamepad.justPressed.START #if switch || gamepad.justPressed.B #end)
                pressedEnter = true;
        }

        titleTimer += elapsed;
        if (titleTimer > 2)
            titleTimer -= 2;

        if (!initialized)
            return super.update(elapsed);

        if (skippedIntro) {
            if (!transitioning) {
                var timer:Float = titleTimer;
                if (timer >= 1)
                    timer = (-timer) + 2;
                
                timer = FlxEase.quadInOut(timer);

                titleText.color = FlxColor.interpolate(titleColors[0], titleColors[1], timer);
                titleText.alpha = CoolUtil.coolLerp(titleAlphas[0], titleAlphas[1], timer);

                if (pressedEnter) {
                    titleText.color = 0xFFFFFFFF;
                    titleText.alpha = 1;
                    titleText.animation.play("press");

                    FlxG.camera.flash(ClientPrefs.data.flashing ? 0xFFFFFFFF : 0x4CFFFFFF, 1, true);
                    FlxG.sound.play(Paths.sound("confirmMenu"), 0.7);

                    transitioning = true;
                    
                    new FlxTimer().start(1, function(tmr:FlxTimer) {
                        FlxG.switchState(new MainMenuState());
                    });
                }
            }
        } else {
            if (pressedEnter)
                skipIntro();

            for (text => targetY in textMap)
                text.y = CoolUtil.coolLerp(text.y, targetY, 0.4);
        }

        super.update(elapsed);
    }

    function createCoolText(textArray:Array<String>, offset:Float = 0) {
        for (i in 0...textArray.length) {
            var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
            money.screenCenter(X);
            credGroup.add(money);
            money.y += (i * 60) + 200 + offset;
            money.y -= 350;
            textMap.set(money, money.y + 350);
        }
    }

    function addMoreText(text:String, ?offset:Float = 0) {
        var textLength:Int = [
            for (key in textMap.keys())
                key
        ].length;
        var coolText:Alphabet = new Alphabet(0, 0, text, true);
        coolText.screenCenter(X);
        credGroup.add(coolText);
        coolText.y += (textLength * 60) + 200 + offset;
        coolText.y += 750;
        textMap.set(coolText, coolText.y - 750);
    }

    function deleteCoolText() {
        for (text in textMap.keys()) {
            credGroup.remove(text);
            textMap.remove(text);
        }
    }

    var sickBeats:Int = 0;
    static var closedState:Bool = false;
    override function beatHit() {
        super.beatHit();

        if (logoBl != null)
            logoBl.animation.play("bump", true);
        if (gfDance != null) {
            danceLeft = !danceLeft;
            if (danceLeft)
                gfDance.animation.play("danceRight");
            else
                gfDance.animation.play("danceLeft");
        }

        if (closedState)
            return;
        
        sickBeats++;
        switch(sickBeats) {
            case 1:
                createCoolText([
                    "ninjamuffin99",
                    "phantomArcade",
                    "kawaisprite",
                    "evilsk8er"
                ]);
            case 3:
                addMoreText("present");
            case 4:
                deleteCoolText();
            case 5:
                createCoolText(["In association", "with"]);
            case 7:
                addMoreText("newgrounds");
				ngSpr.visible = true;
            case 8:
                deleteCoolText();
				ngSpr.visible = false;
            case 9:
                createCoolText([curWacky[0]]);
            case 11:
                addMoreText(curWacky[1]);
            case 12:
                deleteCoolText();
            case 13:
                addMoreText("Friday");
            case 14:
                addMoreText("Night");
            case 15:
                addMoreText("Funkin");
            case 16:
                skipIntro();
        }
    }

    function skipIntro() {
        if (!skippedIntro) {
            remove(ngSpr);
            FlxG.camera.flash(0xFFFFFFFF, 4, true);
			remove(credGroup);
			skippedIntro = true;
        }
    }
}