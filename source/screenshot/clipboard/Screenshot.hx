package screenshot.clipboard;

import openfl.display.PNGEncoderOptions;
import openfl.utils.ByteArray;
import lime.app.Application;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;


class Screenshot {
    public static function shot(rect:Rectangle = null) {
        var bmp:BitmapData = BitmapData.fromImage(Application.current.window.readPixels());

        var png:ByteArray = bmp.encode(rect != null ? rect : bmp.rect, new PNGEncoderOptions());
        png.position = 0;

        Clipboard.set(png);
    }
}