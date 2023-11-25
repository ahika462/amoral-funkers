package funkin.backend;

import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import funkin.backend.Controls.Device;

class InputFormatter {
    /**
     * Returns the name of the control
     * @param id 
     * @param device 
     * @return String
     */
    public static function format(id:Int, device:Device):String {
        return switch(device) {
            case Keys: getKeyName(id);
            case Gamepad(gamepadID): getButtonName(id, FlxG.gamepads.getByID(gamepadID));
        }
    }


    /**
     * Returns the name of the key
     * @param id 
     * @return String
     */
    public static function getKeyName(id:Int):String {
        return switch(id) {
            case ZERO: "0";
            case ONE: "1";
            case TWO: "2";
            case THREE: "3";
            case FOUR: "4";
            case FIVE: "5";
            case SIX: "6";
            case SEVEN: "7";
            case EIGHT: "8";
            case NINE: "9";
            case PAGEUP: "PgUp";
            case PAGEDOWN:"PgDown";
            case HOME: "Hm";
            case END: "End";
            case INSERT: "Ins";
            case ESCAPE: "Esc";
            case MINUS: "-";
            case PLUS: "+";
            case DELETE: "Del";
            case BACKSPACE: "BckSpc";
            case LBRACKET: "[";
            case RBRACKET: "]";
            case BACKSLASH: "\\";
            case CAPSLOCK: "Caps";
            case SEMICOLON: ";";
            case QUOTE: "'";
            case ENTER: "Ent";
            case SHIFT: "Shf";
            case COMMA: ",";
            case PERIOD: ".";
            case SLASH: "/";
            case GRAVEACCENT: "`";
            case CONTROL: "Ctrl";
            case ALT: "Alt";
            case SPACE: "Spc";
            case UP: "Up";
            case DOWN: "Dn";
            case LEFT: "Lf";
            case RIGHT: "Rt";
            case TAB: "Tab";
            case PRINTSCREEN: "PrtScrn";
            case NUMPADZERO: "#0";
            case NUMPADONE: "#1";
            case NUMPADTWO: "#2";
            case NUMPADTHREE: "#3";
            case NUMPADFOUR: "#4";
            case NUMPADFIVE: "#5";
            case NUMPADSIX: "#6";
            case NUMPADSEVEN: "#7";
            case NUMPADEIGHT: "#8";
            case NUMPADNINE: "#9";
            case NUMPADMINUS: "#-";
            case NUMPADPLUS: "#+";
            case NUMPADPERIOD: "#.";
            case NUMPADMULTIPLY: "#*";

            default: titleCase(FlxKey.toStringMap.get(id));
        }
    }

    /**
     * Returns the name of the button
     * @param id 
     * @param gamepad 
     * @return String
     */
    public static function getButtonName(id:Int, gamepad:FlxGamepad):String {
        return switch(gamepad.getInputLabel(id)) {
            case label: shortenButtonName(label);
        }
    }

    static var dirReg:EReg = ~/^(l|r).?-(left|right|down|up)$/;
    static function shortenButtonName(name:String):String {
        return switch(name == null ? "" : name.toLowerCase()) {
            case dir if (dirReg.match(dir)):
                dirReg.matched(1).toUpperCase() + " " + titleCase(dirReg.matched(2));
            case label: titleCase(label);
        }
    }

    static function titleCase(str:String) {
        return str.charAt(0).toUpperCase() + str.substr(1);
    }
}