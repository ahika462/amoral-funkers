import flixel.FlxBasic;

interface IHScriptable {
    public function add(obj:FlxBasic):FlxBasic;
    public function insert(pos:Int, obj:FlxBasic):FlxBasic;
    public function remove(obj:FlxBasic, splice:Bool = false):FlxBasic;

    public function addBehindGf(obj:FlxBasic):FlxBasic;
    public function addBehindDad(obj:FlxBasic):FlxBasic;
    public function addBehindBoyfriend(obj:FlxBasic):FlxBasic;

    public var gf:Character;
    public var dad:Character;
    public var boyfriend:Character;
}