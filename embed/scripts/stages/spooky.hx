var halloweenBG = null;

function create() {
    halloweenBG = new RuntimeSprite(null, -200, -100);
    halloweenBG.loadFrames("halloween_bg");
    halloweenBG.animation.addByPrefix("idle", "halloweem bg0");
    halloweenBG.animation.addByPrefix("lightning", "halloweem bg lightning strike", 24, false);
    halloweenBG.animation.play("idle");
    addBehindGf(halloweenBG);
}

function lightningStrikeShit() {
    playSound("thunder_" + random.int(1, 2));
    halloweenBG.animation.play("lightning");
    
    lightningStrikeBeat = Conductor.curBeat;
    lightningOffset = random.int(8, 24);

    boyfriend.playAnim("scared", true);
	gf.playAnim("scared", true);
}

var lightningStrikeBeat = 0;
var lightningOffset = 8;

function beatHit() {
    if (Conductor.curBeat > lightningStrikeBeat + lightningOffset && random.bool(10))
        lightningStrikeShit();
}