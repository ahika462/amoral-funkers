import lime.utils.Bytes;
import openfl.display.PNGEncoderOptions;
import openfl.display.BitmapData;
import sys.io.File;
import sys.thread.Thread;
import openfl.utils.Assets;
import sys.FileSystem;

using StringTools;

class Install {
    inline static var path:String = "C:/Games/AMORAL FUNKERS/";

    public static function install(onProgress:Float->Void, onError:String->Dynamic->Void, onComplete:Void->Void) {
        if (!FileSystem.exists(path))
            FileSystem.createDirectory(path);

        Thread.create(function() {
            var files:Array<String> = Assets.getLibrary("build").list("BINARY");
            var progress:InstallProgress = new InstallProgress(files.length);

            for (file in files) {
                var fileName:String = file.substr("build/".length);
                if (fileName.contains("/")) {
                    var folder:String = path + fileName.substring(0, fileName.lastIndexOf("/"));
                    if (!FileSystem.exists(folder))
                        FileSystem.createDirectory(folder);
                }

                try {
                    @:privateAccess {
                        if (Assets.getLibrary("build").types.exists(fileName)) {
                            switch(Assets.getLibrary("build").types.get(fileName)) {
                                case IMAGE:
                                    var bmp:BitmapData = BitmapData.fromImage(Assets.getLibrary("build").getImage(fileName));
                                    File.saveBytes(path + fileName, bmp.encode(bmp.rect, new PNGEncoderOptions()));

                                default:
                                    var bytes:Bytes = Assets.getLibrary("build").getBytes(fileName);
                                    File.saveBytes(path + fileName, bytes);
                            }
                        } else
                            File.saveBytes(path + fileName, Assets.getLibrary("build").getBytes(fileName));
                    }
                } catch(e:Dynamic) {
                    onError(fileName, e);
                    break;
                }
                progress.filesInstalled++;

                onProgress(progress.percent);
            }

            onComplete();
        });
    }
}

class InstallProgress {
    public var filesTotal:Int;
    public var filesInstalled:Int;

    public var percent(get, never):Float;
    function get_percent():Float {
        return (filesInstalled / filesTotal);
    }

    public function new(filesTotal:Int) {
        this.filesTotal = filesTotal;
    }
}