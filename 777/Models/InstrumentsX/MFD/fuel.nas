#
# Fuel Synoptic panel
# jylebleu
#
var Label = {
        new : func(elt,format,ratio) {
            var m = { parents: [Label]};
            m.svgelt = elt;
            m.format = format;
            m.ratio = ratio;
            return m;
        },
        update : func(value) {
            me.svgelt.setText(sprintf(me.format,value*me.ratio));
        }
};
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
var Valve = {
        new : func(symbClosed,symbOpened) {
            var m = { parents: [Valve]};
            m.symbClosed = symbClosed;
            m.symbOpened = symbOpened;
            return m;
        },
        update : func(value) {
            if(!value) {
                me.symbClosed.show();
                me.symbOpened.hide();
            }
            else {
                me.symbClosed.hide();
                me.symbOpened.show();
            }
        }
};

var Pump = {
        stopColor:"rgba(255,255,255,1)",
        startColor:"rgba(0,255,0,1)",
        new : func(elt) {
            var m = { parents: [Pump]};
            m.elt = elt;
            return m;
        },
        started : func() {
            me.elt.setStroke(me.startColor);
        },
        stopped : func() {
            me.elt.setStroke(me.stopColor);
        },
        update : func(value) {
            if(value) {
                me.started();
            }
            else {
                me.stopped();
            }
        }
};
    var FuelPanel = {
        new : func(canvas_group)
        {
            var m = { parents: [FuelPanel, MfDPanel.new("fuel",canvas_group,"Aircraft/777/Models/Instruments/MFD/fuel.svg",FuelPanel.update)] };
            m.context = m;
            m.initSvgIds(m.group);
            return m;
        },
        initSvgIds: func(group)
        {
            var lbl = Label.new(group.getElementById("totalfuel"),"%3.1f",0.001);
            me.registry.add("consumables/fuel/total-fuel-lbs",lbl);
            lbl = Label.new(group.getElementById("tank0level"),"%3.1f",0.001);
            me.registry.add("consumables/fuel/tank[0]/level-lbs",lbl);
            lbl = Label.new(group.getElementById("tank1level"),"%3.1f",0.001);
            me.registry.add("consumables/fuel/tank[1]/level-lbs",lbl);
            lbl = Label.new(group.getElementById("tank2level"),"%3.1f",0.001);
            me.registry.add("consumables/fuel/tank[2]/level-lbs",lbl);
            lbl = Label.new(group.getElementById("fueltemp"),"%+2.0f",1);
            me.registry.add("environment/temperature-degc",lbl);
            me.initPumps();
            me.initValves();
            me.buildCircuit(0,0,"left");
            me.buildCircuit(1,2,"right");
            me.buildApuCircuit();
        },
        initPumps : func() {
            var pumps = {"leftfwdpump":[0,0],"leftaftpump":[0,1],
                    "leftcenterpump":[1,0],"rightcenterpump":[1,1],
                    "rightfwdpump":[2,0],"rightaftpump":[2,1]};
            foreach(var pumpId;keys(pumps)) {
                var (tankNb,pumpNb) = pumps[pumpId];
                var pump = Pump.new(me.group.getElementById(pumpId));
                me.registry.add("controls/fuel/tank["~tankNb~"]/boost-pump["~pumpNb~"]",pump);
            }
        },
        initValves : func() {
            var valves = {"eng0valve0":"engines/engine[0]/valve[0]/opened",
                            "eng0valve1":"engines/engine[0]/valve[1]/opened",
                            "eng1valve0":"engines/engine[1]/valve[0]/opened",
                            "eng1valve1":"engines/engine[1]/valve[1]/opened",
                            "aftxfeed":"controls/fuel/xfeedaft-valve/opened",
                            "fwdxfeed":"controls/fuel/xfeedfwd-valve/opened"};
            foreach(var rootId;keys(valves)) {
                var valve = Valve.new(me.group.getElementById(rootId~"closed"),me.group.getElementById(rootId~"opened"));
                me.registry.add(valves[rootId],valve);
            }
        },
        buildApuCircuit : func() {
            var pipe = Pipe.new(me.group.getElementById("apupipe"));
            var apuValve = "controls/APU/valve/opened";
            var apuPump = "controls/fuel/tank[0]/boost-pump[0]";
            pipe.openedBy(apuValve);
            pipe.feededBy(apuPump);
            me.registry.add(apuValve,pipe);
        },
        buildCircuit : func(engineNb,mainTank,side) {
            var fwdMainPump = "controls/fuel/tank["~mainTank~"]/boost-pump[0]";
            var aftMainPump = "controls/fuel/tank["~mainTank~"]/boost-pump[1]";
            var centerPump = "controls/fuel/tank[1]/boost-pump["~engineNb~"]";
            var valve = "engines/engine["~engineNb~"]/valve[0]/opened";
            var apuValve = "controls/APU/valve/opened";

            var addPipe = func(pipe) {
                pipe.openedBy(valve);
                me.registry.add(valve,pipe);
            }
            var pipe = Pipe.new(me.group.getElementById(side~"Pipe"));
            pipe.feededBy(centerPump);
            addPipe(pipe);
            pipe = Pipe.new(me.group.getElementById(side~"AftPipe"));
            pipe.feededBy(aftMainPump);
            pipe.feededBy(centerPump);
            addPipe(pipe);
            pipe = Pipe.new(me.group.getElementById(side~"FwdPipe"));
            pipe.feededBy(aftMainPump);
            pipe.feededBy(centerPump);
            addPipe(pipe);
            #eng0Pipe0 eng0Pipe1 eng1Pipe1 eng1Pipe0
            pipe = Pipe.new(me.group.getElementById("eng"~engineNb~"Pipe0"));
            pipe.feededBy(fwdMainPump);
            pipe.feededBy(aftMainPump);
            pipe.feededBy(centerPump);
            if (side == "left") {
                pipe.openedBy(apuValve);
            }
            addPipe(pipe);
            pipe = Pipe.new(me.group.getElementById("eng"~engineNb~"Pipe1"));
            pipe.feededBy(fwdMainPump);
            pipe.feededBy(aftMainPump);
            pipe.feededBy(centerPump);
            addPipe(pipe);
            #leftfwdpumppipe leftaftpumppipe
            pipe = Pipe.new(me.group.getElementById(side~"fwdpumppipe"));
            pipe.feededBy(fwdMainPump);
            pipe.overridedBy(centerPump);
            if (side == "left") {
                pipe.openedBy(apuValve);
            }
            addPipe(pipe);
            pipe = Pipe.new(me.group.getElementById(side~"aftpumppipe"));
            pipe.feededBy(aftMainPump);
            pipe.overridedBy(centerPump);
            addPipe(pipe);
        },
        update: func()
        {
            me.updateAll();
        }
    };