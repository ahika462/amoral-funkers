package ui;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;

typedef MenuList = MenuTypedList<FlxBasic>;

class MenuTypedList<T:FlxBasic> extends FlxTypedGroup<T> {
    dynamic public function onChange(step:Int = 0) {}
    dynamic public function onSelect() {
        selected = true;
    }
    
    public var selectedIndex:Int = -1;
    public var selectedItem(get, never):T;
    public var selected:Bool = false;

    public function new(startIndex:Int = -1) {
        super();
        selectedIndex = startIndex;
    }

    function get_selectedItem():T {
        return members[selectedIndex];
    }

    override function add(item:T):T {
        super.add(item);

        if (selectedIndex == -1)
            selectedIndex = 0;

        return item;
    }
}