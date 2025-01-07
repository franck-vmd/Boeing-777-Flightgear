

var canvas_chkl8 = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_chkl8, MfDPanel.new("chkl8",canvas_group,"Aircraft/777-VMD/Models/Instruments/MFD/chkl8.svg",canvas_chkl8.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
       {
        },
        update: func()
};
