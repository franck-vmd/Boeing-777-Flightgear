
# This procedure saves/loads the aircraft state depending on the saving/loading settings selected by the user.

var save_state = func {
    if (getprop("aircraft/settings/fuel_persistent")) {
        setprop("aircraft/settings/fuel/tank_level-lbs", getprop("consumables/fuel/tank/level-lbs"));
        setprop("aircraft/settings/fuel/tank1_level-lbs", getprop("consumables/fuel/tank[1]/level-lbs"));
        setprop("aircraft/settings/fuel/tank2_level-lbs", getprop("consumables/fuel/tank[2]/level-lbs"));
    };
    
    if (getprop("aircraft/settings/weight_persistent")) {
        setprop("aircraft/settings/weight/first-request-nr", getprop("services/payload/first-request-nr"));
        setprop("aircraft/settings/weight/first-onboard-nr", getprop("services/payload/first-onboard-nr"));
        setprop("aircraft/settings/weight/first-onboard-lbs", getprop("services/payload/first-onboard-lbs"));
        setprop("aircraft/settings/weight/business-request-nr", getprop("services/payload/business-request-nr"));
        setprop("aircraft/settings/weight/business-onboard-nr", getprop("services/payload/business-onboard-nr"));
        setprop("aircraft/settings/weight/business-onboard-lbs", getprop("services/payload/business-onboard-lbs"));
        setprop("aircraft/settings/weight/economy-request-nr", getprop("services/payload/economy-request-nr"));
        setprop("aircraft/settings/weight/economy-onboard-nr", getprop("services/payload/economy-onboard-nr"));
        setprop("aircraft/settings/weight/economy-onboard-lbs", getprop("services/payload/economy-onboard-lbs"));
        setprop("aircraft/settings/weight/pax-request-nr", getprop("services/payload/pax-request-nr"));
        setprop("aircraft/settings/weight/pax-onboard-nr", getprop("services/payload/pax-onboard-nr"));
        setprop("aircraft/settings/weight/pax-onboard-lbs", getprop("services/payload/pax-onboard-lbs"));
        setprop("aircraft/settings/weight/SOB-nr", getprop("services/payload/SOB-nr"));
        setprop("aircraft/settings/weight/belly-request-lbs", getprop("services/payload/belly-request-lbs"));
        setprop("aircraft/settings/weight/belly-onboard-lbs", getprop("services/payload/belly-onboard-lbs"));
        setprop("aircraft/settings/weight/catering1-request-lbs", getprop("services/payload/catering1-request-lbs"));
        setprop("aircraft/settings/weight/catering1-onboard-lbs", getprop("services/payload/catering1-onboard-lbs"));
        setprop("aircraft/settings/weight/catering2-request-lbs", getprop("services/payload/catering2-request-lbs"));
        setprop("aircraft/settings/weight/catering2-onboard-lbs", getprop("services/payload/catering2-onboard-lbs"));
        setprop("aircraft/settings/weight/catering3-request-lbs", getprop("services/payload/catering3-request-lbs"));
        setprop("aircraft/settings/weight/catering3-onboard-lbs", getprop("services/payload/catering3-onboard-lbs"));
        setprop("aircraft/settings/weight/catering4-request-lbs", getprop("services/payload/catering4-request-lbs"));
        setprop("aircraft/settings/weight/catering4-onboard-lbs", getprop("services/payload/catering4-onboard-lbs"));
        setprop("aircraft/settings/weight/crew-request-nr", getprop("services/payload/crew-request-nr"));
        setprop("aircraft/settings/weight/crew-onboard-nr", getprop("services/payload/crew-onboard-nr"));
        setprop("aircraft/settings/weight/crew-onboard-lbs", getprop("services/payload/crew-onboard-lbs"));
        setprop("aircraft/settings/weight/weight1-lbs", getprop("sim/weight[0]/weight-lb"));
        setprop("aircraft/settings/weight/weight2-lbs", getprop("sim/weight[1]/weight-lb"));
        setprop("aircraft/settings/weight/weight3-lbs", getprop("sim/weight[2]/weight-lb"));
        setprop("aircraft/settings/weight/weight4-lbs", getprop("sim/weight[3]/weight-lb"));
        setprop("aircraft/settings/weight/weight5-lbs", getprop("sim/weight[4]/weight-lb"));
        setprop("aircraft/settings/weight/weight6-lbs", getprop("sim/weight[5]/weight-lb"));
    };
    
    if (getprop("aircraft/settings/ground_services_persistent")) {
        setprop("aircraft/settings/services/stairs/stairs1_enable", getprop("services/stairs/stairs1_enable"));
        setprop("aircraft/settings/services/stairs/stairs2_enable", getprop("services/stairs/stairs2_enable"));
        setprop("aircraft/settings/services/stairs/stairs3_enable", getprop("services/stairs/stairs3_enable"));
        setprop("aircraft/settings/services/stairs/stairs4_enable", getprop("services/stairs/stairs4_enable"));
        setprop("aircraft/settings/services/stairs/paint-end", getprop("services/stairs/paint-end"));
        setprop("aircraft/settings/services/stairs/cover", getprop("services/stairs/cover"));
        setprop("aircraft/settings/services/payload/jetway1_enable", getprop("services/payload/jetway1_enable"));
        setprop("aircraft/settings/services/payload/jetway2_enable", getprop("services/payload/jetway2_enable"));
        setprop("aircraft/settings/services/payload/baggage-truck1-enable", getprop("services/payload/baggage-truck1-enable"));
        setprop("aircraft/settings/services/payload/baggage-truck2-enable", getprop("services/payload/baggage-truck2-enable"));
        setprop("aircraft/settings/services/fuel-truck/enable", getprop("services/fuel-truck/enable"));
        setprop("aircraft/settings/services/fuel-truck/connect", getprop("services/fuel-truck/connect"));
        setprop("aircraft/settings/services/ext-pwr/enable", getprop("services/ext-pwr/enable"));
        setprop("aircraft/settings/services/ext-pwr/primary", getprop("services/ext-pwr/primary"));
        setprop("aircraft/settings/services/ext-pwr/secondary", getprop("services/ext-pwr/secondary"));
        setprop("aircraft/settings/services/ext-pwr/power1", getprop("controls/electric/external-power[0]"));
        setprop("aircraft/settings/services/ext-pwr/power2", getprop("controls/electric/external-power[1]"));
        setprop("aircraft/settings/services/chocks/nose", getprop("services/chocks/nose"));
        setprop("aircraft/settings/services/chocks/left", getprop("services/chocks/left"));
        setprop("aircraft/settings/services/chocks/right", getprop("services/chocks/right"));
        setprop("aircraft/settings/services/catering/enable", getprop("services/catering/enable"));
        setprop("aircraft/settings/services/catering/position", getprop("services/catering/position"));
        setprop("aircraft/settings/services/catering/move", getprop("services/catering/move"));
        setprop("aircraft/settings/services/catering/enable1", getprop("services/catering/enable1"));
        setprop("aircraft/settings/services/catering/position1", getprop("services/catering/position1"));
        setprop("aircraft/settings/services/catering/move1", getprop("services/catering/move1"));
        setprop("aircraft/settings/services/catering/enable2", getprop("services/catering/enable2"));
        setprop("aircraft/settings/services/catering/position2", getprop("services/catering/position2"));
        setprop("aircraft/settings/services/catering/move2", getprop("services/catering/move2"));
        setprop("aircraft/settings/services/catering/enable3", getprop("services/catering/enable3"));
        setprop("aircraft/settings/services/catering/position3", getprop("services/catering/position3"));
        setprop("aircraft/settings/services/catering/move3", getprop("services/catering/move3"));
        setprop("aircraft/settings/services/camion/enable04", getprop("services/camion/enable4"));
        setprop("aircraft/settings/services/camion/position4", getprop("services/camion/position4"));
        setprop("aircraft/settings/services/camion/move4", getprop("services/camion/move4"));
        setprop("aircraft/settings/services/autopush/enabled", getprop("sim/model/autopush/enabled"));
        setprop("aircraft/settings/services/bus/bus1", getprop("services/bus/bus1-enable"));
        setprop("aircraft/settings/services/bus/bus2", getprop("services/bus/bus2-enable"));
        setprop("aircraft/settings/services/Moteurs/Moteur", getprop("services/Moteurs/Moteur-enable"));
        setprop("aircraft/settings/services/cones/cone1", getprop("services/cones/cone1-enable"));
        setprop("aircraft/settings/services/cones/cone2", getprop("services/cones/cone2-enable"));
        setprop("aircraft/settings/services/ASU/enable", getprop("services/ASU/enable"));
        setprop("aircraft/settings/services/ASU/hose1-enable", getprop("services/ASU/hose1-enable"));
        setprop("aircraft/settings/services/ASU/hose2-enable", getprop("services/ASU/hose2-enable"));
        setprop("aircraft/settings/services/deicing_truck/enable", getprop("services/deicing_truck/enable"));
        setprop("aircraft/settings/services/deicing_truck/de-ice", getprop("services/deicing_truck/de-ice"));
        setprop("aircraft/settings/services/deicing_truck/crane", getprop("services/deicing_truck/crane"));
    };
    
    # Write everything to the aircraft specific config file
    
    io.write_properties(getprop("sim/fg-home") ~ "/Export/" ~ getprop("sim/aero") ~ "-specific_config.xml", "/aircraft/settings");
};

var load_state = func {
    
    # Read the config file
    
    io.read_properties(getprop("sim/fg-home") ~ "/Export/" ~ getprop("sim/aero") ~ "-specific_config.xml", "/aircraft/settings");
    
    # Load fuel properties
    
    if (getprop("aircraft/settings/fuel_persistent")) {
        # Make sure we don't pass a nil (first run with this model)
        if ((getprop("aircraft/settings/fuel/tank_level-lbs") != nil) and (getprop("aircraft/settings/fuel/tank1_level-lbs") != nil) and (getprop("aircraft/settings/fuel/tank2_level-lbs") != nil)) {
            setprop("consumables/fuel/tank/level-lbs", getprop("aircraft/settings/fuel/tank_level-lbs"));
            setprop("consumables/fuel/tank[1]/level-lbs", getprop("aircraft/settings/fuel/tank1_level-lbs"));
            setprop("consumables/fuel/tank[2]/level-lbs", getprop("aircraft/settings/fuel/tank2_level-lbs"));
            print("Fuel state ..... Loaded");
        } else {
            setprop("consumables/fuel/tank/level-norm", 0.25);
            setprop("consumables/fuel/tank[1]/level-norm", 0.0);
            setprop("consumables/fuel/tank[2]/level-norm", 0.25);
        };
    } else {
        setprop("consumables/fuel/tank[0]/level-norm", 0.25);
        setprop("consumables/fuel/tank[1]/level-norm", 0.0);
        setprop("consumables/fuel/tank[2]/level-norm", 0.25);
        setprop("aircraft/settings/fuel/tank_level-lbs", 0.0);
        setprop("aircraft/settings/fuel/tank1_level-lbs", 0.0);
        setprop("aircraft/settings/fuel/tank2_level-lbs", 0.0);
    };
    
    # Load weight properties
    
    if (getprop("aircraft/settings/weight_persistent")) {
        # Make sure we don't pass a nil (first run with this model)
        if (getprop("aircraft/settings/weight/first-request-nr") != nil) {
            setprop("services/payload/first-request-nr", getprop("aircraft/settings/weight/first-request-nr"));
            setprop("services/payload/first-onboard-nr", getprop("aircraft/settings/weight/first-onboard-nr"));
            setprop("services/payload/first-onboard-lbs", getprop("aircraft/settings/weight/first-onboard-lbs"));
            setprop("services/payload/business-request-nr", getprop("aircraft/settings/weight/business-request-nr"));
            setprop("services/payload/business-onboard-nr", getprop("aircraft/settings/weight/business-onboard-nr"));
            setprop("services/payload/business-onboard-lbs", getprop("aircraft/settings/weight/business-onboard-lbs"));
            setprop("services/payload/economy-request-nr", getprop("aircraft/settings/weight/economy-request-nr"));
            setprop("services/payload/economy-onboard-nr", getprop("aircraft/settings/weight/economy-onboard-nr"));
            setprop("services/payload/economy-onboard-lbs", getprop("aircraft/settings/weight/economy-onboard-lbs"));
            setprop("services/payload/pax-request-nr", getprop("aircraft/settings/weight/pax-request-nr"));
            setprop("services/payload/pax-onboard-nr", getprop("aircraft/settings/weight/pax-onboard-nr"));
            setprop("services/payload/pax-onboard-lbs", getprop("aircraft/settings/weight/pax-onboard-lbs"));
            setprop("services/payload/SOB-nr", getprop("aircraft/settings/weight/SOB-nr"));
            setprop("services/payload/belly-request-lbs", getprop("aircraft/settings/weight/belly-request-lbs"));
            setprop("services/payload/belly-onboard-lbs", getprop("aircraft/settings/weight/belly-onboard-lbs"));
            if (getprop("aircraft/settings/weight/catering-request-lbs") != nil) {
                setprop("services/payload/catering1-request-lbs", getprop("aircraft/settings/weight/catering1-request-lbs"));
                setprop("services/payload/catering1-onboard-lbs", getprop("aircraft/settings/weight/catering1-onboard-lbs"));
                setprop("services/payload/catering2-request-lbs", getprop("aircraft/settings/weight/catering2-request-lbs"));
                setprop("services/payload/catering2-onboard-lbs", getprop("aircraft/settings/weight/catering2-onboard-lbs"));
                setprop("services/payload/catering3-request-lbs", getprop("aircraft/settings/weight/catering3-request-lbs"));
                setprop("services/payload/catering3-onboard-lbs", getprop("aircraft/settings/weight/catering3-onboard-lbs"));
                setprop("services/payload/catering4-request-lbs", getprop("aircraft/settings/weight/catering4-request-lbs"));
                setprop("services/payload/catering4-onboard-lbs", getprop("aircraft/settings/weight/catering4-onboard-lbs"));
            }
            setprop("services/payload/crew-request-nr", getprop("aircraft/settings/weight/crew-request-nr"));
            setprop("services/payload/crew-onboard-nr", getprop("aircraft/settings/weight/crew-onboard-nr"));
            setprop("services/payload/crew-onboard-lbs", getprop("aircraft/settings/weight/crew-onboard-lbs"));
            setprop("sim/weight[0]/weight-lb", getprop("aircraft/settings/weight/weight1-lbs"));
            setprop("sim/weight[1]/weight-lb", getprop("aircraft/settings/weight/weight2-lbs"));
            setprop("sim/weight[2]/weight-lb", getprop("aircraft/settings/weight/weight3-lbs"));
            setprop("sim/weight[3]/weight-lb", getprop("aircraft/settings/weight/weight4-lbs"));
            setprop("sim/weight[4]/weight-lb", getprop("aircraft/settings/weight/weight5-lbs"));
            setprop("sim/weight[5]/weight-lb", getprop("aircraft/settings/weight/weight6-lbs"));
            print("Weight state ..... Loaded");
        };
    };
    
    # Load Radio properties
    
    if (!getprop("aircraft/settings/radio_persistent")) {
        setprop("instrumentation/comm/frequencies/selected-mhz", 119.10);
        setprop("instrumentation/comm/frequencies/standby-mhz", 125.00);
        setprop("instrumentation/comm[1]/frequencies/selected-mhz", 119.30);
        setprop("instrumentation/comm[1]/frequencies/standby-mhz", 118.70);
        setprop("instrumentation/comm[2]/frequencies/selected-mhz", 119.50);
        setprop("instrumentation/comm[2]/frequencies/standby-mhz", 135.705);
        setprop("instrumentation/nav/frequencies/selected-mhz", 109.50);
        setprop("instrumentation/nav/frequencies/standby-mhz", 109.55);
        setprop("instrumentation/nav[1]/frequencies/selected-mhz", 110.10);
        setprop("instrumentation/nav[1]/frequencies/standby-mhz", 111.70);
        print("Radio channels ..... Loaded");
    } else {
        setprop("instrumentation/rmu/unit/selected-mhz", getprop("instrumentation/comm/frequencies/selected-mhz"));
        setprop("instrumentation/rmu/unit/standby-mhz", getprop("instrumentation/comm/frequencies/standby-mhz"));
        setprop("instrumentation/rmu/unit[1]/selected-mhz", getprop("instrumentation/comm[1]/frequencies/selected-mhz"));
        setprop("instrumentation/rmu/unit[1]/standby-mhz", getprop("instrumentation/comm[1]/frequencies/standby-mhz"));
        setprop("instrumentation/rmu/unit[2]/selected-mhz", getprop("instrumentation/comm[2]/frequencies/selected-mhz"));
        setprop("instrumentation/rmu/unit[2]/standby-mhz", getprop("instrumentation/comm[2]/frequencies/standby-mhz"));
    };
    
    # Load Ground Services
    
    if (getprop("aircraft/settings/ground_services_persistent")) {
        if (getprop("aircraft/settings/services/stairs/stairs1_enable") != nil) {
            setprop("services/stairs/stairs1_enable", getprop("aircraft/settings/services/stairs/stairs1_enable"));
            setprop("services/stairs/stairs2_enable", getprop("aircraft/settings/services/stairs/stairs2_enable"));
            setprop("services/stairs/stairs3_enable", getprop("aircraft/settings/services/stairs/stairs3_enable"));
            setprop("services/stairs/stairs4_enable", getprop("aircraft/settings/services/stairs/stairs4_enable"));
            setprop("services/stairs/paint-end", getprop("aircraft/settings/services/stairs/paint-end"));
            setprop("services/stairs/cover", getprop("aircraft/settings/services/stairs/cover"));
            setprop("services/payload/jetway1_enable", getprop("aircraft/settings/services/payload/jetway1_enable"));
            setprop("services/payload/jetway2_enable", getprop("aircraft/settings/services/payload/jetway2_enable"));
            setprop("services/payload/baggage-truck1-enable", getprop("aircraft/settings/services/payload/baggage-truck1-enable"));
            setprop("services/payload/baggage-truck2-enable", getprop("aircraft/settings/services/payload/baggage-truck2-enable"));
            setprop("services/fuel-truck/enable", getprop("aircraft/settings/services/fuel-truck/enable"));
            setprop("services/fuel-truck/connect", getprop("aircraft/settings/services/fuel-truck/connect"));
            setprop("services/ext-pwr/enable", getprop("aircraft/settings/services/ext-pwr/enable"));
            setprop("services/ext-pwr/primary", getprop("aircraft/settings/services/ext-pwr/primary"));
            setprop("services/ext-pwr/secondary", getprop("aircraft/settings/services/ext-pwr/secondary"));
            setprop("controls/electric/external-power[0]", getprop("aircraft/settings/services/ext-pwr/power1"));
            setprop("controls/electric/external-power[1]", getprop("aircraft/settings/services/ext-pwr/power2"));
            setprop("services/chocks/nose", getprop("aircraft/settings/services/chocks/nose"));
            setprop("services/chocks/left", getprop("aircraft/settings/services/chocks/left"));
            setprop("services/chocks/right", getprop("aircraft/settings/services/chocks/right"));
            setprop("services/catering/enable", getprop("aircraft/settings/services/catering/enable"));
            setprop("services/catering/position", getprop("aircraft/settings/services/catering/position"));
            setprop("services/catering/move", getprop("aircraft/settings/services/catering/move"));
            setprop("services/catering/enable1", getprop("aircraft/settings/services/catering/enable1"));
            setprop("services/catering/position1", getprop("aircraft/settings/services/catering/position1"));
            setprop("services/catering/move1", getprop("aircraft/settings/services/catering/move1"));
            setprop("services/catering/enable2", getprop("aircraft/settings/services/catering/enable2"));
            setprop("services/catering/position2", getprop("aircraft/settings/services/catering/position2"));
            setprop("services/catering/move2", getprop("aircraft/settings/services/catering/move2"));
            setprop("services/catering/enable3", getprop("aircraft/settings/services/catering/enable3"));
            setprop("services/catering/position3", getprop("aircraft/settings/services/catering/position3"));
            setprop("services/catering/move3", getprop("aircraft/settings/services/catering/move3"));
            setprop("services/camion/enable4", getprop("aircraft/settings/services/camion/enable4"));
            setprop("services/camion/position4", getprop("aircraft/settings/services/camion/position4"));
            setprop("services/camion/move4", getprop("aircraft/settings/services/camion/move4"));
            setprop("sim/model/autopush/enabled", getprop("aircraft/settings/services/autopush/enabled"));
            setprop("services/bus/bus1-enable", getprop("aircraft/settings/services/bus/bus1"));
            setprop("services/bus/bus1-enable", getprop("aircraft/settings/services/bus/bus1"));
            setprop("services/Moteurs/Moteur-enable", getprop("aircraft/settings/services/Moteurs/Moteur"));
            setprop("services/cones/cone1-enable", getprop("aircraft/settings/services/cones/cone1"));
            setprop("services/cones/cone2-enable", getprop("aircraft/settings/services/cones/cone2"));
            setprop("services/ASU/enable", getprop("aircraft/settings/services/ASU/enable"));
            setprop("services/ASU/hose1-enable", getprop("aircraft/settings/services/ASU/hose1-enable"));
            setprop("services/ASU/hose2-enable", getprop("aircraft/settings/services/ASU/hose2-enable"));
            setprop("services/deicing_truck/enable", getprop("aircraft/settings/services/deicing_truck/enable"));
            setprop("services/deicing_truck/de-ice", getprop("aircraft/settings/services/deicing_truck/de-ice"));
            setprop("services/deicing_truck/crane", getprop("aircraft/settings/services/deicing_truck/crane"));
            print("Previous ground services ..... Loaded");
        };
    };
    
};

setlistener("sim/signals/fdm-initialized", func {
    load_state();
});

setlistener("sim/signals/exit", func {
    save_state();
});

setlistener("sim/signals/reinit", func {
    save_state();
});
