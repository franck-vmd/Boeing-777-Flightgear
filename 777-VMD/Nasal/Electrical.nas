####    jet engine electrical system    ####
####    Syd Adams    ####
var l_main_ac = props.globals.initNode("systems/electrical/L-MAIN-AC",0,"DOUBLE");
var r_main_ac = props.globals.initNode("systems/electrical/R-MAIN-AC",0,"DOUBLE");
var l_xfr = props.globals.initNode("systems/electrical/L-XFR",0,"DOUBLE");
var r_xfr = props.globals.initNode("systems/electrical/R-XFR",0,"DOUBLE");
var l_dc = props.globals.initNode("systems/electrical/L-DC",0,"DOUBLE");
var r_dc = props.globals.initNode("systems/electrical/R-DC",0,"DOUBLE");
var hot_bat = props.globals.initNode("systems/electrical/HOT-BAT",0,"DOUBLE");
var bat = props.globals.initNode("systems/electrical/BAT",0,"DOUBLE");
var cpt_flt_inst = props.globals.initNode("systems/electrical/CPT-FLT-INST",0,"DOUBLE");
var fo_flt_inst = props.globals.initNode("systems/electrical/FO-FLT-INST",0,"DOUBLE");
var l_gcb = props.globals.initNode("systems/electrical/L-GCB",0,"BOOL");
var r_gcb = props.globals.initNode("systems/electrical/R-GCB",0,"BOOL");
var apb = props.globals.initNode("systems/electrical/APB",0,"BOOL");
var pri_epc = props.globals.initNode("systems/electrical/PRI-EPC",0,"BOOL");
var sec_epc = props.globals.initNode("systems/electrical/SEC-EPC",0,"BOOL");
var l_btb = props.globals.initNode("systems/electrical/L-BTB",0,"BOOL");
var r_btb = props.globals.initNode("systems/electrical/R-BTB",0,"BOOL");
var main_bat_rly = props.globals.initNode("systems/electrical/MAIN-BAT-RLY",0,"BOOL");
var dc_bus_tie_rly = props.globals.initNode("systems/electrical/DC_BUS_TIE_RLY",1,"BOOL");
var bat_cpt_isln_rely = props.globals.initNode("systems/electrical/BAT-CPT-ISLN-RLY",1,"BOOL");
var cpt_fo_bus_tie_rely = props.globals.initNode("systems/electrical/CPT-FO-BUS-TIE-RLY",0,"BOOL");
var primary_external  = props.globals.initNode("controls/electric/external-power",0,"BOOL");
var secondary_external  = props.globals.initNode("controls/electric/external-power[1]",0,"BOOL");
var ac_tie_bus = props.globals.initNode("systems/electrical/AC_TIE_BUS",0,"DOUBLE");

var vbus_count = 0;
var Lbus = props.globals.initNode("systems/electrical/left-bus",0,"DOUBLE");
var Rbus = props.globals.initNode("systems/electrical/right-bus",0,"DOUBLE");
var AVswitch=props.globals.initNode("systems/electrical/outputs/avionics",0,"BOOL");
var APUgen=props.globals.initNode("controls/electric/APU-generator",0,"BOOL");
var l_gen=props.globals.initNode("controls/electric/engine[0]/generator",0,"BOOL");
var r_gen=props.globals.initNode("controls/electric/engine[1]/generator",0,"BOOL");
var CDUswitch=props.globals.initNode("instrumentation/cdu/serviceable",0,"BOOL");
var BLOCswitch=props.globals.initNode("instrumentation/bloc/serviceable",0,"BOOL");
var DomeLtControl=props.globals.initNode("controls/lighting/dome-intencity",0,"DOUBLE");
var DomeLtIntencity=props.globals.initNode("systems/electrical/domelight-int",0,"DOUBLE");
var landinglights=props.globals.initNode("controls/lighting/landing-lights",0,"BOOL");

var lbus_input=[];
var lbus_output=[];
var lbus_load=[];

var rbus_input=[];
var rbus_output=[];
var rbus_load=[];

var lights_input=[];
var lights_output=[];
var lights_load=[];

var strobe_switch = props.globals.getNode("controls/lighting/strobe", 1);
aircraft.light.new("controls/lighting/strobe-state", [0.03, 1.3], strobe_switch);
var beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
aircraft.light.new("controls/lighting/beacon-state", [0.03, 1.28], beacon_switch);

var APU = {
    new : func(generator)
    {
        var m = { parents : [APU] };
        m.generator = generator;
        m.valid = 0;
        return m;
    },

    get_transition : func
    {
        var switched = 0;
        if(me.valid == 0)
        {
            if(me.generator.getValue() == 1)
            {
                apb.setValue(1);
                me.valid = 1;
                switched = 1;
            }
        }
        else
        {
            if(me.generator.getValue() == 0)
            {
                apb.setValue(0);
                me.valid = 0;
                switched = 1;
            }
        }
        return switched;
    }
};

var External = {
    new : func(switch)
    {
        var m = { parents : [External] };
        m.valid = 0;
        m.switch = switch;
        return m;
    },

    get_transition : func
    {
        var switched = 0;
        if(me.valid == 0)
        {
            if(me.switch.getValue() == 1)
            {
                me.valid = 1;
                switched = 1;
            }
        }
        else
        {
            if(me.switch.getValue() == 0)
            {
                me.valid = 0;
                switched = 1;
            }
        }
        return switched;
    }
};

var Battery = {
    new : func(vlt,amp,hr,chp,cha){
        var m = { parents : [Battery] };

        m.ideal_volts = vlt;
        m.ideal_amps = amp;
        m.amp_hours = hr;
        m.charge_percent = chp;
        m.charge_amps = cha;

        return m;
    },

    apply_load : func(load,dt) {
        if(me.switch.getValue()){
            var amphrs_used = load * dt / 3600.0;
            var percent_used = amphrs_used / me.amp_hours;
            me.charge_percent -= percent_used;
            if ( me.charge_percent < 0.0 ) {
                me.charge_percent = 0.0;
            } elsif ( me.charge_percent > 1.0 ) {
                me.charge_percent = 1.0;
            }
            var output = me.amp_hours * me.charge_percent;
            return output;
        } else
            return 0;
    },

    get_output_volts : func {
            var x = 1.0 - me.charge_percent;
            var tmp = -(3.0 * x - 1.0);
            var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
            var output =me.ideal_volts * factor;
            return output;
    },

    get_output_amps : func {
            var x = 1.0 - me.charge_percent;
            var tmp = -(3.0 * x - 1.0);
            var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
            var output =me.ideal_amps * factor;
            return output;
    }
};

# var alternator = Alternator.new(num,switch,rpm_source,rpm_threshold,volts,amps);
var Alternator = {
    new : func (num,switch,src,thr,vlt,amp){
        var m = { parents : [Alternator] };
        m.switch =  props.globals.getNode(switch,1);
        m.switch.setBoolValue(0);
        m.meter =  props.globals.getNode("systems/electrical/gen-load["~num~"]",1);
        m.gen_output =  props.globals.getNode("engines/engine["~num~"]/amp-v",1);
        m.meter.setDoubleValue(0);
        m.gen_output.setDoubleValue(0);
        m.rpm_source =  props.globals.getNode(src,1);
        m.rpm_threshold = thr;
        m.ideal_volts = vlt;
        m.ideal_amps = amp;
        m.valid = 0;
        return m;
    },

    apply_load : func(load) {
        var cur_volt = me.gen_output.getValue();
        var cur_amp  = me.meter.getValue();
        var gout = 0;
        if(cur_volt >1){
            var factor = 1/cur_volt;
            var gout = (load * factor);
            if(gout>1)gout=1;
        }
        me.meter.setValue(gout);
    },

    get_output_volts : func {
        var out = 0;
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold or 0;
            if ( factor > 1.0 )factor = 1.0;
            var out = (me.ideal_volts * factor);
        }
        me.gen_output.setValue(out);
        return out;
    },

    get_output_amps : func {
        var ampout = 0;
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold or 0;
            if ( factor > 1.0 ) {
                factor = 1.0;
            }
            ampout = me.ideal_amps * factor;
        }
        return ampout;
    },

    get_transition : func
    {
    var switched = 0;
        if(me.valid == 0)
        {
            if(me.get_output_volts() > 90)
            {
                me.valid = 1;
                switched = 1;
            }
        }
        else
        {
            if(me.get_output_volts() < 70)
            {
                me.valid = 0;
                switched = 1;
            }
        }
        return switched;
    }
};

var battery = Battery.new(24,30,34,1.0,7.0);
var lidg = Alternator.new(0,"controls/electric/engine[0]/gen-switch","/engines/engine[0]/rpm",17.0,115.0,60.0);
var ridg = Alternator.new(1,"controls/electric/engine[1]/gen-switch","/engines/engine[1]/rpm",17.0,115.0,60.0);
var external_primary = External.new(pri_epc);
var external_secondary = External.new(sec_epc);
var apu = APU.new(APUgen);

#####################################
setlistener("sim/signals/fdm-initialized", func {
    init_switches();
    settimer(update_electrical,5);
});

var init_switches = func{
    setprop("controls/lighting/instruments-norm",0.8);
    setprop("controls/lighting/engines-norm",0.8);
    props.globals.initNode("controls/electric/ammeter-switch",0,"BOOL");
    props.globals.getNode("systems/electrical/serviceable",0,"BOOL");
    props.globals.getNode("controls/electric/external-power",0,"BOOL");
    props.globals.getNode("controls/electric/external-power[1]",0,"BOOL");
    setprop("controls/lighting/instrument-lights-norm",0.8);
    setprop("controls/lighting/efis-norm",0.8);
    setprop("controls/lighting/panel-norm",0.8);
    setprop("controls/electric/battery-switch",0);
    setprop("controls/electric/engine[0]/gen-switch",1);
    setprop("controls/electric/engine[1]/gen-switch",1);
    setprop("controls/electric/engine[0]/bus-tie",1);
    setprop("controls/electric/engine[1]/bus-tie",1);
    setprop("controls/APU/apu-gen-switch",1);
    setprop("controls/electric/engine[0]/gen-bu-switch",1);
    setprop("controls/electric/engine[1]/gen-bu-switch",1);
    setprop("controls/lighting/nav-lights",0);
    setprop("controls/lighting/beacon",0);
    landinglights.setValue(0);
    append(lights_input,props.globals.initNode("controls/lighting/landing-light[0]",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light[0]",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/landing-light[1]",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light[1]",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/landing-light[2]",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light[2]",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/nav-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/nav-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/cabin-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/cabin-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/map-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/map-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/wing-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/wing-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/L-RwayLight",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/L-RwayLight",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/R-RwayLight",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/R-RwayLight",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/recog-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/recog-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/logo-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/logo-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/taxi-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/taxi-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/beacon-state/state",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/beacon",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/strobe-state/state",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/strobe",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/fire/inputs/self-test",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/fire",0,"DOUBLE"));
    append(lights_load,1);

    append(rbus_input,props.globals.initNode("controls/electric/wiper-switch",0,"BOOL"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/wiper",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/engine[0]/fuel-pump",0,"BOOL"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/fuel-pump[0]",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/engine[1]/fuel-pump",0,"BOOL"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/fuel-pump[1]",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/StartIgnition-knob[0]",0,"DOUBLE"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/starter",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/StartIgnition-knob[1]",0,"DOUBLE"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/starter[1]",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/engine[0]/cutoff-switch",0,"BOOL"));
    append(rbus_output,props.globals.initNode("engines/engine[0]/valve[0]/opened",0,"BOOL"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/engine[0]/cutoff-switch",0,"BOOL"));
    append(rbus_output,props.globals.initNode("engines/engine[0]/valve[1]/opened",0,"BOOL"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/engine[1]/cutoff-switch",0,"BOOL"));
    append(rbus_output,props.globals.initNode("engines/engine[1]/valve[0]/opened",0,"BOOL"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/engine[1]/cutoff-switch",0,"BOOL"));
    append(rbus_output,props.globals.initNode("engines/engine[1]/valve[1]/opened",0,"BOOL"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/fuel/xfeedaft-switch",0,"BOOL"));
    append(rbus_output,props.globals.initNode("controls/fuel/xfeedaft-valve/opened",0,"BOOL"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/fuel/xfeedfwd-switch",0,"BOOL"));
    append(rbus_output,props.globals.initNode("controls/fuel/xfeedfwd-valve/opened",0,"BOOL"));
    append(rbus_load,1);
    append(rbus_input,AVswitch);
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/KNS80",0,"DOUBLE"));
    append(rbus_load,1);


    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/efis",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/adf",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/dme",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/gps",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/DG",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/transponder",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/mk-viii",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/turn-coordinator",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/comm",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/comm[1]",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/comm[2]",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/nav",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/nav[1]",0,"DOUBLE"));
    append(lbus_load,1);
}

update_virtual_bus = func( dt ) {
    var PWR = getprop("systems/electrical/serviceable");
    var xtie = 0;
    var load = 0.0;
    var power_source = nil;
    if(lidg.get_transition())
    {
        l_gcb.setValue(lidg.valid);
        l_gen.setValue(lidg.valid);
        if(lidg.valid)
        {
            apb.setValue(0);
            pri_epc.setValue(0);
            sec_epc.setValue(0);
            l_btb.setValue(1);
            r_btb.setValue(1);
        }
    }
    elsif(ridg.get_transition())
    {
        r_gcb.setValue(ridg.valid);
        r_gen.setValue(ridg.valid);
        if(ridg.valid)
        {
            apb.setValue(0);
            pri_epc.setValue(0);
            sec_epc.setValue(0);
            l_btb.setValue(1);
            r_btb.setValue(1);
        }
    }
    elsif(external_primary.get_transition())
    {
        if(external_primary.valid)
        {
            r_gcb.setValue(0);
            if(external_secondary.valid)
            {
                r_btb.setValue(0);
            }
            else
            {
                l_gcb.setValue(0);
                apb.setValue(0);
                l_btb.setValue(1);
                r_btb.setValue(1);
            }
        }
    }
    elsif(external_secondary.get_transition())
    {
        if(external_secondary.valid)
        {
            apb.setValue(0);
            l_gcb.setValue(0);
            l_btb.setValue(1);
            if(external_primary.valid)
            {
                r_btb.setValue(0);
            }
            else
            {
                r_gcb.setValue(0)
            }
        }
    }
    elsif(apu.get_transition())
    {
        if(apu.valid)
        {
            sec_epc.setValue(0);
            pri_epc.setValue(0);
            if(external_primary.valid)
            {
                r_btb.setValue(0);
            }
            else
            {
                r_gcb.setValue(0);
            }
        }
    }

    if(lidg.valid)
    {
        l_main_ac.setValue(lidg.get_output_volts());
    }
    elsif(apu.valid)
    {
        l_main_ac.setValue(115);
    }
    elsif(external_secondary.valid)
    {
        l_main_ac.setValue(115);
    }
    elsif(external_primary.valid)
    {
        l_main_ac.setValue(115);
    }
    elsif(ridg.valid)
    {
        l_main_ac.setValue(ridg.get_output_volts());
    }
    else
    {
        l_main_ac.setValue(0);
    }
    l_xfr.setValue(l_main_ac.getValue());

    if(ridg.valid)
    {
        r_main_ac.setValue(ridg.get_output_volts());
    }
    elsif(external_primary.valid)
    {
        r_main_ac.setValue(115);
    }
    elsif(external_secondary.valid)
    {
        r_main_ac.setValue(115);
    }
    elsif(apu.valid)
    {
        r_main_ac.setValue(115);
    }
    elsif(lidg.valid)
    {
        r_main_ac.setValue(lidg.get_output_volts());
    }
    else
    {
        r_main_ac.setValue(0);
    }
    r_xfr.setValue(r_main_ac.getValue());

    if(lidg.valid or apu.valid or external_secondary.valid or external_primary.valid or ridg.valid)
    {
        ac_tie_bus.setValue(115);
    }
    else
    {
        ac_tie_bus.setValue(0);
    }

    if(vbus_count==0)
    {
        hot_bat.setValue(battery.get_output_volts());
        main_bat_rly.setValue(getprop("controls/electric/APU-generator"));
        bat.setValue(hot_bat.getValue() * main_bat_rly.getValue());
        if(l_xfr.getValue() > 80)
        {
            l_dc.setValue(l_xfr.getValue() * 28 /115);
            cpt_flt_inst.setValue(l_xfr.getValue() * 28 /115);
            lidg.apply_load(load);
        }
        else
        {
            l_dc.setValue(0);
            cpt_flt_inst.setValue(bat.getValue() * bat_cpt_isln_rely.getValue());
#           battery.apply_load(load);
        }
        load += lh_bus(cpt_flt_inst.getValue());
    }
    else
    {
        if(r_xfr.getValue() > 80)
        {
            r_dc.setValue(r_xfr.getValue() * 28 /115);
            fo_flt_inst.setValue(r_xfr.getValue() * 28 /115);
            ridg.apply_load(load);
        }
        else
        {
            r_dc.setValue(0);
            fo_flt_inst.setValue(cpt_flt_inst.getValue() * cpt_fo_bus_tie_rely.getValue());
#           battery.apply_load(load);
        }
        load += rh_bus(fo_flt_inst.getValue());
    }
    vbus_count = 1-vbus_count;
    if(l_dc.getValue() > 5 and r_dc.getValue() > 5) xtie=1;
    dc_bus_tie_rly.setValue(xtie);
    if(l_dc.getValue() > 5 or r_dc.getValue() > 5) load += lighting(28);

    if(r_xfr.getValue() > 80)
    {
        if(getprop("controls/lighting/cockpit"))
        {
            DomeLtIntencity.setValue(1.0);
        }
        else
        {
            DomeLtIntencity.setValue(DomeLtControl.getValue());
        }
    }
    elsif(cpt_flt_inst.getValue() > 24)
    {
        DomeLtIntencity.setValue(0.5);
    }
    else
    {
        DomeLtIntencity.setValue(0);
    }

    return load;
}

rh_bus = func(bv) {
    var bus_volts = bv;
    var load = 0.0;
    var srvc = 0.0;

    for(var i=0; i<size(rbus_input); i+=1) {
        var srvc = rbus_input[i].getValue();
        load += rbus_load[i] * srvc;
        rbus_output[i].setValue(bus_volts * srvc);
    }
    return load;
}

lh_bus = func(bv) {
    var load = 0.0;
    var srvc = 0.0;

    for(var i=0; i<size(lbus_input); i+=1) {
        var srvc = lbus_input[i].getValue();
        load += lbus_load[i] * srvc;
        lbus_output[i].setValue(bv * srvc);
    }

    var isEnabled = (bv>20);
    if (AVswitch.getBoolValue()!=isEnabled)
        AVswitch.setBoolValue(isEnabled);
    if (CDUswitch.getBoolValue()!=isEnabled)
        CDUswitch.setBoolValue(isEnabled);
    setprop("systems/electrical/outputs/flaps",bv);
    return load;
}

lighting = func(bv) {
    var load = 0.0;
    var srvc = 0.0;
    var ac=bv*4.29;

    for(var i=0; i<size(lights_input); i+=1) {
        var srvc = lights_input[i].getValue();
        load += lights_load[i] * srvc;
        lights_output[i].setValue(bv * srvc);
    }

    return load;
}

update_electrical = func {
    var scnd = getprop("sim/time/delta-sec");
    update_virtual_bus( scnd );
    settimer(update_electrical, 0.01);
}
