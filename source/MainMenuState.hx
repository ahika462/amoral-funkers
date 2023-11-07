import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
#if discord_rpc
import Discord.DiscordClient;
#end
import flixel.FlxSprite;

class MainMenuState extends MusicBeatState {
	static var curSelected:Int = 0;
	var optionShit:Array<String> = [
		"story_mode",
		"freeplay",
		"credits",
		"donate",
		"options"
	];
	var menuItems:FlxSpriteGroup;

	var magenta:FlxSprite;

	override function create() {
		#if discord_rpc
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music("freakyMenu"));

		persistentDraw = true;
		persistentUpdate = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(Paths.image("menuBG"));
		bg.scrollFactor.set(0, yScroll);
		#if (flixel >= "5.4.0")
		bg.setGraphicSize(bg.width * 1.2);
		#else
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		#end
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		if (ClientPrefs.data.flashing) {
			magenta = new FlxSprite(-80, Paths.image("menuDesat"));
			magenta.scrollFactor.set(0, yScroll);
			#if (flixel >= "5.4.0")
			magenta.setGraphicSize(bg.width);
			#else
			magenta.setGraphicSize(Std.int(bg.width));
			#end
			magenta.updateHitbox();
			magenta.screenCenter();
			magenta.visible = false;
			magenta.antialiasing = ClientPrefs.data.antialiasing;
			magenta.color = 0xFFfd719b;
			add(magenta);
		}

		menuItems = new FlxSpriteGroup();
		for (i in 0...optionShit.length) {
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.frames = Paths.getSparrowAtlas("mainmenu/menu_" + optionShit[i]);
			menuItem.animation.addByPrefix("idle", optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix("selected", optionShit[i] + " white", 24);
			menuItem.animation.play("idle");
			menuItem.screenCenter(X);
			menuItems.add(menuItem);

			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.updateHitbox();
		}
		add(menuItems);

		FlxG.cameras.reset(new SwagCamera());
		FlxG.camera.target = new FlxObject(0, 0, 0, 0);
		FlxG.camera.style = LOCKON;
		FlxG.camera.followLerp = 0.06;

		changeItem();

		var versionShit:FlxText = new FlxText(1, FlxG.height - 18, 0, "AMORAL FUNKERS PRIVATE BETA " + FlxG.stage.application.meta.get("version") + " (7QUID EXCLUSIVE)", 12);
		versionShit.setFormat(Paths.font("vcr.ttf"), 16, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
		versionShit.scrollFactor.set();
		add(versionShit);

		super.create();
	}

	function changeItem(value:Int = 0) {
		curSelected = CoolUtil.boundSelection(curSelected + value, 0, optionShit.length - 1);

		for (i in 0...menuItems.length) {
			if (i != curSelected) {
				var menuItem:FlxSprite = menuItems.members[i];
				menuItem.animation.play("idle");
				menuItem.updateHitbox();
			}
		}
		
		var menuItem:FlxSprite = menuItems.members[curSelected];
		menuItem.animation.play("selected");
		menuItem.centerOffsets();

		FlxG.camera.target.setPosition(menuItem.getGraphicMidpoint().x, menuItem.getGraphicMidpoint().y - (menuItems.length > 4 ? menuItems.length * 8 : 0));
	}

	var selectedSomethin:Bool = false;
	override function update(elapsed:Float) {
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		function checkControls() {
			if (selectedSomethin)
				return;

			if (FlxG.keys.justPressed.SEVEN) {
				selectedSomethin = true;
				LoadingState.loadAndSwitchState(new modding.ModdingState());
			}
			if (controls.UI_UP_P) {
				FlxG.sound.play(Paths.sound("scrollMenu"));
				changeItem(-1);
			}
			if (controls.UI_DOWN_P) {
				FlxG.sound.play(Paths.sound("scrollMenu"));
				changeItem(1);
			}
			if (controls.BACK) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound("cancelMenu"));
				FlxG.switchState(new TitleState());
			}
			if (controls.ACCEPT) {
				if (optionShit[curSelected] == "donate") {
					CoolUtil.coolOpenURL("https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game/");
					return;
				}
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound("confirmMenu"));

				if (magenta != null)
					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

				for (i in 0...menuItems.length) {
					if (i != curSelected) {
						var menuItem:FlxSprite = menuItems.members[i];
						FlxTween.tween(menuItem, {"alpha": 0}, 0.4, {"ease": FlxEase.quadOut, "onComplete": function(twn:FlxTween) {
							menuItem.destroy();
						}});
					}
				}

				var menuItem:FlxSprite = menuItems.members[curSelected];
				FlxFlicker.flicker(menuItem, 1, 0.06, false, false, function(flick:FlxFlicker) {
					var daChoice:String = optionShit[curSelected];

					switch (daChoice) {
						case "story_mode":
							FlxG.switchState(new StoryMenuState());
						case "freeplay":
							FlxG.switchState(new FreeplayState());
						case "credits":
							FlxG.switchState(new CredtitsState());
						case "options":
							// FlxG.switchState(new ui.OptionsState());
					}
				});
			}
		}
		checkControls();

		super.update(elapsed);
	}
}