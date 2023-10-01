package modding.editors;

import StageData.StageFile;

using StringTools;

class StageDebugger extends BaseDebugger {
    public var curStage:String = "stage";
    public var json:StageFile;

    var gf:Character;
    var dad:Character;
    var boyfriend:Character;

    var hscripts:Array<HScript> = [];

    public function new(stage:String = "stage") {
        super();
        curStage = stage;
        json = StageData.get(stage);

        gf = new Character(400 + json.gf[0], 130 + json.gf[0], "gf");
        add(gf);

        dad = new Character(100 + json.dad[0], 100 + json.dad[1], "dad");
        add(dad);

        boyfriend = new Character(770 + json.boyfriend[0], 450 + json.boyfriend[1], "bf");
        add(boyfriend);

        var files:Array<String> = Paths.getEmbedFiles("scripts/stages");
        for (file in files) {
            if (file.endsWith(".hx"))
                hscripts.push(new HScript(file));
        }

        for (hscript in hscripts) {
            hscript.call("pre_create");
            hscript.call();
        }
    }
}