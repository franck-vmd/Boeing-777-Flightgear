##########################################################################
# GPWS nasal wrapper
# 2010, Thorsten Brehm
#
# For more documentation see http://wiki.flightgear.org/index.php/GPWS
##########################################################################

##########################################################################
# Configuration settings
##########################################################################
# Minimum landing flap position
# 777 requires at least flap position 25 (=83%) for landing
var gpws_min_landing_flaps = 0.83;

##############################################
# GPWS specific class
# ie: var Gpws = GPWS.new("instrumentation/mk-viii");
##############################################
var GPWS =
{
    new : func(prop1)
    {
        var m = { parents : [GPWS]};
        m.self_tested     = props.globals.initNode("instrumentation/mk-viii/inputs/discretes/self-tested",0,"BOOL");
        m.gpws            = props.globals.getNode(prop1);
        m.self_test       = m.gpws.getNode("inputs/discretes/self-test");
        m.flap_override   = m.gpws.getNode("inputs/discretes/momentary-flap-override");
        m.gs_inhibit      = m.gpws.getNode("inputs/discretes/glideslope-inhibit");
        m.gpws_inhibit    = m.gpws.getNode("inputs/discretes/gpws-inhibit");
        m.terrain_inhibit = m.gpws.getNode("inputs/discretes/ta-tcf-inhibit");
        m.landing_gear    = m.gpws.getNode("inputs/discretes/landing-gear");
        m.landing_flaps   = m.gpws.getNode("inputs/discretes/landing-flaps");

        # mk-viii doesn't provide gear-override input. Emulate it...
        m.gear_override = m.gpws.initNode("inputs/discretes/gear-override",0,"BOOL");

        m.last_gear_state = 0;
        m.test_seq = 0;

        # add listener to gear
        setlistener("controls/gear/gear-down",         func { Gpws.update_gear_state() } );

        # GPWS provides two TCWs (Time Critical Warnings) to the PFD:
        # "PULL UP" and "WINDSHEAR" alerts (windshears not supported here...)
        m.tcw_out = m.gpws.initNode("outputs/warning","","STRING");
        m.tcw_out.setValue("");
        m.logic_discretes = m.gpws.getNode("outputs/arinc429/egpwc-logic-discretes");
        settimer(gpws_input_feeder,0);

        return m;
    },

#### self-test buttons ####
    clicked_selftest : func
    {
        if (!me.self_test.getBoolValue())
        {
            # simulate a long button press (>> 5 seconds)
            me.self_test.setBoolValue(1);
            settimer(func { Gpws.release_selftest_button() },9);
        }
        else
        {
            # clicked again => release button early...
            me.release_selftest_button();
        }
    },
    press_selftest_button : func
    {
        me.self_test.setBoolValue(1);
    },
    release_selftest_button : func
    {
        me.self_test.setBoolValue(0);
    },    

#### flap-override button ####
    clicked_flap_override : func
    {
        if (!me.flap_override.getBoolValue())
        {
            # simulate a short button press
            me.flap_override.setBoolValue(1);
            settimer(func {Gpws.release_button_flap_override() },0.5);
        }
    },
    release_button_flap_override : func
    {
        me.flap_override.setBoolValue(0);
    },

#### gear-override button ####
    clicked_gear_override : func
    {
        # toggle
        me.gear_override.setBoolValue(!me.gear_override.getBoolValue());
        me.update_gear_state();
    },

#### glide-slope button ####
    clicked_gs_override : func
    {
        # toggle g/s inhibit.
        me.gs_inhibit.setBoolValue(!me.gs_inhibit.getBoolValue());
    },
    disable_gs_override : func
    {
        me.gs_inhibit.setBoolValue(0);
    },

#### gpws inhibit button ####
    clicked_gpws_inhibit : func
    {
        # toggle
        me.gpws_inhibit.setBoolValue(!me.gpws_inhibit.getBoolValue());
    },

#### terrain inhibit button ####
    clicked_terrain_inhibit : func
    {
        # toggle
        me.terrain_inhibit.setBoolValue(!me.terrain_inhibit.getBoolValue());
    },

#### decode alerts to time critical warnings ####
    tcw_feeder : func
    {
        var tcwmsg="";
        var alerts = me.logic_discretes.getValue();
        if (gpws_test_bit(alerts,0x100000)) # bit 20="MODE1_PULL_UP"
            tcwmsg="PULL UP";
        me.tcw_out.setValue(tcwmsg);
    },

#### custom input feeders ####
    update_gear_state : func()
    {
        # Simulate gear override button using a custom landing gear feeder.
        # Default mk-viii gear feeder is disabled in <plane>-set.xml
        var gear_state = getprop("controls/gear/gear-down");

        me.landing_gear.setBoolValue(gear_state or me.gear_override.getBoolValue());

        if ((me.last_gear_state)and(!gear_state))
        {
            # g/s override is cancelled when retracting landing gear...
            me.disable_gs_override();
        }
        me.last_gear_state = gear_state;
    },
    update_flap_state : func()
    {
        # Feeder to configure custom "minimum landing flap position".
        # Default mk-viii flap feeder is disabled in <plane>-set.xml
        var flap_position = getprop("controls/flight/flaps");

        me.landing_flaps.setBoolValue(flap_position < gpws_min_landing_flaps);
    },
    update_height : func()
    {
        var radio_alt = getprop("position/gear-agl-ft");
        if(radio_alt != nil)
        {
            # "glide-slope warning inhibited" is disabled below 50 feet
            if ((radio_alt < 50.0)or(radio_alt > 1000.0))
                me.disable_gs_override();
        }
    },
    GPWStester : func()
    {
        var GPWStest = getprop("/instrumentation/mk-viii/inputs/discretes/self-test");
        var GPWSinop = getprop("/instrumentation/mk-viii/outputs/discretes/gpws-inop");
        var TADinop = getprop("/instrumentation/mk-viii/outputs/discretes/tad-inop");
        if(GPWStest and !(me.self_tested.getBoolValue()))
        {
            if(0 == me.test_seq)
            {
                if(GPWSinop and TADinop)
                {
                    me.test_seq = 1;
                }
            }
            elsif(1 == me.test_seq)
            {
                if(!(GPWSinop and TADinop))
                {
                    me.test_seq = 2;
                }
            }
            elsif(2 == me.test_seq)
            {
                if(GPWSinop and TADinop)
                {
                    me.self_tested.setBoolValue(1);
                }
            }
        }
        else
        {
            me.test_seq = 0;
        }
    },
};

##############################################
# helper
##############################################
var gpws_test_bit = func(value,bitValue)
{
    if (bitValue>1) value=int(value/bitValue);
    # test if LSB set
    return (value!=int(value/2)*2);
}

##############################################
# timer callbacks
##############################################
var gpws_input_feeder = func
{
    Gpws.tcw_feeder();
    Gpws.update_flap_state();
    Gpws.update_height();
    Gpws.GPWStester();
    settimer(gpws_input_feeder,0.3);
}

##############################################
# main
##############################################
var Gpws = GPWS.new("instrumentation/mk-viii");

