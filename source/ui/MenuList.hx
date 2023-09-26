package ui;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;

typedef MenuList = MenuTypedList<FlxBasic>;

class MenuTypedList<T:FlxBasic> extends FlxTypedGroup<T> {
    dynamic public function onChange(step:Int) {}
    dynamic public function onSelect() {}
    
    public var selectedIndex:Int = -1;
    public var selectedItem(get, never):T;
    public var selected:Bool = false;

    public var checkBounds:Bool = false;

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

    public function change(step:Int = 0, pattern:Bool = true) {
        if (pattern) {
            if (selected)
                return;
            
            selectedIndex += step;
    
            if (checkBounds) {
                if (selectedIndex >= length)
                    selectedIndex = 0;
                if (selectedIndex < 0)
                    selectedIndex = length - 1;
            }
        }

        onChange(step);
    }

    public function select(pattern:Bool = true) {
        if (pattern)
            selected = true;

        onSelect();
    }
}