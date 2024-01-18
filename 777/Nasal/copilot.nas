setlistener("/sim/signals/fdm-initialized", func {
    copilot.init();
 });
 
 # Copilot announcements
 var copilot = {
    init : func { 
        me.UPDATE_INTERVAL = 1.73; 
        me.loopid = 0;
        # Initialize state variables.
        me.V1announced = 0;
        me.VRannounced = 0;
        me.V2announced = 0;
        me.lights = {};
        me.seatbelts_on = getprop('controls/switches/seatbelt-sign');
        me.reset(); 
        print("Copilot ready"); 
    }, 
    update : func {
        var airspeed = getprop("velocities/airspeed-kt");
        var V1 = getprop("/instrumentation/fmc/vspeeds/V1");
        var V2 = getprop("/instrumentation/fmc/vspeeds/V2");
        var VR = getprop("/instrumentation/fmc/vspeeds/VR");
 
        if ((V1 != 0) and (VR != 0) and (V2 != 0)) {

            #Check if the V1, VR and V2 callouts should occur and if so, add to the announce function
            if ((airspeed != nil) and (V1 != nil) and (airspeed > V1) and (me.V1announced == 0)) {
                me.announce("V1!");
                me.V1announced = 1;
                setprop("/sim/sound/copilot/v1", 1);

            } elsif ((airspeed != nil) and (VR != nil) and (airspeed > VR) and (me.VRannounced == 0)) {
                me.announce("Vr Rotate!");
                me.VRannounced = 1;
                setprop("/sim/sound/copilot/vr", 1);

            } elsif ((airspeed != nil) and (V2 != nil) and (airspeed > V2) and (me.V2announced == 0)) {
                me.announce("V2!");
                me.V2announced = 1;
                setprop("/sim/sound/copilot/v2", 1);
            }

        }
        
        var altitude = getprop("/instrumentation/altimeter/indicated-altitude-ft");
        var wow = getprop('gear/gear/wow');
        var ias = getprop("/velocities/airspeed-kt");
        var eng1_n1 = getprop('engines/engine[0]/n1');
        var eng2_n1 = getprop('engines/engine[1]/n1');
        var engine_started = (eng1_n1 >= 30 and eng2_n1 >= 30);
        if(getprop("copilot/lights")){
            if(wow){
                var apu = getprop("engines/apu/running");
                var eng_starter = getprop("controls/engines/engine-start-switch");
                if(eng_starter == 2)
                    me.turn_light('beacon', 1);  
                if(engine_started and ias > 13 and ias < 50){
                    me.turn_light('landing-lights[1]', 1);
                }
                elsif(ias >= 50){
                    me.turn_light('landing-lights[1]', 0);
                    settimer(func(){
                        me.turn_light('wing-lights', 1);
                        me.turn_light('landing-lights[0]', 1);
                        me.turn_light('landing-lights[2]', 1);
                    }, 4);
                }  
            } else {
                var agl = getprop("/position/altitude-agl-ft");
                var phase = getprop("flight-management/phase");
                if(phase == 'APP'){    
                    if(agl < 600){
                        me.turn_light('landing-lights[0]', 1);
                        me.turn_light('landing-lights[2]', 1);
                    }
                } else {
                    if(agl > 500){
                        me.turn_light('landing-lights[0]', 0);
                        me.turn_light('landing-lights[2]', 0);
                    }
                }
            }
            if(engine_started){
                me.turn_light('strobe', 1);
                me.turn_light('nav-lights-switch', 2);
            }
        }
        if(getprop("copilot/seatbelts")){
            var seatbelts_on = ((wow and engine_started) or 
                                (!wow and altitude < 10000));
            me.turn_seatbelts_sign(seatbelts_on);
        }
       
       # RESET
       
       	if (getprop("/velocities/airspeed-kt") < 20) {
       
			me.V1announced = 0;
			me.VRannounced = 0;
			me.V2announced = 0;
			setprop("/sim/sound/copilot/v1", 0);
			setprop("/sim/sound/copilot/vr", 0);
			setprop("/sim/sound/copilot/v2", 0);
       
       	}
    },
 
    # Print the announcement on the screen
    announce : func(msg) {
        setprop("/sim/messages/copilot", msg);
    },
    turn_light: func(light, on){
        if(me.lights[light] == on) return;
        setprop("controls/lighting/"~ light, on);
        utils.clickSound(7);
        var self = me;
        settimer(func(){
            var light_name = '';
            if(light == 'landing-lights[1]'){
                light_name = 'taxi';
            }
            elsif(light == 'landing-lights[0]'){
                light_name = 'left landing';
            }
            elsif(light == 'landing-lights[2]'){
                light_name = 'right landing';
            } else {
                light_name = string.replace(light, '[', '');
                light_name = string.replace(light, ']', '');
                light_name = string.replace(light, '-', ' ');   
            }
            self.announce(light_name ~" light " ~ (on ? "on" : "off"));
        }, 2);
        me.lights[light] = on;
    },
    turn_seatbelts_sign: func(on){
        var seatbelts = 'controls/switches/seatbelt-sign';
        if(me.seatbelts_on == on) return;
        setprop(seatbelts, on);
        utils.clickSound(6);
        var self = me;
        settimer(func(){
            self.announce("Seat-belts sign " ~ (on ? "on" : "off"));
        }, 2);
        me.seatbelts_on = on;
    },
    reset : func {
        me.loopid += 1;
        me._loop_(me.loopid);
    },
    _loop_ : func(id) {
        id == me.loopid or return;
        me.update();
        settimer(func { me._loop_(id); }, me.UPDATE_INTERVAL);
    }
 };
