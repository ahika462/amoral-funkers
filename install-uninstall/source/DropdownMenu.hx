import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using flixel.util.FlxSpriteUtil;

class DropdownMenu extends FlxSpriteGroup {
    inline static var HIGHLIGHT_WIDTH:Int = 160;
    inline static var HIGHLIGHT_HEIGHT:Int = 25;

    inline static var OPTION_WIDTH:Int = 170;
    inline static var OPTION_HEIGHT:Int = 35;

    var background:FlxSprite;
    var highlight:FlxSprite;

    var options:Array<String> = [];
    var items:Array<FlxText> = [];

    public dynamic function callback(choice:String) {}

    public function new(x:Float = 0, y:Float = 0, options:Array<String>) {
        super(x - OPTION_WIDTH, y);
        this.options = options;
        
        background = new FlxSprite().makeGraphic(OPTION_WIDTH, OPTION_HEIGHT * options.length, 0x00000000);
        background.drawRoundRect(0, 0, OPTION_WIDTH, OPTION_HEIGHT * options.length, 10, 10, 0xFFFFFFFF);
        add(background);

        highlight = new FlxSprite().makeGraphic(OPTION_WIDTH, OPTION_HEIGHT, 0x00000000);
        highlight.drawRoundRect((OPTION_WIDTH - HIGHLIGHT_WIDTH) / 2, (OPTION_HEIGHT - HIGHLIGHT_HEIGHT) / 2, HIGHLIGHT_WIDTH, HIGHLIGHT_HEIGHT, 10 / options.length, 10 / options.length, 0xFFE4E4E4);
        highlight.alpha = 0;
        add(highlight);

        for (i in 0...options.length) {
            var txt:FlxText = new FlxText(HIGHLIGHT_HEIGHT - 16, HIGHLIGHT_HEIGHT - 16 + OPTION_HEIGHT * i, OPTION_WIDTH - 10 / options.length, options[i], 14);
            txt.font = AssetPaths.font__otf;
            txt.color = 0xFF000000;
            // txt.y = (HIGHLIGHT_HEIGHT - txt.height) / 2;
            // txt.x = txt.y;
            add(txt);
            items.push(txt);
        }
    }

    override function update(elapsed:Float) {
        if (active) {
            var choice:Int = Std.int(Math.max(FlxG.mouse.y - y, 0) / OPTION_HEIGHT);
        
            if (choice >= 0 && choice < options.length) {
                highlight.y = OPTION_HEIGHT * choice + y;
                highlight.alpha = 1;
    
                if (FlxG.mouse.justPressed)
                    callback(options[choice]);
            } else
                highlight.alpha = 0;
        }

        if (!((FlxG.mouse.x > x - 10 && FlxG.mouse.x < x - 10 + width + 11 && FlxG.mouse.y > y - 10 && FlxG.mouse.y < y - 10 + height + 10)))
            deactivate();

        super.update(elapsed);
    }

    public function activate() {
        active = true;
        visible = true;
    }

    public function deactivate() {
        active = false;
        visible = false;
    }

    override function setPosition(x:Float = 0, y:Float = 0) {
        super.setPosition(x - width, y);
    }
}