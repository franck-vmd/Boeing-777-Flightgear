

var payload_boarding = {
    init : func {
    
    # pax
    
    props.globals.initNode("services/payload/first-request-nr", 0);
    props.globals.initNode("services/payload/first-onboard-nr", 0);
    props.globals.initNode("services/payload/first-onboard-lbs", 0);
    props.globals.initNode("services/payload/business-request-nr", 0);
    props.globals.initNode("services/payload/business-onboard-nr", 0);
    props.globals.initNode("services/payload/business-onboard-lbs", 0);
    props.globals.initNode("services/payload/economy-request-nr", 0);
    props.globals.initNode("services/payload/economy-onboard-nr", 0);
    props.globals.initNode("services/payload/economy-onboard-lbs", 0);
    props.globals.initNode("services/payload/pax-request-nr", 0);
    props.globals.initNode("services/payload/pax-onboard-nr", 0);
    props.globals.initNode("services/payload/pax-onboard-lbs", 0);
    props.globals.initNode("services/payload/pax-random-nr", 0);
    props.globals.initNode("services/payload/pax-boarding", 0);
    props.globals.initNode("services/payload/pax-force-deboard", 0);
    props.globals.initNode("services/stairs/stairs1_enable", 0);
    props.globals.initNode("services/stairs/stairs2_enable", 0);
    props.globals.initNode("services/stairs/stairs3_enable", 0);
    props.globals.initNode("services/stairs/stairs4_enable", 0);
    props.globals.initNode("services/stairs/paint-end", "blue-shade.png");
    props.globals.initNode("services/stairs/cover", 1);
    props.globals.initNode("services/payload/passenger-added", 0);
    props.globals.initNode("services/payload/passenger-removed", 0);
    props.globals.initNode("services/payload/speed", 6.0); #This defines the loading/boarding cycle speed. 6.0 equals 1 cycle every 6 seconds.
    props.globals.initNode("services/payload/SOB-nr", 0);
    props.globals.initNode("services/payload/jetway1_enable", 0);
    props.globals.initNode("services/payload/jetway2_enable", 0);
    props.globals.initNode("services/payload/boardingtime_remaining", " ");
    props.globals.initNode("services/payload/speed-text", "Normal");
    
    # Baggage
    
    props.globals.initNode("services/payload/belly-request-lbs", 0);
    props.globals.initNode("services/payload/belly-onboard-lbs", 0);
    props.globals.initNode("services/payload/baggage-loading", 0);
    props.globals.initNode("services/payload/baggage-truck1-enable", 0);
    props.globals.initNode("services/payload/baggage-truck2-enable", 0);
    props.globals.initNode("services/payload/baggage-speed", 0);
    props.globals.initNode("services/payload/loadingtime_remaining", " ");
    
    # Catering
    
    props.globals.initNode("services/payload/catering-request-lbs", 0);
    props.globals.initNode("services/payload/catering-onboard-lbs", 0);
    props.globals.initNode("services/payload/catering-loading", 0);
    props.globals.initNode("services/payload/catering-trolley-lbs", 0);
    props.globals.initNode("services/payload/catering-trolley-nr", 0);
    props.globals.initNode("services/payload/catering-galley-0-trolley-nr", 0);
    props.globals.initNode("services/payload/catering-galley-1-trolley-nr", 0);
    props.globals.initNode("services/payload/catering-galley-2-trolley-nr", 0);
    props.globals.initNode("services/payload/catering-galley-3-trolley-nr", 0);
    props.globals.initNode("services/payload/catering-galley-0-full", 0);
    props.globals.initNode("services/payload/catering-galley-1-full", 0);
    props.globals.initNode("services/payload/catering-galley-2-full", 0);
    props.globals.initNode("services/payload/catering-galley-3-full", 0);
    props.globals.initNode("services/payload/catering-cycle-nr", 0);
    props.globals.initNode("services/payload/catering-skipcycle-nr", 0);
    
    # Crew
    
    props.globals.initNode("services/payload/crew-request-nr", 2.0);
    props.globals.initNode("services/payload/crew-onboard-nr", 2.0);
    props.globals.initNode("services/payload/crew-onboard-lbs", 300.0);

    _startstop();

    },
    
    update : func {
        
        #Keep the dialog up to date and prepare some values for calculations
        
        setprop("services/payload/pax-request-nr", getprop("services/payload/first-request-nr") + getprop("services/payload/business-request-nr") + getprop("services/payload/economy-request-nr"));
                
        #Passenger boarding
        
        # First: each passenger weighs between 85 and 189 Lbs (random for each passenger) and has 110 Lbs of luggage
        # Business: each passenger weighs between 85 and 189 Lbs (random for each passenger) and has 88 Lbs of luggage
        # Economy: each passenger weighs between 85 and 189 Lbs (random for each passenger) and has 33 Lbs of luggage
        
        # Passengers are boarding quite randomly (classwise) and the same amount of passengers will weigh a different amount with each flight. The average should be around the worldwide average weight of 137 Lbs pp.
        # First class passengers will only (de)board via door 1L, unless it is not connected with a staircase or jetway, in that case they will (de)board via door 2L. They will never (de)board via door 3L or 4L.
        # Business class passengers will only (de)board via door 1L and 2L, never via door 3L or 4L.
        # Economy class passengers will only (de)board via door 2L, 3L and 4L, not via door 1L, unless door 1L is the only one with a staircase or jetway connected. Only in that case they will (de)board via door 1L.
        # This boarding system can greatly affect the estimated (de)boarding speed in the weight & payload dialog.
        
        # The jetway toggles in the weight dialog only affect the boarding speed, they don't move jetways, because the AI jetway system is unable to do that. You still have to extend/retract  the jetways separatly.
        
        if (getprop("services/payload/pax-boarding") == 1) {
        
            #If no stairs or Jetways are connected, cancel the boarding process.
            
            if (getprop("services/stairs/stairs1_enable") + getprop("services/stairs/stairs2_enable") + getprop("services/stairs/stairs3_enable") + getprop("services/stairs/stairs4_enable") + getprop("services/payload/jetway1_enable") + getprop("services/payload/jetway2_enable") == 0) {
                setprop("services/payload/pax-boarding", 0);
                screen.log.write("Captain, we cannot continue boarding, the stairs or jetways have been disconnected.", 1, 0, 0);
            }
            
            if (getprop("services/payload/pax-onboard-nr") < getprop("services/payload/pax-request-nr")) {
                
                # If Door 1L stairs or jetway are connected, a first, business or economy (only if no other stairs/jetways are connected) passenger is added every cycle
                
                # This random number defines which type of passenger (first/business/economy) is boarding in this cycle.
                setprop("services/payload/pax-random-nr", math.round(rand() * getprop("services/payload/pax-request-nr")));
                
                if ((getprop("services/stairs/stairs1_enable") == 1) or (getprop("services/payload/jetway1_enable") == 1)) {
                
                    if (getprop("services/payload/first-onboard-nr") < getprop("services/payload/first-request-nr")) {			    
                        if ((getprop("services/payload/pax-request-nr") - getprop("services/payload/pax-onboard-nr")) > (getprop("services/payload/first-request-nr"))) {
                            if (getprop("services/payload/pax-random-nr") <= getprop("services/payload/first-request-nr")) {
                                setprop("services/payload/first-onboard-nr", getprop("services/payload/first-onboard-nr") + 1.0);
                                setprop("services/payload/first-onboard-lbs", math.round(getprop("services/payload/first-onboard-lbs") + 195 + math.round(rand() * 104)));
                                setprop("services/payload/passenger-added", 1);
                            }
                        } else {
                            setprop("services/payload/first-onboard-nr", getprop("services/payload/first-onboard-nr") + 1.0);
                            setprop("services/payload/first-onboard-lbs", math.round(getprop("services/payload/first-onboard-lbs") + 195 + math.round(rand() * 104)));
                            setprop("services/payload/passenger-added", 1);
                        }
                    }
                    
                    # Economy passengers will only board here if no other stairs or jetways are connected.
                    
                    if ((getprop("services/payload/passenger-added") != 1) and (getprop("services/payload/economy-onboard-nr") < getprop("services/payload/economy-request-nr")) and (getprop("services/stairs/stairs2_enable") == 0) and (getprop("services/stairs/stairs3_enable") == 0) and (getprop("services/stairs/stairs4_enable") == 0) and (getprop("services/payload/jetway2_enable") == 0)) {			    
                        if ((getprop("services/payload/pax-request-nr") - getprop("services/payload/pax-onboard-nr")) > (getprop("services/payload/economy-request-nr"))) {
                            if (getprop("services/payload/pax-random-nr") >= (getprop("services/payload/pax-request-nr") - getprop("services/payload/economy-request-nr"))) {
                                setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") + 1.0);
                                setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-onboard-lbs") + 118 + rand() * 104));
                                setprop("services/payload/passenger-added", 1);
                            }
                        } else {
                            setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") + 1.0);
                            setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-onboard-lbs") + 118 + rand() * 104));
                            setprop("services/payload/passenger-added", 1);
                        }
                    }
                    
                    if (getprop("services/payload/passenger-added") != 1) {
                        if (getprop("services/payload/business-onboard-nr") < getprop("services/payload/business-request-nr")) {
                            setprop("services/payload/business-onboard-nr", getprop("services/payload/business-onboard-nr") + 1.0);
                            setprop("services/payload/business-onboard-lbs", math.round(getprop("services/payload/business-onboard-lbs") + 173 + rand() * 104));
                        }
                    }
                }
                
                setprop("services/payload/passenger-added", 0);
                
                # if door 2L staircase or jetway is connected, an extra first (only if door 1L staircase/jetway is not connected), business or economy passenger is added every cycle because they can board faster.
                
                setprop("services/payload/pax-random-nr", math.round(rand() * getprop("services/payload/pax-request-nr")));
                
                if ((getprop("services/stairs/stairs2_enable") == 1) or (getprop("services/payload/jetway2_enable") == 1)) {
                    
                    #First class passengers will only board here if there are no stairs or jetway connected to Door 1L.
                    
                    if ((getprop("services/stairs/stairs1_enable") == 0) and (getprop("services/payload/jetway1_enable") == 0)) {
                        if (getprop("services/payload/first-onboard-nr") < getprop("services/payload/first-request-nr")) {			    
                            if ((getprop("services/payload/pax-request-nr") - getprop("services/payload/pax-onboard-nr")) > (getprop("services/payload/first-request-nr"))) {
                                if (getprop("services/payload/pax-random-nr") <= getprop("services/payload/first-request-nr")) {
                                    setprop("services/payload/first-onboard-nr", getprop("services/payload/first-onboard-nr") + 1.0);
                                    setprop("services/payload/first-onboard-lbs", math.round(getprop("services/payload/first-onboard-lbs") + 195 + math.round(rand() * 104)));
                                    setprop("services/payload/passenger-added", 1);
                                }
                            } else {
                                setprop("services/payload/first-onboard-nr", getprop("services/payload/first-onboard-nr") + 1.0);
                                setprop("services/payload/first-onboard-lbs", math.round(getprop("services/payload/first-onboard-lbs") + 195 + math.round(rand() * 104)));
                                setprop("services/payload/passenger-added", 1);
                            }
                        }
                    }
                    
                    if ((getprop("services/payload/passenger-added") != 1) and (getprop("services/payload/economy-onboard-nr") < getprop("services/payload/economy-request-nr"))) {			    
                        if ((getprop("services/payload/pax-request-nr") - getprop("services/payload/pax-onboard-nr")) > (getprop("services/payload/economy-request-nr"))) {
                            if (getprop("services/payload/pax-random-nr") >= (getprop("services/payload/pax-request-nr") - getprop("services/payload/economy-request-nr"))) {
                                setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") + 1.0);
                                setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-onboard-lbs") + 118 + rand() * 104));
                                setprop("services/payload/passenger-added", 1);
                            }
                        } else {
                            setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") + 1.0);
                            setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-onboard-lbs") + 118 + rand() * 104));
                            setprop("services/payload/passenger-added", 1);
                        }
                    }
                    
                    if (getprop("services/payload/passenger-added") != 1) {
                        if (getprop("services/payload/business-onboard-nr") < getprop("services/payload/business-request-nr")) {
                            setprop("services/payload/business-onboard-nr", getprop("services/payload/business-onboard-nr") + 1.0);
                            setprop("services/payload/business-onboard-lbs", math.round(getprop("services/payload/business-onboard-lbs") + 173 + rand() * 104));
                        }
                    }
                }
                
                #if the staircase of Door 3L is connected, an extra economy passenger is added every cycle because they can board faster.
                
                if (getprop("services/stairs/stairs3_enable") == 1) {
                    if (getprop("services/payload/economy-onboard-nr") < getprop("services/payload/economy-request-nr")) {
                        setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") + 1);
                        setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-onboard-lbs") + 118 + rand() * 104));
                    }
                }
                
                #if the staircase of Door 4L is connected, an extra economy passenger is added every cycle because they can board faster.
                
                if (getprop("services/stairs/stairs4_enable") == 1) {
                    if (getprop("services/payload/economy-onboard-nr") < getprop("services/payload/economy-request-nr")) {
                        setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") + 1);
                        setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-onboard-lbs") + 118 + rand() * 104));
                    }
                }
                
                setprop("services/payload/passenger-added", 0);
                
                #####
                #Calculate the estimated remaining time (this is not so easy, as it depends on which stairs/jetway combination is connected; it will always be an estimate because we can't know on forehand which random passenger will be added in the next cycles).
                #####
                
                if (((getprop("services/stairs/stairs1_enable") == 1) or (getprop("services/payload/jetway1_enable") == 1)) and ((getprop("services/stairs/stairs2_enable") == 1) or (getprop("services/payload/jetway2_enable") == 1)) and ((getprop("services/stairs/stairs3_enable") == 1) or (getprop("services/stairs/stairs4_enable")))) {
                
                # Stairs/jetways 1, 2 and 3 and/or 4 connected.
                
                    if ((getprop("services/payload/economy-request-nr") > getprop("services/payload/economy-onboard-nr"))) {
                        if ((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) > (getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr"))) {
                            setprop("services/payload/boardingtime_remaining", "Est. " ~ math.round(((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) / (1 + getprop("services/stairs/stairs3_enable") + getprop("services/stairs/stairs4_enable"))) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        } else {
                            setprop("services/payload/boardingtime_remaining", "Est. " ~ math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        }
                    } else {
                        setprop("services/payload/boardingtime_remaining", "Est. " ~ math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                    }
                
                } elsif (((getprop("services/stairs/stairs1_enable") == 1) or (getprop("services/payload/jetway1_enable") == 1)) and ((getprop("services/stairs/stairs2_enable") == 1) or (getprop("services/payload/jetway2_enable") == 1)) and (getprop("services/stairs/stairs3_enable") != 1) and (getprop("services/stairs/stairs4_enable") != 1)) {
                
                # Stairs/jetways 1 and 2 connected, stairs 3 and 4 not connected
                    if ((getprop("services/payload/economy-request-nr") > getprop("services/payload/economy-onboard-nr"))) {
                        if ((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) > (getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr"))) {
                            setprop("services/payload/boardingtime_remaining", "Est. " ~ math.round((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        } else {
                            setprop("services/payload/boardingtime_remaining", "Est. " ~ math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        }
                    } else {
                        setprop("services/payload/boardingtime_remaining", "Est. " ~ math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                    }
                } elsif (((getprop("services/stairs/stairs1_enable") == 1) or (getprop("services/payload/jetway1_enable") == 1)) and ((getprop("services/stairs/stairs2_enable") != 1) and (getprop("services/payload/jetway2_enable") != 1)) and (getprop("services/stairs/stairs3_enable") == 1)) {
                
                # Stairs/jetways 1 and 3 and/or 4 connected, stairs/jetway 2 not connected
                    if ((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) > (getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr"))) {
                        if ((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) > (getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr"))) {						
                            setprop("services/payload/boardingtime_remaining", "Est. " ~ math.round(((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) / (1 + getprop("services/stairs/stairs3_enable") + getprop("services/stairs/stairs4_enable"))) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        } else {
                            setprop("services/payload/boardingtime_remaining", "Est. " ~ math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        }
                    } else {
                        setprop("services/payload/boardingtime_remaining", "Est. " ~ math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                    }
                } elsif (((getprop("services/stairs/stairs1_enable") != 1) and (getprop("services/payload/jetway1_enable") != 1)) and ((getprop("services/stairs/stairs2_enable") == 1) or (getprop("services/payload/jetway2_enable") == 1)) and (getprop("services/stairs/stairs3_enable") == 1)) {
                
                # Stairs/jetways 2 and 3 and/or 4 connected, stairs/jetway 1 not connected
                    if ((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) > (getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr"))) {
                        if ((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) > (getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr"))) {						
                            setprop("services/payload/boardingtime_remaining", "Est. " ~ math.round(((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) / (1 + getprop("services/stairs/stairs3_enable") + getprop("services/stairs/stairs4_enable"))) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        } else {
                            setprop("services/payload/boardingtime_remaining", "Est. " ~ math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        }
                    } else {
                        setprop("services/payload/boardingtime_remaining", "Est. " ~ math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                    }
                } elsif (((getprop("services/stairs/stairs1_enable") == 1) or (getprop("services/payload/jetway1_enable") == 1)) or ((getprop("services/stairs/stairs2_enable") == 1) or (getprop("services/payload/jetway2_enable") == 1)) and (getprop("services/stairs/stairs3_enable") != 1) and (getprop("services/stairs/stairs4_enable") != 1)) {
                
                # Only 1 of stair/jetway 1 or 2 connected, stairs 3, 4 and the other one not connected
                    setprop("services/payload/boardingtime_remaining", "Est. " ~ math.round((getprop("services/payload/pax-request-nr") - getprop("services/payload/pax-onboard-nr")) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                } elsif (((getprop("services/stairs/stairs1_enable") != 1) and (getprop("services/payload/jetway1_enable") != 1)) and ((getprop("services/stairs/stairs2_enable") != 1) or (getprop("services/payload/jetway2_enable") != 1)) and (getprop("services/stairs/stairs3_enable") == 1)) {
                
                # Only stairs 3 and/or 4 connected, stairs/jetways 1 and 2 not connected. This means that first and business are unable to board the plane.
                    setprop("services/payload/boardingtime_remaining", "Est. " ~ math.round(((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) / (getprop("services/stairs/stairs3_enable") + getprop("services/stairs/stairs4_enable"))) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                    screen.log.write("Captain, first and business class passengers are unable to board, Door 1L and 2L are not accessible for them. Please enable another stairs or jetway before we continue boarding.", 1, 0, 0);
                    setprop("services/payload/boarding", 0);
                }
                setprop("services/payload/pax-onboard-nr", (getprop("services/payload/first-onboard-nr") + getprop("services/payload/business-onboard-nr") + getprop("services/payload/economy-onboard-nr")));
                setprop("services/payload/pax-onboard-lbs", (getprop("services/payload/first-onboard-lbs") + getprop("services/payload/business-onboard-lbs") + getprop("services/payload/economy-onboard-lbs")));
            } else {
                setprop("services/payload/pax-boarding", 0);
                setprop("services/payload/boardingtime_remaining", " ");
                screen.log.write("Boarding complete. " ~ getprop("services/payload/pax-onboard-nr") ~ " pax on board, weighing " ~ getprop("services/payload/pax-onboard-lbs") ~ " Lbs.", 0, 0.584, 1);
            }
            
        #Deboarding
        
        } elsif (getprop("services/payload/pax-boarding") == 2) {
            setprop("services/payload/weight-total-lbs", getprop("services/payload/pax-onboard-lbs") + getprop("services/payload/belly-onboard-lbs"));
            setprop("services/payload/boardingtime_remaining", "Est. " ~ math.round(getprop("services/payload/pax-onboard-nr") / (getprop("services/stairs/stairs1_enable") + getprop("services/stairs/stairs2_enable") + getprop("services/stairs/stairs3_enable") + getprop("services/stairs/stairs4_enable") + getprop("services/payload/jetway1_enable") + getprop("services/payload/jetway2_enable")) / 60 * getprop("services/payload/speed")) ~ "min Remaining.");
            
            if (getprop("services/stairs/stairs1_enable") + getprop("services/stairs/stairs2_enable") + getprop("services/stairs/stairs3_enable") + getprop("services/stairs/stairs4_enable") + getprop("services/payload/jetway1_enable") + getprop("services/payload/jetway2_enable") == 0) {
                setprop("services/payload/pax-boarding", 0);
                screen.log.write("Captain, we cannot continue deboarding, the stairs or jetways have been disconnected.", 1, 0, 0);
            }
            
            if ((getprop("services/payload/weight-total-lbs") <= getprop("sim/weight[1]/max-lb")) or (getprop("services/payload/pax-force-deboard") == 1))  {
                
                # Door 1L deboarding
                
                if ((getprop("services/stairs/stairs1_enable") == 1) or (getprop("services/payload/jetway1_enable") == 1)) {
                    if (getprop("services/payload/first-onboard-nr") > 0) {
                        setprop("services/payload/first-onboard-lbs", math.round((getprop("services/payload/first-onboard-lbs") - (getprop("services/payload/first-onboard-lbs") / getprop("services/payload/first-onboard-nr")))));
                        setprop("services/payload/first-onboard-nr", getprop("services/payload/first-onboard-nr") - 1.0);
                        setprop("services/payload/passenger-removed", 1);
                    } elsif ((getprop("services/payload/business-onboard-nr") > 0) and (getprop("services/payload/passenger-removed") != 1)) {
                        setprop("services/payload/business-onboard-lbs", math.round((getprop("services/payload/business-onboard-lbs") - (getprop("services/payload/business-onboard-lbs") / getprop("services/payload/business-onboard-nr")))));
                        setprop("services/payload/business-onboard-nr", getprop("services/payload/business-onboard-nr") - 1.0);
                        setprop("services/payload/passenger-removed", 1);
                    # Economy passengers will only deboard here if no other stairs or jetways are connected.
                    } elsif ((getprop("services/payload/economy-onboard-nr") > 0) and (getprop("services/payload/passenger-removed") != 1) and (getprop("services/stairs/stairs2_enable") == 0) and (getprop("services/stairs/stairs3_enable") == 0) and (getprop("services/stairs/stairs4_enable") == 0) and (getprop("services/payload/jetway2_enable") == 0)) {
                        setprop("services/payload/economy-onboard-lbs", math.round((getprop("services/payload/economy-onboard-lbs") - (getprop("services/payload/economy-onboard-lbs") / getprop("services/payload/economy-onboard-nr")))));
                        setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") - 1.0);
                    }
                }
                
                # if door 2L staircase or jetway is enabled, an extra first (only if Door 1L stairs or jetways are not connected), business or economy passenger is removed every cycle because they can deboard faster.
                
                setprop("services/payload/passenger-removed", 0);
                
                #First class passengers only deboard here if Door 1L stairs/jetways are not connected.	
                
                if ((getprop("services/stairs/stairs2_enable") == 1) or (getprop("services/payload/jetway2_enable") == 1)) {
                    if ((getprop("services/stairs/stairs1_enable") == 0) and (getprop("services/payload/jetway1_enable") == 0)) {
                        if (getprop("services/payload/first-onboard-nr") > 0) {
                            setprop("services/payload/first-onboard-lbs", math.round((getprop("services/payload/first-onboard-lbs") - (getprop("services/payload/first-onboard-lbs") / getprop("services/payload/first-onboard-nr")))));
                            setprop("services/payload/first-onboard-nr", getprop("services/payload/first-onboard-nr") - 1.0);
                            setprop("services/payload/passenger-removed", 1);
                        }
                    }
                    if (getprop("services/payload/passenger-removed") == 0) {
                        if (getprop("services/payload/business-onboard-nr") > 0) {
                            setprop("services/payload/business-onboard-lbs", math.round((getprop("services/payload/business-onboard-lbs") - (getprop("services/payload/business-onboard-lbs") / getprop("services/payload/business-onboard-nr")))));
                            setprop("services/payload/business-onboard-nr", getprop("services/payload/business-onboard-nr") - 1.0);
                        } elsif (getprop("services/payload/economy-onboard-nr") > 0) {
                            setprop("services/payload/economy-onboard-lbs", math.round((getprop("services/payload/economy-onboard-lbs") - (getprop("services/payload/economy-onboard-lbs") / getprop("services/payload/economy-onboard-nr")))));
                            setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") - 1.0);
                        }
                    }
                }
                
                # if Door 3L stairs are enabled, an extra economy passenger is removed every cycle because they can deboard faster.
                
                if (getprop("services/stairs/stairs3_enable") == 1) {
                    if (getprop("services/payload/economy-onboard-nr") > 0) {
                        setprop("services/payload/economy-onboard-lbs", math.round((getprop("services/payload/economy-onboard-lbs") - (getprop("services/payload/economy-onboard-lbs") / getprop("services/payload/economy-onboard-nr")))));
                        setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") - 1.0);
                    }
                }
                
                # if Door 4L stairs are enabled, an extra economy passenger is removed every cycle because they can deboard faster.
                
                if (getprop("services/stairs/stairs4_enable") == 1) {
                    if (getprop("services/payload/economy-onboard-nr") > 0) {
                        setprop("services/payload/economy-onboard-lbs", math.round((getprop("services/payload/economy-onboard-lbs") - (getprop("services/payload/economy-onboard-lbs") / getprop("services/payload/economy-onboard-nr")))));
                        setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") - 1.0);
                    }
                }
            
            } else {
                setprop("services/payload/pax-boarding", 3);
            }
            setprop("services/payload/passenger-removed", 0);
            setprop("services/payload/pax-onboard-nr", (getprop("services/payload/first-onboard-nr") + getprop("services/payload/business-onboard-nr") + getprop("services/payload/economy-onboard-nr")));
            setprop("services/payload/pax-onboard-lbs", (getprop("services/payload/first-onboard-lbs") + getprop("services/payload/business-onboard-lbs") + getprop("services/payload/economy-onboard-lbs")));
            
            # Stop deboarding if all passengers have left the airplane.
            if (getprop("services/payload/pax-onboard-nr") < 1) {
                setprop("services/payload/pax-boarding", 0);
                setprop("services/payload/pax-force-deboard", 0);
                setprop("services/payload/boardingtime_remaining", " ");
                screen.log.write("Deboarding complete.", 0, 0.584, 1);
            }
            
        
        #Deboarding a few passengers when over the maximum loading weight. This enables the user to choose which passengers he wants to remove.
        
        } elsif (getprop("services/payload/pax-boarding") == 3) {			
            if (getprop("services/payload/first-request-nr") < getprop("services/payload/first-onboard-nr")) {
                setprop("services/payload/first-onboard-lbs", math.round(getprop("services/payload/first-onboard-lbs") - getprop("services/payload/first-onboard-lbs") / getprop("services/payload/first-onboard-nr")));
                setprop("services/payload/first-onboard-nr", getprop("services/payload/first-onboard-nr") - 1.0);
            } elsif (getprop("services/payload/business-request-nr") < getprop("services/payload/business-onboard-nr")) {
                setprop("services/payload/business-onboard-lbs", math.round(getprop("services/payload/business-onboard-lbs") - getprop("services/payload/business-onboard-lbs") / getprop("services/payload/business-onboard-nr")));
                setprop("services/payload/business-onboard-nr", getprop("services/payload/business-onboard-nr") - 1.0);
            } elsif (getprop("services/payload/economy-request-nr") < getprop("services/payload/economy-onboard-nr")) {
                setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-onboard-lbs") - getprop("services/payload/economy-onboard-lbs") / getprop("services/payload/economy-onboard-nr")));
                setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") - 1.0);
            } else {
                if (getprop("services/payload/weight-total-lbs") < (getprop("sim/weight[1]/max-lb") + getprop("sim/weight[0]/max-lb"))) {
                    setprop("services/payload/pax-boarding", 0);
                    setprop("services/payload/pax-force-deboard", 0);
                    screen.log.write("Captain, a few passengers have deboarded. We can safely travel now.", 0, 0.584, 1);
                } else {
                    setprop("services/payload/pax-boarding", 2);
                    setprop("services/payload/pax-force-deboard", 1);
                    screen.log.write("Captain, we still are not light enough, we will continue deboarding, please stop the deboarding process manually.", 1, 0, 0);
                }
            }
            
            setprop("services/payload/passenger-removed", 0);
            setprop("services/payload/pax-onboard-nr", (getprop("services/payload/first-onboard-nr") + getprop("services/payload/business-onboard-nr") + getprop("services/payload/economy-onboard-nr")));
            setprop("services/payload/pax-onboard-lbs", (getprop("services/payload/first-onboard-lbs") + getprop("services/payload/business-onboard-lbs") + getprop("services/payload/economy-onboard-lbs")));
        }
        
        #Baggage Loading
        
        #This works easier than boarding passengers. Between 50 and 250 Lbs is loaded/unloaded per baggage truck per cycle, averaging around 150 Lbs per cycle.
        
        if (getprop("services/payload/baggage-loading") == 1) {
            
            # Baggage Loading
            # Define loading speed based on the number of baggage trucks connected.
            setprop("services/payload/baggage-speed", math.round((getprop("services/payload/baggage-truck1-enable") + getprop("services/payload/baggage-truck2-enable")) * (50 + rand() * 200)));
            setprop("services/payload/loadingtime_remaining", "Est. " ~ math.round((getprop("services/payload/belly-request-lbs") - getprop("services/payload/belly-onboard-lbs")) / (150 * (getprop("services/payload/baggage-truck1-enable") + getprop("services/payload/baggage-truck2-enable"))) / 60 * getprop("services/payload/speed")) ~ " min remaining");
            if (getprop("services/payload/belly-onboard-lbs") < getprop("services/payload/belly-request-lbs")) {
                setprop("services/payload/belly-onboard-lbs", getprop("services/payload/belly-onboard-lbs") + getprop("/services/payload/baggage-speed"));
                if (getprop("services/payload/belly-onboard-lbs") >= getprop("services/payload/belly-request-lbs")) {
                    setprop("services/payload/belly-onboard-lbs", getprop("services/payload/belly-request-lbs"));
                    setprop("services/payload/baggage-loading", 0);
                    screen.log.write("Baggage loading complete.", 0, 0.584, 1);
                    setprop("services/payload/loadingtime_remaining", " ");
                }
            }
            
        } elsif (getprop("services/payload/baggage-loading") == 2) {
            #Define unloading speed based on the number of baggage trucks connected.
            setprop("services/payload/baggage-speed", math.round((getprop("services/payload/baggage-truck1-enable") + getprop("services/payload/baggage-truck2-enable")) * (50 + rand() * 200)));
            setprop("services/payload/loadingtime_remaining", "Est. " ~ math.round(getprop("services/payload/belly-onboard-lbs") / (150 * (getprop("services/payload/baggage-truck1-enable") + getprop("services/payload/baggage-truck2-enable"))) / 60 * getprop("services/payload/speed")) ~ " min remaining");
            #unload
            if (getprop("services/payload/belly-onboard-lbs") > 0) {
                if (getprop("services/payload/belly-onboard-lbs") <= getprop("services/payload/baggage-speed")) {
                    setprop("services/payload/belly-onboard-lbs", 0);
                    setprop("services/payload/baggage-loading", 0);
                    setprop("services/payload/loadingtime_remaining", " ");
                    screen.log.write("Baggage unloading complete.", 0, 0.584, 1);
                } else {
                    setprop("services/payload/belly-onboard-lbs", getprop("services/payload/belly-onboard-lbs") - getprop("services/payload/baggage-speed"))
                }
            }
        }
        
        
        # Catering Loading
        
        if (getprop("services/payload/catering-loading") == 1) {
        
            var prepgalley0trolley = 0;
            var prepgalley1trolley = 0;
            var prepgalley2trolley = 0;
            var prepgalley3trolley = 0;
            var prepgalleytotal = 0;
            
            # Catering trolley Loading preparation
            # Define how heavy the catering trolleys are. A standard trolley weighs about 33 Lbs empty (Wikipedia information) and we assume it can contain up to 67 Lbs of food and drinks.
            
            if (math.round((getprop("services/payload/catering-request-lbs") - getprop("services/payload/catering-onboard-lbs")) / 100) < ((getprop("services/payload/catering-request-lbs") - getprop("services/payload/catering-onboard-lbs")) / 100)) {
                prepgalleytotal = math.round((getprop("services/payload/catering-request-lbs") - getprop("services/payload/catering-onboard-lbs")) / 100) + 1.0;
            } else {
                prepgalleytotal = math.round((getprop("services/payload/catering-request-lbs") - getprop("services/payload/catering-onboard-lbs")) / 100);
            }
            setprop("services/payload/catering-trolley-lbs", (getprop("services/payload/catering-request-lbs") - getprop("services/payload/catering-onboard-lbs")) / prepgalleytotal);
            
            # Check if  the defined trolleys fit into the catering galleys, based on the number of catering truck connected (each galley has another capacity and is accessed by one defined catering truck)
            # After this check, the system will jump to the actual loading process by setting the catering-loading property to 3.
            
            if (getprop("services/catering/position")) {
                if (math.round((getprop("sim/weight[2]/max-lb") - getprop("sim/weight[2]/weight-lb")) / getprop("services/payload/catering-trolley-lbs")) < ((getprop("sim/weight[2]/max-lb") - getprop("sim/weight[2]/weight-lb")) / getprop("services/payload/catering-trolley-lbs"))) {
                    prepgalley0trolley = math.round((getprop("sim/weight[2]/max-lb") - getprop("sim/weight[2]/weight-lb")) / getprop("services/payload/catering-trolley-lbs"));
                    prepgalleytotal = prepgalleytotal - prepgalley0trolley;
                } else {
                    prepgalley0trolley = getprop("services/payload/catering-galley-0-trolley-nr") + math.round((getprop("sim/weight[2]/max-lb") - getprop("sim/weight[2]/weight-lb")) / getprop("services/payload/catering-trolley-lbs")) - 1.0;
                    prepgalleytotal = prepgalleytotal - prepgalley0trolley;
                }
            }
            if (getprop("services/catering/position1")) {
                if (math.round((getprop("sim/weight[2]/max-lb") - getprop("sim/weight[2]/weight-lb")) / getprop("services/payload/catering-trolley-lbs")) < ((getprop("sim/weight[2]/max-lb") - getprop("sim/weight[2]/weight-lb")) / getprop("services/payload/catering-trolley-lbs"))) {
                    prepgalley1trolley = math.round((getprop("sim/weight[2]/max-lb") - getprop("sim/weight[2]/weight-lb")) / getprop("services/payload/catering-trolley-lbs"));
                    prepgalleytotal = prepgalleytotal - prepgalley1trolley;
                } else {
                    prepgalley1trolley = getprop("services/payload/catering-galley-1-trolley-nr") + math.round((getprop("sim/weight[2]/max-lb") - getprop("sim/weight[2]/weight-lb")) / getprop("services/payload/catering-trolley-lbs")) - 1.0;
                    prepgalleytotal = prepgalleytotal - prepgalley1trolley;
                }
            }
            if (getprop("services/catering/position2")) {
                if (math.round((getprop("sim/weight[3]/max-lb") - getprop("sim/weight[3]/weight-lb")) / getprop("services/payload/catering-trolley-lbs")) < ((getprop("sim/weight[3]/max-lb") - getprop("sim/weight[3]/weight-lb")) / getprop("services/payload/catering-trolley-lbs"))) {
                    prepgalley2trolley = getprop("services/payload/catering-galley-1-trolley-nr") + math.round((getprop("sim/weight[3]/max-lb") - getprop("sim/weight[3]/weight-lb")) / getprop("services/payload/catering-trolley-lbs"));
                    prepgalleytotal = prepgalleytotal - prepgalley2trolley;
                } else {
                    prepgalley2trolley = getprop("services/payload/catering-galley-1-trolley-nr") + math.round((getprop("sim/weight[3]/max-lb") - getprop("sim/weight[3]/weight-lb")) / getprop("services/payload/catering-trolley-lbs")) - 1.0;
                    prepgalleytotal = prepgalleytotal - prepgalley2trolley;
                }
            }
            if (getprop("services/catering/position3")) {
                if (math.round((getprop("sim/weight[4]/max-lb") - getprop("sim/weight[4]/weight-lb")) / getprop("services/payload/catering-trolley-lbs")) < ((getprop("sim/weight[4]/max-lb") - getprop("sim/weight[4]/weight-lb")) / getprop("services/payload/catering-trolley-lbs"))) {
                    prepgalley3trolley = getprop("services/payload/catering-galley-1-trolley-nr") + math.round((getprop("sim/weight[4]/max-lb") - getprop("sim/weight[4]/weight-lb")) / getprop("services/payload/catering-trolley-lbs"));
                    prepgalleytotal = prepgalleytotal - prepgalley3trolley;
                } else {
                    prepgalley3trolley = getprop("services/payload/catering-galley-1-trolley-nr") + math.round((getprop("sim/weight[4]/max-lb") - getprop("sim/weight[4]/weight-lb")) / getprop("services/payload/catering-trolley-lbs")) - 1.0;
                    prepgalleytotal = prepgalleytotal - prepgalley3trolley;
                }
            }
            if (prepgalleytotal > 0) {
                if ((getprop("services/catering/position") + getprop("services/catering/position1") + getprop("services/catering/position2") + getprop("services/catering/position3")) < 4) {
                    setprop("services/payload/catering-loading", 0);
                    screen.log.write("Captain, we don't have enough space for " ~ prepgalleytotal ~ " trolleys of food and drinks. Please connect some more catering trucks, so we can use all the catering galleys.", 1, 0, 0);
                } else {
                    setprop("services/payload/catering-loading", 0);
                    screen.log.write("Captain, we don't have enough space for " ~ prepgalleytotal ~ " trolleys of food and drinks. Please reduce the amount of catering you wish to take on this flight.", 1, 0, 0);
                }
            } else {
                # The Cycle number and skipcycle-number are used to slowly load the catering in line with the time the baggage loading takes, for more realism. If the baggage is not loading, a trolley is loaded per catering truck every three cycles.
                
                setprop("services/payload/catering-cycle-nr", 0);
                if ((getprop("services/payload/baggage-loading") == 0) or (getprop("services/payload/belly-request-lbs") == 0)) {
                    setprop("services/payload/catering-skipcycle-nr", 3);
                } else {
                    if ((((getprop("services/payload/belly-request-lbs") - getprop("services/payload/belly-onboard-lbs")) / (150 * (getprop("services/payload/baggage-truck1-enable") + getprop("services/payload/baggage-truck2-enable")))) / (prepgalley0trolley + prepgalley1trolley + prepgalley2trolley + prepgalley3trolley)) < 4) {
                        setprop("services/payload/catering-skipcycle-nr", 3);
                    } else {
                        setprop("services/payload/catering-skipcycle-nr", ((getprop("services/payload/belly-request-lbs") - getprop("services/payload/belly-onboard-lbs")) / (150 * (getprop("services/payload/baggage-truck1-enable") + getprop("services/payload/baggage-truck2-enable")))) / (prepgalley0trolley + prepgalley1trolley + prepgalley2trolley + prepgalley3trolley));
                        
                        setprop("services/payload/catering-skipcycle-nr", math.round(getprop("services/payload/catering-skipcycle-nr")));
                    }
                }
                
                # Ready to proceed to the actual catering loading process.
                setprop("services/payload/catering-loading", 4);
            }			
        } elsif (getprop("services/payload/catering-loading") == 2) {
            
            # Catering trolley unloading preparation
            
            setprop("services/payload/catering-cycle-nr", 0);
            setprop("services/payload/catering-skipcycle-nr", 3);
            setprop("services/payload/catering-trolley-lbs", getprop("services/payload/catering-onboard-lbs") / getprop("services/payload/catering-trolley-nr"));
            if (getprop("services/payload/catering-onboard-lbs") <= 0) {
                setprop("services/payload/catering-loading", 0);
                screen.log.write("Captain, the catering galleys are empty, we can not unload the catering trolleys.", 1, 0, 0);
            } else {
                setprop("services/payload/catering-loading", 4);
            }
            
        } elsif (getprop("services/payload/catering-loading") == 3) {
            # Catering trolley loading process after preparation.
            setprop("services/payload/catering-cycle-nr", getprop("services/payload/catering-cycle-nr") + 1);
            
            if ((getprop("services/catering/position1") != 1) and (getprop("services/catering/position2") != 1) and (getprop("services/catering/position3") != 1)) {
                setprop("services/payload/catering-loading", 0);
                screen.log.write("Captain, the catering trucks are disconnected, we cannot continue loading the catering trolleys.", 1, 0, 0);
            }
            
            # Catering Truck 
            if (getprop("services/payload/catering-request-lbs") > getprop("services/payload/catering-onboard-lbs")) {
                if ((getprop("services/catering/position") == 1) and ((getprop("services/payload/catering-cycle-nr") / getprop("services/payload/catering-skipcycle-nr")) == math.round(getprop("services/payload/catering-cycle-nr") / getprop("services/payload/catering-skipcycle-nr")))) {
                    if ((getprop("sim/weight[2]/weight-lb") + getprop("services/payload/catering-trolley-lbs")) < getprop("sim/weight[2]/max-lb")) {
                        setprop("services/payload/catering-galley-0-full", 0);
                        setprop("services/payload/catering-galley-0-trolley-nr", getprop("services/payload/catering-galley-0-trolley-nr") + 1.0);
                        setprop("services/payload/catering-trolley-nr", getprop("services/payload/catering-trolley-nr") + 1.0);
                        setprop("sim/weight[2]/weight-lb", sprintf("%i",getprop("sim/weight[2]/weight-lb") + getprop("services/payload/catering-trolley-lbs")));
                        setprop("services/payload/catering-onboard-lbs", sprintf("%i",getprop("sim/weight[2]/weight-lb") + getprop("sim/weight[3]/weight-lb") + getprop("sim/weight[4]/weight-lb")));
                    } else {
                        setprop("services/payload/catering-galley-0-full", 1);
                        if ((getprop("services/payload/catering-galley-0-full") + getprop("services/payload/catering-galley-1-full") + getprop("services/payload/catering-galley-2-full") + getprop("services/payload/catering-galley-3-full")) == 4) {
                            if (getprop("services/payload/catering-onboard-lbs") < getprop("services/payload/catering-request-lbs")) {
                                setprop("services/payload/catering-loading", 0);
                                screen.log.write("Captain, it seems something went wrong with the catering trucks, the loading process is stopped because the available galleys are full.", 1, 0, 0);
                            }
                        }
                    }
                }
            }
            
            # Catering Truck 1
            if (getprop("services/payload/catering-request-lbs") > getprop("services/payload/catering-onboard-lbs")) {
                if ((getprop("services/catering/position1") == 1) and ((getprop("services/payload/catering-cycle-nr") / getprop("services/payload/catering-skipcycle-nr")) == math.round(getprop("services/payload/catering-cycle-nr") / getprop("services/payload/catering-skipcycle-nr")))) {
                    if ((getprop("sim/weight[2]/weight-lb") + getprop("services/payload/catering-trolley-lbs")) < getprop("sim/weight[2]/max-lb")) {
                        setprop("services/payload/catering-galley-1-full", 0);
                        setprop("services/payload/catering-galley-1-trolley-nr", getprop("services/payload/catering-galley-1-trolley-nr") + 1.0);
                        setprop("services/payload/catering-trolley-nr", getprop("services/payload/catering-trolley-nr") + 1.0);
                        setprop("sim/weight[2]/weight-lb", sprintf("%i",getprop("sim/weight[2]/weight-lb") + getprop("services/payload/catering-trolley-lbs")));
                        setprop("services/payload/catering-onboard-lbs", sprintf("%i",getprop("sim/weight[2]/weight-lb") + getprop("sim/weight[3]/weight-lb") + getprop("sim/weight[4]/weight-lb")));
                    } else {
                        setprop("services/payload/catering-galley-1-full", 1);
                        if ((getprop("services/payload/catering-galley-0-full") + getprop("services/payload/catering-galley-1-full") + getprop("services/payload/catering-galley-2-full") + getprop("services/payload/catering-galley-3-full")) == 4) {
                            if (getprop("services/payload/catering-onboard-lbs") < getprop("services/payload/catering-request-lbs")) {
                                setprop("services/payload/catering-loading", 0);
                                screen.log.write("Captain, it seems something went wrong with the catering trucks, the loading process is stopped because the available galleys are full.", 1, 0, 0);
                            }
                        }
                    }
                }
            }
            
            # Catering Truck 2
            if (getprop("services/payload/catering-request-lbs") > getprop("services/payload/catering-onboard-lbs")) {
                if ((getprop("services/catering/position2") == 1) and (((getprop("services/payload/catering-cycle-nr") + 1) / getprop("services/payload/catering-skipcycle-nr")) == math.round((getprop("services/payload/catering-cycle-nr") + 1) / getprop("services/payload/catering-skipcycle-nr")))) {
                    if ((getprop("sim/weight[3]/weight-lb") + getprop("services/payload/catering-trolley-lbs")) < getprop("sim/weight[3]/max-lb")) {
                        setprop("services/payload/catering-galley-2-full", 0);
                        setprop("services/payload/catering-galley-2-trolley-nr", getprop("services/payload/catering-galley-2-trolley-nr") + 1.0);
                        setprop("services/payload/catering-trolley-nr", getprop("services/payload/catering-trolley-nr") + 1.0);
                        setprop("sim/weight[3]/weight-lb", sprintf("%i",getprop("sim/weight[3]/weight-lb") + getprop("services/payload/catering-trolley-lbs")));
                        setprop("services/payload/catering-onboard-lbs", sprintf("%i",getprop("sim/weight[2]/weight-lb") + getprop("sim/weight[3]/weight-lb") + getprop("sim/weight[4]/weight-lb")));
                    } else {
                        setprop("services/payload/catering-galley-2-full", 1);
                        if ((getprop("services/payload/catering-galley-0-full") + getprop("services/payload/catering-galley-1-full") + getprop("services/payload/catering-galley-2-full") + getprop("services/payload/catering-galley-3-full")) == 4) {
                            if (getprop("services/payload/catering-onboard-lbs") < getprop("services/payload/catering-request-lbs")) {
                                setprop("services/payload/catering-loading", 0);
                                screen.log.write("Captain, it seems something went wrong with the catering trucks, the loading process is stopped because the available galleys are full.", 1, 0, 0);
                            }
                        }
                    }
                }
            }
            
            # Catering Truck 3
            if (getprop("services/payload/catering-request-lbs") > getprop("services/payload/catering-onboard-lbs")) {
                if ((getprop("services/catering/position3") == 1) and (((getprop("services/payload/catering-cycle-nr") + 2) / getprop("services/payload/catering-skipcycle-nr")) == math.round((getprop("services/payload/catering-cycle-nr") + 2) / getprop("services/payload/catering-skipcycle-nr")))) {
                    if ((getprop("sim/weight[4]/weight-lb") + getprop("services/payload/catering-trolley-lbs")) < getprop("sim/weight[4]/max-lb")) {
                        setprop("services/payload/catering-galley-3-full", 0);
                        setprop("services/payload/catering-galley-3-trolley-nr", getprop("services/payload/catering-galley-3-trolley-nr") + 1.0);
                        setprop("services/payload/catering-trolley-nr", getprop("services/payload/catering-trolley-nr") + 1.0);
                        setprop("sim/weight[4]/weight-lb", sprintf("%i",getprop("sim/weight[4]/weight-lb") + getprop("services/payload/catering-trolley-lbs")));
                        setprop("services/payload/catering-onboard-lbs", sprintf("%i",getprop("sim/weight[2]/weight-lb") + getprop("sim/weight[3]/weight-lb") + getprop("sim/weight[4]/weight-lb")));
                    } else {
                        setprop("services/payload/catering-galley-3-full", 1);
                        if ((getprop("services/payload/catering-galley-0-full") + getprop("services/payload/catering-galley-1-full") + getprop("services/payload/catering-galley-2-full") + getprop("services/payload/catering-galley-3-full")) == 4) {
                            if (getprop("services/payload/catering-onboard-lbs") < getprop("services/payload/catering-request-lbs")) {
                                setprop("services/payload/catering-loading", 0);
                                screen.log.write("Captain, it seems something went wrong with the catering trucks, the loading process is stopped because the available galleys are full.", 1, 0, 0);
                            }
                        }
                    }
                }
            }		
            
            # Check if the catering process has finished
            if (getprop("services/payload/catering-onboard-lbs") >= getprop("services/payload/catering-request-lbs")) {
                setprop("services/payload/catering-loading", 0);
                screen.log.write("Catering loading process finished. Please disconnect the catering trucks.", 0, 0.584, 1);
            }
         } elsif (getprop("services/payload/catering-loading") == 4) {
        
            # Catering unloading process
            
            setprop("services/payload/catering-cycle-nr", getprop("services/payload/catering-cycle-nr") + 1.0);
             
            # Catering Truck 
            if (getprop("sim/weight[2]/weight-lb") > 0) {
                if ((getprop("services/catering/position") == 1) and (getprop("services/payload/catering-galley-0-trolley-nr") != 0)) {
                    if ((getprop("services/payload/catering-cycle-nr") / getprop("services/payload/catering-skipcycle-nr")) == math.round(getprop("services/payload/catering-cycle-nr") / getprop("services/payload/catering-skipcycle-nr"))) {
                        setprop("services/payload/catering-onboard-lbs", sprintf("%i",getprop("services/payload/catering-onboard-lbs") - getprop("services/payload/catering-trolley-lbs")));
                        setprop("sim/weight[2]/weight-lb", sprintf("%i",getprop("sim/weight[2]/weight-lb") - getprop("services/payload/catering-trolley-lbs")));
                        setprop("services/payload/catering-galley-0-trolley-nr", getprop("services/payload/catering-galley-0-trolley-nr") - 1.0);
                    }
                } elsif (getprop("services/catering/position") != 1) {
                    setprop("services/payload/catering-loading", 0);
                    screen.log.write("Captain, catering galley 0 is not empty, but there is no catering truck connected to it. Please connect a catering truck before you start unloading.", 1, 0, 0);
                }
            } 
                
            # Catering Truck 1
            if (getprop("sim/weight[2]/weight-lb") > 0) {
                if ((getprop("services/catering/position1") == 1) and (getprop("services/payload/catering-galley-1-trolley-nr") != 0)) {
                    if ((getprop("services/payload/catering-cycle-nr") / getprop("services/payload/catering-skipcycle-nr")) == math.round(getprop("services/payload/catering-cycle-nr") / getprop("services/payload/catering-skipcycle-nr"))) {
                        setprop("services/payload/catering-onboard-lbs", sprintf("%i",getprop("services/payload/catering-onboard-lbs") - getprop("services/payload/catering-trolley-lbs")));
                        setprop("sim/weight[2]/weight-lb", sprintf("%i",getprop("sim/weight[2]/weight-lb") - getprop("services/payload/catering-trolley-lbs")));
                        setprop("services/payload/catering-galley-1-trolley-nr", getprop("services/payload/catering-galley-1-trolley-nr") - 1.0);
                    }
                } elsif (getprop("services/catering/position1") != 1) {
                    setprop("services/payload/catering-loading", 0);
                    screen.log.write("Captain, catering galley 1 is not empty, but there is no catering truck connected to it. Please connect a catering truck before you start unloading.", 1, 0, 0);
                }
            }
            
            # Catering Truck 2
            if (getprop("sim/weight[3]/weight-lb") > 0) {
                if ((getprop("services/catering/position2") == 1) and (getprop("services/payload/catering-galley-2-trolley-nr") != 0)) {
                    if (((getprop("services/payload/catering-cycle-nr") + 1) / getprop("services/payload/catering-skipcycle-nr")) == math.round((getprop("services/payload/catering-cycle-nr") + 1) / getprop("services/payload/catering-skipcycle-nr"))) {
                        setprop("services/payload/catering-onboard-lbs", sprintf("%i",getprop("services/payload/catering-onboard-lbs") - getprop("services/payload/catering-trolley-lbs")));
                        setprop("sim/weight[3]/weight-lb", sprintf("%i",getprop("sim/weight[3]/weight-lb") - getprop("services/payload/catering-trolley-lbs")));
                        setprop("services/payload/catering-galley-2-trolley-nr", getprop("services/payload/catering-galley-2-trolley-nr") - 1.0);
                    }
                } elsif (getprop("services/catering/position2") != 1) {
                    setprop("services/payload/catering-loading", 0);
                    screen.log.write("Captain, catering galley 2 is not empty, but there is no catering truck connected to it. Please connect a catering truck before you start unloading.", 1, 0, 0);
                }
            }
            
            # Catering Truck 3
            if (getprop("sim/weight[4]/weight-lb") > 0) {
                if ((getprop("services/catering/position3") == 1) and (getprop("services/payload/catering-galley-3-trolley-nr") != 0)) {
                    if (((getprop("services/payload/catering-cycle-nr") + 2) / getprop("services/payload/catering-skipcycle-nr")) == math.round((getprop("services/payload/catering-cycle-nr") + 2) / getprop("services/payload/catering-skipcycle-nr"))) {
                        setprop("services/payload/catering-onboard-lbs", sprintf("%i",getprop("services/payload/catering-onboard-lbs") - getprop("services/payload/catering-trolley-lbs")));
                        setprop("sim/weight[4]/weight-lb", sprintf("%i",getprop("sim/weight[4]/weight-lb") - getprop("services/payload/catering-trolley-lbs")));
                        setprop("services/payload/catering-galley-3-trolley-nr", getprop("services/payload/catering-galley-3-trolley-nr") - 1.0);
                    }
                } elsif (getprop("services/catering/position3") != 1) {
                    setprop("services/payload/catering-loading", 0);
                    screen.log.write("Captain, catering galley 3 is not empty, but there is no catering truck connected to it. Please connect a catering truck before you start unloading.", 1, 0, 0);
                }
            }
            
            # Check if the catering unloading process has finished.
            if (getprop("services/payload/catering-onboard-lbs") < 100) {
                setprop("services/payload/catering-loading", 0);
                setprop("services/payload/catering-onboard-lbs", 0);
                setprop("sim/weight[2]/weight-lb", 0);
                setprop("sim/weight[3]/weight-lb", 0);
                setprop("sim/weight[4]/weight-lb", 0);
                setprop("services/payload/catering-trolley-lbs", 0);
                setprop("services/payload/catering-trolley-nr", 0);
                setprop("services/payload/catering-galley-0-trolley-nr", 0);
                setprop("services/payload/catering-galley-1-trolley-nr", 0);
                setprop("services/payload/catering-galley-2-trolley-nr", 0);
                setprop("services/payload/catering-galley-3-trolley-nr", 0);
                screen.log.write("Captain, the catering galleys are empty, we can now start refilling them or disconnect the catering trucks.", 0, 0.584, 1);
            }
        }
        
        
        #Crew
        
        #We're assuming an average crew member weighs 137 Lbs, as does the average human, and has 13 lbs of luggage with him/her.
        #Changes are applied immediatly because doing this via a procedure is overkill.
        
        if (getprop("services/payload/crew-onboard-nr") != getprop("services/payload/crew-request-nr")) {
            setprop("services/payload/crew-onboard-nr", getprop("services/payload/crew-request-nr"));
            setprop("services/payload/crew-onboard-lbs", getprop("services/payload/crew-onboard-nr") * 150);
        }
        
        # Write to weight properties, but check if we are not overloading first.
        
        setprop("services/payload/weight-total-lbs", getprop("services/payload/pax-onboard-lbs") + getprop("services/payload/belly-onboard-lbs") + getprop("services/payload/crew-onboard-lbs") + getprop("services/payload/catering-onboard-lbs"));
        if ((getprop("services/payload/weight-total-lbs") >= getprop("sim/weight[1]/max-lb")) and ((getprop("services/payload/baggage-loading") == 1) or (getprop("services/payload/pax-boarding") == 1))) {
            setprop("services/payload/baggage-loading", 0);
            setprop("services/payload/pax-boarding", 0);
            screen.log.write("Captain, we are overloading the aircraft. Please reduce the number of passengers or cargo on board. Boarding & loading stopped.", 1, 0, 0);
        }
        
        setprop("services/payload/expected-weight-lbs", getprop("services/payload/belly-request-lbs") + getprop("services/payload/catering-request-lbs") + getprop("services/payload/first-request-nr") * 247 + getprop("services/payload/business-request-nr") * 225 + getprop("services/payload/economy-request-nr") * 170 + getprop("services/payload/crew-request-nr") * 150);
        setprop("sim/weight[1]/weight-lb", getprop("services/payload/pax-onboard-lbs") + getprop("services/payload/belly-onboard-lbs"));
        setprop("sim/weight/weight-lb", getprop("services/payload/crew-onboard-lbs"));
        setprop("services/payload/SOB-nr", (getprop("services/payload/pax-onboard-nr") + getprop("services/payload/crew-onboard-nr")));

    },
};

var _timer = maketimer(6.0, func{payload_boarding.update()});

var _startstop = func() {
    if (getprop("gear/gear[0]/wow") == 1) {
        _timer.start();
    } else {
        _timer.stop();
    }
}

var _adjustspeed = func() {
    if (_timer.isRunning) {
        if (getprop("services/payload/speed") == 0) {
            if (getprop("services/payload/pax-boarding") == 1) {
                setprop("services/payload/first-onboard-nr", getprop("services/payload/first-request-nr"));
                setprop("services/payload/first-onboard-lbs", math.round(getprop("services/payload/first-request-nr") * 247));
                setprop("services/payload/business-onboard-nr", getprop("services/payload/business-request-nr"));
                setprop("services/payload/business-onboard-lbs", math.round(getprop("services/payload/business-request-nr") * 225));
                setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-request-nr"));
                setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-request-nr") * 170));
            } elsif (getprop("services/payload/pax-boarding") == 2) {
                setprop("services/payload/first-onboard-nr", 0);
                setprop("services/payload/first-onboard-lbs", 0);
                setprop("services/payload/business-onboard-nr", 0);
                setprop("services/payload/business-onboard-lbs", 0);
                setprop("services/payload/economy-onboard-nr", 0);
                setprop("services/payload/economy-onboard-lbs", 0);
            }
            
            if (getprop("services/payload/baggage-loading") == 1) {
                setprop("services/payload/belly-onboard-lbs", getprop("services/payload/belly-request-lbs") - 1.0);
            } elsif (getprop("services/payload/baggage-loading") == 2) {
                setprop("services/payload/belly-onboard-lbs", 0);
            }
            
            if (getprop("services/payload/catering-loading") == 1 or (getprop("services/payload/catering-loading") == 3)) {
                if (getprop("services/payload/catering-request-lbs") < getprop("sim/weight[2]/max-lb")) {
                    setprop("sim/weight[2]/weight-lb", sprintf("%i",getprop("services/payload/catering-request-lbs")));
                } else {
                    setprop("sim/weight[2]/weight-lb", sprintf("%i",getprop("sim/weight[2]/max-lb")));
                }
                setprop("services/payload/catering-galley-1-trolley-nr", math.round(getprop("sim/weight[2]/weight-lb") / 100));
                setprop("services/payload/catering-trolley-lbs", getprop("sim/weight[2]/weight-lb") / getprop("services/payload/catering-galley-1-trolley-nr"));
                setprop("services/payload/catering-trolley-nr", getprop("services/payload/catering-galley-1-trolley-nr"));
                setprop("services/payload/catering-onboard-lbs", sprintf("%i",getprop("sim/weight[2]/weight-lb")));
                
                if (getprop("services/payload/catering-onboard-lbs") < getprop("services/payload/catering-request-lbs")) {
                    if ((getprop("services/payload/catering-request-lbs") - getprop("services/payload/catering-onboard-lbs")) < getprop("sim/weight[3]/max-lb")) {
                        setprop("sim/weight[3]/weight-lb", sprintf("%i",getprop("services/payload/catering-request-lbs") - getprop("services/payload/catering-onboard-lbs")));
                    } else {
                        setprop("sim/weight[3]/weight-lb", sprintf("%i",getprop("sim/weight[3]/max-lb")));
                    }
                    setprop("services/payload/catering-onboard-lbs", sprintf("%i",getprop("services/payload/catering-onboard-lbs") + getprop("sim/weight[3]/weight-lb")));
                    setprop("services/payload/catering-galley-2-trolley-nr", math.round(getprop("sim/weight[3]/weight-lb") / getprop("services/payload/catering-trolley-lbs")));
                    setprop("services/payload/catering-trolley-nr", getprop("services/payload/catering-trolley-nr") + getprop("services/payload/catering-galley-2-trolley-nr"));
                }
                
                if (getprop("services/payload/catering-onboard-lbs") < getprop("services/payload/catering-request-lbs")) {
                    if ((getprop("services/payload/catering-request-lbs") - getprop("services/payload/catering-onboard-lbs")) < getprop("sim/weight[4]/max-lb")) {
                        setprop("sim/weight[4]/weight-lb", sprintf("%i",getprop("services/payload/catering-request-lbs") - getprop("services/payload/catering-onboard-lbs")));
                    } else {
                        setprop("sim/weight[4]/weight-lb", sprintf("%i",getprop("sim/weight[4]/max-lb")));
                    }
                    setprop("services/payload/catering-onboard-lbs", sprintf("%i",getprop("services/payload/catering-onboard-lbs") + getprop("sim/weight[4]/weight-lb")));
                    setprop("services/payload/catering-galley-3-trolley-nr", math.round(getprop("sim/weight[4]/weight-lb") / getprop("services/payload/catering-trolley-lbs")));
                    setprop("services/payload/catering-trolley-nr", getprop("services/payload/catering-trolley-nr") + getprop("services/payload/catering-galley-3-trolley-nr"));
                }
                screen.log.write("Captain, catering loading completed.", 0, 0.584, 1);
            } elsif (getprop("services/payload/catering-loading") == 2 or (getprop("services/payload/catering-loading") == 4)) {
                setprop("sim/weight[2]/weight-lb", 0);
                setprop("sim/weight[3]/weight-lb", 0);
                setprop("sim/weight[4]/weight-lb", 0);
                setprop("services/payload/catering-onboard-lbs", 0);
                setprop("services/payload/catering-trolley-nr", 0);
                setprop("services/payload/catering-trolley-lbs", 0);
                setprop("services/payload/catering-galley-0-trolley-nr", 0);
                setprop("services/payload/catering-galley-1-trolley-nr", 0);
                setprop("services/payload/catering-galley-2-trolley-nr", 0);
                setprop("services/payload/catering-galley-3-trolley-nr", 0);
                screen.log.write("Captain, catering unloading completed.", 0, 0.584, 1);
            }
                
        setprop("services/payload/speed", 6.0); #Reset the speed to normal.
        setprop("services/payload/speed-text", "Normal");
        } else {
            _timer.restart(getprop("services/payload/speed"));
        }
    }
}

setlistener("sim/signals/fdm-initialized", func {
    payload_boarding.init();
    print("Payload system ..... Initialized");
});

setlistener("gear/gear[0]/wow", func {_startstop()});

setlistener("services/payload/speed", func{_adjustspeed()});
