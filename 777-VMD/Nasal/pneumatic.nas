# Pneumatics

var supply_l = 0.0;
var supply_r = 0.0;

var pneumatic = {
    new : func {
        m = { parents : [pneumatic]};
	m.controls = props.globals.getNode("controls/pneumatic",1);
	m.system = props.globals.getNode("systems/pneumatic",1);
	# Switches
	m.apu_valve = m.controls.initNode("APU-bleed-valve",0,"BOOL");
	m.eng_bleed = [ m.controls.initNode("engine-bleed[0]",0,"BOOL"),
			m.controls.initNode("engine-bleed[1]",0,"BOOL"),
			m.controls.initNode("engine-bleed[2]",0,"BOOL"),
			m.controls.initNode("engine-bleed[3]",0,"BOOL") ];
	m.isln_l = m.controls.initNode("isolation-valve[0]",1,"BOOL");
	m.isln_r = m.controls.initNode("isolation-valve[1]",1,"BOOL");

	# Supplies
	m.APU = m.system.initNode("APU-bleed",0,"BOOL");
	m.eng = [ props.globals.getNode("engines/engine[0]/n1-ind",1),
		  props.globals.getNode("engines/engine[1]/n1-ind",1),
		  props.globals.getNode("engines/engine[2]/n1-ind",1),
		  props.globals.getNode("engines/engine[3]/n1-ind",1) ];
	m.service = m.system.initNode("air-service",0,"BOOL");

	# Packs
	m.pack_knob = [ m.controls.initNode("pack-control[0]",0,"BOOL"),
			m.controls.initNode("pack-control[1]",0,"BOOL"),
			m.controls.initNode("pack-control[2]",0,"BOOL") ];
	m.pack_status = [ m.system.initNode("pack[0]",0,"INT"),
			  m.system.initNode("pack[1]",0,"INT"),
			  m.system.initNode("pack[2]",0,"INT") ];
	m.packs_hi = m.controls.initNode("pack-high-flow",0,"BOOL");
	m.pack_fault = m.system.initNode("pack-sys-fault",0,"BOOL");

	# Demands
	m.starter = [ props.globals.getNode("controls/engines/engine[0]/starter",1),
		      props.globals.getNode("controls/engines/engine[1]/starter",1),
		      props.globals.getNode("controls/engines/engine[2]/starter",1),
		      props.globals.getNode("controls/engines/engine[3]/starter",1) ];
	m.APU_gen = [ props.globals.getNode("systems/electrical/apu-generator[0]",1),
		      props.globals.getNode("systems/electrical/apu-generator[1]",1) ];
	m.deice = props.globals.getNode("controls/anti-ice/wing-heat",1);
	m.deice.setBoolValue(0);

	# Output
	m.bleed_air = [ m.system.initNode("bleed-air[0]",0,"BOOL"),
			m.system.initNode("bleed-air[1]",0,"BOOL") ];
	m.pressure = [ m.system.initNode("pressure-norm[0]",0,"DOUBLE"),
		       m.system.initNode("pressure-norm[1]",0,"DOUBLE") ];

    return m;
    },

    update_pres : func {
	# Supply
	supply_l = 0.0;
	supply_r = 0.0;

	#   Left
	if (me.isln_l.getBoolValue()) {
	    if (me.service.getBoolValue())
		supply_l = supply_l + 0.89;
	    if (me.APU.getBoolValue() and !me.apu_valve.getBoolValue())
		supply_l = supply_l + 1.02;
	}
	if (me.eng[0].getValue() > 50 and me.eng_bleed[0].getBoolValue()) {
		supply_l = supply_l + 1.08;
	    if (me.isln_l.getBoolValue() and me.isln_r.getBoolValue())
		supply_r = supply_r + 1.08;
	}
	if (me.eng[1].getValue() > 50 and me.eng_bleed[1].getBoolValue()) {
		supply_l = supply_l + 1.08;
	    if (me.isln_l.getBoolValue() and me.isln_r.getBoolValue())
		supply_r = supply_r + 1.08;
	}

	#   Right
	if (me.isln_r.getBoolValue()) {
	    if (me.service.getBoolValue())
		supply_r = supply_r + 0.89;
	    if (me.APU.getBoolValue() and !me.apu_valve.getBoolValue())
		supply_r = supply_r + 1.02;
	}
	if (me.eng[2].getValue() > 50 and me.eng_bleed[2].getBoolValue()) {
		supply_r = supply_r + 1.08;
	    if (me.isln_l.getBoolValue() and me.isln_r.getBoolValue())
		supply_l = supply_l + 1.08;
	}
	if (me.eng[3].getValue() > 50 and me.eng_bleed[3].getBoolValue()) {
		supply_r = supply_r + 1.08;
	    if (me.isln_r.getBoolValue() and me.isln_l.getBoolValue())
		supply_l = supply_l + 1.08;
	}

	var air_l = 45 * supply_l;
	var air_r = 45 * supply_r;

	supply_l = 0.0;
	supply_r = 0.0;

	# Demand

	 # Starters
	var dem = 0;
	for (var i=0; i<4; i+=1) {
	    if (me.starter[i].getBoolValue()) {
		if (me.eng[i].getValue() < 26) {
		    dem = 0.33;
		} else {
		    dem = 0.12;
		}
		if (i < 2) {
		    supply_l = supply_l - dem;
		    if (me.isln_r.getBoolValue() and me.isln_l.getBoolValue())
			supply_r = supply_r - dem;
		} else {
		    supply_r = supply_r - dem;
		    if (me.isln_r.getBoolValue() and me.isln_l.getBoolValue())
			supply_l = supply_l - dem;
		}
	    }
	}

	 # Pneumatically driven hydraulic pumps
	if (getprop("controls/hydraulic/demand-pump[0]") > 0) {
	    supply_l = supply_l - 0.20;
	    if (me.isln_r.getBoolValue() and me.isln_l.getBoolValue())
		supply_r = supply_r - 0.20;
	}
	if (getprop("controls/hydraulic/demand-pump[3]") > 0) {
	    supply_r = supply_r - 0.20;
	    if (me.isln_r.getBoolValue() and me.isln_l.getBoolValue())
		supply_l = supply_l - 0.20;
	}

	 # APU generators
	if (me.APU_gen[0].getValue() == 2 and !me.apu_valve.getBoolValue()) {
	    if (me.isln_l.getBoolValue())
		supply_l = supply_l - 0.05;
	    if (me.isln_r.getBoolValue())
		supply_r = supply_r - 0.05;
	}
	if (me.APU_gen[1].getValue() == 2 and !me.apu_valve.getBoolValue()) {
	    if (me.isln_r.getBoolValue())
		supply_r = supply_r - 0.05;
	    if (me.isln_l.getBoolValue())
		supply_l = supply_l - 0.05;
	}

	 # Packs
	var hiflo = 1.0;
	if (me.packs_hi.getBoolValue()) hiflo = 1.2;
	if (me.pack_status[0].getValue() == 1) {
	    supply_l = supply_l - (0.30 * hiflo);
	    if (me.isln_r.getBoolValue() and me.isln_l.getBoolValue())
		supply_r = supply_r - (0.30 * hiflo);
	}
	if (me.pack_status[1].getValue() == 1) {
	    if (me.isln_l.getBoolValue())
		supply_l = supply_l - (0.30 * hiflo);
	    if (me.isln_r.getBoolValue())
		supply_r = supply_r - (0.30 * hiflo);
	}
	if (me.pack_status[2].getValue() == 1) {
	    supply_r = supply_r - (0.30 * hiflo);
	    if (me.isln_r.getBoolValue() and me.isln_l.getBoolValue())
		supply_l = supply_l - (0.30 * hiflo);
	}

	 # Wing Anti-Ice
	if (me.deice.getBoolValue()) {
		supply_l = supply_l - 0.18;
		supply_r = supply_r - 0.18;
	}

	supply_l = 8 * supply_l;
	supply_r = 8 * supply_r;


	supply_l = supply_l + air_l;
	supply_r = supply_r + air_r;

	if (supply_l > 45) supply_l = 45;
	if (supply_r > 45) supply_r = 45;
	if (supply_l < 0) supply_l = 0;
	if (supply_r < 0) supply_r = 0;

	if (supply_l > 36.8) {
		me.bleed_air[0].setBoolValue(1);
	} else {
		me.bleed_air[0].setBoolValue(0);
	}
	if (supply_r > 36.8) {
		me.bleed_air[1].setBoolValue(1);
	} else {
		me.bleed_air[1].setBoolValue(0);
	}
	me.pressure[0].setValue(supply_l);
	me.pressure[1].setValue(supply_r);
    },

    update : func {
	# Packs
	var packs_off = 0;
	var status = 0;
	for (var i=0; i<3; i+=1) {
	    if (me.pack_knob[i].getBoolValue()) {
		if (!me.pack_fault.getBoolValue()) {
		    status = 1;
		    if (i == 1) {
			if (getprop("systems/pressurization/relief-valve") or getprop("controls/pressurization/outflow-valve-pos[0]") == 0 or getprop("controls/pressurization/outflow-valve-pos[1]") == 0)
			    status = 0;
			if (getprop("gear/on-ground") and !getprop("controls/gear/brake-parking"))
			    status = 0;
		    }
#		    me.pack_status[i].setValue(1);
		}
	    } else {
#		me.pack_status[i].setValue(0);
		status = 0;
		packs_off += 1;
	    }
	    me.pack_status[i].setValue(status);
	}
	if (packs_off == 3)
		me.pack_fault.setBoolValue(0);

	# No ground air if parking brake off or aircraft in the air.
	if (!getprop("controls/gear/brake-parking") or !getprop("gear/gear[1]/wow"))
	    me.service.setBoolValue(0);

	# APU active
	if (getprop("engines/apu/running")) {
	    me.APU.setBoolValue(1);
	} else {
	    me.APU.setBoolValue(0);
	}

	# Pressure checks
	me.update_pres();
	var cutout_l = 0;
	var cutout_r = 0;
	var middle = 0;
	if ((me.bleed_air[0].getBoolValue() and me.isln_l.getBoolValue()) or (me.bleed_air[1].getBoolValue() and me.isln_r.getBoolValue())) {
	    middle = 1;
	} elsif (!me.isln_l.getBoolValue() and !me.isln_r.getBoolValue()) {
	    if ((me.APU.getBoolValue() and !me.apu_valve.getBoolValue()) or me.service.getBoolValue())
		middle = 1;
	} else {
	    middle = 0;
	}
	if (!me.bleed_air[0].getBoolValue())
		cutout_l = 1;
	if (!me.bleed_air[1].getBoolValue())
		cutout_r = 1;

	# Low pressure cutouts
	if (getprop("instrumentation/airspeed-indicator/indicated-speed-kt") < 180) {
	    if (cutout_l == 1 and me.starter[0].getBoolValue()) {
		me.starter[0].setBoolValue(0);
		cutout_l = 0;
		cutout_r = 0;
	    }
	    if (cutout_l == 1 and me.starter[1].getBoolValue()) {
		me.starter[1].setBoolValue(0);
		cutout_l = 0;
		cutout_r = 0;
	    }
	    if (cutout_r == 1 and me.starter[2].getBoolValue()) {
		me.starter[2].setBoolValue(0);
		cutout_l = 0;
		cutout_r = 0;
	    }
	    if (cutout_r == 1 and me.starter[3].getBoolValue()) {
		me.starter[3].setBoolValue(0);
		cutout_l = 0;
		cutout_r = 0;
	    }
	}
	if (cutout_r == 1 and me.pack_status[2].getValue() == 1) {
		me.pack_status[2].setValue(-1);
		cutout_l = 0;
		cutout_r = 0;
	}
	if (middle == 0 and me.pack_status[1].getBoolValue()) {
		me.pack_status[1].setValue(0);
		me.pack_fault.setBoolValue(1);
	}
	if (cutout_l == 1 and me.pack_status[0].getValue() == 1) {
		me.pack_status[0].setValue(-1);
		cutout_l = 0;
		cutout_r = 0;
	}
	if (cutout_l == 1 and cutout_r == 1)
		me.deice.setBoolValue(0);
    },

    turn_starter : func (eng) {
	var side = 0;
	if (eng > 1) side = 1;
	if (getprop("controls/engines/engine["~eng~"]/cutoff") and (me.bleed_air[side].getBoolValue() or getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") > 180)) {
	    settimer(func me.starter[eng].setBoolValue(0),120);
	} else {
	    settimer(func me.starter[eng].setBoolValue(0),0.5);
	}
    },
	
};
B748air = pneumatic.new();
var air_loop = func {
	B748air.update();
	settimer(air_loop,0.5);
}
setlistener("/sim/signals/fdm-initialized", func (init) {
	if (init.getBoolValue()) {
		settimer( func {
		   air_loop(); 
		},2);
	}
},0,0);

# Starter Listeners
setlistener("controls/engines/engine[0]/starter", func(start) {
	if (start.getBoolValue()) B748air.turn_starter(0);
},0,0);
setlistener("controls/engines/engine[1]/starter", func(start) {
	if (start.getBoolValue()) B748air.turn_starter(1);
},0,0);
setlistener("controls/engines/engine[2]/starter", func(start) {
	if (start.getBoolValue()) B748air.turn_starter(2);
},0,0);
setlistener("controls/engines/engine[3]/starter", func(start) {
	if (start.getBoolValue()) B748air.turn_starter(3);
},0,0);

