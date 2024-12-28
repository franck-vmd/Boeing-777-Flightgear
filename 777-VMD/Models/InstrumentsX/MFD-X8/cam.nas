

var canvas_cam = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_cam, MfDPanel.new("cam",canvas_group,"Aircraft/777-VMD/Models/InstrumentsX/MFD-X8/cam.svg",canvas_cam.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
       {
        },
        update: func()
};
