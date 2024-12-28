
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
    var canvas_doors = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_doors, MfDPanel.new("doors",canvas_group,"Aircraft/777-VMD/Models/InstrumentsX/MFD-X9/doors.svg",canvas_doors.update)] };
                m.context = m;
                m.initSvgIds(m.group);
                return m;
        },
        initSvgIds: func(group)
        {
            me.radar();
            me.d1l();
            me.d2l();
            me.d3l();
            me.d4l();
            me.d5l();
            me.d1r();
            me.d2r();
            me.d3r();
            me.d4r();
            me.d5r();
            me.fwd();
            me.aft();
            me.bulk();
            me.apug();
            me.apud();
            me.grdg();
            me.engl1();
            me.engl2();
            me.engl3();
            me.engl4();
            me.engr1();
            me.engr2();
            me.engr3();
            me.engr4();
            me.winglr();
        },
            radar : func() {
            var pipe = Pipe.new(me.group.getElementById("rad"));
            var apuValve = "sim/multiplay/generic/float[29]";
            var apuPump = "sim/multiplay/generic/float[29]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            d1l : func() {
            var pipe = Pipe.new(me.group.getElementById("d1lopened"));
            var apuValve = "sim/multiplay/generic/float[10]";
            var apuPump = "sim/multiplay/generic/float[10]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            d2l : func() {
            var pipe = Pipe.new(me.group.getElementById("d2lopened"));
            var apuValve = "sim/multiplay/generic/float[20]";
            var apuPump = "sim/multiplay/generic/float[20]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            d3l : func() {
            var pipe = Pipe.new(me.group.getElementById("d3lopened"));
            var apuValve = "sim/multiplay/generic/float[22]";
            var apuPump = "sim/multiplay/generic/float[22]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            d4l : func() {
            var pipe = Pipe.new(me.group.getElementById("d4lopened"));
            var apuValve = "sim/multiplay/generic/float[24]";
            var apuPump = "sim/multiplay/generic/float[24]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            d5l : func() {
            var pipe = Pipe.new(me.group.getElementById("d5lopened"));
            var apuValve = "sim/multiplay/generic/float[73]";
            var apuPump = "sim/multiplay/generic/float[73]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            d1r : func() {
            var pipe = Pipe.new(me.group.getElementById("d1ropened"));
            var apuValve = "sim/multiplay/generic/float[11]";
            var apuPump = "sim/multiplay/generic/float[11]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            d2r : func() {
            var pipe = Pipe.new(me.group.getElementById("d2ropened"));
            var apuValve = "sim/multiplay/generic/float[21]";
            var apuPump = "sim/multiplay/generic/float[21]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            d3r : func() {
            var pipe = Pipe.new(me.group.getElementById("d3ropened"));
            var apuValve = "sim/multiplay/generic/float[23]";
            var apuPump = "sim/multiplay/generic/float[23]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            d4r : func() {
            var pipe = Pipe.new(me.group.getElementById("d4ropened"));
            var apuValve = "sim/multiplay/generic/float[25]";
            var apuPump = "sim/multiplay/generic/float[25]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            d5r : func() {
            var pipe = Pipe.new(me.group.getElementById("d5ropened"));
            var apuValve = "sim/multiplay/generic/float[74]";
            var apuPump = "sim/multiplay/generic/float[74]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            fwd : func() {
            var pipe = Pipe.new(me.group.getElementById("fwdopened"));
            var apuValve = "sim/multiplay/generic/float[26]";
            var apuPump = "sim/multiplay/generic/float[26]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            aft : func() {
            var pipe = Pipe.new(me.group.getElementById("aftopened"));
            var apuValve = "sim/multiplay/generic/float[27]";
            var apuPump = "sim/multiplay/generic/float[27]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            bulk : func() {
            var pipe = Pipe.new(me.group.getElementById("bulkopened"));
            var apuValve = "sim/multiplay/generic/float[28]";
            var apuPump = "sim/multiplay/generic/float[28]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            apug : func() {
            var pipe = Pipe.new(me.group.getElementById("apugopened"));
            var apuValve = "sim/multiplay/generic/float[53]";
            var apuPump = "sim/multiplay/generic/float[53]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
           apud : func() {
            var pipe = Pipe.new(me.group.getElementById("apudopened"));
            var apuValve = "sim/multiplay/generic/float[54]";
            var apuPump = "sim/multiplay/generic/float[54]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            grdg : func() {
            var pipe = Pipe.new(me.group.getElementById("gropened"));
            var apuValve = "sim/multiplay/generic/float[55]";
            var apuPump = "sim/multiplay/generic/float[55]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            engl1 : func() {
            var pipe = Pipe.new(me.group.getElementById("engl1opened"));
            var apuValve = "sim/multiplay/generic/float[12]";
            var apuPump = "sim/multiplay/generic/float[12]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            engl2 : func() {
            var pipe = Pipe.new(me.group.getElementById("engl2opened"));
            var apuValve = "sim/multiplay/generic/float[13]";
            var apuPump = "sim/multiplay/generic/float[13]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            engl3 : func() {
            var pipe = Pipe.new(me.group.getElementById("engl3opened"));
            var apuValve = "sim/multiplay/generic/float[17]";
            var apuPump = "sim/multiplay/generic/float[17]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            engl4 : func() {
            var pipe = Pipe.new(me.group.getElementById("engl4opened"));
            var apuValve = "sim/multiplay/generic/float[16]";
            var apuPump = "sim/multiplay/generic/float[16]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            engr1 : func() {
            var pipe = Pipe.new(me.group.getElementById("engr1opened"));
            var apuValve = "sim/multiplay/generic/float[14]";
            var apuPump = "sim/multiplay/generic/float[14]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            engr2 : func() {
            var pipe = Pipe.new(me.group.getElementById("engr2opened"));
            var apuValve = "sim/multiplay/generic/float[15]";
            var apuPump = "sim/multiplay/generic/float[15]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            engr3 : func() {
            var pipe = Pipe.new(me.group.getElementById("engr3opened"));
            var apuValve = "sim/multiplay/generic/float[19]";
            var apuPump = "sim/multiplay/generic/float[19]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            engr4 : func() {
            var pipe = Pipe.new(me.group.getElementById("engr4opened"));
            var apuValve = "sim/multiplay/generic/float[18]";
            var apuPump = "sim/multiplay/generic/float[18]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
            winglr : func() {
            var pipe = Pipe.new(me.group.getElementById("winglropened"));
            var apuValve = "sim/multiplay/generic/float[70]";
            var apuPump = "sim/multiplay/generic/float[70]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
        update: func()
        {
            me.updateAll();
        }
    };
