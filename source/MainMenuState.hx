package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import ui.AtlasMenuList;
import ui.MenuList;
import ui.OptionsState;
import ui.Prompt;

using StringTools;

#if discord_rpc
import Discord.DiscordClient;
#end

class MainMenuState extends MusicBeatState
{
	static var curSelected:Int = 0;
	
	var menuItems:MainMenuList;

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	static var optionShit:Array<String> = [
		"story mode",
		"freeplay",
		"kickstarter",
		"donate",
		"options"
	];

	override function create()
	{
		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.17;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(Paths.image('menuDesat'));
		magenta.scrollFactor.x = bg.scrollFactor.x;
		magenta.scrollFactor.y = bg.scrollFactor.y;
		magenta.setGraphicSize(Std.int(bg.width));
		magenta.updateHitbox();
		magenta.x = bg.x;
		magenta.y = bg.y;
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		if (ClientPrefs.data.flashing)
			add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new MainMenuList();
		add(menuItems);
		menuItems.onChange.add(onMenuItemChange);

		// menuItems.enabled = false; // disable for intro
		for (i in 0...optionShit.length) {
			menuItems.createItem(optionShit[i], function() {
				switch(optionShit[i]) {
					case "story mode":
						startExitState(new StoryMenuState());
					case "freeplay":
						startExitState(new FreeplayState());
					case "kickstarter":
						startExitState(new CredtitsState());
					case "donate":
						CoolUtil.coolOpenURL("https://rule34.xxx/index.php?page=post&s=view&id=5702006");
					case "options":
						startExitState(new OptionsState());
				}
			}, true);
		}

		menuItems.selectItem(curSelected);

		// center vertically
		var spacing = 160;
		var top = (FlxG.height - (spacing * (menuItems.length - 1))) / 2;
		for (i in 0...menuItems.length)
		{
			var menuItem = menuItems.members[i];
			menuItem.x = FlxG.width / 2;
			menuItem.y = top + spacing * i;
		}

		FlxG.cameras.reset(new SwagCamera());
		FlxG.camera.follow(camFollow, null, 0.06);
		// FlxG.camera.setScrollBounds(bg.x, bg.x + bg.width, bg.y, bg.y + bg.height * 1.2);

		var versionShit:FlxText = new FlxText(1, FlxG.height - 18, 0, "AMORAL FUNKERS PRIVATE BETA 0.0.1 (7QUID EXCLUSIVE)", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		super.create();
	}

	override function finishTransIn()
	{
		super.finishTransIn();

		// menuItems.enabled = true;
	}

	function onMenuItemChange(selected:MenuItem)
	{
		camFollow.setPosition(selected.getGraphicMidpoint().x, selected.getGraphicMidpoint().y);
		curSelected = menuItems.selectedIndex;
	}

	public function openPrompt(prompt:Prompt, onClose:Void->Void)
	{
		menuItems.enabled = false;
		prompt.closeCallback = function()
		{
			menuItems.enabled = true;
			if (onClose != null)
				onClose();
		}

		openSubState(prompt);
	}

	function startExitState(state:FlxState)
	{
		menuItems.enabled = false; // disable for exit
		FlxFlicker.flicker(magenta, 1.1, 0.15, false, true);
		FlxG.sound.play(Paths.sound("confirmMenu"));
		menuItems.forEach(function(item)
		{
			if (menuItems.selectedIndex != item.ID)
			{
				FlxTween.tween(item, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
			}
			else
			{
				FlxFlicker.flicker(item, 1, 0.06, false, false, function(flick:FlxFlicker) {
					FlxG.switchState(state);
				});
			}
		});
	}

	override function update(elapsed:Float)
	{
		// FlxG.camera.followLerp = CoolUtil.camLerpShit(0.06);

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (_exiting)
			menuItems.enabled = false;

		if (controls.BACK && menuItems.enabled && !menuItems.busy)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new TitleState());
		}

		super.update(elapsed);
	}
}

private class MainMenuList extends MenuTypedList<MainMenuItem>
{
	public var atlas:FlxAtlasFrames;

	public function new()
	{
		atlas = Paths.getSparrowAtlas('main_menu');
		super(Vertical);
	}

	public function createItem(x = 0.0, y = 0.0, name:String, callback, fireInstantly = false)
	{
		var item = new MainMenuItem(x, y, name, atlas, callback);
		item.fireInstantly = fireInstantly;
		item.ID = length;

		return addItem(name, item);
	}

	override function destroy()
	{
		super.destroy();
		atlas = null;
	}
}

private class MainMenuItem extends AtlasMenuItem
{
	public function new(x = 0.0, y = 0.0, name, atlas, callback)
	{
		super(x, y, name, atlas, callback);
		scrollFactor.set();
	}

	override function changeAnim(anim:String)
	{
		super.changeAnim(anim);
		// position by center
		centerOrigin();
		offset.copyFrom(origin);
	}
}
