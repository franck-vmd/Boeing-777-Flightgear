
##############################################################################

load_nasal(narcissedir~"mockproputil.nas");
load_nasal(narcissedir~"mockprops.nas","props");
load_nasal(narcissedir~"mocksvg.nas","canvas");
load_nasal("../mfd.nas","b777");
load_nasal("../fuel.nas","b777");
load_nasal(narcissedir~"nasmine.nas","nsm");

var canvas_group = {
        createChild : func(type,name){ 
            var child = {
                    hide : func(){},
                    getElementById : func(id){}
            };
            return child;
        },
        
};

nsm.describe("a fuel panel",func() {
    nsm.it("should be able to be created",func(){
        var fuel_panel = b777.FuelPanel.new(canvas_group);
        
        nsm.expect(1).toBe(1);
    });
    nsm.it("can init pumps",func() {
        var fuel_panel = b777.FuelPanel.new(canvas_group);
        fuel_panel.initPumps(fuel_panel.group);
        
        nsm.expect(fuel_panel.registry.registry["controls/fuel/tank[0]/boost-pump[0]"]).toBeDefined();
    });
    nsm.it("can init valves",func() {
        var fuel_panel = b777.FuelPanel.new(canvas_group);
        fuel_panel.initValves();
        
        nsm.expect(fuel_panel.registry.registry["controls/fuel/xfeedaft-valve/opened"]).toBeDefined();
    });
});

nsm.describe("a label",func() {
    var elt = {
            text : "",
            setText: func(txt) {
                me.text = txt;
            }
    };
    nsm.it("should be able to be updated",func(){
        var lbl = b777.Label.new(elt,"%3.1f",1);
        lbl.update(974.5678);
        nsm.expect(elt.text).toBe(974.6);
    });
    nsm.it("should apply ratio",func(){
        var lbl = b777.Label.new(elt,"%3.1f",0.1);
        lbl.update(6789.4);
        nsm.expect(elt.text).toBe(678.9);
    });
});
nsm.describe("a pump",func() {
    var elt = {
            stroke : "",
            fill : "",
            setStroke: func(color) {
                me.stroke = color;
            },
            setFill:func(color) {
            }
    };
    nsm.it("changed color to start on start",func(){
        var pump = b777.Pump.new(elt);
        pump.update(1);
        nsm.expect(elt.stroke).toBe(pump.startColor);
    });
    nsm.it("changed color to stop on stop",func(){
        var pump = b777.Pump.new(elt);
        pump.update(0);
        nsm.expect(elt.stroke).toBe(pump.stopColor);
    });
});

nsm.describe("a valve",func() {
    nsm.it("can be closed",func(){
        var symbClosed = {
                showCalled : 0,
                show : func(){
                    me.showCalled = 1;
                }
        };
        var symbOpened = {
                hideCalled : 0,
                hide : func() {
                    me.hideCalled = 1;
                }
        };
        var valve = b777.Valve.new(symbClosed,symbOpened);
        valve.update(0);
        nsm.expect(symbClosed.showCalled).toBe(1);
        nsm.expect(symbOpened.hideCalled).toBe(1);
    });
    nsm.it("can be opened",func(){
        var symbOpened = {
                showCalled : 0,
                show : func(){
                    me.showCalled = 1;
                }
        };
        var symbClosed = {
                hideCalled : 0,
                hide : func() {
                    me.hideCalled = 1;
                }
        };
        var valve = b777.Valve.new(symbClosed,symbOpened);
        valve.update(1);
        nsm.expect(symbOpened.showCalled).toBe(1);
        nsm.expect(symbClosed.hideCalled).toBe(1);
    });
});
nsm.describe("a pipe",func() {
    var elt = {
            showCalled : 0,
            hideCalled : 0,
            show: func() {
                me.showCalled = 1;
            },
            hide: func() {
                me.hideCalled = 1;
            },
            reset: func() {
                me.showCalled = 0;
                me.hideCalled = 0;
            }
    };

    nsm.it("feeded with one pump started",func(){
        elt.reset();
        var mockPump = "controls/fuel/tank[0]/boost-pump[0]";
        var pipe = b777.Pipe.new(elt);
        pipe.feededBy(mockPump);
        setprop(mockPump,1);

        pipe.update();

        nsm.expect(elt.showCalled).toBe(1);

    });
    nsm.it("not feeded when pump stop",func(){
        elt.reset();
        var mockPump = "controls/fuel/tank[0]/boost-pump[0]";
        var pipe = b777.Pipe.new(elt);
        pipe.feededBy(mockPump);
        setprop(mockPump,0);

        pipe.update();

        nsm.expect(elt.hideCalled).toBe(1);

    });
    nsm.it("not feeded when override pump starts",func(){
        elt.reset();
        var mainPump = "controls/fuel/tank[0]/boost-pump[0]";
        var overridePump = "controls/fuel/tank[1]/boost-pump[0]";
        var pipe = b777.Pipe.new(elt);
        pipe.feededBy(mainPump);
        pipe.overridedBy(overridePump);
        setprop(mainPump,1);
        setprop(overridePump,1);

        pipe.update();

        nsm.expect(elt.hideCalled).toBe(1);

    });
    nsm.it("not feeded when valve is closed",func(){
        elt.reset();
        var pump = "controls/fuel/tank[0]/boost-pump[0]";
        var valve = "engines/engine[0]/valve[0]/opened";
        var pipe = b777.Pipe.new(elt);
        pipe.feededBy(pump);
        pipe.openedBy(valve);
        setprop(pump,1);
        setprop(valve,0);

        pipe.update();

        nsm.expect(elt.hideCalled).toBe(1);

    });
    nsm.it("can be feeded by many pumps, still opened when one is stopped",func(){
        elt.reset();
        var pump0 = "controls/fuel/tank[0]/boost-pump[0]";
        var pump1 = "controls/fuel/tank[0]/boost-pump[1]";
        var pipe = b777.Pipe.new(elt);
        pipe.feededBy(pump0);
        pipe.feededBy(pump1);
        setprop(pump0,1);
        setprop(pump1,0);

        pipe.update();

        nsm.expect(elt.showCalled).toBe(1);

    });
    nsm.it("can be controlled by more than one valve",func(){
       elt.reset();
       var pump = "controls/fuel/tank[0]/boost-pump[0]";
       var valve1 = "engines/engine[0]/valve[0]/opened";
       var valve2 = "engines/apu/valve/opened";
       var pipe = b777.Pipe.new(elt);
       pipe.feededBy(pump);
       pipe.openedBy(valve1);
       pipe.openedBy(valve2);
       setprop(pump,1);
       setprop(valve1,1);
       setprop(valve2,0);

       pipe.update();

       nsm.expect(elt.showCalled).toBe(1);
       
    });
});


print("\n-------done-----------\n");