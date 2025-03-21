
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
var canvas_chkl1 = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_chkl1, MfDPanel.new("chkl1",canvas_group,"Aircraft/777-VMD/Models/InstrumentsX/MFD-X9/chkl1.svg",canvas_gear.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
        {
            me.opened1v();
            me.opened2v();
            me.opened3v();
            me.opened4v();
            me.opened5v();
            me.opened6v();
            me.opened7v();
            me.opened8v();
            me.opened9v();
            me.opened10v();
            me.opened11v();
        },
            opened1v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened1v"));
            var apuValve = "controls/switches/DOOR_Switch";
            var apuPump = "controls/switches/DOOR_Switch";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened2v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened2v"));
            var apuValve = "controls/cabin/SeatBelt-status";
            var apuPump = "controls/cabin/SeatBelt-status";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened3v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened3v"));
            var apuValve = "instrumentation/afds/inputs/alt-knob";
            var apuPump = "instrumentation/afds/inputs/alt-knob";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened4v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened4v"));
            var apuValve = "sim/multiplay/generic/float[92]";
            var apuPump = "sim/multiplay/generic/float[92]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened5v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened5v"));
            var apuValve = "autopilot/route-manager/active";
            var apuPump = "autopilot/route-manager/active";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened6v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened6v"));
            var apuValve = "sim/multiplay/generic/float[90]";
            var apuPump = "sim/multiplay/generic/float[90]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened7v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened7v"));
            var apuValve = "sim/multiplay/generic/float[91]";
            var apuPump = "sim/multiplay/generic/float[91]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened8v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened8v"));
            var apuValve = "controls/lighting/taxi-lights";
            var apuPump = "controls/lighting/taxi-lights";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened9v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened9v"));
            var apuValve = "controls/lighting/beacon";
            var apuPump = "controls/lighting/beacon";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened10v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened10v"));
            var apuValve = "controls/lighting/beacon";
            var apuPump = "controls/lighting/beacon";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened11v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened11v"));
            var apuValve = "controls/lighting/beacon";
            var apuPump = "controls/lighting/beacon";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
        update: func()
        {
            me.updateAll();
        }
    };
