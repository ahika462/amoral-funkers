package funkin.backend.beat;

import funkin.backend.beat.Conductor.BPMChangeEvent;
import flixel.FlxSubState;

class MusicBeatState extends FlxSubState {
    var curStep:Int = 0;
    var curBeat:Int = 0;
    var curSection:Int = 0;
	
	function stepHit() {}

	function beatHit() {}

	function sectionHit() {}

    override function update(elapsed:Float) {
		var oldStep:Int = curStep;

        var lastChange:BPMChangeEvent = {
            stepTime: 0,
            songTime: 0,
            bpm: 0
        }
        for (i in 0...Conductor.bpmChangeMap.length) {
            if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
                lastChange = Conductor.bpmChangeMap[i];
        }

        curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
        
		if (oldStep != curStep && curStep >= 0) {
			curBeat = Std.int(curStep / 4);
			
			var oldSection:Int = curSection;
			curSection = 0;
			
			var stepsToDo:Int = 0;
			/*if (PlayState.SONG != null && PlayState.SONG.notes[0] != null) {
				if (PlayState.SONG.notes[0].sectionBeats != null)
					stepsToDo += PlayState.SONG.notes[0].sectionBeats * 4;
				else
					stepsToDo += PlayState.SONG.notes[0].lengthInSteps;
			} else*/
				stepsToDo += 16;

			while (curStep >= stepsToDo) {
				curSection++;
				
				/*if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) {
					if (PlayState.SONG.notes[curSection].sectionBeats != null)
						stepsToDo += PlayState.SONG.notes[curSection].sectionBeats * 4;
					else
						stepsToDo += PlayState.SONG.notes[curSection].lengthInSteps;
				} else*/
					stepsToDo += 16;
			}

			stepHit();
			if (curStep % 4 == 0)
				beatHit();
			if (oldSection != curSection)
				sectionHit();
        }

		super.update(elapsed);
	}
}