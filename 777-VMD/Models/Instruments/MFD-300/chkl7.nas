

var canvas_chkl7 = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_chkl7, MfDPanel.new("chkl7",canvas_group,"Aircraft/777-VMD/Models/Instruments/MFD-300/chkl7.svg",canvas_chkl7.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
       {
        },
        update: func()
};
