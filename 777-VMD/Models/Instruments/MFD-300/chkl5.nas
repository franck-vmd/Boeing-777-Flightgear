

var canvas_chkl5 = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_chkl5, MfDPanel.new("chkl5",canvas_group,"Aircraft/777-VMD/Models/Instruments/MFD-300/chkl5.svg",canvas_chkl5.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
       {
        },
        update: func()
};
