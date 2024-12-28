

var canvas_elec = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_elec, MfDPanel.new("elec",canvas_group,"Aircraft/777-VMD/Models/Instruments/MFD/elec.svg",canvas_elec.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
       {
        },
        update: func()
};
