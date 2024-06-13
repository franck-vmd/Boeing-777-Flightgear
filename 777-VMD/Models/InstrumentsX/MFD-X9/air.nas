

var canvas_air = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_air, MfDPanel.new("air",canvas_group,"Aircraft/777-VMD/Models/InstrumentsX/MFD-X9/air.svg",canvas_air.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
       {
        },
        update: func()
};
