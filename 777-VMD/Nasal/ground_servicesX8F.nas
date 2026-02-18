#Ground Services added by franck VMD - 20220220
var door = aircraft.door.new("services/deicing_truck/crane", 20);
var door3 = aircraft.door.new("services/deicing_truck/deicing", 20);


var ground_services = {
    init : func {
    
    # Fuel Truck
    
    setprop("services/fuel-truck/enable", 0);
    setprop("services/fuel-truck/connect", 0);
    setprop("controls/switches/NOZZLELSwitchTimer/position-norm", 0);
    setprop("controls/switches/NOZZLERSwitchTimer/position-norm", 0);
    setprop("controls/fuel/jitteson-arm-switch", 0);
    setprop("services/fuel-truck/transfer", 0);
    setprop("services/fuel-truck/clean", 0);
    setprop("services/fuel-truck/request-lbs", getprop("consumables/fuel/total-fuel-lbs"));
    setprop("services/fuel-truck/extra-lbs", 0);
    setprop("services/fuel-truck/speed-text", " ");

    # External Power
    
    setprop("services/ext-pwr/enable", 1);
    setprop("services/ext-pwr/was_enabled", 0);
    setprop("services/ext-pwr/primary", 1);
    setprop("services/ext-pwr/secondary", 0);

    # Camion Radar
    
    setprop("services/camion/enable4", 0);
    setprop("services/camion/move4", 0);	
    setprop("services/camion/position4", 0);
    
    # Camion cargo
    setprop("services/cargo/move5", 0);	
    setprop("services/cargo/position5", 0);

    # Camion cargo1
    setprop("services/cargo1/move6", 0);	
    setprop("services/cargo1/position6", 0);

    # Camion cargo2
    setprop("services/cargo2/move7", 0);	
    setprop("services/cargo2/position7", 0);
    
    # Payload System
    
    if (getprop("sim/aero") != "777-X8F-v2") { 
        # The 777-200F has its own payload dialog. For the other types, the max number of first/business/economy pax and catering has to be defined, so we
        # overwrite the dialog with the values specified in their respective -set files.
        var payload = gui.Dialog.new("sim/gui/dialogs/payload/dialog", "gui/dialogs/payload-dlg.xml");
        setprop("sim/gui/dialogs/payload/dialog/group[1]/slider[0]/max", getprop("services/payload/first-max-nr"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/slider[1]/max", getprop("services/payload/business-max-nr"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/slider[2]/max", getprop("services/payload/economy-max-nr"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/slider[3]/max", getprop("services/payload/belly-max-lbs"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/slider[4]/max", getprop("services/payload/catering1-max-lbs"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/slider[5]/max", getprop("services/payload/catering2-max-lbs"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/slider[6]/max", getprop("services/payload/catering3-max-lbs"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/slider[7]/max", getprop("services/payload/catering4-max-lbs"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/slider[8]/max", getprop("services/payload/crew-max-nr"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/button[1]/binding/max", getprop("services/payload/first-max-nr"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/button[3]/binding/max", getprop("services/payload/business-max-nr"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/button[5]/binding/max", getprop("services/payload/economy-max-nr"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/button[7]/binding/max", getprop("services/payload/belly-max-lbs"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/button[9]/binding/max", getprop("services/payload/catering1-max-lbs"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/button[11]/binding/max", getprop("services/payload/catering2-max-lbs"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/button[13]/binding/max", getprop("services/payload/catering3-max-lbs"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/button[15]/binding/max", getprop("services/payload/catering4-max-lbs"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/button[17]/binding/max", getprop("services/payload/crew-max-nr"));
    }
    setprop("services/stairs/flaps-jammed", 0);
    
    # Chocks
    
    setprop("services/chocks/nose", 0);
    setprop("services/chocks/left", 0);
    setprop("services/chocks/right", 0);
    
    # Catering Truck
    
    setprop("services/catering/enable", 0);
    setprop("services/catering/move", 0);	
    setprop("services/catering/position", 0);
    setprop("services/catering/enable1", 0);
    setprop("services/catering/move1", 0);	
    setprop("services/catering/position1", 0);
    setprop("services/catering/enable2", 0);
    setprop("services/catering/move2", 0);	
    setprop("services/catering/position2", 0);
    setprop("services/catering/enable3", 0);
    setprop("services/catering/move3", 0);	
    setprop("services/catering/position3", 0);

    # De-icing Truck
	
    setprop("services/deicing_truck/enable", 0);
    setprop("services/deicing_truck/de-ice", 0);

    _startstop_gsv();
    
    },
    update : func {
    
        # Fuel Truck Controls
        # Fuel Transfer Rate is based on a 1000 US Gal flow per minute, which is at the fast side of real life operations, but not unrealistic.
        
        if (getprop("services/fuel-truck/enable") and getprop("services/fuel-truck/connect") or (getprop("controls/switches/NOZZLELSwitchTimer/position-norm") == 1) and (getprop("controls/switches/NOZZLERSwitchTimer/position-norm") == 1)) {
        
            if (getprop("services/fuel-truck/transfer")) {
            
                if (getprop("consumables/fuel/total-fuel-lbs") < getprop("services/fuel-truck/request-lbs")) {
                    if (getprop("consumables/fuel/tank[0]/level-gal_us") < getprop("consumables/fuel/tank[2]/capacity-gal_us")) {
                        if (getprop("consumables/fuel/tank[0]/level-lbs") + 6 > getprop("services/fuel-truck/request-lbs") - getprop("consumables/fuel/tank[2]/level-lbs") - getprop("consumables/fuel/tank[1]/level-lbs")) {
                            setprop("consumables/fuel/tank[0]/level-lbs", getprop("consumables/fuel/tank[0]/level-lbs") + 0.1);
                        } else {
                            setprop("consumables/fuel/tank[0]/level-lbs", getprop("consumables/fuel/tank[0]/level-lbs") + 5.55);
                        }
                    }
                    if (getprop("consumables/fuel/tank[2]/level-gal_us") < getprop("consumables/fuel/tank[2]/capacity-gal_us")) {
                        if (getprop("consumables/fuel/tank[2]/level-lbs") + 6 > getprop("services/fuel-truck/request-lbs") - getprop("consumables/fuel/tank[0]/level-lbs") - getprop("consumables/fuel/tank[1]/level-lbs")) {
                            setprop("consumables/fuel/tank[2]/level-lbs", getprop("consumables/fuel/tank[2]/level-lbs") + 0.1);
                        } else {
                            setprop("consumables/fuel/tank[2]/level-lbs", getprop("consumables/fuel/tank[2]/level-lbs") + 5.55);
                        }
                    }
                    if ((getprop("consumables/fuel/tank[0]/capacity-gal_us") <= getprop("consumables/fuel/tank[0]/level-gal_us")) and (getprop("consumables/fuel/tank[2]/capacity-gal_us") <= getprop("consumables/fuel/tank[2]/level-gal_us"))) {
                        if (getprop("consumables/fuel/tank[0]/level-gal_us") > getprop("consumables/fuel/tank[0]/capacity-gal_us")) {
                            setprop("consumables/fuel/tank[1]/level-gal_us", (getprop("consumables/fuel/tank[1]/level-gal_us") + getprop("consumables/fuel/tank[0]/level-gal_us") - getprop("consumables/fuel/tank[0]/capacity-gal_us")));
                            setprop("consumables/fuel/tank[0]/level-gal_us", getprop("consumables/fuel/tank/capacity-gal_us"));
                        }
                        if (getprop("consumables/fuel/tank[2]/level-gal_us") > getprop("consumables/fuel/tank[2]/capacity-gal_us")) {
                            setprop("consumables/fuel/tank[1]/level-gal_us", (getprop("consumables/fuel/tank[1]/level-gal_us") + getprop("consumables/fuel/tank[2]/level-gal_us") - getprop("consumables/fuel/tank[2]/capacity-gal_us")));
                            setprop("consumables/fuel/tank[2]/level-gal_us", getprop("consumables/fuel/tank[2]/capacity-gal_us"));
                        }
                        if (getprop("consumables/fuel/tank[1]/level-lbs") + 12 > getprop("services/fuel-truck/request-lbs") - getprop("consumables/fuel/tank[0]/level-lbs") - getprop("consumables/fuel/tank[2]/level-lbs")) {
                            setprop("consumables/fuel/tank[1]/level-lbs", getprop("consumables/fuel/tank[1]/level-lbs") + 0.1);
                        } else {
                            setprop("consumables/fuel/tank[1]/level-lbs", getprop("consumables/fuel/tank[1]/level-lbs") + 11.1);
                        }
                    }
                setprop("services/fuel-truck/speed-text", math.round((getprop("services/fuel-truck/request-lbs")-getprop("consumables/fuel/total-fuel-lbs")) / 6660) ~ " min remaining");
                } else {
                    setprop("services/fuel-truck/transfer", 0);
                    setprop("services/fuel-truck/speed-text", " ");
                    screen.log.write("Refueling complete. " ~ math.round(getprop("consumables/fuel/total-fuel-lbs")) ~" Lbs. of fuel loaded.", 0, 0.584, 1);
                }
            }
            
            if (getprop("services/fuel-truck/clean")) {
            
                if (getprop("consumables/fuel/total-fuel-lbs") > 200) {
                
                    setprop("consumables/fuel/tank[0]/level-lbs", getprop("consumables/fuel/tank[0]/level-lbs") - 3.7);
                    setprop("consumables/fuel/tank[1]/level-lbs", getprop("consumables/fuel/tank[1]/level-lbs") - 3.7);
                    setprop("consumables/fuel/tank[2]/level-lbs", getprop("consumables/fuel/tank[2]/level-lbs") - 3.7);
                    setprop("services/fuel-truck/speed-text", math.round(getprop("consumables/fuel/total-fuel-lbs") / 6660) ~ " min remaining");
                } else {
                    setprop("services/fuel-truck/clean", 0);
                    setprop("services/fuel-truck/speed-text", " ");
                    screen.log.write("Fuel tanks drained.", 0, 0.584, 1);
                }	
            
            }
        } elsif (!(getprop("services/fuel-truck/enable")) and (getprop("services/fuel-truck/connect"))) {
            setprop("services/fuel-truck/connect", 0);
        }
        
        #External Ground Power controls
        
        if (getprop("services/ext-pwr/enable") == 1) {
            if (getprop("services/ext-pwr/primary") == 1) {
                setprop("controls/electric/external-power", 1);
            } else {
                setprop("controls/electric/external-power", 0);
            }
            if (getprop("services/ext-pwr/secondary") == 1) {
                setprop("controls/electric/external-power[1]", 1);
            } else {
                setprop("controls/electric/external-power[1]", 0);
            }
            setprop("services/ext-pwr/was_enabled", 1);
        } else {
            if (getprop("services/ext-pwr/primary") == 1) {
                if (getprop("services/ext-pwr/was_enabled") != 1) {
                    screen.log.write("Can't connect primary ground power without a powerbox!", 1, 0 ,0);
                }
                setprop("services/ext-pwr/primary", 0);
                setprop("controls/electric/external-power", 0);
            }
            if (getprop("services/ext-pwr/secondary") == 1) {
                if (getprop("services/ext-pwr/was_enabled") != 1) {
                    screen.log.write("Can't connect secondary ground power without a powerbox!", 1, 0 ,0);
                }
                setprop("services/ext-pwr/secondary", 0);
                setprop("controls/electric/external-power[1]", 0);
            }
            setprop("services/ext-pwr/was_enabled", 0);
        }
			
        
        # Chocks
        # This uses the left and right brakes for the moment, to avoid the parking brake from being active.
        
        if ((getprop("services/chocks/nose") == 1) or (getprop("services/chocks/left") == 1)) {
            setprop("controls/gear/brake-left", 1);
            setprop("services/chocks/left-was-enabled", 1);
        } else {
            if (getprop("services/chocks/left-was-enabled") == 1) {
                setprop("controls/gear/brake-left", 0);
                setprop("services/chocks/left-was-enabled", 0);
            }
        }
        
        if ((getprop("services/chocks/nose") == 1) or (getprop("services/chocks/right") == 1)) {
            setprop("controls/gear/brake-right", 1);
            setprop("services/chocks/right-was-enabled", 1);
        } else {
            if (getprop("services/chocks/right-was-enabled") == 1) {
                setprop("controls/gear/brake-right", 0);
                setprop("services/chocks/right-was-enabled", 0);
            }
        }
        
        # De-icing Truck
		
		if (getprop("services/deicing_truck/enable") and getprop("services/deicing_truck/de-ice"))
		{
		
			if (me.ice_time == 2){
				door.move(1);
				print ("Lifting De-icing Crane...");
			}
			
			if (me.ice_time == 220){
				door3.move(1);
				print ("Starting De-icing Process...");
			}
			
			if (me.ice_time == 420){
				door3.move(0);
				print ("De-icing Process Completed...");
			}
				
			if (me.ice_time == 650){
				door.move(0);
				print ("Lowering De-icing Crane...");
			}
			
			if (me.ice_time == 900) {
				screen.log.write("De-icing Completed!", 1, 1, 1);
				setprop("services/deicing_truck/de-ice", 0);
				setprop("controls/ice/wing/temp", 30);
				setprop("controls/ice/wing/eng1", 30);
				setprop("controls/ice/wing/eng2", 30);
			}
		
		} else 
			me.ice_time = 0;
			
			me.ice_time += 1;
        
        # Catering Truck Controls
        
        var cater_move = getprop("services/catering/move");
        var cater_move1 = getprop("services/catering/move1");
        var cater_move2 = getprop("services/catering/move2");
        var cater_move3 = getprop("services/catering/move3");
        var cater_position = getprop("services/catering/position");
        var cater_position1 = getprop("services/catering/position1");
        var cater_position2 = getprop("services/catering/position2");
        var cater_position3 = getprop("services/catering/position3");
        
        if (getprop("services/catering/enable") != 0) {
            if (cater_position < cater_move) { #raise catering truck 
                setprop("services/catering/position", cater_position + 0.005);  
                if (cater_move - getprop("services/catering/position") < 0.0001) {
                    setprop("services/catering/position", cater_move);
                }
            } elsif (cater_position > cater_move) { #lower catering truck 
                setprop("services/catering/position", cater_position - 0.005);  
                if ((getprop("services/catering/position") - cater_move) < 0.0001) {
                    setprop("services/catering/position", cater_move);
                }
            }
        } else {
            setprop("services/catering/position", 0);
            setprop("services/catering/move", 0);
        }
        
        if (getprop("services/catering/enable1") != 0) {
            if (cater_position1 < cater_move1) { #raise catering truck 1
                setprop("services/catering/position1", cater_position1 + 0.005);  
                if (cater_move1 - getprop("services/catering/position1") < 0.0001) {
                    setprop("services/catering/position1", cater_move1);
                }
            } elsif (cater_position1 > cater_move1) { #lower catering truck 1
                setprop("services/catering/position1", cater_position1 - 0.005);  
                if ((getprop("services/catering/position1") - cater_move1) < 0.0001) {
                    setprop("services/catering/position1", cater_move1);
                }
            }
        } else {
            setprop("services/catering/position1", 0);
            setprop("services/catering/move1", 0);
        }
        
        if (getprop("services/catering/enable2") != 0) {
            if (cater_position2 < cater_move2) { #raise catering truck 2
                setprop("services/catering/position2", cater_position2 + 0.005);  
                if (cater_move2 - getprop("services/catering/position2") < 0.0001) {
                    setprop("services/catering/position2", cater_move2);
                }
            } elsif (cater_position2 > cater_move2) { #lower catering truck 2
                setprop("services/catering/position2", cater_position2 - 0.005);  
                if ((getprop("services/catering/position2") - cater_move2) < 0.0001) {
                    setprop("services/catering/position2", cater_move2);
                }
            }
        } else {
            setprop("services/catering/position2", 0);
            setprop("services/catering/move2", 0);
        }
        
        if (getprop("services/catering/enable3") != 0) {
            if (cater_position3 < cater_move3) { #raise catering truck 3
                setprop("services/catering/position3", cater_position3 + 0.005);  
                if (cater_move3 - getprop("services/catering/position3") < 0.0001) {
                    setprop("services/catering/position3", cater_move3);
                }
            } elsif (cater_position3 > cater_move3) { #lower catering truck 3
                setprop("services/catering/position3", cater_position3 - 0.005);  
                if ((getprop("services/catering/position3") - cater_move3) < 0.0001) {
                    setprop("services/catering/position3", cater_move3);
                }
            }
        } else {
            setprop("services/catering/position3", 0);
            setprop("services/catering/move3", 0);
        }
        
        var cater_move = getprop("services/camion/move4");
        var cater_position = getprop("services/camion/position4");
        
        if (getprop("services/camion/enable4") != 0) {
            if (cater_position < cater_move) { #raise catering truck 
                setprop("services/camion/position4", cater_position + 0.005);  
                if (cater_move - getprop("services/camion/position4") < 0.0001) {
                    setprop("services/camion/position4", cater_move);
                }
            } elsif (cater_position > cater_move) { #lower catering truck 
                setprop("services/camion/position4", cater_position - 0.005);  
                if ((getprop("services/camion/position4") - cater_move) < 0.0001) {
                    setprop("services/camion/position4", cater_move);
                }
            }
        } else {
            setprop("services/camion/position4", 0);
            setprop("services/camion/move4", 0);
        }

        var cater_move = getprop("services/cargo/move5");
        var cater_position = getprop("services/cargo/position5");
        
        if (getprop("services/cargo/enable5") != 0) {
            if (cater_position < cater_move) { #raise catering truck 
                setprop("services/cargo/position5", cater_position + 0.001);  
                if (cater_move - getprop("services/cargo/position5") < 0.0001) {
                    setprop("services/cargo/position5", cater_move);
                }
            } elsif (cater_position > cater_move) { #lower catering truck 
                setprop("services/cargo/position5", cater_position - 0.001);  
                if ((getprop("services/cargo/position5") - cater_move) < 0.0001) {
                    setprop("services/cargo/position5", cater_move);
                }
            }
        } else {
            setprop("services/cargo/position5", 0);
            setprop("services/cargo/move5", 0);
        }

        var cater_move = getprop("services/cargo1/move6");
        var cater_position = getprop("services/cargo1/position6");
        
        if (getprop("services/cargo1/enable6") != 0) {
            if (cater_position < cater_move) { #raise catering truck 
                setprop("services/cargo1/position6", cater_position + 0.001);  
                if (cater_move - getprop("services/cargo1/position6") < 0.0001) {
                    setprop("services/cargo1/position6", cater_move);
                }
            } elsif (cater_position > cater_move) { #lower catering truck 
                setprop("services/cargo1/position6", cater_position - 0.001);  
                if ((getprop("services/cargo1/position6") - cater_move) < 0.0001) {
                    setprop("services/cargo1/position6", cater_move);
                }
            }
        } else {
            setprop("services/cargo1/position6", 0);
            setprop("services/cargo1/move6", 0);
        }

        var cater_move = getprop("services/cargo2/move7");
        var cater_position = getprop("services/cargo2/position7");
        
        if (getprop("services/cargo2/enable7") != 0) {
            if (cater_position < cater_move) { #raise catering truck 
                setprop("services/cargo2/position7", cater_position + 0.001);  
                if (cater_move - getprop("services/cargo2/position7") < 0.0001) {
                    setprop("services/cargo2/position7", cater_move);
                }
            } elsif (cater_position > cater_move) { #lower catering truck 
                setprop("services/cargo2/position7", cater_position - 0.001);  
                if ((getprop("services/cargo2/position7") - cater_move) < 0.0001) {
                    setprop("services/cargo2/position7", cater_move);
                }
            }
        } else {
            setprop("services/cargo2/position7", 0);
            setprop("services/cargo2/move7", 0);
        }
        
        # Pax and baggage
        
        # Gui update for the weight & payload dialog (code is in payload.nas, but Gui update needs the faster timer of the ground services system)
        setprop("services/payload/expected-weight-lbs", getprop("services/payload/belly-request-lbs") + getprop("services/payload/catering1-request-lbs") + getprop("services/payload/catering2-request-lbs") + getprop("services/payload/catering3-request-lbs") + getprop("services/payload/catering4-request-lbs") + getprop("services/payload/first-request-nr") * 137 + getprop("services/payload/business-request-nr") * 137 + getprop("services/payload/economy-request-nr") * 137 + getprop("services/payload/crew-request-nr") * 150);
        setprop("services/payload/pax-request-nr", getprop("services/payload/first-request-nr") + getprop("services/payload/business-request-nr") + getprop("services/payload/economy-request-nr"));
        
        # Make sure a Jetway and Stair cannot be connected to the same door at the same time.
        
        if (getprop("services/payload/jetway1_enable") == 1) {
            if (getprop("services/stairs/stairs1_enable") == 1) {
                setprop("services/stairs/stairs1_enable", 0);
                screen.log.write("Can't connect a Stair and a Jetway to the same door!", 1, 0 ,0);
            }
        }
        if (getprop("services/payload/jetway2_enable") == 1) {
            if (getprop("services/stairs/stairs2_enable") == 1) {
                setprop("services/stairs/stairs2_enable", 0);
                screen.log.write("Can't connect a Stair and a Jetway to the same door!", 1, 0 ,0);
            }
        }	
    }

};

var _timer_gsv = maketimer(0.1, func{ground_services.update()});

var _startstop_gsv = func() {
    if (getprop("gear/gear[0]/wow") == 1) {
        _timer_gsv.start();
    } else {
        _timer_gsv.stop();
    }
}

setlistener("sim/signals/fdm-initialized", func {
    ground_services.init();
    print("Ground Services ..... Initialized");
});

setlistener("gear/gear[0]/wow", func {_startstop_gsv()});
