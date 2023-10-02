package modding.editors;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import StageData.StageFile;

using StringTools;

class StageDebugger extends BaseDebugger {
    public var curStage:String = "stage";
    public var json:StageFile;

    var gf:Character;
    var dad:Character;
    var boyfriend:Character;
    var holdingChar:Character = null;

    public var camOverlay:FlxSprite;

    var hscripts:Array<HScript> = [];

    public function new(stage:String = "stage") {
        super();
        curStage = stage;
        json = StageData.get(stage);

        gf = new Character(400 + json.gf[0], 130 + json.gf[0], "gf");
        add(gf);

        dad = new Character(100 + json.dad[0], 100 + json.dad[1], "dad");
        add(dad);

        boyfriend = new Character(770 + json.boyfriend[0], 450 + json.boyfriend[1], "bf", true);
        add(boyfriend);

        camOverlay = new FlxSprite(Paths.image("camThingy"));
        camOverlay.scale.set((FlxG.camera.width * json.zoom) / camOverlay.width, (FlxG.camera.height * json.zoom) / camOverlay.height);
        camOverlay.updateHitbox();
        camOverlay.setPosition(gf.getGraphicMidpoint().x - camOverlay.width / 2, gf.getGraphicMidpoint().y - camOverlay.height / 2);
        camOverlay.antialiasing = ClientPrefs.data.antialiasing;
        add(camOverlay);

        if (Paths.embedExists("scripts/stages/" + stage + ".hx"))
            hscripts.push(new HScript(Paths.getEmbedShit("scripts/stages/" + stage + ".hx")));

        for (hscript in hscripts) {
            hscript.call("pre_create");
            hscript.call("create");
        }
    }

    override function update(elapsed:Float) {
        if (FlxG.mouse.justPressed) {
            if (FlxG.mouse.overlaps(boyfriend, ModdingState.instance.camEditor))
                holdingChar = boyfriend;
            else if (FlxG.mouse.overlaps(dad, ModdingState.instance.camEditor))
                holdingChar = dad;
            else if (FlxG.mouse.overlaps(gf, ModdingState.instance.camEditor))
                holdingChar = gf;
        }

        if (FlxG.mouse.justReleased)
            holdingChar = null;

        if (holdingChar != null) {
            holdingChar.setPosition(FlxG.mouse.x - holdingChar.width / 2, FlxG.mouse.y - holdingChar.height / 2);

            if (holdingChar == boyfriend)
                json.boyfriend = [boyfriend.x - 770, boyfriend.y - 450];
            else if (holdingChar == dad)
                json.dad = [dad.x - 100, dad.y - 100];
            else if (holdingChar == gf)
                json.gf = [gf.x - 400, gf.y - 130];
        }

        super.update(elapsed);
    }

    public function updateZoomShit(newZoom:Float) {
        json.zoom = newZoom;
        camOverlay.scale.set((FlxG.camera.width * json.zoom) / camOverlay.width, (FlxG.camera.height * json.zoom) / camOverlay.height);
    }
}