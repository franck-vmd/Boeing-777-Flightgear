
##############################################################################

load_nasal(narcissedir~"mockproputil.nas");
load_nasal(narcissedir~"mockprops.nas","props");
load_nasal("../mfd.nas","b777");
load_nasal(narcissedir~"nasmine.nas","nsm");

nsm.describe("a panel registry should",func() {
    nsm.it("update an element when added",func(){
        var elt = {
                updateCalled: 0,
                update : func(value) {
                    me.value = value;
                    me.updateCalled = 1;
                }
        };
        var prop = "controls/flight/speedbrakeangle";
        setprop(prop,54);
        var panelR = b777.PanelRegistry.new();
        panelR.add(prop,elt);
        panelR.updateAll();

        nsm.expect(elt.value).toBe(54);
    });
    nsm.it("be independant from another",func(){
        var elt = {
                updateCalled: 0,
                update : func(value) {
                    me.value = value;
                    me.updateCalled = 1;
                }
        };
        var prop = "controls/flight/speedbrakeangle";
        setprop(prop,54);
        var panelR = b777.PanelRegistry.new();
        panelR.add(prop,elt);
        var panelM = b777.PanelRegistry.new();

        nsm.expect(panelM.registry[prop]).toBeUnDefined();
    });
    nsm.it("not update an element on nil property",func(){
        var elt = {
                value : 0,
                updateCalled: 0,
                update : func(value) {
                    me.value = value;
                    me.updateCalled = 1;
                }
        };
        var prop = "controls/flight/unknown";
        var panelR = b777.PanelRegistry.new();
        panelR.add(prop,elt);
        panelR.updateAll();

        nsm.expect(elt.value).toBe(0);
    });
    nsm.it("update more than on element on same property",func(){
        var elt1 = {
                value: 0,
                update : func(value) {
                    me.value = value;
                }
        };
        var elt2 = {
                value: 0,
                update : func(value) {
                    me.value = value;
                }
        };
        var prop = "controls/flight/trim";
        var panelR = b777.PanelRegistry.new();
        panelR.add(prop,elt1);
        panelR.add(prop,elt2);
        setprop(prop,72);
        panelR.updateAll();

        nsm.expect(elt1.value).toBe(72);
    });
});

print("\n-------done-----------\n");