package funkin;

import funkin.backend.PlayerSettings;
import funkin.backend.Controls;
import funkin.CustomFadeTransition;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;

class MusicBeatState extends FlxUIState {
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		Conductor.onStepHit.add(stepHit);
		Conductor.onBeatHit.add(beatHit);
		Conductor.onSectionHit.add(sectionHit);

		super.create();
	}

	public function stepHit() {}
	public function beatHit() {}
	public function sectionHit() {}

	override function destroy() {
		Conductor.onStepHit.remove(stepHit);
		Conductor.onBeatHit.remove(beatHit);
		Conductor.onSectionHit.remove(sectionHit);

		for (sound in FlxG.sound.list) {
			if (!sound.playing && !sound.persist)
				sound.destroy();
		}
	}

	override function transitionIn() {
		if (FlxTransitionableState.skipNextTransIn)
		{
			FlxTransitionableState.skipNextTransIn = false;

			if (finishTransIn != null)
				finishTransIn();

			return;
		}

		var _trans = new CustomFadeTransition(true);

		_trans.setStatus(FULL);
		openSubState(_trans);

		_trans.finishCallback = finishTransIn;
		_trans.start(OUT);
	}

	override function transitionOut(?onExit:Void->Void) {
		_onExit = onExit;

		var _trans = new CustomFadeTransition(false);

		_trans.setStatus(EMPTY);
		openSubState(_trans);

		_trans.finishCallback = finishTransOut;
		_trans.start(IN);
	}

	override function startOutro(onOutroComplete:Void->Void) {
		_exiting = true;
		transitionOut(onOutroComplete);
		
		if (FlxTransitionableState.skipNextTransOut) {
			FlxTransitionableState.skipNextTransOut = false;
			finishTransOut();
		}
	}
}
