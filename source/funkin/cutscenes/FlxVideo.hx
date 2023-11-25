package funkin.cutscenes;

import flixel.FlxG;
#if hxCodec
import hxcodec.flixel.FlxVideo as Video;
#else
import openfl.events.NetStatusEvent;
import openfl.net.NetConnection;
import openfl.net.NetStream;
import openfl.media.Video;
#end

class FlxVideo {
	var video:Video;
	#if !hxCodec
	var netStream:NetStream;
	#end

	public var volume(get, set):Float;
	public var pan(get, set):Float;

	dynamic public function finishCallback() {}

	public function new(vidSrc:String) {
		video = new Video();
		video.x = 0;
		video.y = 0;

		FlxG.addChildBelowMouse(video);

		#if hxCodec
		video.onEndReached.add(function() {
			video.dispose();
			FlxG.removeChild(video);

			finishCallback();
		});
		video.play(Paths.file(vidSrc));
		#else
		var netConnection = new NetConnection();
		netConnection.connect(null);

		netStream = new NetStream(netConnection);
		netStream.client = {onMetaData: function(data:Dynamic) {
			video.attachNetStream(netStream);

			video.width = FlxG.width;
			video.height = FlxG.height;
		}};
		netConnection.addEventListener(NetStatusEvent.NET_STATUS, function(?e:NetStatusEvent) {
			if (e.info.code == 'NetStream.Play.Complete') {
				netStream.dispose();
				FlxG.removeChild(video);
	
				finishCallback();
			}
		});
		netStream.play(Paths.file(vidSrc));
		#end
	}

	public function get_volume():Float {
		#if hxCodec
		return video.volume / 100 / (FlxG.sound.muted ? 0 : FlxG.sound.volume);
		#else
		return netStream.soundTransform.volume / (FlxG.sound.muted ? 0 : FlxG.sound.volume);
		#end
	}

	public function set_volume(value:Float):Float {
		#if hxCodec
		video.volume = Std.int(value * 100 * (FlxG.sound.muted ? 0 : FlxG.sound.volume));
		#else
		netStream.soundTransform.volume = value * (FlxG.sound.muted ? 0 : FlxG.sound.volume);
		#end
		return value;
	}
}