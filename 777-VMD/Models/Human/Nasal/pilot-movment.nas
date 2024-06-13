# Basic Control for the Pilot and Copilot Model


var looptime = 0.05;


var gload = props.globals.getNode("accelerations/pilot-g");

var aileron = props.globals.getNode("controls/flight/aileron");
var elevator = props.globals.getNode("controls/flight/elevator");

var idle_z = 0;
var idle_y = 0;


var init = func {
		print ("Pilot movement initialized");		
		var idle_z = getprop (head_z);
		
  settimer(main_loop, looptime);
}
var main_loop = func {

		var h_z = idle_z + aileron.getValue()*30;
		setprop (head_z, h_z);
		var h_y = idle_y + elevator.getValue()*15;
		setprop (head_y, h_y);

  	settimer(main_loop, looptime);
}

setlistener("/sim/signals/fdm-initialized",init);

#var pilot_theme_dialog = gui.OverlaySelector.new("Select Theme", "Aircraft/777-VMD/Models/Human/Models/Themes", "sim/model/crew/" ~ num ~ "/theme-name", nil, "sim/multiplay/generic/string[11]");
