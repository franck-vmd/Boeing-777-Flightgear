
var Pipe = {
        feeder : [],
        fillColor:"rgba(0,255,0,1)",
        emptyColor:"rgba(255,255,255,1)",
        new : func(elt) {
            var m = {parents : [Pipe]};
            m.feeder=[];
            m.overridePump = nil;
            m.elt = elt;
            m.valves = [];
            return m;
        },
        feededBy : func(feeder) {
            append(me.feeder,feeder);
        },
        overridedBy : func(overridePump) {
            me.overridePump = overridePump;
        },
        openedBy : func(valve) {
            append(me.valves,valve);
        },
        oneValveOpened : func {
            if (size(me.valves) == 0) {
                return 1;
            }
            var valveStatus = 0;
            for(var i=0; i<size(me.valves); i+=1) {
                valveStatus = valveStatus or getprop(me.valves[i]);
            }
            return valveStatus;
        },
        opened : func() {
            var feederStatus = 0;
            for(var i=0; i<size(me.feeder); i+=1) {
                feederStatus = feederStatus or getprop(me.feeder[i]);
            }
            if (me.overridePump != nil and getprop(me.overridePump) == 1) {
                feederStatus = 0;
            }
            if (me.oneValveOpened() == 1 and feederStatus == 1) {
                return 1;
            }
            else return 0;
        },
        update : func() {
            if (me.opened()) {
                me.elt.show();
            }
            else {
                me.elt.hide();
            }
        }
};
var canvas_gear = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_gear, MfDPanel.new("gear",canvas_group,"Aircraft/777-VMD/Models/InstrumentsX/MFD-X8F/gear.svg",canvas_gear.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
        {
            me.open1();
            me.rect1();
            me.open2();
            me.rect2();
            me.open3();
            me.rect3();
            me.gear();
        },
            open1 : func() {
            var pipe = Pipe.new(me.group.getElementById("open1"));
            var apuValve = "gear/gear[1]/position-norm";
            var apuPump = "gear/gear[1]/position-norm";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            rect1 : func() {
            var pipe = Pipe.new(me.group.getElementById("rect1"));
            var apuValve = "gear/gear[1]/position-norm";
            var apuPump = "gear/gear[1]/position-norm";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            open2 : func() {
            var pipe = Pipe.new(me.group.getElementById("open2"));
            var apuValve = "gear/gear[1]/position-norm";
            var apuPump = "gear/gear[1]/position-norm";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            rect2 : func() {
            var pipe = Pipe.new(me.group.getElementById("rect2"));
            var apuValve = "gear/gear[1]/position-norm";
            var apuPump = "gear/gear[1]/position-norm";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            open3 : func() {
            var pipe = Pipe.new(me.group.getElementById("open3"));
            var apuValve = "gear/gear[1]/position-norm";
            var apuPump = "gear/gear[1]/position-norm";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            rect3 : func() {
            var pipe = Pipe.new(me.group.getElementById("rect3"));
            var apuValve = "gear/gear[1]/position-norm";
            var apuPump = "gear/gear[1]/position-norm";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            gear : func() {
            var pipe = Pipe.new(me.group.getElementById("gear"));
            var apuValve = "gear/gear[1]/position-norm";
            var apuPump = "gear/gear[1]/position-norm";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
        update: func()
        {
            me.updateAll();
        }
    };
