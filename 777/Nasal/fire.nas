#######################
# FIRE nasal 
# 2024  Franck.VMD
#######################
var FIRE =
{
    new : func(prop60)
    {
        var m = { parents : [FIRE]};
        m.self_tested     = props.globals.initNode("controls/fire/inputs/self-tested",0,"BOOL");
        m.fire            = props.globals.getNode(prop60);
        m.self_test       = m.fire.getNode("inputs/self-test");

        m.test_seq = 0;

        settimer(fire_input_feeder,0);

        return m;
    },

    clicked_selftest : func
    {
        if (!me.self_test.getBoolValue())
        {
            me.self_test.setBoolValue(1);
            settimer(func { Fire.release_selftest_button() },14);
        }
        else
        {
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

    FIREtester : func()
    {
        var FIREtest = getprop("controls/fire/inputs/self-test");
        var FIREinop = getprop("controls/fire/outputs/fire-inop");
        var TADinop = getprop("controls/fire/outputs/tad-inop");
        if(FIREtest and !(me.self_tested.getBoolValue()))
        {
            if(0 == me.test_seq)
            {
                if(FIREinop and TADinop)
                {
                    me.test_seq = 1;
                }
            }
            elsif(1 == me.test_seq)
            {
                if(!(FIREinop and TADinop))
                {
                    me.test_seq = 2;
                }
            }
            elsif(2 == me.test_seq)
            {
                if(FIREinop and TADinop)
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
var fire_test_bit = func(value,bitValue)
{
    if (bitValue>1) value=int(value/bitValue);
    return (value!=int(value/2)*2);
}

##############################################
# timer callbacks
##############################################
var fire_input_feeder = func
{
    Fire.FIREtester();
    settimer(fire_input_feeder,0.3);
}

##############################################
# main
##############################################
var Fire = FIRE.new("controls/fire");

