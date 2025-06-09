
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
var canvas_elec = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_elec, MfDPanel.new("elec",canvas_group,"Aircraft/777-VMD/Models/InstrumentsX/MFD-X8F/elec.svg",canvas_elec.update)] };
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
            me.opened12v();
            me.opened13v();
            me.opened14v();
            me.opened15v();
            me.opened17v();
            me.opened18v();
            me.opened19v();
            me.opened20v();
            me.opened21v();
            me.opened22v();
            me.opened23v();
            me.opened24v();
            me.opened25v();
            me.opened26v();
        },
            opened1v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened1v"));
            var apuValve = "controls/electric/external-power[1]";
            var apuPump = "controls/electric/external-power[1]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened2v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened2v"));
            var apuValve = "systems/electrical/SEC-EPC";
            var apuPump = "systems/electrical/SEC-EPC";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened3v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened3v"));
            var apuValve = "controls/APU/off-start-run";
            var apuPump = "controls/APU/off-start-run";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened4v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened4v"));
            var apuValve = "controls/electric/APU-generator";
            var apuPump = "controls/electric/APU-generator";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },

            opened5v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened5v"));
            var apuValve = "controls/electric/external-power[0]";
            var apuPump = "controls/electric/external-power[0]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened6v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened6v"));
            var apuValve = "controls/electric/engine[0]/bus-tie";
            var apuPump = "controls/electric/engine[0]/bus-tie";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened7v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened7v"));
            var apuValve = "controls/electric/engine[1]/bus-tie";
            var apuPump = "controls/electric/engine[1]/bus-tie";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened8v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened8v"));
            var apuValve = "systems/electrical/PRI-EPC";
            var apuPump = "systems/electrical/PRI-EPC";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened9v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened9v"));
            var apuValve = "systems/electrical/PRI-EPC";
            var apuPump = "systems/electrical/PRI-EPC";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened10v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened10v"));
            var apuValve = "controls/electric/engine[1]/gen-switch";
            var apuPump = "controls/electric/engine[1]/gen-switch";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened11v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened11v"));
            var apuValve = "systems/electrical/PRI-EPC";
            var apuPump = "systems/electrical/PRI-EPC";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened12v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened12v"));
            var apuValve = "engines/engine[1]/run";
            var apuPump = "engines/engine[1]/run";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened13v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened13v"));
            var apuValve = "controls/electric/engine[0]/bus-tie";
            var apuPump = "controls/electric/engine[0]/bus-tie";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened14v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened14v"));
            var apuValve = "controls/electric/engine[1]/bus-tie";
            var apuPump = "controls/electric/engine[1]/bus-tie";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened15v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened15v"));
            var apuValve = "controls/electric/engine[0]/gen-switch";
            var apuPump = "controls/electric/engine[0]/gen-switch";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened17v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened17v"));
            var apuValve = "engines/engine[0]/run";
            var apuPump = "engines/engine[0]/run";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened18v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened18v"));
            var apuValve = "controls/electric/engine[0]/bus-tie";
            var apuPump = "controls/electric/engine[0]/bus-tie";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened19v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened19v"));
            var apuValve = "controls/electric/engine[1]/bus-tie";
            var apuPump = "controls/electric/engine[1]/bus-tie";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened20v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened20v"));
            var apuValve = "systems/electrical/PRI-EPC";
            var apuPump = "systems/electrical/PRI-EPC";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened21v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened21v"));
            var apuValve = "controls/electric/engine[0]/bus-tie";
            var apuPump = "controls/electric/engine[0]/bus-tie";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened22v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened22v"));
            var apuValve = "controls/electric/engine[0]/gen-bu-switch";
            var apuPump = "controls/electric/engine[0]/gen-bu-switch";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened23v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened23v"));
            var apuValve = "controls/electric/engine[1]/bus-tie";
            var apuPump = "controls/electric/engine[1]/bus-tie";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened24v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened24v"));
            var apuValve = "controls/electric/engine[1]/gen-bu-switch";
            var apuPump = "controls/electric/engine[1]/gen-bu-switch";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened25v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened25v"));
            var apuValve = "controls/electric/engine[0]/bus-tie";
            var apuPump = "controls/electric/engine[0]/bus-tie";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            opened26v : func() {
            var pipe = Pipe.new(me.group.getElementById("opened26v"));
            var apuValve = "controls/electric/engine[1]/bus-tie";
            var apuPump = "controls/electric/engine[1]/bus-tie";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
        update: func()
        {
            me.updateAll();
        }
    };
