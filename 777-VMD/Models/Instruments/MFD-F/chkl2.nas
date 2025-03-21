

var canvas_chkl2 = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_chkl2, MfDPanel.new("chkl2",canvas_group,"Aircraft/777-VMD/Models/Instruments/MFD-F/chkl2.svg",canvas_chkl2.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
       {
        },
        update: func()
};
