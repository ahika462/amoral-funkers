package modcore;

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
}