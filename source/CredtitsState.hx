import flixel.FlxG;
import openfl.utils.Assets;
import flixel.FlxSprite;
import flixel.text.FlxText;

class CredtitsState extends MusicBeatState {
    static var creditsStuff:Array<CreditMetadata> = [
        new CreditMetadata("temmie")
    ];

    override function create() {
        for (i in creditsStuff) {
            var text:FlxText = new FlxText(300, 300, i.name, 64);
            add(text);
            var icon:FlxSprite = new FlxSprite(i.name == "temmie" ? Assets.getBitmapData("amoral/e705aac6-6fb4-4ccc-945c-df2950a1d972.png") : Paths.image("credits/" + i.icon));
            icon.setGraphicSize(0, 300);
            icon.updateHitbox();
            icon.x = text.x + text.width + 10;
            icon.y = (text.y + text.height / 2) - icon.height / 2;
            icon.antialiasing = ClientPrefs.data.antialiasing;
            add(icon);
        }

        super.create();
    }

    override function update(elapsed:Float) {
        if (controls.BACK) {
            FlxG.sound.play(Paths.sound("cancelMenu"));
            FlxG.switchState(new MainMenuState());
        }

        super.update(elapsed);
    }
}

class CreditMetadata {
    public var name:String;
    public var icon:String;
    public var description:String;
    public var link:String;

    public function new(name:String, ?icon:String, ?description:String, ?link:String) {
        this.name = name;
        this.icon = icon;
        this.description = description;
        this.link = link;
    }
}