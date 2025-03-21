

var canvas_chkl6 = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_chkl6, MfDPanel.new("chkl6",canvas_group,"Aircraft/777-VMD/Models/InstrumentsX/MFD-X9/chkl6.svg",canvas_chkl6.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
       {
        },
        update: func()
};
