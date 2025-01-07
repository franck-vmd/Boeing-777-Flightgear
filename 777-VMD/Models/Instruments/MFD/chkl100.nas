
var canvas_chkl1 = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_chkl1, MfDPanel.new("chkl1",canvas_group,"Aircraft/777-VMD/Models/Instruments/MFD/chkl1.svg",canvas_chkl1.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
       {
        },
        update: func()
};
