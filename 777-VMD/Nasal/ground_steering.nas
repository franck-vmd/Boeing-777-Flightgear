# Nose gear can be rotated 70 degrees left or right with the tiller.
var NOSE_GEAR_MAX_ANGLE_DEG = 70.0;

# Nose gear is only rotated 7 degrees left or right by use of rudder pedals..and tiller overrides rudder.
var NOSE_GEAR_MAX_ANGLE_WITH_RUDDER_DEG = 7.0;

# Minimum amount that nose gear angle must exceed before main gear steering starts working.
var NOSE_GEAR_MIN_ANGLE_TO_ENABLE_MAIN_GEAR_STEERING_DEG = 13.0;

# Main gear steering angle is 8 degrees left or right. (not verified)
var MAIN_GEAR_MAX_ANGLE_DEG = 8.0;


var GroundSteeringManager = {

	new: func()
	{
		var m = { parents: [GroundSteeringManager] };
		m.rudder_node = props.globals.getNode("controls/flight/rudder", 1);
		m.tiller_node = props.globals.getNode("controls/gear/tiller-cmd-norm", 1);
		m.nosegear_steering_node = props.globals.getNode("controls/gear/nosegear-steering-cmd", 1);
		m.maingear_steering_node = props.globals.getNode("controls/gear/maingear-steering-cmd", 1);
		m.tiller_switch = props.globals.getNode("controls/gear/tiller-enabled", 1);
		return m;
	},

	update: func()
	{
		var rudder_cmd_norm = me.rudder_node.getValue();
		var tiller_cmd_norm = me.tiller_node.getValue();
		var nosegear_steering_cmd_norm = 0.0;
		var maingear_steering_cmd_norm = 0.0;
		if(getprop("position/altitude-agl-ft") < 50)
		{
            var v_tiller_by_rudder = rudder_cmd_norm * (NOSE_GEAR_MAX_ANGLE_WITH_RUDDER_DEG / NOSE_GEAR_MAX_ANGLE_DEG);

			if (!me.tiller_switch.getValue()
					and (getprop("velocities/groundspeed-kt") < 50)
                    and (abs(tiller_cmd_norm) < 0.01))
				tiller_cmd_norm = rudder_cmd_norm;

            if (abs(tiller_cmd_norm) > 0.01) {
				nosegear_steering_cmd_norm = tiller_cmd_norm;
				var angle_degrees = tiller_cmd_norm * NOSE_GEAR_MAX_ANGLE_DEG;
				if (abs(angle_degrees) > NOSE_GEAR_MIN_ANGLE_TO_ENABLE_MAIN_GEAR_STEERING_DEG) {
					maingear_steering_cmd_norm = ((abs(angle_degrees) - NOSE_GEAR_MIN_ANGLE_TO_ENABLE_MAIN_GEAR_STEERING_DEG)
										/ (NOSE_GEAR_MAX_ANGLE_DEG - NOSE_GEAR_MIN_ANGLE_TO_ENABLE_MAIN_GEAR_STEERING_DEG));
					# opposite turning angle on rear gear
					if (tiller_cmd_norm > 0)
						maingear_steering_cmd_norm = -maingear_steering_cmd_norm;
				}
			}
			else
			{
				# limit to factor maximum angle with rudder
				nosegear_steering_cmd_norm = v_tiller_by_rudder;
			}
		}

		me.nosegear_steering_node.setDoubleValue(nosegear_steering_cmd_norm);
		me.maingear_steering_node.setDoubleValue(maingear_steering_cmd_norm);
	}
};

var manager = GroundSteeringManager.new();
setlistener("controls/gear/tiller-cmd-norm", func { manager.update(); }, 0, 0);
setlistener("controls/flight/rudder", func { manager.update(); }, 0, 0);
