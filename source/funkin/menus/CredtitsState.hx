package funkin.menus;

import funkin.Alphabet;
import funkin.MusicBeatState;
import flixel.FlxG;
import openfl.utils.Assets;
import flixel.FlxSprite;
import flixel.text.FlxText;

class CredtitsState extends MusicBeatState {
    static var creditsStuff:Array<CreditMetadata> = [
        new CreditMetadata("temmie"),
        new CreditMetadata("BBQ")
    ];

    override function create() {
        for (i in creditsStuff) {
            var text:Alphabet = new Alphabet(0, (130 * creditsStuff.indexOf(i)) + 100, i.name, true);
            text.screenCenter(X);
            add(text);

            var icon:FlxSprite = new FlxSprite();
            if (i.name == "temmie")
                icon.loadGraphic(Assets.getBitmapData("amoral/e705aac6-6fb4-4ccc-945c-df2950a1d972.png"));
            else if (i.name == "BBQ")
                icon.loadGraphic(Assets.getBitmapData("amoral/-.png"));
            else
                icon.loadGraphic(Paths.image("credits/" + i.icon));
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
    public var image:String;
    public var link:String;

    public function new(name:String, ?icon:String, ?description:String, ?image:String, ?link:String) {
        this.name = name;
        this.icon = icon;
        this.description = description;
        this.image = image;
        this.link = link;
    }
}