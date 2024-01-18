####    jet engine air system    ####
####    Hyde Yamakawa    ####

var AIR = {
	new : func(prop1){
		var m = { parents : [AIR]};
		m.equip_cool_sw = props.globals.initNode("controls/air/equip-cool-switch", 1, "BOOL");
		m.air = props.globals.initNode(prop1);
		return m;
	},
	update : func{
		if((cpt_flt_inst.getValue() < 24)
				or me.equip_cool_sw.getValue())
		{
			setprop("controls/air/equip-cool", 1);
		}
		else
		{
			setprop("controls/air/equip-cool", 0);
		}
		if((cpt_flt_inst.getValue() < 24)
				or (getprop("engines/engine/run") and getprop("controls/air/lpack-switch")))
		{
			setprop("controls/air/lpack", 1);
		}
		else
		{
			setprop("controls/air/lpack", 0);
		}
		if((cpt_flt_inst.getValue() < 24)
				or (getprop("engines/engine[1]/run") and getprop("controls/air/rpack-switch")))
		{
			setprop("controls/air/rpack", 1);
		}
		else
		{
			setprop("controls/air/rpack", 0);
		}
		if((cpt_flt_inst.getValue() < 24)
				or getprop("controls/air/ltrim-switch"))
		{
			setprop("controls/air/ltrim", 1);
		}
		else
		{
			setprop("controls/air/ltrim", 0);
		}
		if((cpt_flt_inst.getValue() < 24)
				or getprop("controls/air/rtrim-switch"))
		{
			setprop("controls/air/rtrim", 1);
		}
		else
		{
			setprop("controls/air/rtrim", 0);
		}
		if((cpt_flt_inst.getValue() < 24)
				or getprop("controls/air/ofvfwd-switch"))
		{
			setprop("controls/air/ofvfwd", 1);
		}
		else
		{
			setprop("controls/air/ofvfwd", 0);
		}
		if((cpt_flt_inst.getValue() < 24)
				or getprop("controls/air/ofvaft-switch"))
		{
			setprop("controls/air/ofvaft", 1);
		}
		else
		{
			setprop("controls/air/ofvaft", 0);
		}
		if((cpt_flt_inst.getValue() < 24)
				or getprop("controls/air/islationl-switch"))
		{
			setprop("controls/air/islationl", 1);
		}
		else
		{
			setprop("controls/air/islationl", 0);
		}
		if((cpt_flt_inst.getValue() < 24)
				or getprop("controls/air/islationc-switch"))
		{
			setprop("controls/air/islationc", 1);
		}
		else
		{
			setprop("controls/air/islationc", 0);
		}
		if((cpt_flt_inst.getValue() < 24)
				or getprop("controls/air/islationr-switch"))
		{
			setprop("controls/air/islationr", 1);
		}
		else
		{
			setprop("controls/air/islationr", 0);
		}
		if((cpt_flt_inst.getValue() < 24)
				or getprop("controls/air/bleedapu-switch"))
		{
			setprop("controls/air/bleedapu", 1);
		}
		else
		{
			setprop("controls/air/bleedapu", 0);
		}
		if((cpt_flt_inst.getValue() < 24)
				or (getprop("engines/engine/run") and getprop("controls/air/bleedengl-switch")))
		{
			setprop("controls/air/bleedengl", 1);
		}
		else
		{
			setprop("controls/air/bleedengl", 0);
		}
		if((cpt_flt_inst.getValue() < 24)
				or (getprop("engines/engine[1]/run") and getprop("controls/air/bleedengr-switch")))
		{
			setprop("controls/air/bleedengr", 1);
		}
		else
		{
			setprop("controls/air/bleedengr", 0);
		}
	}
};

var Air = AIR.new("systems/air");

var update_air = func {
	Air.update();
    settimer(update_air, 0.2);
}

#####################################
	setlistener("sim/signals/fdm-initialized", func {
	Air.equip_cool_sw.setValue(1);
	setprop("controls/air/gasper-switch", 1);
	setprop("controls/air/recircup-switch", 1);
	setprop("controls/air/recirclo-switch", 1);
	setprop("controls/air/fltdeck_temp", 0.5);
	setprop("controls/air/cabin_temp", 0.5);
	setprop("controls/air/lpack-switch", 1);
	setprop("controls/air/rpack-switch", 1);
	setprop("controls/air/ltrim-switch", 1);
	setprop("controls/air/rtrim-switch", 1);
	setprop("controls/air/ofvfwd-switch", 1);
	setprop("controls/air/ofvaft-switch", 1);
	setprop("controls/air/islationl-switch", 1);
	setprop("controls/air/islationc-switch", 1);
	setprop("controls/air/islationr-switch", 1);
	setprop("controls/air/bleedapu-switch", 1);
	setprop("controls/air/bleedengl-switch", 1);
	setprop("controls/air/bleedengr-switch", 1);
	setprop("controls/anti-ice/wing-antiice-knob", 1);
	setprop("controls/anti-ice/engin/antiice-knob", 1);
	setprop("controls/anti-ice/engin[1]/antiice-knob", 1);
    settimer(update_air,5);
});

