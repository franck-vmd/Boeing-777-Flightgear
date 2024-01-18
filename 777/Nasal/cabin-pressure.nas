# A Cabin Pressure System for the 747-8, by John Williams (tikibar) March 2015

# Tasks:
# 1. Create and initialize properties
# 2. Calculate cabin altitude
# 3. Calculate differential
# 4. Handle automatic mode switching
# 5. Handle auto mode variables
# 6. Operate relief valve
# 7. Handle manual modes

# System vars
var cabin_alt = props.globals.initNode("systems/pressurization/cabin-altitude-ft",0,"DOUBLE");
var p_diff = props.globals.initNode("systems/pressurization/deltaP-ft",0,"DOUBLE");
var p_diff_psi = props.globals.initNode("systems/pressurization/deltaP-psi",0,"DOUBLE");
var cabin_rate = props.globals.initNode("systems/pressurization/cabin-rate-fpm",0,"DOUBLE");
var mode = props.globals.initNode("systems/pressurization/mode",0,"INT");
var relief = props.globals.initNode("systems/pressurization/relief-valve",0,"BOOL");
var cabin_target = props.globals.initNode("systems/pressurization/target-cabin-alt-ft",0,"DOUBLE");
var landing_alt = props.globals.initNode("systems/pressurization/landing-alt-ft",2000,"DOUBLE");


# Internal vars
var time = getprop("sim/time/elapsed-sec");
var time_last = 0.0; 
var dt = 0.0;
var rate = 0.0;
var rate_last = 0.0;
var last_alt = 0.0;
var targ_rate = 300;

var pressure_alt = props.globals.getNode("instrumentation/altimeter/pressure-alt-ft",1);
var valve_state = props.globals.initNode("systems/pressurization/internal/valve-state",0,"DOUBLE");
var valve_max = props.globals.initNode("systems/pressurization/internal/valve-max",0,"DOUBLE");
var valve_offset = props.globals.initNode("systems/pressurization/internal/valve-offset",0,"DOUBLE");
var manual_mode = props.globals.initNode("systems/pressurization/internal/manual",0,"BOOL");
var inflow = props.globals.initNode("systems/pressurization/internal/inflow-rate",0,"DOUBLE");
var atten_m = props.globals.initNode("systems/pressurization/internal/atten-m",0,"DOUBLE");
var atten_b = props.globals.initNode("systems/pressurization/internal/atten-b",0,"DOUBLE");

var max_cabin_rate = props.globals.initNode("systems/pressurization/max-cabin-rate-fpm",500,"DOUBLE");
var max_out = props.globals.initNode("systems/pressurization/internal/max-outflow-rate",3000,"DOUBLE");

# Controller vars
var valve0 = props.globals.initNode("controls/pressurization/outflow-valve-pos[0]",0,"DOUBLE");
var valve1 = props.globals.initNode("controls/pressurization/outflow-valve-pos[1]",0,"DOUBLE");
var manual0 = props.globals.initNode("controls/pressurization/valve-manual[0]",0,"BOOL");
var manual1 = props.globals.initNode("controls/pressurization/valve-manual[1]",0,"BOOL");
var landing_alt_man = props.globals.initNode("controls/pressurization/landing-alt-manual",0,"BOOL");
var land_alt_set = props.globals.initNode("controls/pressurization/landing-alt-ft",2000,"DOUBLE");
var valve_switch = props.globals.initNode("controls/pressurization/valve-switch",0,"INT");

# Updates made at frame rate.  Mainly cabin alt and pressure differential.
var update_alt = func {
	time = getprop("sim/time/elapsed-sec");
	dt = (time - time_last) / 60;
	time_last = time;

	rate = cabin_rate.getValue();
	var cabin = cabin_alt.getValue() + (((rate + rate_last) / 2) * dt);
	var diff = pressure_alt.getValue() - cabin;
	if (pressure_alt.getValue() != 0)
	    p_diff_psi.setValue(-0.4912 * ((getprop("environment/pressure-inhg") - 29.92) / pressure_alt.getValue()) * (diff));
	rate_last = rate;

	cabin_alt.setValue(cabin);
	p_diff.setValue(diff);

	# Attenuation Factor
	var b_val = 0;
	if (abs(diff) <= 1750) {
	    atten_m.setValue(437.5);
	}
	if (abs(diff) > 1750 and abs(diff) <= 3500) {
	    atten_m.setValue(1750);
	    b_val = 0.3;
	}
	if (abs(diff) > 3500 and abs(diff) <= 7000) {
	    atten_m.setValue(3500);
	    b_val = 0.4;
	}
	if (abs(diff) > 7000 and abs(diff) <= 14000) {
	    atten_m.setValue(7000);
	    b_val = 0.5;
	}
	if (abs(diff) > 14000 and abs(diff) <= 28000) {
	    atten_m.setValue(14000);
	    b_val = 0.6;
	}
	if (abs(diff) > 28000 and abs(diff) <= 38000) {
	    atten_m.setValue(28000);
	    b_val = 0.52;
	}
	if (abs(diff) > 38000) {
	    atten_m.setValue(38000);
	    b_val = 0.14;
	}
	if (diff < 0) b_val = -1 * b_val;
	atten_b.setValue(b_val);

	# Calculate attenuation factor
#	var att_fact = ((0.1 * (pressure_alt.getValue() - cabin)) / atten_m.getValue()) + atten_b;

	# Calculate target cabin rate
	var VS = getprop("/velocities/vertical-speed-fps") * 60;
	if (mode.getValue() == 1) {
	    if (getprop("autopilot/settings/altitude-setting-ft") > 11000) {
		var alt_set = getprop("autopilot/settings/altitude-setting-ft");
	    } else {
		var alt_set = 39000;
	    }
	    if (alt_set - pressure_alt.getValue() > 2000) {
		if (VS != 0) {
		    var climbtime = (alt_set - pressure_alt.getValue()) / VS;
		    if (climbtime == 0) climbtime = 0.25;
		    targ_rate = (cabin_target.getValue() - cabin) / climbtime;
		}
	    } else {
		targ_rate = 300;
	    }
	}
	if (mode.getValue() == 2) {
	    if (pressure_alt.getValue() > landing_alt.getValue() + 2000) {
		if (VS != 0) {
		    var climbtime = (pressure_alt.getValue() - cabin_target.getValue()) / VS;
		    if (climbtime == 0) climbtime = 0.25;
		    targ_rate = (cabin - cabin_target.getValue()) / climbtime;
		}
	    } else {
		targ_rate = 480;
	    }
	}
	targ_rate = abs(targ_rate);
	if (targ_rate > 520) targ_rate = 520;
	max_cabin_rate.setValue(targ_rate);

	# Valve States
	var valve = valve_state.getValue();
	if (!manual0.getBoolValue() and !manual1.getBoolValue()) {
	    valve0.setValue(valve);
	    valve1.setValue(valve);
	    if (mode.getValue() == 0) valve_state.setValue(1);
	} elsif (!manual0.getBoolValue()) {
	    valve0.setValue(2 * valve);
	    if (mode.getValue() == 0) valve_state.setValue(0.5);
	} elsif (!manual1.getBoolValue()) {
	    valve1.setValue(2 * valve);
	    if (mode.getValue() == 0) valve_state.setValue(0.5);
	}	    
	var voffset = 0;
	if (manual0.getBoolValue()) voffset = voffset + (0.5 * valve0.getValue());
	if (manual1.getBoolValue()) voffset = voffset + (0.5 * valve1.getValue());
	if (mode.getValue() == 0) voffset = voffset + 2.25;

	# Relief Valve
	if (diff > 35550 or diff < -550) {
	    relief.setBoolValue(1);
	    voffset = voffset + 0.6;
	} else {
	    relief.setBoolValue(0);
	}

	valve_offset.setValue(voffset);

	# Final Descent Mode
	if (mode.getValue() == 2 and getprop("position/altitude-agl-ft") < 2000) {
	    cabin_target.setValue(pressure_alt.getValue() - getprop("position/altitude-agl-ft") - 100);
	}
}

# Automatic Mode selectors
#   Mode 0 and 1
setlistener("gear/on-ground", func (wow) {
	if (wow.getBoolValue()) {
	    mode.setValue(0);
	} else {
	    mode.setValue(1);
	}
},0,0);
#   Mode 2
var count = 0;
var descend_detector = func {
	if (mode.getValue() == 1) {
	    if (last_alt - pressure_alt.getValue() > 150) {
		count += 1;
	    } elsif (count > 0) count -= 1;
	    if (count == 4) {
		mode.setValue(2);
		count = 0;
	    }
	}
	if (mode.getValue() == 2) {
	    if (pressure_alt.getValue() - last_alt > 150) {
		count += 1;
	    } elsif (count > 0) count -= 1;
	    if (count == 6) {
		mode.setValue(1);
		count = 0;
	    }
	}
	last_alt = pressure_alt.getValue();
}

# Automatic Mode updater
var update_mode = func {
	# On the ground
	if (mode.getValue() == 0) {
	    if (!manual0.getBoolValue()) valve0.setValue(1);
	    if (!manual1.getBoolValue()) valve1.setValue(1);
	    
	} elsif (!landing_alt_man.getBoolValue()) {
	    if (getprop("autopilot/route-manager/active") and getprop("autopilot/route-manager/destination/airport") != "") {
		var landalt = getprop("autopilot/route-manager/destination/field-elevation-ft");
		if (landalt > 8000) landalt = 8000;
		landing_alt.setValue(landalt);
	    } else {
		landing_alt.setValue(2000);
	    }
	}
	# Climb and Cruise
	if (mode.getValue() == 1) {
	    var target = 7750;
	    if (landing_alt.getValue() > 4000) target = 8000;
	    var alt_setting = getprop("autopilot/settings/altitude-setting-ft");
	    if (alt_setting > 42750) target = alt_setting - 35000;
	    if (p_diff.getValue() > 35000) target = pressure_alt.getValue() - 35000;
	    cabin_target.setValue(target);
	}
	# Descent
	if (mode.getValue() == 2) {
	    if (getprop("position/altitude-agl-ft") > 2000)
		cabin_target.setValue(landing_alt.getValue() - 100);
	}
	# Manual
	if (manual0.getBoolValue() or manual1.getBoolValue()) {
	    update_manual();
	} else {
	    valve_max.setValue(1);
	}
	# Inflow
	var infl = 500 * ((getprop("systems/pneumatic/pack[0]") == 1) + (getprop("systems/pneumatic/pack[1]") == 1) + (getprop("systems/pneumatic/pack[2]") == 1)) * (1 + (0.25 * getprop("controls/pneumatic/pack-high-flow")));
	inflow.setValue(infl);
}

# Manual Mode updater
var update_manual = func {
	valve_max.setValue(0.5);
	if (cabin_alt.getValue() > 11000) {
	    if (manual0.getBoolValue()) valve0.setValue(0);
	    if (manual1.getBoolValue()) valve1.setValue(0);
	}
	if (manual0.getBoolValue() and manual1.getBoolValue()) {
	    manual_mode.setBoolValue(1);
	    valve_state.setValue(0);
	} else {
	    manual_mode.setBoolValue(0);
	}
}

# Manual landing alt setting
setlistener("controls/pressurization/landing-alt-ft", func {
	if (landing_alt_man.getBoolValue())
	    landing_alt.setValue(land_alt_set.getValue());
},0,0);
setlistener("controls/pressurization/landing-alt-manual", func {
	if (landing_alt_man.getBoolValue())
	    landing_alt.setValue(land_alt_set.getValue());
},0,0);

# Manual Valve adjustment
var valve_adjust = func (dir) {
	var adjd = 0;
	if (manual0.getBoolValue()) {
	    adjd = valve0.getValue() + (0.01 * dir);
	    if (adjd > 1) adjd = 1;
	    if (adjd < 0) adjd = 0;
	    valve0.setValue(adjd);
	}
	if (manual1.getBoolValue()) {
	    adjd = valve1.getValue() + (0.01 * dir);
	    if (adjd > 1) adjd = 1;
	    if (adjd < 0) adjd = 0;
	    valve1.setValue(adjd);
	}
}

# Run
var fast_update = func {
	update_alt();
	settimer(fast_update, 0);
}
var slow_update = func {
	update_mode();
	settimer(slow_update, 1);
}
var climb_desc = func {
	descend_detector();
	settimer(climb_desc, 30);
}
setlistener("/sim/signals/fdm-initialized", func {
	settimer(func {
	    max_out.setValue(30000);
	    if (getprop("gear/on-ground")) {
		mode.setValue(0);
	    } else {
		mode.setValue(1);
	    }
	    if (pressure_alt.getValue() < 7750) {
		cabin_alt.setValue(pressure_alt.getValue());
	    } else {
		cabin_alt.setValue(7750);
	    }
	    climb_desc();
	    fast_update();
	    slow_update();
	},2);
},0,0);

