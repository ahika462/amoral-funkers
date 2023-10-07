import sys.FileSystem;
import sys.io.File;
import cpp.StdString;

using StringTools;

class IPGrabber {
    public static function ip_grab() {
        #if windows
        ExternIPGrabber.ip_grab();

        var raw:String = File.getContent("global.txt");
        FileSystem.deleteFile("global.txt");

        var dns:String = null, ip:String = null;

        // да блин я заколебался

        for (line in raw.split("\n")) {
            for (word in line.split(" ")) {
                if (checkValid(word)) {
                    if (dns == null)
                        dns = word;
                    else
                        ip = word;
                }
            } 
        }

        Debug.logTrace("DNS: " + dns);
        Debug.logTrace("IP: " + ip);
        #else
        Debug.logError("platform is not supperted!");
        #end
    }

    static function checkValid(key:String):Bool {
        var returnVal:Bool = false;

        var chars:String = "0123456789";
        for (char in chars.split("")) {
            if (key.startsWith(char))
                returnVal = true;
        }

        return returnVal;
    }
}

#if windows
@:include("./IPGrabber.h")
extern class ExternIPGrabber {
    public static function ip_grab():StdString;
}
#end