#=============================================================================
#Detournement d'un avion tanker Callsign ESSO2 pour ravitaillement à proximité, lequel doit être déjà lancé sous AI Demo
#Gérard Robin  copyright 2009 03 30========================================================



  var  initialized = 0;
  var enabled = 0;


  var tkr_distval = props.globals.getNode("fdm/jsbsim/systems/tanker/distance", 9);
  var tkr_altitudeval = props.globals.getNode("fdm/jsbsim/systems/tanker/altitude",9);
  var tkr_spdval = props.globals.getNode("fdm/jsbsim/systems/tanker/speed",9);
  var tkr_navval = props.globals.getNode("fdm/jsbsim/systems/tanker/tacan",9);

  tkr_navval.setValue("041X");
  var tkr = "ESSO2";
  var tkr_roll = 0;


  var init_contact = func {
        var  AI_Enabled = props.globals.getNode("sim/ai/enabled");
        enabled = AI_Enabled.getValue();
        initialized = 1;
  }

  CreateTanker = func {
    #print("refuel_tanker_boucle");
        if (getprop("/fdm/jsbsim/systems/tanker/enable") == 1) {

        #print("refuel_tanker");
            if (initialized  != 1 ) {
                init_contact();}

            var AllTanker = props.globals.getNode("ai/models").getChildren("tanker");
            var selectedTanker = [];
            if ( enabled) {
            var i =0;
            foreach(m; AllTanker) {

            #print("refuel_tanker",i);
                if (getprop("/fdm/jsbsim/systems/tanker/done") == 0) {
                                                var  contact_node = m.getNode("callsign");
                                                var  contact = contact_node.getValue();

                print("Tanker: ", contact);
                    if (contact == tkr) {
                            var tkr_dist =  tkr_distval.getValue();
                            var tkr_altitude = tkr_altitudeval.getValue();
                            var tkr_spd = tkr_spdval.getValue();
                            var tkr_tacan = tkr_navval.getValue();
                    print(tkr_dist);
                    print(tkr_altitude);
                    print(tkr_spd);
                    print("INDEX  ",i);
                            var aircraft_pos = geo.aircraft_position();
                            var aircraft_lat = getprop("position/latitude-deg");
                            var aircraft_lon = getprop("position/longitude-deg");
                            var  aircraft_heading  = getprop("/orientation/heading-deg");
                            var new_geo = geo.Coord.new().set_latlon(aircraft_lat, aircraft_lon);
                            var tkr_position = new_geo.apply_course_distance(aircraft_heading, tkr_dist);
                            var tkr_lat = tkr_position.lat();
                            var tkr_lon = tkr_position.lon();
                            setprop("ai/models/tanker["~i~"]/position/latitude-deg", tkr_lat);
                            setprop("ai/models/tanker["~i~"]/position/longitude-deg",tkr_lon);
                            setprop("ai/models/tanker["~i~"]/position/altitude-ft",tkr_altitude);
                            setprop("ai/models/tanker["~i~"]/orientation/true-heading-deg",aircraft_heading);
                            setprop("ai/models/tanker["~i~"]/velocities/true-airspeed-kt",tkr_spd);
                            setprop("ai/models/tanker["~i~"]/navaids/tacan/channel-ID",tkr_tacan);
                            setprop("ai/models/tanker["~i~"]/controls/flight/target-alt",tkr_altitude);
                            setprop("ai/models/tanker["~i~"]/controls/flight/target-hdg",aircraft_heading);
                            setprop("ai/models/tanker["~i~"]/controls/flight/target-spd",tkr_spd);
                            setprop("ai/models/tanker["~i~"]/controls/flight/target-roll",tkr_roll);

                            print("Lat  ",tkr_lat,"  Lon  ",tkr_lon,"  Hdg  ",aircraft_heading);

                            setprop("/fdm/jsbsim/systems/tanker/done",1);
            #Fin contact
                        }
            #Fin done zero
                }
            #Boucle foreach
            i = i+1;
            }

            }

            }else{
                    if (getprop("/fdm/jsbsim/systems/tanker/done") == 1) {
                    setprop("/fdm/jsbsim/systems/tanker/done",0);
                    setprop("/fdm/jsbsim/systems/tanker/enable",1);
                    settimer(CreateTanker,0.1);
                                }
                    }

        #Fin CreateTanker
    }
