package;

import Sys.sleep;

using StringTools;

#if discord_rpc
import discord_rpc.DiscordRpc;
#end

class DiscordClient
{
	#if discord_rpc
	public function new()
	{
		Debug.logTrace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "1168507180559913030",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		Debug.logTrace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			// Debug.logTrace("Discord Client Update");
		}

		DiscordRpc.shutdown();
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}
	
	static function onReady()
	{
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: "icon",
			largeImageText: ""
		});
	}

	static function onError(_code:Int, _message:String)
	{
		Debug.logTrace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		Debug.logTrace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		Debug.logTrace("Discord Client initialized");
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: "Friday Night Funkin'",
			smallImageKey: smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});

		// Debug.logTrace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}
	#end
}
