var seatbeltNode = props.getNode("/controls/cabin/SeatBelt-status", 1);
var nosmokingNode = props.getNode("/controls/cabin/NoSmoking-status", 1);
var seatbeltKnobNode = props.getNode("/controls/cabin/SeatBelt-knob", 1);
var nosmokingKnobNode = props.getNode("/controls/cabin/NoSmoking-knob", 1);

#//Initialize with seatbelts sign off, no smoking sign on
seatbeltKnobNode.setValue(-1);
seatbeltNode.setValue(-1);
nosmokingKnobNode.setValue(1);
nosmokingNode.setValue(1);

props.getNode("/controls/cabin/altitude-limit-ft", 1).setValue(10300); #//Depends on airline, default to be 10300 ft for now - Sidi Liang

var cabinAlertUpdate = func(){
    var indAltFt = props.getNode("/instrumentation/altimeter/indicated-altitude-ft", 1).getValue();
    var flapStatus = props.getNode("/controls/flight/flaps", 1).getValue(); 
    var gearStatus = props.getNode("/controls/gear/gear-down", 1).getValue();
    var altLimit = props.getNode("/controls/cabin/altitude-limit-ft", 1).getValue();
    #//To do: turn on both cabin alerts when cabin altitude is greater then 10000ft or passinger oxygen is on, according to FCOM - Sidi Liang

    if(seatbeltKnobNode.getValue() == 0){ #//Knob in Auto Position 
        if((indAltFt < altLimit) or (!flapStatus==0) or (gearStatus == 1)){
            seatbeltNode.setValue(1);
        }else{
            seatbeltNode.setValue(-1);
        }
    }
    if(nosmokingKnobNode.getValue() == 0){ #//Knob in Auto Position
        if(gearStatus == 1){
            nosmokingNode.setValue(1);
        }else{
           nosmokingNode.setValue(-1);
        }
    }
}

var cabinAlertTimer = maketimer(1, cabinAlertUpdate);

var cabinAlertStartup = func{
    cabinAlertTimer.start();
}

var warning_messages = func {
	if (getprop("systems/pressurization/cabin-altitude-ft") > 10000)
		append(msgs_warning,"CABIN ALTITUDE");

#	if (getprop("controls/pressurization/valve-manual[0]") and getprop("controls/pressurization/valve-manual[1]"))
#		append(msgs_caution,"CABIN ALT AUTO");
}

var caution_messages = func {
	if (getprop("controls/pressurization/valve-manual[0]") and getprop("controls/pressurization/valve-manual[1]"))
		append(msgs_caution,"CABIN ALT AUTO");
}
		
var advisory_messages = func {		
if (getprop("systems/pressurization/relief-valve"))
		append(msgs_advisory," PRESS RELIEF");
	if (getprop("controls/pressurization/valve-manual[0]") and getprop("controls/pressurization/valve-manual[1]"))
		append(msgs_advisory," OUTFLOW VLV L, R");
	if (getprop("controls/pressurization/valve-manual[0]") and !getprop("controls/pressurization/valve-manual[1]"))
		append(msgs_advisory," OUTFLOW VLV L");
	if (!getprop("controls/pressurization/valve-manual[0]") and getprop("controls/pressurization/valve-manual[1]"))
		append(msgs_advisory," OUTFLOW VLV R");
	if (getprop("systems/pressurization/mode") == 2 and (!getprop("autopilot/route-manager/active") or getprop("autopilot/route-manager/destination/airport") == "") and !getprop("controls/pressurization/landing-alt-manual"))
		append(msgs_advisory," LANDING ALT");
}

var seatbeltTrigger = func(){
    if(seatbeltKnobNode.getValue() == 0){ #//Knob in Auto Position 
        cabinAlertTimer.start();
    }else{
        if(cabinAlertTimer.isRunning) cabinAlertTimer.stop();
        seatbeltNode.setValue(seatbeltKnobNode.getValue());
    }
}

var nosmokingTrigger = func(){
    if(nosmokingKnobNode.getValue() == 0){ #//Knob in Auto Position 
        cabinAlertTimer.start();
    }else{
        if(cabinAlertTimer.isRunning) cabinAlertTimer.stop();
        nosmokingNode.setValue(nosmokingKnobNode.getValue());
    }
}

var seatbeltListener = setlistener("/controls/cabin/SeatBelt-knob", seatbeltTrigger, 1, 0);
var nosmokingListener = setlistener("/controls/cabin/NoSmoking-knob", nosmokingTrigger, 1, 0);
