package funkin;

import funkin.backend.PlayerSettings;
import funkin.backend.Controls;
import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState {
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		Conductor.onStepHit.add(stepHit);
		Conductor.onBeatHit.add(beatHit);
		Conductor.onSectionHit.add(sectionHit);

		super.create();
	}

	function stepHit() {}
	function beatHit() {}
	function sectionHit() {}

	override function destroy() {
		Conductor.onStepHit.remove(stepHit);
		Conductor.onBeatHit.remove(beatHit);
		Conductor.onSectionHit.remove(sectionHit);
	}
}
