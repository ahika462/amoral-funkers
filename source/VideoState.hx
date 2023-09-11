package;

import openfl.events.MouseEvent;
import flixel.FlxG;
import openfl.display.Sprite;

class VideoState extends MusicBeatState {
	var video:FlxVideo;
	private var overlay:Sprite;

	public static var seenVideo:Bool = false;

	override function create() {
		super.create();

		seenVideo = true;

		FlxG.save.data.seenVideo = true;
		FlxG.save.flush();

		video = new FlxVideo("music/kickstarterTrailer.mp4");
		video.finishCallback = finishVid;

		overlay = new Sprite();
		overlay.graphics.beginFill(0, 0.5);
		overlay.graphics.drawRect(0, 0, 1280, 720);
		overlay.addEventListener(MouseEvent.MOUSE_DOWN, overlay_onMouseDown);

		overlay.buttonMode = true;
		// FlxG.stage.addChild(overlay);
	}

	function finishVid() {
		TitleState.initialized = false;
		FlxG.switchState(new TitleState());
	}

	private function overlay_onMouseDown(?e:MouseEvent) {
		video.volume = 20;
		video.pan = -1;

		FlxG.stage.removeChild(overlay);
	}
}