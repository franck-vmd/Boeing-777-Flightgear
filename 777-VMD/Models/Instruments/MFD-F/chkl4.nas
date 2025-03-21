

var canvas_chkl4 = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_chkl4, MfDPanel.new("chkl4",canvas_group,"Aircraft/777-VMD/Models/Instruments/MFD-F/chkl4.svg",canvas_chkl4.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
       {
        },
        update: func()
};
