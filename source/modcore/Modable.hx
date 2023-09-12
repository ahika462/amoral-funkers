package modcore;

interface Modable {
    private var script:ModScript;
    private function initializeScript(path:String):ModScript;
    private function callOnScript(name:String, args:Array<Dynamic>):Dynamic;
    private function setOnScript(name:String, value:Dynamic):Dynamic;
}