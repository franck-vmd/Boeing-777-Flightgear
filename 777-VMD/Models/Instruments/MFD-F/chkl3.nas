

var canvas_chkl3 = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_chkl3, MfDPanel.new("chkl3",canvas_group,"Aircraft/777-VMD/Models/Instruments/MFD-F/chkl3.svg",canvas_chkl3.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
       {
        },
        update: func()
};
