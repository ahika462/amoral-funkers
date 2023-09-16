package modcore;

import hscriptBase.Expr;
import tea.SScript;

using StringTools;

class ModScript extends SScript {
    public function new(?scriptPath:String = "", ?preset:Bool = true, ?startExecute:Bool = true) {
        super(scriptPath, preset, startExecute);
    }

    override function preset() {
        if (_destroyed)
			return;
		if (!active)
			return;

		setClass(Date);
		setClass(DateTools);
		setClass(Math);
		setClass(Std);
		setClass(StringTools);
		setClass(Type);
    }

	override function execute() {
		if (_destroyed)
			return;

		if (interp == null || !active)
			return;

		var origin:String = #if hscriptPos {
			if (customOrigin != null && customOrigin.length > 0)
				customOrigin;
			else if (scriptFile != null && scriptFile.length > 0)
				scriptFile;
			else 
				"SScript";
		} #else null #end;

		if (script != null && script.length > 0) {
			try  {
				var expr:Expr = parser.parseString(script #if hscriptPos, origin #end);
				var r = interp.execute(expr);
				returnValue = r;
			}
			catch (e) {
				parsingException = e;
				returnValue = null;
			}
		}
	}
}