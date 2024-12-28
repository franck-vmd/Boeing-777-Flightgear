
# Radio Management Unit #
# AM = 520 -1720 khz  adf#
# HF = 3000 - 30000 khz#
# VHF = 108 - 156.690 Mhz# 

var comm = 118.000 - 136.000 mhz
var nav = 108.000 - 118.000 mhz



# ie: var efis = RMU.new(unit number);
var RMU = {
    new : func(unit){
        var m = { parents : [RMU]};
        m.mfd_mode_list=["APP","VOR","MAP","PLAN"];

        m.radio = props.globals.initNode("instrumentation/rmu["~unit~"]");
        m.active_freq = m.radio.initNode("frequencyinstrumentation/rmu["~unit~"]");

        m.kpaL = setlistener("instrumentation/altimeter/setting-inhg", func m.calc_kpa());

        for(var i=0; i<11; i+=1) {
            append(m.eicas_msg,m.eicas.initNode("msg["~i~"]/text"," ","STRING"));
            append(m.eicas_msg_red,m.eicas.initNode("msg["~i~"]/red",0.1 *i));
            append(m.eicas_msg_green,m.eicas.initNode("msg["~i~"]/green",0.8));
            append(m.eicas_msg_blue,m.eicas.initNode("msg["~i~"]/blue",0.8));
            append(m.eicas_msg_alpha,m.eicas.initNode("msg["~i~"]/alpha",1.0));
        }

        return m;
    },
}
