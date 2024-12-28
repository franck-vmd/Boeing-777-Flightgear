var autoannunciator_active = "aircraft-config/auto-annunciator";
var landed = 0;

setlistener("controls/electric/battery-switch", func(){
    var running = getprop("controls/electric/battery-switch");
    var phase = getprop("flight-management/phase");
    if(running and phase == "T/O"){
        settimer(func(){
            if(getprop(autoannunciator_active)){
                setprop("sim/sound/welcome", 1);
            }
        }, 10);
    }
});

setlistener("flight-management/phase", func(){
    var phase = getprop("flight-management/phase");
    if(phase == 'APP'){
        settimer(func(){
            if(getprop(autoannunciator_active)){
                setprop("sim/sound/descent", 1);
            }
        }, 10);
    }
    elsif(phase == 'CLB'){
        settimer(func(){
            if(getprop(autoannunciator_active)){
                setprop("sim/sound/climb", 1);
            }
        }, 90);
    }
    elsif(phase == 'CRZ'){
        settimer(func(){
            if(getprop(autoannunciator_active)){
                setprop("sim/sound/cruise", 1);
            }
        }, 60);
    }
    elsif(phase == 'LANDED'){
        landed = 1;
        var ldg_chk = func(){
            if(getprop(autoannunciator_active)){
                var ias = getprop("/velocities/airspeed-kt");
                if(ias <= 40){
                    setprop("sim/sound/land", 1);
                } else {
                    settimer(ldg_chk, 10);
                }
            }
        };
        settimer(ldg_chk, 10);
    }
}, 0, 0);
