import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.effects.FlxFlicker;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
#if discord_rpc
import Discord.DiscordClient;
#end
import flixel.FlxObject;
import flixel.FlxSprite;
import ui.MenuList.MenuTypedList;

class MainMenuState extends MusicBeatState {
	static var lastSelected:Int = -1;
	var menuItems:MenuTypedList<FlxSprite>;
	var optionShit:Array<String> = [
		"story_mode",
		"freeplay",
		"credits",
		"donate",
		"options"
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create() {
		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music("freakyMenu"));

		persistentDraw = true;
		persistentUpdate = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(Paths.image("menuBG"));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80, Paths.image("menuDesat"));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(bg.width));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.color = 0xFFfd719b;
		if (ClientPrefs.data.flashing)
			add(magenta);

		menuItems = new MenuTypedList<FlxSprite>(lastSelected);
		menuItems.checkBounds = true;
		menuItems.onChange = function(step:Int) {
			menuItems.forEach(function(spr:FlxSprite) {
				spr.animation.play("idle");
				spr.updateHitbox();

				if (spr == menuItems.selectedItem) {
					spr.animation.play("selected");

					var add:Float = 0;
					if (menuItems.length > 4)
						add = menuItems.length * 8;

					camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
					spr.centerOffsets();
				}
			});
		}
		menuItems.onSelect = function() {
			if (optionShit[menuItems.selectedIndex] == "donate")
				CoolUtil.coolOpenURL("https://ninja-muffin24.itch.io/funkin");
			else
			{
				if (menuItems.selected)
					return;

				menuItems.selected = true;
				lastSelected = menuItems.selectedIndex;

				FlxFlicker.flicker(magenta, 1.1, 0.15, false);

				menuItems.forEach(function(spr:FlxSprite) {
					if (menuItems.selectedItem != spr) {
						FlxTween.tween(spr, {alpha: 0}, 0.4, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween) {
							spr.kill();
						}});
					}
					else {
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
							var daChoice:String = optionShit[menuItems.selectedIndex];

							switch (daChoice) {
								case "story_mode":
									FlxG.switchState(new StoryMenuState());
								case "freeplay":
									FlxG.switchState(new FreeplayState());
								case "credits":
									FlxG.switchState(new CredtitsState());
								case "options":
									FlxG.switchState(new ui.OptionsState());
							}
						});
					}
				});
			}
		}
		add(menuItems);

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

		menuItems.change();

		FlxG.cameras.reset(new SwagCamera());
		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit:FlxText = new FlxText(1, FlxG.height - 18, 0, "AMORAL FUNKERS PRIVATE BETA " + FlxG.stage.application.meta["version"] + " (7QUID EXCLUSIVE)", 12);
		versionShit.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.scrollFactor.set();
		add(versionShit);

		super.create();
	}

	override function update(elapsed:Float) {
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (controls.UI_UP_P) {
			FlxG.sound.play(Paths.sound("scrollMenu"));
			menuItems.change(-1);
		}

		if (controls.UI_DOWN_P) {
			FlxG.sound.play(Paths.sound("scrollMenu"));
			menuItems.change(1);
		}

		if (!menuItems.selected) {
			if (controls.BACK) {
				FlxG.sound.play(Paths.sound("cancelMenu"));
				menuItems.selected = true;
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT) {
				FlxG.sound.play(Paths.sound("confirmMenu"));
				menuItems.select(false);
			}

			if (FlxG.keys.justPressed.SEVEN)
				LoadingState.loadAndSwitchState(new modding.ModdingState());
		}
		
		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite) {
			spr.screenCenter(X);
		});
	}
}