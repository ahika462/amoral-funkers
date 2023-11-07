import haxe.Json;
import flixel.animation.FlxAnimation;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

typedef DeathConfig = {
	var bpm:Float;
	var fnf_loss_sfx:String;
	var gameOver:String;
	var gameOverEnd:String;
}

class GameOverSubstate extends MusicBeatSubstate
{
	public static var instance:GameOverSubstate = null;

	public var boyfriend:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";
	var randomGameover:Int = 1;

	var tweenVocals:FlxTween;
	var tweenInst:FlxTween;

	var config:DeathConfig;

	var x:Float = 0;
	var y:Float = 0;

	public function new(x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
		super();
	}

	override function create() {
		config = Json.parse(Paths.getEmbedText("data/death.json"));

		instance = this;

		Conductor.onStepHit.remove(PlayState.instance.stepHit);
		Conductor.onBeatHit.remove(PlayState.instance.beatHit);
		Conductor.onSectionHit.remove(PlayState.instance.sectionHit);
		
		var daStage = PlayState.curStage;
		var daBf:String = '';

		if (PlayState.isPixelStage) {
			stageSuffix = "-pixel";
			daBf = "bf-pixel-dead";
		} else
			daBf = "bf-dead";

		super.create();

		// Conductor.songPosition = 0;

		boyfriend = new Boyfriend(x, y, daBf);
		add(boyfriend);

		var tweenProps:Dynamic = {
			"pitch": 0.1,
			"volume": 0
		};
		var anim:FlxAnimation = boyfriend.animation.getByName("firstDeath");
		var tweenDur:Float = anim.frameDuration * (anim.numFrames - 1);
		var tweenEase:EaseFunction = FlxEase.sineInOut;
		if (PlayState.instance != null && PlayState.instance.vocals != null)
			tweenVocals = FlxTween.tween(PlayState.instance.vocals, tweenProps, tweenDur, {"ease": tweenEase, "onComplete": function(twn:FlxTween) {
				PlayState.instance.vocals.stop();
			}});
		if (FlxG.sound.music != null)
			tweenInst = FlxTween.tween(FlxG.sound.music, tweenProps, tweenDur, {"ease": tweenEase, "onComplete": function(twn:FlxTween) {
				FlxG.sound.music.stop();
			}});

		camFollow = new FlxObject(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound(config.fnf_loss_sfx + stageSuffix));
		Conductor.bpm = config.bpm;

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		var randomCensor:Array<Int> = [];

		if (ClientPrefs.data.censorNaughty)
			randomCensor = [1, 3, 8, 13, 17, 21];

		randomGameover = FlxG.random.int(1, 25, randomCensor);
	}

	var playingDeathSound:Bool = false;

	override function update(elapsed:Float)
	{
		// makes the lerp non-dependant on the framerate
		// FlxG.camera.followLerp = CoolUtil.camLerpShit(0.01);

		super.update(elapsed);

		if (controls.ACCEPT || controls.BACK) {
			if (controls.ACCEPT)
				endBullshit();
			PlayState.instance.vocals.stop();
			FlxG.sound.music.stop();
		}

		if (controls.BACK)
		{
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (boyfriend.animation.curAnim.name == 'firstDeath' && boyfriend.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		switch (PlayState.storyWeek)
		{
			case 7:
				if (boyfriend.animation.curAnim.name == 'firstDeath' && boyfriend.animation.curAnim.finished && !playingDeathSound) {
					playingDeathSound = true;

					coolStartDeath(0.2);

					FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + randomGameover), 1, false, null, true, function() {
						if (!isEnding)
							FlxG.sound.music.fadeIn(4, 0.2, 1);
					});
				}
			default:
				if (boyfriend.animation.curAnim.name == 'firstDeath' && boyfriend.animation.curAnim.finished)
					coolStartDeath();
		}

		/*if (deathStarted)
			Debug.logTrace(Conductor.songPosition);*/
	}

	var deathStarted:Bool = false;
	private function coolStartDeath(?vol:Float = 1):Void
	{
		if (!isEnding) {
			deathStarted = true;
			FlxG.sound.music.stop();
			FlxG.sound.playMusic(Paths.music(config.gameOver + stageSuffix), vol);
			// Conductor.followSound = FlxG.sound.music;

			boyfriend.playAnim("deathLoop", true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (deathStarted && !isEnding)
			boyfriend.playAnim("deathLoop", true);
	}

	var isEnding:Bool = false;

	function endBullshit() {
		if (!isEnding) {
			if (tweenVocals != null)
				tweenVocals.cancel();
			if (tweenInst != null)
				tweenInst.cancel();

			isEnding = true;
			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(config.gameOverEnd + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer) {
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function() {
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}

	override function destroy() {
		if (tweenVocals != null)
			tweenVocals.cancel();
		if (tweenInst != null)
			tweenInst.cancel();

		instance = null;
		super.destroy();
	}
}
