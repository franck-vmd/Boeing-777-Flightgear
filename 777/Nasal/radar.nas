# ================================== EHSI Stuff ===================================

props.globals.initNode("/instrumentation/display-unit/control", 1, "INT");
props.globals.initNode("/instrumentation/radar/mode-control", 1, "INT");

var range_control_node = props.globals.initNode("/instrumentation/radar/range-control", 3, "INT");
var range_node = props.globals.initNode("/instrumentation/radar/range", 40, "INT");
var wx_range_node = props.globals.initNode("/instrumentation/wxradar/range", 40, "INT");
var x_shift_node = props.globals.initNode("instrumentation/tacan/display/x-shift");
var x_shift_scaled_node = props.globals.initNode("instrumentation/tacan/display/x-shift-scaled");
var y_shift_node = props.globals.initNode("instrumentation/tacan/display/y-shift");
var y_shift_scaled_node = props.globals.initNode("instrumentation/tacan/display/y-shift-scaled");

var pow2 = func(e) bits.bit[e];  # 2^e
var scale = 2.55;


setlistener(range_control_node, func(n) {
	var range_control = n.getValue();
	var range = 5 * pow2(range_control);

	range_node.setIntValue(range);
	wx_range_node.setIntValue(range);
	scale = sprintf("%2.3f", 1.275 * pow2(7 - range_control) * 0.1275) ~ "";
	# printf("scale=%s  range=%d", scale, range);
}, 1);


var scaleShift = func {
	x_shift_scaled_node.setDoubleValue(var x = x_shift_node.getValue() * scale);
	y_shift_scaled_node.setDoubleValue(var y = y_shift_node.getValue() * scale);
	# printf("(x,y)-shift-scaled=(%.3f, %.3f)", x, y);
	settimer(scaleShift, 0.3);
}


scaleShift();


setlistener("/instrumentation/radar/mode-control", func(n) {
	setprop("/instrumentation/radar/display-mode", n.getValue() == 2 ? "map" : "plan");
}, 1);

