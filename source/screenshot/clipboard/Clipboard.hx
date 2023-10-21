package screenshot.clipboard;

import openfl.utils.ByteArray;
#if cpp
import cpp.StdString;
#end

@:cppFileCode('
    #include <iostream>
    #include <windows.h>

    using namespace std;
')

class Clipboard {
    public static function set(bytes:ByteArray) {
        #if cpp
        cpp_set(StdString.ofString(Std.string(bytes)));
        #end
    }

    #if cpp
    @:functionCode('
        if (IsClipboardFormatAvailable(CF_BITMAP)) {
            if (OpenClipboard(0)) {
                EmptyClipboard();
                const char *hBuff = str.c_str();
                /// SetClipboardData(CF_BITMAP, const_cast<char*>(hBuff));
                SetClipboardData(CF_BITMAP, new char[strlen(hBuff) + 1]);
            }
        }
    ')
    @:noPrivateAccess static function cpp_set(str:StdString) {}
    #end
}

// сука блять иди нахуй ебаная хуета я тебя в рот ебал