

var canvas_stat = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_stat, MfDPanel.new("stat",canvas_group,"Aircraft/777-VMD/Models/Instruments/MFD-300/stat.svg",canvas_stat.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
       {
        },
        update: func()
};
