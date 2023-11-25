package funkin.backend;

class Utils {
    public static var array:ArrayUtil = new ArrayUtil();
}

private class ArrayUtil {
    public function new() {}

    public function resize<T>(array:Array<T>, size:Int, fill:T = null):Array<T> {
        if (array.length > size)
            array.resize(size);
        else {
            while (array.length < size)
                array.push(fill);
        }
        return array;
    }
}