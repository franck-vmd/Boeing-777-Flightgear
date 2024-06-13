

var canvas_chkl = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_chkl, MfDPanel.new("chkl",canvas_group,"Aircraft/777-VMD/Models/InstrumentsX/MFD-X9/chkl.svg",canvas_chkl.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
       {
        },
        update: func()
};
