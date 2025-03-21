

var canvas_chkl9 = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_chkl9, MfDPanel.new("chkl9",canvas_group,"Aircraft/777-VMD/Models/Instruments/MFD-300/chkl9.svg",canvas_chkl9.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
       {
        },
        update: func()
};
