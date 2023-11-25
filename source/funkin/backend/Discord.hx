package funkin.backend;

import sys.thread.Thread;
#if discord_rpc
import discord_rpc.DiscordRpc;
#end

class DiscordClient {
    #if discord_rpc
    /**
     * Starts Discord RPC
     */
     public static function initialize() {
		Thread.create(function() {
            Debug.logTrace("Discord Client starting...");
            DiscordRpc.start({
                clientID: "1168507180559913030",
                onReady: onReady,
                onError: onError,
                onDisconnected: onDisconnected
            });
            Debug.logTrace("Discord Client started.");

            while (true) {
                DiscordRpc.process();
                Sys.sleep(2);
            }

            DiscordRpc.shutdown();
        });
		Debug.logTrace("Discord Client initialized");
	}

    /**
     * Changes Discord RPC presence
     * @param details 
     * @param state 
     * @param smallImageKey 
     * @param hasStartTimestamp 
     * @param endTimestamp 
     */
    public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
		var startTimestamp:Float = hasStartTimestamp ? Date.now().getTime() : 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: "icon",
			largeImageText: "",
			smallImageKey: smallImageKey,
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});
	}

    /**
     * Stops Discord RPC
     */
    public static function shutdown() {
		DiscordRpc.shutdown();
	}

    @:noPrivateAccess static function onReady() {
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: "icon",
			largeImageText: ""
		});
	}

	@:noPrivateAccess static function onError(code:Int, message:String) {
        Debug.logError(code + ": " + message);
	}

	@:noPrivateAccess static function onDisconnected(code:Int, message:String) {
        Debug.logTrace("Disconnected! " + code + ": " + message);
	}
    #end
}