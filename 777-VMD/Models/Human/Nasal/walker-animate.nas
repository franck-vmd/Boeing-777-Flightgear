# == walker animation v1.4 for FlightGear version 1.9 with OSG ==

var walker1_node = props.globals.getNode("sim/model/walker[1]", 1);
var w1_animate_node = props.globals.getNode("sim/model/walker[1]/animate", 1);
var w1_loop_enabled_node = props.globals.getNode("sim/model/walker[1]/loop-enabled", 1);
var w1a_enabled_current_node = props.globals.getNode("sim/model/walker[1]/animate/enabled-current", 1);
var w1a_dialog_position_node = props.globals.getNode("sim/model/walker[1]/animate/dialog-position", 1);
var w1a_list_node = props.globals.getNode("sim/model/walker[1]/animate/list", 1);
var w1a_sequence_selected_node = props.globals.getNode("sim/model/walker[1]/animate/sequence-selected", 1);
var sequence_node = w1a_list_node.getNode("sequence[" ~ w1a_sequence_selected_node.getValue() ~ "]", 1);
var triggered_seq_node = nil;
var trigger_standing_node = props.globals.getNode("sim/model/walker[1]/animate/triggers/standing", 1);
var trigger_walking_node = props.globals.getNode("sim/model/walker[1]/animate/triggers/walking", 1);
var trigger_running_node = props.globals.getNode("sim/model/walker[1]/animate/triggers/running", 1);
var trigger_backwards_node = props.globals.getNode("sim/model/walker[1]/animate/triggers/backwards", 1);
var trigger_falling_node = props.globals.getNode("sim/model/walker[1]/animate/triggers/falling", 1);
var trigger_landing_node = props.globals.getNode("sim/model/walker[1]/animate/triggers/landing", 1);
var trigger_open_parachute_node = props.globals.getNode("sim/model/walker[1]/animate/triggers/open-parachute", 1);
var trigger_crashing_node = props.globals.getNode("sim/model/walker[1]/animate/triggers/crashing", 1);
var trigger_free1_node = props.globals.getNode("sim/model/walker[1]/animate/triggers/free1", 1);
var seq_node_now = nil;
var content_modified_node = props.globals.getNode("sim/gui/dialogs/position-modified", 1);
var walker_dialog1 = nil;
var walker_dialog2 = nil;
var walker_dialog3 = nil;
var walker_dialog4 = nil;
var sequence_count = 0;
var position_count = 0;
var anim_enabled = 0;
var anim_running = -1;
var triggers_enabled = 1;
var triggers_list = [0, 0, 0, 0, 0, 0, 0, 0, 0];
var triggers_names = ["standing","walking","running","backwards","falling","open-parachute","landing","crashing","free1"];
var triggers_abbrev = ["S","W","R","B","F","P","L","C"];
var log_priority = getprop("sim/logging/priority");
var log_level = 0;
if (log_priority == "info" or log_priority == "debug") {
	log_level += 1;
	print ("incr log_level");
}
var walking_momentum = 0;
var w_outside = 0;
var in_air = 0;
var parachute_deployed_ft = 0;
var animate_time_start = 0;
var animate_current_position = 0.0;
var animate_time_length = 0.0;
var loop_enabled = 0;
var loop_to = 0;
var loop_start_sec = 0.0;
var loop_length_sec = 0.0;
var time_chart = [];
var w_speed_mps = 0;
var w_key_speed = 0;
var am_L_id = nil;
var tm_L_id = nil;
var tr_L_id = nil;
var ta_L_id = nil;
var tj_L_id = nil;
var tl_L_id = nil;
var tc_L_id = nil;
var to_L_id = nil;

# remember preference for animations turned on or off
aircraft.data.add("sim/model/walker[1]/animate/enabled-triggers");

var interpolate_limb = func (a, b, p) {
	if (a == nil or b == nil or p == nil){
		print ("Undefined input error at walker-animate.interpolate_limb a= ",a," b= ",b," p= ",p);
	} else {
		return (a + ((b - a) * p));
	}
}

var clamp = func(v, min, max) { v < min ? min : v > max ? max : v }

var gui_list_node = props.globals.getNode("/sim/gui/dialogs/anim-sequence", 1);
if (gui_list_node.getNode("list", 1) == nil)
	gui_list_node.getNode("list", 1).setValue("");

gui_list_node = gui_list_node.getNode("list", 1);
var listbox_apply = func {
	var id = pop(split(" ",gui_list_node.getValue()));
	id = substr(id, 1, find(")", id) - 1);  # strip parentheses
	w1a_sequence_selected_node.setValue(int(id));
	sequence_node = w1a_list_node.getNode("sequence[" ~ int(w1a_sequence_selected_node.getValue()) ~ "]", 1);
#	sequence_selected = 3;
}

var apply = func {
	return gui_list_node.getValue();
}

var sequence = {
	new_animation:	func (name) {
		if (walker_dialog2 != nil) {
			fgcommand("dialog-close", props.Node.new({ "dialog-name" : "walker-config" }));
			walker_dialog2 = nil;
			return;
		}
		var s = "";
		for (var i = 0; i < size(name); i += 1) {
			if ((string.isascii(name[i]) and !string.ispunct(name[i])) or int(name[i]) == 95 or int(name[i]) == 45) {
				s ~= chr(name[i]);
			}
		}
		s = string.trim(s, 0);
		if (s == nil or s == "" or s == " ") {
			return 0;
		}
		var new_sequence = props.globals.getNode("sim/model/walker[1]/animate/list/sequence[" ~ size(w1a_list_node.getChildren("sequence")) ~ "]", 1);
		sequence_count = size(w1a_list_node.getChildren("sequence"));
		w1a_sequence_selected_node.setValue(int(sequence_count - 1));
		sequence_node = new_sequence;
		new_sequence.getNode("name", 1).setValue(s);
		new_sequence.getNode("loop-enabled", 1).setBoolValue(0);
		new_sequence.getNode("loop-to", 1).setIntValue(0);
		new_sequence.getNode("trigger-upon", 1).setValue("Disabled");
	},
	edit_animation:	func {
		sequence_node = w1a_list_node.getNode("sequence[" ~ int(w1a_sequence_selected_node.getValue()) ~ "]", 1);
		position_count = size(sequence_node.getChildren("position"));
		if (position_count == 0) {
			animate.reset_position();
			w1a_dialog_position_node.setValue(-1);
		} else {
			w1a_dialog_position_node.setValue(0);
			animate.copy_position(sequence_node.getNode("position[0]", 1), walker1_node);
			w1_loop_enabled_node.setBoolValue(sequence_node.getNode("loop-enabled", 1).getValue());
			walker1_node.getNode("loop-to", 1).setIntValue(sequence_node.getNode("loop-to", 1).getValue());
			walker1_node.getNode("trigger-upon", 1).setValue(sequence_node.getNode("trigger-upon", 1).getValue());
		}
		w1a_enabled_current_node.setValue(0);
		setprop("sim/model/walker[1]/animate/enabled-triggers", 0);
		fgcommand("dialog-close", props.Node.new({ "dialog-name" : "walker-sequences" }));
		walker_dialog1 = nil;
		animate.showDialog();
	},
	load_animation:	func {
		var load_sel = nil;
		var load = func(n) {
			print ("Loading from ",n.getValue());
			var new_sequence = props.globals.getNode("sim/model/walker[1]/animate/list/sequence[" ~ size(w1a_list_node.getChildren("sequence")) ~ "]", 1);
			io.read_properties(n.getValue(), new_sequence);
			var s = new_sequence.getNode("name", 1).getValue();
			if (s != nil) {
				sequence_node = new_sequence;
				sequence_count = size(w1a_list_node.getChildren("sequence"));
				w1a_sequence_selected_node.setValue(int(sequence_count - 1));
				sequence.reloadDialog();
			} else {
				w1a_list_node.removeChild("sequence", (size(w1a_list_node.getChildren("sequence")) - 1));
			}
		}
		load_sel = gui.FileSelector.new(load, "Load Walker Sequence", "Load",
			["walker-*.xml"], getprop("/sim/fg-home") ~ "/aircraft-data", "");
		load_sel.open();
	},
	save_animation:	func {
		var data_path = getprop("/sim/fg-home") ~ "/aircraft-data/walker-" ~ sequence_node.getNode("name", 1).getValue() ~ ".xml";
		print ("Saving to ",data_path);
		io.write_properties(data_path, sequence_node);
	},
	showDialog: func {
		var name1 = "walker-sequences";
		if (walker_dialog1 != nil) {
			fgcommand("dialog-close", props.Node.new({ "dialog-name" : name1 }));
			walker_dialog1 = nil;
			return;
		}

		walker_dialog1 = gui.Widget.new();
		walker_dialog1.set("layout", "vbox");
		walker_dialog1.set("name", name1);
		walker_dialog1.set("x", -40);
		walker_dialog1.set("y", -40);

		# "window" titlebar
		titlebar = walker_dialog1.addChild("group");
		titlebar.set("layout", "hbox");
		titlebar.addChild("empty").set("stretch", 1);
		titlebar.addChild("text").set("label", "Walker posing animations");
		titlebar.addChild("empty").set("stretch", 1);

		w = titlebar.addChild("button");
		w.set("pref-width", 16);
		w.set("pref-height", 14);
		w.set("legend", "");
		w.set("keynum", 27);
		w.set("border", 1);
		w.prop().getNode("binding[0]/command", 1).setValue("nasal");
		w.prop().getNode("binding[0]/script", 1).setValue("walker.walker_dialog1 = nil");
		w.prop().getNode("binding[1]/command", 1).setValue("dialog-close");

		walker_dialog1.addChild("hrule").addChild("dummy");

		var g = walker_dialog1.addChild("group");
		g.set("layout", "hbox");
		g.addChild("empty").set("pref-width", 8);
		var content = g.addChild("input");
		content.set("name", "input");
		content.set("layout", "hbox");
		content.set("halign", "fill");
		content.set("border", 1);
		content.set("editable", 1);
		content.set("property", "/sim/gui/dialogs/anim-sequence/list");
		content.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		content.prop().getNode("binding[0]/object-name", 1).setValue("input");
		content.prop().getNode("binding[1]/command", 1).setValue("dialog-update");
		content.prop().getNode("binding[1]/object-name", 1).setValue("sequence-list");
#		var box1 = g.addChild("button");
#		box1.set("legend", "Search");
#		box1.set("label", "");
#		box1.set("pref-width", 50);
#		box1.set("pref-height", 18);
#		box1.set("border", 2);
#		box1.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
#		box1.prop().getNode("binding[0]/object-name", 1).setValue("input");
#		box1.prop().getNode("binding[1]/command", 1).setValue("dialog-update");
#		box1.prop().getNode("binding[1]/object-name", 1).setValue("sequence-list");
		var box2 = g.addChild("button");
		box2.set("halign", "left");
		box2.set("label", "");
		box2.set("pref-width", 50);
		box2.set("pref-height", 18);
		box2.set("border", 2);
		box2.set("legend", "New");
		box2.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box2.prop().getNode("binding[0]/object-name", 1).setValue("input");
		box2.prop().getNode("binding[1]/command", 1).setValue("nasal");
		box2.prop().getNode("binding[1]/script", 1).setValue("walker.sequence.new_animation(walker.apply())");
		box2.prop().getNode("binding[2]/command", 1).setValue("dialog-update");
		box2.prop().getNode("binding[2]/object-name", 1).setValue("sequence-list");
		box2.prop().getNode("binding[3]/command", 1).setValue("nasal");
		box2.prop().getNode("binding[3]/script", 1).setValue("walker.sequence.reloadDialog()");
		box2.prop().getNode("binding[4]/command", 1).setValue("nasal");
		box2.prop().getNode("binding[4]/script", 1).setValue("walker.sequence.edit_animation()");
		g.addChild("empty").set("stretch", 1);

		var a = walker_dialog1.addChild("list");
		a.set("name", "sequence-list");
		a.set("pref-width", 300);
		a.set("pref-height", 160);
		a.set("slider", 18);
		a.set("property", "/sim/gui/dialogs/anim-sequence/list");
		sequence_count = size(w1a_list_node.getChildren("sequence"));
		var sList = [];
		for (var i = 0 ; i < sequence_count ; i += 1) {
			var name_in = w1a_list_node.getNode("sequence[" ~ i ~ "]", 1).getNode("name", 1).getValue();
			var trigger_in = w1a_list_node.getNode("sequence[" ~ i ~ "]", 1).getNode("trigger-upon", 1).getValue();
			var trigger_ab = "";
			for (var j = 0 ; j < size(triggers_names) ; j += 1) {
				if (string.lc(trigger_in) == string.lc(triggers_names[j])) {
#					print ("found trigger ",j," ",trigger_in," at ",i);
					trigger_ab = triggers_abbrev[j];
				}
			}
			if (name_in != nil) {
				append(sList, { index: i , name: name_in,
					comb: w1a_list_node.getNode("sequence[" ~ i ~ "]", 1).getNode("name", 1).getValue() ~ " (" ~ i ~ ")" ~ trigger_ab });
			}
		}
		sList = sort(sList, func(a,b) {cmp(a.name, b.name)});
		for (var i = 0 ; i < size(sList) ; i += 1) {
			a.set("value[" ~ i ~ "]", sList[i].comb);
		}
		a.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		a.prop().getNode("binding[0]/object-name", 1).setValue("sequence-list");
		a.prop().getNode("binding[1]/command", 1).setValue("nasal");
		a.prop().getNode("binding[1]/script", 1).setValue("walker.listbox_apply()");

		var g = walker_dialog1.addChild("group");
		g.set("layout", "hbox");
		g.addChild("empty").set("pref-width", 8);
		var box2 = g.addChild("button");
		box2.set("halign", "left");
		box2.set("label", "");
		box2.set("pref-width", 60);
		box2.set("pref-height", 18);
		box2.set("border", 2);
		box2.set("default", 1);
		box2.set("legend", "Edit/Run");
		box2.prop().getNode("binding[0]/command", 1).setValue("nasal");
		box2.prop().getNode("binding[0]/script", 1).setValue("walker.sequence.edit_animation()");
		var box3 = g.addChild("button");
		box3.set("halign", "left");
		box3.set("label", "");
		box3.set("pref-width", 50);
		box3.set("pref-height", 18);
		box3.set("legend", "Help");
		box3.set("border", 2);
		box3.prop().getNode("binding[0]/command", 1).setValue("nasal");
		box3.prop().getNode("binding[0]/script", 1).setValue("walker.sequence.helpDialog()");
		g.addChild("empty").set("stretch", 1);

		g.addChild("empty").set("pref-width", 8);
		g.addChild("text").set("label", "File:");
		var box4 = g.addChild("button");
		box4.set("halign", "right");
		box4.set("legend", "Load");
		box4.set("pref-width", 50);
		box4.set("pref-height", 18);
		box4.set("border", 2);
		box4.prop().getNode("binding[0]/command", 1).setValue("nasal");
		box4.prop().getNode("binding[0]/script", 1).setValue("walker.sequence.load_animation()");
		var box5 = g.addChild("button");
		box5.set("halign", "right");
		box5.set("legend", "Save");
		box5.set("pref-width", 50);
		box5.set("pref-height", 18);
		box5.set("border", 2);
		box5.prop().getNode("binding[0]/command", 1).setValue("nasal");
		box5.prop().getNode("binding[0]/script", 1).setValue("walker.sequence.save_animation()");
		g.addChild("empty").set("pref-width", 8);

		walker_dialog1.addChild("hrule").addChild("dummy");

		var g = walker_dialog1.addChild("group");
		g.set("layout", "hbox");
		g.addChild("empty").set("pref-width", 8);
		var box = g.addChild("checkbox");
		box.set("halign", "left");
		box.set("live", 1);
		box.set("label", "Enable animations upon Trigger");
		box.set("property", "sim/model/walker[1]/animate/enabled-triggers");
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		g.addChild("empty").set("stretch", 1);

		# finale
		walker_dialog1.addChild("empty").set("pref-height", "3");
		fgcommand("dialog-new", walker_dialog1.prop());
		gui.showDialog(name1);
	},
	reloadDialog: func {
		if (walker_dialog1 != nil) {
			fgcommand("dialog-close", props.Node.new({ "dialog-name" : "walker-sequences" }));
			walker_dialog1 = nil;
			sequence.showDialog();
		}
	},
	helpDialog: func {
		var name3 = "walker-sequence-help";
		if (walker_dialog3 != nil) {
			fgcommand("dialog-close", props.Node.new({ "dialog-name" : name3 }));
			walker_dialog3 = nil;
			return;
		}

		walker_dialog3 = gui.Widget.new();
		walker_dialog3.set("layout", "vbox");
		walker_dialog3.set("name", name3);
		walker_dialog3.set("x", (370 - getprop("/sim/startup/xsize")));
		walker_dialog3.set("y", -40);

		# "window" titlebar
		titlebar = walker_dialog3.addChild("group");
		titlebar.set("layout", "hbox");
		titlebar.addChild("empty").set("stretch", 1);
		titlebar.addChild("text").set("label", "Walker posing animations - Help");
		titlebar.addChild("empty").set("stretch", 1);

		w = titlebar.addChild("button");
		w.set("pref-width", 16);
		w.set("pref-height", 14);
		w.set("legend", "");
		w.set("keynum", 27);
		w.set("border", 1);
		w.prop().getNode("binding[0]/command", 1).setValue("nasal");
		w.prop().getNode("binding[0]/script", 1).setValue("walker.walker_dialog3 = nil");
		w.prop().getNode("binding[1]/command", 1).setValue("dialog-close");

		walker_dialog3.addChild("hrule").addChild("dummy");

		var text1 = props.globals.getNode("sim/about/text1", 1);
		text1.setValue("This model comes preloaded with an animation for every trigger.\n\n" ~
			"To add a new sequence, click in the text box left of [New], input a " ~
			"name, (hint: remember to press [Enter] after inputting in any of the " ~
			"text or number boxes,) and click [New]. This new sequence is now " ~
			"selected. It is recommended to use the underscore instead of spaces " ~
			"between words.\n\n" ~
			"To edit an existing sequence, click on it to select it.\n" ~
			"Then press [Enter] or click on [Edit/Run] (This button is the default, " ~
			"as depicted by the dashed lines around it's edge.)\n\n " ~
			"The number in parenthesis is the ID number for each sequence.\n\n" ~
			"The letter following the parenthesis indicated a trigger is set for this sequence.\n\n" ~
			"If some sequences do not show in the list box, and the scroll bar " ~
			"is not visible, just click in the text box.\n\n" ~
			"Your creations can be saved, shared with friends, and loaded from here. " ~
			"The animation files will be saved in:\n " ~
			"{home directory}/.fgfs/aircraft-data/\n\n" ~
			"The checkbox at the bottom enables the triggering of animations, " ~
			"and is automatically turned off when editing a sequence.\n\n" ~
			"To close this dialog box, press [Esc] or click on the button in the " ~
			"upper right corner.", "STRING");
		w = walker_dialog3.addChild("textbox");
		w.set("halign", "fill");
		w.set("pref-width", 350);
		w.set("pref-height", 250);
		w.set("editable", 0);
		w.set("property", "sim/about/text1");

		# finale
		walker_dialog3.addChild("empty").set("pref-height", "3");
		fgcommand("dialog-new", walker_dialog3.prop());
		gui.showDialog(name3);
	},
};

var animate = {
	add_position:	func {	# add to the end of list and fill with current values
		var new_position = sequence_node.getNode("position[" ~ size(sequence_node.getChildren("position")) ~ "]", 1);
		position_count = size(sequence_node.getChildren("position"));
		w1a_dialog_position_node.setValue(position_count - 1);
		if (position_count == 0) {
			animate.reset_position();
		} else {
			animate.copy_position(walker1_node, new_position);
			animate.save_header();
		}
		content_modified_node.setValue(5);
		return new_position;
	},
	ins_position:	func {
		var dialog_position = w1a_dialog_position_node.getValue();
		i = position_count;
		while (i > dialog_position) {
			animate.copy_position(sequence_node.getNode("position[" ~ (i - 1) ~ "]", 1), 
				sequence_node.getNode("position[" ~ i ~ "]", 1));
			i -= 1;
		}
		animate.save_position();
		position_count = size(sequence_node.getChildren("position"));
		content_modified_node.setValue(5);
	},
	del_position:	func {
		position_count = size(sequence_node.getChildren("position"));
		var dialog_position = w1a_dialog_position_node.getValue();
		var i = dialog_position;
		while (i < (position_count - 1)) {
			animate.copy_position(sequence_node.getNode("position[" ~ (i + 1) ~ "]", 1), 
				sequence_node.getNode("position[" ~ i ~ "]", 1));
			i += 1;
		}
		sequence_node.removeChild("position", (position_count - 1));
		position_count = size(sequence_node.getChildren("position"));
		if (position_count == 0) {
			w1a_dialog_position_node.setValue(position_count - 1);
			animate.reset_position();
		} else {
			if (dialog_position >= position_count) {
				w1a_dialog_position_node.setValue(position_count - 1);
			}
			animate.load_position();
		}
		content_modified_node.setValue(0);
	},
	copy_position:	func (from_node, to_node) {
		to_node.getNode("name", 1).setValue(from_node.getNode("name", 1).getValue());
		to_node.getNode("rest-sec", 1).setValue(from_node.getNode("rest-sec", 1).getValue());
		var t = from_node.getNode("transit-sec", 1);
		if (t.getValue() <= 0) {
			t.setValue(0.1);
		}
		to_node.getNode("transit-sec", 1).setValue(t.getValue());
		to_node.getNode("limb[0]", 1).getNode("y-deg", 1).setValue(from_node.getNode("limb[0]", 1).getNode("y-deg", 1).getValue());
		to_node.getNode("limb[0]", 1).getNode("z-m", 1).setValue(from_node.getNode("limb[0]", 1).getNode("z-m", 1).getValue());
		to_node.getNode("limb[1]", 1).getNode("y-deg", 1).setValue(from_node.getNode("limb[1]", 1).getNode("y-deg", 1).getValue());
		to_node.getNode("limb[1]", 1).getNode("z-deg", 1).setValue(from_node.getNode("limb[1]", 1).getNode("z-deg", 1).getValue());
		to_node.getNode("limb[2]", 1).getNode("y-deg", 1).setValue(from_node.getNode("limb[2]", 1).getNode("y-deg", 1).getValue());
		to_node.getNode("limb[2]", 1).getNode("z-deg", 1).setValue(from_node.getNode("limb[2]", 1).getNode("z-deg", 1).getValue());
		to_node.getNode("limb[3]", 1).getNode("x-deg", 1).setValue(from_node.getNode("limb[3]", 1).getNode("x-deg", 1).getValue());
		to_node.getNode("limb[3]", 1).getNode("y-deg", 1).setValue(from_node.getNode("limb[3]", 1).getNode("y-deg", 1).getValue());
		to_node.getNode("limb[3]", 1).getNode("z-deg", 1).setValue(from_node.getNode("limb[3]", 1).getNode("z-deg", 1).getValue());
		to_node.getNode("limb[4]", 1).getNode("y-deg", 1).setValue(from_node.getNode("limb[4]", 1).getNode("y-deg", 1).getValue());
		to_node.getNode("limb[4]", 1).getNode("z-deg", 1).setValue(from_node.getNode("limb[4]", 1).getNode("z-deg", 1).getValue());
		to_node.getNode("limb[5]", 1).getNode("x-deg", 1).setValue(from_node.getNode("limb[5]", 1).getNode("x-deg", 1).getValue());
		to_node.getNode("limb[5]", 1).getNode("y-deg", 1).setValue(from_node.getNode("limb[5]", 1).getNode("y-deg", 1).getValue());

		to_node.getNode("limb[5]", 1).getNode("hand-pose", 1).setValue(from_node.getNode("limb[5]", 1).getNode("hand-pose", 1).getValue());

		to_node.getNode("limb[6]", 1).getNode("x-deg", 1).setValue(from_node.getNode("limb[6]", 1).getNode("x-deg", 1).getValue());
		to_node.getNode("limb[6]", 1).getNode("y-deg", 1).setValue(from_node.getNode("limb[6]", 1).getNode("y-deg", 1).getValue());
		to_node.getNode("limb[6]", 1).getNode("z-deg", 1).setValue(from_node.getNode("limb[6]", 1).getNode("z-deg", 1).getValue());
		to_node.getNode("limb[7]", 1).getNode("y-deg", 1).setValue(from_node.getNode("limb[7]", 1).getNode("y-deg", 1).getValue());
		to_node.getNode("limb[7]", 1).getNode("z-deg", 1).setValue(from_node.getNode("limb[7]", 1).getNode("z-deg", 1).getValue());
		to_node.getNode("limb[8]", 1).getNode("x-deg", 1).setValue(from_node.getNode("limb[8]", 1).getNode("x-deg", 1).getValue());
		to_node.getNode("limb[8]", 1).getNode("y-deg", 1).setValue(from_node.getNode("limb[8]", 1).getNode("y-deg", 1).getValue());
		to_node.getNode("limb[8]", 1).getNode("hand-pose", 1).setValue(from_node.getNode("limb[8]", 1).getNode("hand-pose", 1).getValue());
		to_node.getNode("limb[9]", 1).getNode("x-deg", 1).setValue(from_node.getNode("limb[9]", 1).getNode("x-deg", 1).getValue());
		to_node.getNode("limb[9]", 1).getNode("y-deg", 1).setValue(from_node.getNode("limb[9]", 1).getNode("y-deg", 1).getValue());
		to_node.getNode("limb[9]", 1).getNode("z-deg", 1).setValue(from_node.getNode("limb[9]", 1).getNode("z-deg", 1).getValue());
		to_node.getNode("limb[10]", 1).getNode("y-deg", 1).setValue(from_node.getNode("limb[10]", 1).getNode("y-deg", 1).getValue());
		to_node.getNode("limb[11]", 1).getNode("y-deg", 1).setValue(from_node.getNode("limb[11]", 1).getNode("y-deg", 1).getValue());
		to_node.getNode("limb[12]", 1).getNode("x-deg", 1).setValue(from_node.getNode("limb[12]", 1).getNode("x-deg", 1).getValue());
		to_node.getNode("limb[12]", 1).getNode("y-deg", 1).setValue(from_node.getNode("limb[12]", 1).getNode("y-deg", 1).getValue());
		to_node.getNode("limb[12]", 1).getNode("z-deg", 1).setValue(from_node.getNode("limb[12]", 1).getNode("z-deg", 1).getValue());
		to_node.getNode("limb[13]", 1).getNode("y-deg", 1).setValue(from_node.getNode("limb[13]", 1).getNode("y-deg", 1).getValue());
		to_node.getNode("limb[14]", 1).getNode("y-deg", 1).setValue(from_node.getNode("limb[14]", 1).getNode("y-deg", 1).getValue());
	},
	incr_position:	func {
		if (position_count > 0) {
			var dialog_position = w1a_dialog_position_node.getValue() + 1;
			if (dialog_position <= (position_count - 1)) {
				w1a_dialog_position_node.setValue(dialog_position);
				animate.load_position();
			}
			content_modified_node.setValue(2);
		}
	},
	decr_position:	func {
		var dialog_position = w1a_dialog_position_node.getValue() - 1;
		if (dialog_position >= 0) {
			w1a_dialog_position_node.setValue(dialog_position);
			animate.load_position();
		}
		content_modified_node.setValue(3);
	},
	reset_position:	func {
		setprop("sim/model/walker[1]/name", "");
		setprop("sim/model/walker[1]/limb[0]/y-deg", 0.0);
		setprop("sim/model/walker[1]/limb[0]/z-m", 0.0);
		setprop("sim/model/walker[1]/limb[1]/y-deg", 0.0);
		setprop("sim/model/walker[1]/limb[1]/z-deg", 0.0);
		setprop("sim/model/walker[1]/limb[2]/y-deg", 0.0);
		setprop("sim/model/walker[1]/limb[2]/z-deg", 0.0);
		setprop("sim/model/walker[1]/limb[3]/x-deg", -80.0);
		setprop("sim/model/walker[1]/limb[3]/y-deg", 0.0);
		setprop("sim/model/walker[1]/limb[3]/z-deg", 0.0);
		setprop("sim/model/walker[1]/limb[4]/y-deg", 0.0);
		setprop("sim/model/walker[1]/limb[4]/z-deg", 0.0);
		setprop("sim/model/walker[1]/limb[5]/x-deg", 0.0);
		setprop("sim/model/walker[1]/limb[5]/y-deg", 0.0);
		setprop("sim/model/walker[1]/limb[5]/hand-pose", 0.0);
		setprop("sim/model/walker[1]/limb[6]/x-deg", -80.0);
		setprop("sim/model/walker[1]/limb[6]/y-deg", 0.0);
		setprop("sim/model/walker[1]/limb[6]/z-deg", 0.0);
		setprop("sim/model/walker[1]/limb[7]/y-deg", 0.0);
		setprop("sim/model/walker[1]/limb[7]/z-deg", 0.0);
		setprop("sim/model/walker[1]/limb[8]/x-deg", 0.0);
		setprop("sim/model/walker[1]/limb[8]/y-deg", 0.0);
		setprop("sim/model/walker[1]/limb[8]/hand-pose", 0.0);
		setprop("sim/model/walker[1]/limb[9]/x-deg", 0.0);
		setprop("sim/model/walker[1]/limb[9]/y-deg", 0.0);
		setprop("sim/model/walker[1]/limb[9]/z-deg", 0.0);
		setprop("sim/model/walker[1]/limb[10]/y-deg", 0.0);
		setprop("sim/model/walker[1]/limb[11]/y-deg", 0.0);
		setprop("sim/model/walker[1]/limb[12]/x-deg", 0.0);
		setprop("sim/model/walker[1]/limb[12]/y-deg", 0.0);
		setprop("sim/model/walker[1]/limb[12]/z-deg", 0.0);
		setprop("sim/model/walker[1]/limb[13]/y-deg", 0.0);
		setprop("sim/model/walker[1]/limb[14]/y-deg", 0.0);
		w1_loop_enabled_node.setValue(1);
		setprop("sim/model/walker[1]/loop-to", 0);
		setprop("sim/model/walker[1]/rest-sec", 0.0);
		setprop("sim/model/walker[1]/transit-sec", 1.0);
		setprop("sim/model/walker[1]/trigger-upon", "Disabled");
		content_modified_node.setValue(1);
	},
	save_header:	func {
		sequence_node.getNode("loop-enabled", 1).setBoolValue(w1_loop_enabled_node.getValue());
		sequence_node.getNode("loop-to", 1).setIntValue(walker1_node.getNode("loop-to", 1).getValue());
		var t = walker1_node.getNode("trigger-upon", 1).getValue();
		if (t != sequence_node.getNode("trigger-upon", 1).getValue()) {
			sequence_node.getNode("trigger-upon", 1).setValue(t);
			if (t == "Walking") {
				trigger_walking_node.setValue(int(w1a_sequence_selected_node.getValue()));
				print ("  saving animation: walking to position ", w1a_sequence_selected_node.getValue());
			} elsif (t == "Running") {
				trigger_running_node.setValue(int(w1a_sequence_selected_node.getValue()));
				print ("  saving animation: running to position ", w1a_sequence_selected_node.getValue());
			} elsif (t == "Backwards") {
				trigger_backwards_node.setValue(int(w1a_sequence_selected_node.getValue()));
				print ("  saving animation: backwards to position ", w1a_sequence_selected_node.getValue());
			} elsif (t == "Standing") {
				trigger_standing_node.setValue(int(w1a_sequence_selected_node.getValue()));
				print ("  saving animation: standing to position ", w1a_sequence_selected_node.getValue());
			} elsif (t == "Falling") {
				trigger_falling_node.setValue(int(w1a_sequence_selected_node.getValue()));
				print ("  saving animation: falling to position ", w1a_sequence_selected_node.getValue());
			} elsif (t == "Landing") {
				trigger_landing_node.setValue(int(w1a_sequence_selected_node.getValue()));
				print ("  saving animation: landing to position ", w1a_sequence_selected_node.getValue());
			} elsif (t == "Open-Parachute") {
				trigger_open_parachute_node.setValue(int(w1a_sequence_selected_node.getValue()));
				print ("  saving animation: open-parachute to position ", w1a_sequence_selected_node.getValue());
			} elsif (t == "Crashing") {
				trigger_crashing_node.setValue(int(w1a_sequence_selected_node.getValue()));
				print ("  saving animation: crashing to position ", w1a_sequence_selected_node.getValue());
			}
			discover_triggers(0);
		}
	},
	save_position:	func {
		var dialog_position = w1a_dialog_position_node.getValue();
		if (position_count == 0) {
			animate.add_position();
			w1a_dialog_position_node.setValue(0);
		} else {
			animate.copy_position(walker1_node, sequence_node.getNode("position[" ~ dialog_position ~ "]", 1));
		}
		animate.save_header();
		content_modified_node.setValue(6);
	},
	load_position:	func {
		var dialog_position = int(w1a_dialog_position_node.getValue());
		if (dialog_position >= 0) {
			animate.copy_position(sequence_node.getNode("position[" ~ dialog_position ~ "]", 1), walker1_node);
			var i1 = sequence_node.getNode("loop-enabled", 1).getValue();
			if (i1 == nil) {
				i1 = 0;
			}
			w1_loop_enabled_node.setBoolValue(i1);
			var i2 = sequence_node.getNode("loop-to", 1).getValue();
			if (i2 == nil) {
				i2 = 0;
			}
			walker1_node.getNode("loop-to", 1).setIntValue(i2);
			var i3 = sequence_node.getNode("trigger-upon", 1).getValue();
			if (i3 == nil) {
				i3 = "Disabled";
			}
			walker1_node.getNode("trigger-upon", 1).setValue(i3);
			content_modified_node.setValue(7);
		}
	},
	check_loop: func {
		var i = walker1_node.getNode("loop-to", 1).getValue();
		if (i >= position_count or i < 0 or i == "") {
			walker1_node.getNode("loop-to", 1).setValue(0);
		}
	},
	showDialog: func {
		var name2 = "walker-config";
		if (walker_dialog2 != nil) {
			fgcommand("dialog-close", props.Node.new({ "dialog-name" : name2 }));
			walker_dialog2 = nil;
			return;
		}

		walker_dialog2 = gui.Widget.new();
		walker_dialog2.set("layout", "vbox");
		walker_dialog2.set("name", name2);
		walker_dialog2.set("x", -10);
		walker_dialog2.set("y", -3);

		# "window" titlebar
		titlebar = walker_dialog2.addChild("group");
		titlebar.set("layout", "hbox");
		titlebar.addChild("empty").set("stretch", 1);
		titlebar.addChild("text").set("label", "Walker position config -- " ~ sequence_node.getNode("name", 1).getValue());
		titlebar.addChild("empty").set("stretch", 1);

		walker_dialog2.addChild("hrule").addChild("dummy");

		w = titlebar.addChild("button");
		w.set("pref-width", 16);
		w.set("pref-height", 14);
		w.set("legend", "");
		w.set("keynum", 27);
		w.set("border", 1);
		w.prop().getNode("binding[0]/command", 1).setValue("nasal");
		w.prop().getNode("binding[0]/script", 1).setValue("walker.sequence.showDialog()");
		w.prop().getNode("binding[1]/command", 1).setValue("nasal");
		w.prop().getNode("binding[1]/script", 1).setValue("walker.walker_dialog2 = nil");
		w.prop().getNode("binding[2]/command", 1).setValue("dialog-close");

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "Position");
		var content = g.addChild("input");
		content.set("name", "position");
		content.set("layout", "hbox");
		content.set("halign", "fill");
		content.set("label", "");
		content.set("default-padding", 1);
		content.set("pref-width", 40);
		content.set("editable", 1);
		content.set("live", 1);
		content.set("property", "sim/model/walker[1]/animate/dialog-position");
		content.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		content.prop().getNode("binding[0]/object-name", 1).setValue("position");
		content.prop().getNode("binding[1]/command", 1).setValue("nasal");
		content.prop().getNode("binding[1]/script", 1).setValue("walker.animate.load_position()");
		var gv = g.addChild("group");
		gv.set("layout", "table");
		gv.set("default-padding", 1);
		var box1 = gv.addChild("button");
		box1.set("row", 1);
		box1.set("column", 0);
		box1.set("halign", "left");
		box1.set("label", "");
		box1.set("pref-width", 20);
		box1.set("pref-height", 14);
		var pos_children_size = size(sequence_node.getChildren("position"));
		var dia_pos = w1a_dialog_position_node.getValue();
		box1.set("border", (pos_children_size > 1 ? (dia_pos > 0 ? 2 : 0) : 0));
		box1.set("legend", "-");
		box1.prop().getNode("binding[0]/command", 1).setValue("nasal");
		box1.prop().getNode("binding[0]/script", 1).setValue("walker.animate.decr_position()");
		var box2 = gv.addChild("button");
		box2.set("row", 0);
		box2.set("column", 0);
		box2.set("halign", "left");
		box2.set("label", "");
		box2.set("pref-width", 20);
		box2.set("pref-height", 14);
		box2.set("border", (pos_children_size > 1 ? (dia_pos < (pos_children_size - 1) ? 2 : 0) : 0));
		box2.set("legend", "+");
		box2.prop().getNode("binding[0]/command", 1).setValue("nasal");
		box2.prop().getNode("binding[0]/script", 1).setValue("walker.animate.incr_position()");
		g.addChild("empty").set("stretch", 1);
		var t = g.addChild("text");
		t.set("label", "Desc.");
		var content = g.addChild("input");
		content.set("name", "input");
		content.set("layout", "hbox");
		content.set("halign", "fill");
		content.set("label", "");
		content.set("default-padding", 1);
		content.set("pref-width", 200);
		content.set("editable", 1);
		content.set("live", 1);
		content.set("property", "sim/model/walker[1]/name");
		content.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		content.prop().getNode("binding[0]/object-name", 1).setValue("input");
#		content.prop().getNode("binding[1]/command", 1).setValue("property-assign");
#		content.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
#		content.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("pref-width", 4);


		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var box3 = g.addChild("button");
		box3.set("halign", "left");
		box3.set("label", "");
		box3.set("pref-width", 50);
		box3.set("pref-height", 18);
		box3.set("legend", "Insert");
		if (dia_pos < 0) {
			box3.setColor(0.44, 0.31, 0.31);
		}
		box3.prop().getNode("binding[0]/command", 1).setValue("nasal");
		box3.prop().getNode("binding[0]/script", 1).setValue("walker.animate.ins_position()");
		var box4 = g.addChild("button");
		box4.set("halign", "left");
		box4.set("label", "");
		box4.set("pref-width", 50);
		box4.set("pref-height", 18);
		box4.set("legend", "Add");
		box4.prop().getNode("binding[0]/command", 1).setValue("nasal");
		box4.prop().getNode("binding[0]/script", 1).setValue("walker.animate.add_position()");
		var box5 = g.addChild("button");
		box5.set("halign", "left");
		box5.set("label", "");
		box5.set("pref-width", 50);
		box5.set("pref-height", 18);
		box5.set("legend", "Delete");
		if (dia_pos < 0) {
			box5.setColor(0.44, 0.31, 0.31);
		}
		box5.prop().getNode("binding[0]/command", 1).setValue("nasal");
		box5.prop().getNode("binding[0]/script", 1).setValue("walker.animate.del_position()");
		var box6 = g.addChild("button");
		box6.set("halign", "left");
		box6.set("label", "");
		box6.set("pref-width", 50);
		box6.set("pref-height", 18);
		box6.set("legend", "Reset");
		box6.prop().getNode("binding[0]/command", 1).setValue("nasal");
		box6.prop().getNode("binding[0]/script", 1).setValue("walker.animate.reset_position()");
		var box7 = g.addChild("button");
		box7.set("halign", "left");
		box7.set("label", "");
		box7.set("pref-width", 50);
		box7.set("pref-height", 18);
		box7.set("border", (content_modified_node.getValue() == 1 ? 2 : 1));
		if (dia_pos < 0) {
			box7.setColor(0.44, 0.31, 0.31);
		}
		box7.set("legend", "Revert");
		box7.prop().getNode("binding[0]/command", 1).setValue("nasal");
		box7.prop().getNode("binding[0]/script", 1).setValue("walker.animate.load_position()");
		var box8 = g.addChild("button");
		box8.set("name", "save");
		box8.set("halign", "left");
		box8.set("label", "");
		box8.set("pref-width", 50);
		box8.set("pref-height", 18);
		box8.set("border", (content_modified_node.getValue() == 1 ? 2 : 1));
		box8.set("legend", "Save");
		box8.prop().getNode("binding[0]/command", 1).setValue("nasal");
		box8.prop().getNode("binding[0]/script", 1).setValue("walker.animate.save_position()");

		walker_dialog2.addChild("hrule").addChild("dummy");

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "0.y");
		t.set("pref-width", 15);
		g.addChild("empty").set("pref-width", 3);
		var box = g.addChild("slider");
		box.set("name", "Hip 0y");
		box.set("property", "sim/model/walker[1]/limb[0]/y-deg");
		box.set("legend", "Hip forward  < >  backward   ");
		box.set("pref-width", 300);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -180);
		box.set("max", 180);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Hip 0y");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[0]/y-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "0.z");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 25);
		var box = g.addChild("slider");
		box.set("name", "Body 0z");
		box.set("property", "sim/model/walker[1]/limb[0]/z-m");
		box.set("legend", "Body down  < >  up                   ");
		box.set("pref-width", 270);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -0.8225);
		box.set("max", 1);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Body 0z");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[0]/z-m");
		number.set("pref-width", 32);
		number.set("format", "%6.2f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "1.y");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 3);
		var box = g.addChild("slider");
		box.set("name", "Chest 1y");
		box.set("property", "sim/model/walker[1]/limb[1]/y-deg");
		box.set("legend", "               Chest forward  < >  backward");
		box.set("pref-width", 200);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -135);
		box.set("max", 45);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Chest 1y");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[1]/y-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "1.z");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 16);
		var box = g.addChild("slider");
		box.set("name", "Chest 1z");
		box.set("property", "sim/model/walker[1]/limb[1]/z-deg");
		box.set("legend", "Chest left  < >  right        ");
		box.set("pref-width", 264);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -30);
		box.set("max", 30);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Chest 1z");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[1]/z-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "2.y");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 49);
		var box = g.addChild("slider");
		box.set("name", "Head 2y");
		box.set("property", "sim/model/walker[1]/limb[2]/y-deg");
		box.set("legend", " Head forward  < >  backward");
		box.set("pref-width", 170);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -90.5);
		box.set("max", 62.5);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Head 2y");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[2]/y-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "2.z");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 48);
		var box = g.addChild("slider");
		box.set("name", "Head 2z");
		box.set("property", "sim/model/walker[1]/limb[2]/z-deg");
		box.set("legend", "Head left  < >  right       ");
		box.set("pref-width", 200);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -90);
		box.set("max", 90);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Head 2z");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[2]/z-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "3.x");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 53);
		var box = g.addChild("slider");
		box.set("name", "Arm1R 3x");
		box.set("property", "sim/model/walker[1]/limb[3]/x-deg");
		box.set("legend", "Right Arm1 down  < >  up                        ");
		box.set("pref-width", 200);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -85);
		box.set("max", 95);
		box.setColor(0.5, 1, 0.5);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Arm1R 3x");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[3]/x-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "3.y");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 63);
		var box = g.addChild("slider");
		box.set("name", "Arm1R 3y");
		box.set("property", "sim/model/walker[1]/limb[3]/y-deg");
		box.set("legend", "counter-clockwise < > clockwise                               ");
		box.set("pref-width", 240);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -90);
		box.set("max", 180);
		box.setColor(0.5, 1, 0.5);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Arm1R 3y");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[3]/y-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "3.z");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 30);
		var box = g.addChild("slider");
		box.set("name", "Arm1R 3z");
		box.set("property", "sim/model/walker[1]/limb[3]/z-deg");
		box.set("legend", "Right Arm1 forward left  < >  back right                ");
		box.set("pref-width", 220);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -106);
		box.set("max", 92);
		box.setColor(0.5, 1, 0.5);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Arm1R 3z");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[3]/z-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

#		var g = walker_dialog2.addChild("group");
#		g.set("layout", "hbox");
#		g.set("default-padding", 2);
#		g.addChild("empty").set("pref-width", 4);
#		var t = g.addChild("text");
#		t.set("label", "4.y");
#		t.set("pref-width", 20);
#		var box = g.addChild("slider");
#		box.set("name", "Arm2R 4y");
#		box.set("property", "sim/model/walker[1]/limb[4]/y-deg");
#		box.set("legend", "Right Arm2 counter-clockwise < > clockwise");
#		box.set("pref-width", 300);
#		box.set("pref-height", 16);
#		box.set("live", 1);
#		box.set("min", -90);
#		box.set("max", 90);
#		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
#		box.prop().getNode("binding[0]/object-name", 1).setValue("Arm2R 4y");
#		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
#		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
#		box.prop().getNode("binding[1]/value", 1).setValue(1);
#		g.addChild("empty").set("stretch", 1);
#		var number = g.addChild("text");
#		number.set("property", "sim/model/walker[1]/limb[4]/y-deg");
#		number.set("pref-width", 32);
#		number.set("format", "%6.1f");
#		number.set("live", 1);
#		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "4.z");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 139);
		var box = g.addChild("slider");
		box.set("name", "Arm2R 4z");
		box.set("property", "sim/model/walker[1]/limb[4]/z-deg");
		box.set("legend", "Right Arm2 straighten  < >  bend                                                             ");
		box.set("pref-width", 165);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", 0);
		box.set("max", 150);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Arm2R 4z");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[4]/z-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "5.x");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 50);
		var box = g.addChild("slider");
		box.set("name", "HandR 5x");
		box.set("property", "sim/model/walker[1]/limb[5]/x-deg");
		box.set("legend", "Right Hand down  < >  up                 ");
		box.set("pref-width", 176);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -90);
		box.set("max", 70);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("HandR 5x");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[5]/x-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "5.y");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 67);
		var box = g.addChild("slider");
		box.set("name", "HandR 5y");
		box.set("property", "sim/model/walker[1]/limb[5]/y-deg");
		box.set("legend", "counter-clockwise < > clockwise                               ");
		box.set("pref-width", 233);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -90);
		box.set("max", 180);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("HandR 5y");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[5]/y-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

# hand pose start
		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		g.addChild("text").set("label", "Right Hand Pose Nr.");
		var content2 = g.addChild("input");
		content2.set("name", "transit");
		content2.set("layout", "hbox");
		content2.set("halign", "fill");
		content2.set("label", "");
		content2.set("default-padding", 1);
		content2.set("pref-width", 40);
		content2.set("editable", 1);
		content2.set("live", 1);
		content2.set("property", "sim/model/walker[1]/limb[5]/hand-pose");
		content2.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		content2.prop().getNode("binding[0]/object-name", 1).setValue("transit");
#		content2.prop().getNode("binding[1]/command", 1).setValue("property-assign");
#		content2.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
#		content2.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("text").set("label", "1-6.");
		g.addChild("empty").set("pref-width", 4);
# hand pose stop

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "6.x");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 53);
		var box = g.addChild("slider");
		box.set("name", "Arm1L 6x");
		box.set("property", "sim/model/walker[1]/limb[6]/x-deg");
		box.set("legend", "Left Arm1 down  < >  up                      ");
		box.set("pref-width", 200);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -85);
		box.set("max", 95);
		box.setColor(1, 0.5, 0.5);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Arm1L 6x");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[6]/x-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "6.y");
		t.set("pref-width", 15);
		var box = g.addChild("slider");
		box.set("name", "Arm1L 6y");
		box.set("property", "sim/model/walker[1]/limb[6]/y-deg");
		box.set("legend", "     counter-clockwise < > clockwise");
		box.set("pref-width", 240);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -180);
		box.set("max", 90);
		box.setColor(1, 0.5, 0.5);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Arm1L 6y");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[6]/y-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "6.z");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 30);
		var box = g.addChild("slider");
		box.set("name", "Arm1L 6z");
		box.set("property", "sim/model/walker[1]/limb[6]/z-deg");
		box.set("legend", "Left Arm1 forward right  < >  back left                 ");
		box.set("pref-width", 220);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -106);
		box.set("max", 92);
		box.setColor(1, 0.5, 0.5);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Arm1L 6z");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[6]/z-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

#		var g = walker_dialog2.addChild("group");
#		g.set("layout", "hbox");
#		g.set("default-padding", 2);
#		g.addChild("empty").set("pref-width", 4);
#		var t = g.addChild("text");
#		t.set("label", "7.y");
#		t.set("pref-width", 20);
#		var box = g.addChild("slider");
#		box.set("name", "Arm2L 7y");
#		box.set("property", "sim/model/walker[1]/limb[7]/y-deg");
#		box.set("legend", "counter-clockwise < > clockwise");
#		box.set("pref-width", 300);
#		box.set("pref-height", 16);
#		box.set("live", 1);
#		box.set("min", -90);
#		box.set("max", 90);
#		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
#		box.prop().getNode("binding[0]/object-name", 1).setValue("Arm2L 7y");
#		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
#		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
#		box.prop().getNode("binding[1]/value", 1).setValue(1);
#		g.addChild("empty").set("stretch", 1);
#		var number = g.addChild("text");
#		number.set("property", "sim/model/walker[1]/limb[7]/y-deg");
#		number.set("pref-width", 32);
#		number.set("format", "%6.1f");
#		number.set("live", 1);
#		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "7.z");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 139);
		var box = g.addChild("slider");
		box.set("name", "Arm2L 7z");
		box.set("property", "sim/model/walker[1]/limb[7]/z-deg");
		box.set("legend", "Left Arm2 straighten  < >  bend                                                           ");
		box.set("pref-width", 165);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", 0);
		box.set("max", 150);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Arm2L 7z");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[7]/z-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "8.x");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 50);
		var box = g.addChild("slider");
		box.set("name", "HandL 8x");
		box.set("property", "sim/model/walker[1]/limb[8]/x-deg");
		box.set("legend", "Left Hand down  < >  up               ");
		box.set("pref-width", 176);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -90);
		box.set("max", 70);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("HandL 8x");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[8]/x-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "8.y");
		t.set("pref-width", 21);
		var box = g.addChild("slider");
		box.set("name", "HandL 8y");
		box.set("property", "sim/model/walker[1]/limb[8]/y-deg");
		box.set("legend", "    counter-clockwise < > clockwise");
		box.set("pref-width", 233);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -180);
		box.set("max", 90);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("HandL 8y");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[8]/y-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);


# hand pose start
		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		g.addChild("text").set("label", "Left Hand Pose Nr.");
		var content2 = g.addChild("input");
		content2.set("name", "transit");
		content2.set("layout", "hbox");
		content2.set("halign", "fill");
		content2.set("label", "");
		content2.set("default-padding", 1);
		content2.set("pref-width", 40);
		content2.set("editable", 1);
		content2.set("live", 1);
		content2.set("property", "sim/model/walker[1]/limb[8]/hand-pose");
		content2.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		content2.prop().getNode("binding[0]/object-name", 1).setValue("transit");
#		content2.prop().getNode("binding[1]/command", 1).setValue("property-assign");
#		content2.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
#		content2.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("text").set("label", "1-6.");
		g.addChild("empty").set("pref-width", 4);
# hand pose stop



		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "9.x");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 53);
		var box = g.addChild("slider");
		box.set("name", "Leg1R 9x");
		box.set("property", "sim/model/walker[1]/limb[9]/x-deg");
		box.set("legend", "   Right Leg1 out  < >  in");
		box.set("pref-width", 100);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -90.0);
		box.set("max", 0.0);
		box.setColor(0.5, 1, 0.5);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Leg1R 9x");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[9]/x-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "9.y");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 1);
		var box = g.addChild("slider");
		box.set("name", "Leg1R 9y");
		box.set("property", "sim/model/walker[1]/limb[9]/y-deg");
		box.set("legend", "Right Leg1 forward  < >  back       ");
		box.set("pref-width", 240);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -135.0);
		box.set("max", 81.0);
		box.setColor(0.5, 1, 0.5);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Leg1R 9y");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[9]/y-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "9.z");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 60);
		var box = g.addChild("slider");
		box.set("name", "Leg1R 9z");
		box.set("property", "sim/model/walker[1]/limb[9]/z-deg");
		box.set("legend", "counter-clockwise in < > clockwise out   ");
		box.set("pref-width", 140);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -81);
		box.set("max", 45);
		box.setColor(0.5, 1, 0.5);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Leg1R 9z");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[9]/z-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "10.y");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 125);
		var box = g.addChild("slider");
		box.set("name", "Leg2R 10y");
		box.set("property", "sim/model/walker[1]/limb[10]/y-deg");
		box.set("legend", "Right Leg2 straighten  < >  bend                                                     ");
		box.set("pref-width", 160);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -14);
		box.set("max", 130);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Leg2R 10y");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[10]/y-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "11.y");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 98);
		var box = g.addChild("slider");
		box.set("name", "FootR 11y");
		box.set("property", "sim/model/walker[1]/limb[11]/y-deg");
		box.set("legend", "Right Foot down  < >  up                     ");
		box.set("pref-width", 100);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -45);
		box.set("max", 45);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("FootR 11y");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[11]/y-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "12.x");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 53);
		var box = g.addChild("slider");
		box.set("name", "Leg1R 12x");
		box.set("property", "sim/model/walker[1]/limb[12]/x-deg");
		box.set("legend", "     Left Leg1 out  < >  in");
		box.set("pref-width", 100);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -90.0);
		box.set("max", 0.0);
		box.setColor(1, 0.5, 0.5);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Leg1R 12x");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[12]/x-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "12.y");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 1);
		var box = g.addChild("slider");
		box.set("name", "Leg1L 12y");
		box.set("property", "sim/model/walker[1]/limb[12]/y-deg");
		box.set("legend", "Left Leg1 forward  < >  back      ");
		box.set("pref-width", 240);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -135.0);
		box.set("max", 81.0);
		box.setColor(1, 0.5, 0.5);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Leg1L 12y");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[12]/y-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "12.z");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 95);
		var box = g.addChild("slider");
		box.set("name", "Leg1L 12z");
		box.set("property", "sim/model/walker[1]/limb[12]/z-deg");
		box.set("legend", "counter-clockwise out < > clockwise in                        ");
		box.set("pref-width", 140);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -45);
		box.set("max", 81);
		box.setColor(1, 0.5, 0.5);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Leg1L 12z");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[12]/z-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "13.y");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 125);
		var box = g.addChild("slider");
		box.set("name", "Leg2L 13y");
		box.set("property", "sim/model/walker[1]/limb[13]/y-deg");
		box.set("legend", "Left Leg2 straighten  < >  bend                                                   ");
		box.set("pref-width", 160);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -14);
		box.set("max", 130);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("Leg2L 13y");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[13]/y-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		var t = g.addChild("text");
		t.set("label", "14.y");
		t.set("pref-width", 20);
		g.addChild("empty").set("pref-width", 98);
		var box = g.addChild("slider");
		box.set("name", "FootL 14y");
		box.set("property", "sim/model/walker[1]/limb[14]/y-deg");
		box.set("legend", "Left Foot down  < >  up                   ");
		box.set("pref-width", 100);
		box.set("pref-height", 16);
		box.set("live", 1);
		box.set("min", -45);
		box.set("max", 45);
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[0]/object-name", 1).setValue("FootL 14y");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		var number = g.addChild("text");
		number.set("property", "sim/model/walker[1]/limb[14]/y-deg");
		number.set("pref-width", 32);
		number.set("format", "%6.1f");
		number.set("live", 1);
		g.addChild("empty").set("pref-width", 4);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 4);
		g.addChild("text").set("label", "Rest here");
		var content1 = g.addChild("input");
		content1.set("name", "rest");
		content1.set("layout", "hbox");
		content1.set("halign", "fill");
		content1.set("label", "sec.");
		content1.set("default-padding", 1);
		content1.set("pref-width", 40);
		content1.set("editable", 1);
		content1.set("live", 1);
		content1.set("property", "sim/model/walker[1]/rest-sec");
		content1.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		content1.prop().getNode("binding[0]/object-name", 1).setValue("rest");
#		content1.prop().getNode("binding[1]/command", 1).setValue("property-assign");
#		content1.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
#		content1.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("stretch", 1);
		g.addChild("text").set("label", "Transit time to next");
		var content2 = g.addChild("input");
		content2.set("name", "transit");
		content2.set("layout", "hbox");
		content2.set("halign", "fill");
		content2.set("label", "");
		content2.set("default-padding", 1);
		content2.set("pref-width", 40);
		content2.set("editable", 1);
		content2.set("live", 1);
		content2.set("property", "sim/model/walker[1]/transit-sec");
		content2.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		content2.prop().getNode("binding[0]/object-name", 1).setValue("transit");
#		content2.prop().getNode("binding[1]/command", 1).setValue("property-assign");
#		content2.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
#		content2.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("text").set("label", "seconds");
		g.addChild("empty").set("pref-width", 4);

		walker_dialog2.addChild("hrule").addChild("dummy");

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 0);
		g.addChild("empty").set("pref-width", 11);
		var box = g.addChild("checkbox");
		box.set("halign", "left");
		box.set("label", "Loop to position");
		box.set("live", 1);
		box.set("property", "sim/model/walker[1]/loop-enabled");
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		box.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		box.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		box.prop().getNode("binding[1]/value", 1).setValue(1);
		var content = g.addChild("input");
		content.set("name", "loop-input");
		content.set("layout", "hbox");
		content.set("halign", "fill");
		content.set("label", "");
		content.set("default-padding", 1);
		content.set("pref-width", 40);
		content.set("editable", 1);
		content.set("live", 1);
		content.set("property", "sim/model/walker[1]/loop-to");
		content.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		content.prop().getNode("binding[0]/object-name", 1).setValue("loop-input");
#		content.prop().getNode("binding[]/command", 1).setValue("property-assign");
#		content.prop().getNode("binding[]/property", 1).setValue("sim/gui/dialogs/position-modified");
		content.prop().getNode("binding[1]/command", 1).setValue("nasal");
		content.prop().getNode("binding[1]/script", 1).setValue("walker.animate.check_loop()");
		g.addChild("empty").set("stretch", 1);
		g.addChild("text").set("label", "Trigger");
		var combo = g.addChild("combo");
		combo.set("default-padding", 1);
		combo.set("pref-width", 130);
		combo.set("live", 1);
		combo.set("property", "sim/model/walker[1]/trigger-upon");
		combo.prop().getNode("value[0]", 1).setValue("Disabled");
		combo.prop().getNode("value[1]", 1).setValue("Standing");
		combo.prop().getNode("value[2]", 1).setValue("Walking");
		combo.prop().getNode("value[3]", 1).setValue("Running");
		combo.prop().getNode("value[4]", 1).setValue("Backwards");
		combo.prop().getNode("value[5]", 1).setValue("Falling");
		combo.prop().getNode("value[6]", 1).setValue("Open-Parachute");
		combo.prop().getNode("value[7]", 1).setValue("Landing");
		combo.prop().getNode("value[8]", 1).setValue("Crashing");
		combo.prop().getNode("value[9]", 1).setValue("free1");
		combo.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
		combo.prop().getNode("binding[1]/command", 1).setValue("property-assign");
		combo.prop().getNode("binding[1]/property", 1).setValue("sim/gui/dialogs/position-modified");
		combo.prop().getNode("binding[1]/value", 1).setValue(1);
		g.addChild("empty").set("pref-width", 8);

		var g = walker_dialog2.addChild("group");
		g.set("layout", "hbox");
		g.set("default-padding", 2);
		g.addChild("empty").set("pref-width", 5);
		var box = g.addChild("checkbox");
		box.set("halign", "left");
		box.set("label", "Enable This Animation Now");
		box.set("property", "sim/model/walker[1]/animate/enabled-current");
		box.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

		g.addChild("empty").set("stretch", 1);
		var box = g.addChild("button");
		box.set("halign", "left");
		box.set("label", "");
		box.set("pref-width", 50);
		box.set("pref-height", 18);
		box.set("legend", "Help");
		box.set("border", 2);
		box.prop().getNode("binding[0]/command", 1).setValue("nasal");
		box.prop().getNode("binding[0]/script", 1).setValue("walker.animate.helpDialog()");
		g.addChild("empty").set("pref-width", 8);

		walker_dialog2.addChild("empty").set("pref-height", "3");
		fgcommand("dialog-new", walker_dialog2.prop());
		gui.showDialog(name2);
	},
	reloadDialog: func {
		if (walker_dialog2 != nil) {
			fgcommand("dialog-close", props.Node.new({ "dialog-name" : "walker-config" }));
			walker_dialog2 = nil;
			animate.showDialog();
		}
	},
	helpDialog: func {
		var name4 = "walker-position-help";
		if (walker_dialog4 != nil) {
			fgcommand("dialog-close", props.Node.new({ "dialog-name" : name4 }));
			walker_dialog4 = nil;
			return;
		}

		walker_dialog4 = gui.Widget.new();
		walker_dialog4.set("layout", "vbox");
		walker_dialog4.set("name", name4);
		walker_dialog4.set("x", (400 - getprop("/sim/startup/xsize")));
		walker_dialog4.set("y", -40);

		# "window" titlebar
		titlebar = walker_dialog4.addChild("group");
		titlebar.set("layout", "hbox");
		titlebar.addChild("empty").set("stretch", 1);
		titlebar.addChild("text").set("label", "Walker animation position editing - Help");
		titlebar.addChild("empty").set("stretch", 1);

		w = titlebar.addChild("button");
		w.set("pref-width", 16);
		w.set("pref-height", 14);
		w.set("legend", "");
		w.set("keynum", 27);
		w.set("border", 1);
		w.prop().getNode("binding[0]/command", 1).setValue("nasal");
		w.prop().getNode("binding[0]/script", 1).setValue("walker.walker_dialog4 = nil");
		w.prop().getNode("binding[1]/command", 1).setValue("dialog-close");

		walker_dialog4.addChild("hrule").addChild("dummy");

		var text2 = props.globals.getNode("sim/about/text2", 1);
		text2.setValue("Each animation sequence is made up of 2 or more positions.\n" ~
			"A new sequence starts with no positions, as indicated by the " ~
			"position indicator showing -1. (the first position is zero in most " ~
			"computer languages.) Input a description (remember to press [Enter]), " ~
			"adjust the locations of the limbs, and press [Save]. Any change made " ~
			"to any position must be Saved before moving to another position. " ~
			"This allows you to Revert or discard changes. \n\n" ~
			"[Insert] will save the current settings before this position.\n" ~
			"[Add] will save the current settings to the end.\n\n" ~
			"Rest here will insert a timed delay of the indicated seconds " ~
			"after arriving here at this position, and before moving to the next " ~
			"position.\n Transit time is how long it takes to move the limbs from " ~
			"the current position to the next position.\n\n" ~
			"The bottom section does not change with each position, but instead is " ~
			"part of the sequence definition. If Loop To is enabled, the animation " ~
			"will loop endlessly between the indicated (you input) position and the " ~
			"end position. If Loop To is disabled, the animation will make One pass " ~
			"and stop at the end position.\n\n" ~
			"If a trigger is defined, this animation sequence will be played at the " ~
			"appropriate time. If you want to replace an existing trigger, after saving " ~
			"this sequence, just edit the other animation that has a duplicate trigger, " ~
			"change the trigger setting, save it, exit the dialog, and re-enable " ~
			"the Trigger checkbox on the other (sequence) dialog.\n\n" ~
			"To test your animation before enabling the trigger, just click in the " ~
			"checkbox at the bottom, to enable this current animation.", "STRING");
		w = walker_dialog4.addChild("textbox");
		w.set("halign", "fill");
		w.set("pref-width", 380);
		w.set("pref-height", 250);
		w.set("editable", 0);
		w.set("property", "sim/about/text2");

		walker_dialog4.addChild("hrule").addChild("dummy");

		# finale
		walker_dialog4.addChild("empty").set("pref-height", "3");
		fgcommand("dialog-new", walker_dialog4.prop());
		gui.showDialog(name4);
	},
};

var animate_update = func (seq_node) {
	var current_time = getprop("sim/time/elapsed-sec");
	var time_elapsed = current_time - animate_time_start;
	var i = 0;
	if (time_elapsed >= animate_time_length) {
		if (w1_loop_enabled_node.getValue()) {
			animate_current_position -= position_count;
			animate_current_position += loop_to;
			animate_time_start += loop_length_sec;
			time_elapsed -= loop_length_sec;
		} else {
			animate_current_position = position_count - 1;
			animate_current_position = int(animate_current_position);
			i = 99;
		}
	}
	animate_current_position = clamp(animate_current_position, 0.0, position_count);
	var move_percent = 0.0;
	if (i < 99) {
		while ((time_elapsed > time_chart[int(animate_current_position)].transit_until) and (animate_current_position < position_count)) {
			animate_current_position = int(animate_current_position) + 1;
		}
		if (animate_current_position >= position_count) {
			animate_current_position = loop_to;
		}
		if (time_elapsed <= time_chart[int(animate_current_position)].rest_until) {
			animate_current_position = int(animate_current_position) + ((time_elapsed - time_chart[int(animate_current_position)].time0) / (time_chart[int(animate_current_position)].transit_until - time_chart[int(animate_current_position)].time0));
		} elsif (time_elapsed <= time_chart[int(animate_current_position)].transit_until) {
			move_percent = (time_elapsed - time_chart[int(animate_current_position)].rest_until) / time_chart[int(animate_current_position)].transit;
			animate_current_position = int(animate_current_position) + ((time_elapsed - time_chart[int(animate_current_position)].time0) / (time_chart[int(animate_current_position)].transit_until - time_chart[int(animate_current_position)].time0));
		}
		animate_current_position = clamp(animate_current_position, 0.0, position_count);
	}
	w1a_dialog_position_node.setValue(int(animate_current_position));
	var s = "position[" ~ int(animate_current_position) ~ "]";
	var from_node = seq_node.getNode(s, 1);
	walker1_node.getNode("name", 1).setValue(from_node.getNode("name", 1).getValue());
	walker1_node.getNode("rest-sec", 1).setValue(from_node.getNode("rest-sec", 1).getValue());
	walker1_node.getNode("transit-sec", 1).setValue(from_node.getNode("transit-sec", 1).getValue());
	if (i == 99) {
		var next_position = int(animate_current_position);
		var to_node = seq_node.getNode("position[" ~ (position_count - 1) ~ "]", 1);
	} else {
		var next_position = int(animate_current_position) + 1;
		if (next_position > (position_count - 1)) {
			var to_node = seq_node.getNode("position[" ~ loop_to ~ "]", 1);
		} else {
			var to_node = seq_node.getNode("position[" ~ next_position ~ "]", 1);
		}
	}
	walker1_node.getNode("limb[0]", 1).getNode("y-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[0]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[0]", 1).getNode("y-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[0]", 1).getNode("z-m", 1).setValue(interpolate_limb(from_node.getNode("limb[0]", 1).getNode("z-m", 1).getValue(), to_node.getNode("limb[0]", 1).getNode("z-m", 1).getValue(), move_percent));
	walker1_node.getNode("limb[1]", 1).getNode("y-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[1]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[1]", 1).getNode("y-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[1]", 1).getNode("z-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[1]", 1).getNode("z-deg", 1).getValue(), to_node.getNode("limb[1]", 1).getNode("z-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[2]", 1).getNode("y-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[2]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[2]", 1).getNode("y-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[2]", 1).getNode("z-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[2]", 1).getNode("z-deg", 1).getValue(), to_node.getNode("limb[2]", 1).getNode("z-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[3]", 1).getNode("x-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[3]", 1).getNode("x-deg", 1).getValue(), to_node.getNode("limb[3]", 1).getNode("x-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[3]", 1).getNode("y-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[3]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[3]", 1).getNode("y-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[3]", 1).getNode("z-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[3]", 1).getNode("z-deg", 1).getValue(), to_node.getNode("limb[3]", 1).getNode("z-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[4]", 1).getNode("y-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[4]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[4]", 1).getNode("y-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[4]", 1).getNode("z-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[4]", 1).getNode("z-deg", 1).getValue(), to_node.getNode("limb[4]", 1).getNode("z-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[5]", 1).getNode("x-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[5]", 1).getNode("x-deg", 1).getValue(), to_node.getNode("limb[5]", 1).getNode("x-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[5]", 1).getNode("y-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[5]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[5]", 1).getNode("y-deg", 1).getValue(), move_percent));

# 	walker1_node.getNode("limb[5]", 1).getNode("hand-pose", 1).setValue(interpolate_limb(from_node.getNode("limb[5]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[5]", 1).getNode("hand-pose", 1).getValue(), move_percent));

	walker1_node.getNode("limb[6]", 1).getNode("x-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[6]", 1).getNode("x-deg", 1).getValue(), to_node.getNode("limb[6]", 1).getNode("x-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[6]", 1).getNode("y-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[6]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[6]", 1).getNode("y-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[6]", 1).getNode("z-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[6]", 1).getNode("z-deg", 1).getValue(), to_node.getNode("limb[6]", 1).getNode("z-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[7]", 1).getNode("y-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[7]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[7]", 1).getNode("y-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[7]", 1).getNode("z-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[7]", 1).getNode("z-deg", 1).getValue(), to_node.getNode("limb[7]", 1).getNode("z-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[8]", 1).getNode("x-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[8]", 1).getNode("x-deg", 1).getValue(), to_node.getNode("limb[8]", 1).getNode("x-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[8]", 1).getNode("y-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[8]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[8]", 1).getNode("y-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[9]", 1).getNode("x-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[9]", 1).getNode("x-deg", 1).getValue(), to_node.getNode("limb[9]", 1).getNode("x-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[9]", 1).getNode("y-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[9]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[9]", 1).getNode("y-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[9]", 1).getNode("z-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[9]", 1).getNode("z-deg", 1).getValue(), to_node.getNode("limb[9]", 1).getNode("z-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[10]", 1).getNode("y-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[10]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[10]", 1).getNode("y-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[11]", 1).getNode("y-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[11]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[11]", 1).getNode("y-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[12]", 1).getNode("x-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[12]", 1).getNode("x-deg", 1).getValue(), to_node.getNode("limb[12]", 1).getNode("x-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[12]", 1).getNode("y-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[12]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[12]", 1).getNode("y-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[12]", 1).getNode("z-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[12]", 1).getNode("z-deg", 1).getValue(), to_node.getNode("limb[12]", 1).getNode("z-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[13]", 1).getNode("y-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[13]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[13]", 1).getNode("y-deg", 1).getValue(), move_percent));
	walker1_node.getNode("limb[14]", 1).getNode("y-deg", 1).setValue(interpolate_limb(from_node.getNode("limb[14]", 1).getNode("y-deg", 1).getValue(), to_node.getNode("limb[14]", 1).getNode("y-deg", 1).getValue(), move_percent));
	if (i == 99) {
		if (anim_enabled) {
			w1a_enabled_current_node.setValue(0);
		}
		seq_node_now = nil;
		settimer(func { animate.reloadDialog() }, 0);
	}

}

var animate_loop_id = 0;
var animate_loop = func (id, seq_node) {
	id == animate_loop_id or return;
	if (anim_enabled or (anim_running >= 0)) {
		if (seq_node == seq_node_now) {
			animate_update(seq_node);
			settimer(func { animate_loop(animate_loop_id += 1, seq_node) }, 0.01);
		}
	}
}

var start_animation = func (seq_node, seqId) {
	seq_node_now = seq_node;
	if (anim_running != seqId) {
		position_count = size(seq_node.getChildren("position"));
		w1a_dialog_position_node.setValue(0);
		loop_enabled = seq_node.getNode("loop-enabled", 1).getValue();
		w1_loop_enabled_node.setValue(loop_enabled);
		var s = seq_node.getNode("trigger-upon", 1).getValue();
		walker1_node.getNode("trigger-upon", 1).setValue(s);
		if (position_count >= 2) {
			animate_current_position = 0.0;
			time_chart = [];
			var t = 0.0;
			loop_to = (loop_enabled ? seq_node.getNode("loop-to", 1).getValue() : position_count - 1);
			for (var i = 0 ; i < position_count ; i += 1) {
				var i_node = seq_node.getNode("position[" ~ i ~ "]", 1);
				var rest_sec = i_node.getNode("rest-sec", 1).getValue();
				var transit_sec = i_node.getNode("transit-sec", 1).getValue();
				if (i == loop_to) {
					loop_start_sec = t;
				}
				append(time_chart, { position: i, time0: t , rest_until: (t + rest_sec), 
					transit_until: (t + rest_sec + transit_sec),
					transit: transit_sec });
				if (loop_enabled or i < (position_count - 1)) {
					t += rest_sec;
					t += transit_sec;
				}
			}
			animate_time_length = t;
			loop_length_sec = t - loop_start_sec;
			if (t > 0.0) {
				anim_running = seqId;
				animate_time_start = getprop("sim/time/elapsed-sec");
				if (getprop("logging/walker-debug")) {
					print ("Starting animation: ",seqId," ",seq_node.getNode("name", 1).getValue()," animate_time_length= ",animate_time_length," loop_length_sec= ",loop_length_sec, " animate_time_start= ",animate_time_start);
				}
				settimer(func { animate_loop(animate_loop_id += 1, seq_node) }, 0);
			}
		}
	}
}

var stop_animation = func {
	if (anim_enabled) {
		settimer(func { w1a_enabled_current_node.setValue(0) }, 0.1);
	}
	anim_running = -1;
}

var check_walk_animations = func {	# keyboard handling for osg version
	walking_momentum = getprop("sim/walker/walking-momentum");
	if (triggers_enabled) {
		var s = nil;
		if (!getprop("sim/walker/airborne")) {	# on ground
			var w_direction = getprop("sim/walker/key-triggers/forward");
			var w_slide = getprop("sim/walker/key-triggers/slide");
			if (walking_momentum) {
				if (getprop("sim/current-view/view-number") != 0) {
					if (w_direction < 0) {
						if (triggers_list[3] >= 0) {
							s = int(trigger_backwards_node.getValue());
						}
					} elsif (w_direction > 0 or w_slide != 0) {
						#print ("listener: walking ",walking_momentum," ",w_direction," w_key_speed= ",w_key_speed,"  speed_mps= ",w_speed_mps);
						if (w_key_speed < (w_speed_mps * 2)) {
							if (triggers_list[1] >= 0) {
								s = int(trigger_walking_node.getValue());
							}
						} else {
							if (triggers_list[2] >= 0) {
								s = int(trigger_running_node.getValue());
							}
						}
					}
				}
			} else {
				if (triggers_list[0] >= 0) {
					if (w_outside) {
						s = int(trigger_standing_node.getValue());
					} else {
						stop_animation();
						animate.reset_position();
					}
				}
			}
			if ((s != nil) and (s >= 0)) {
				triggered_seq_node = props.globals.getNode("sim/model/walker[1]/animate/list/sequence[" ~ s ~ "]", 1);
				if (triggered_seq_node != nil and (s != anim_running)) {
					start_animation(triggered_seq_node, s);
				}
			} else {
				stop_animation();
			}
		}	# else no animation if attempt to walk in midair
	}
}

var discover_triggers = func (verbose) {
	var a = size(w1a_list_node.getChildren("sequence"));
	triggers_list = [0, 0, 0, 0, 0, 0, 0, 0];
	var trig_c = 0;
	for (var i = 0; i < a; i += 1) {
		var t = props.globals.getNode("sim/model/walker[1]/animate/list/sequence[" ~ i ~"]", 1).getNode("trigger-upon", 1).getValue();
		if (t == "Walking") {
			if (triggers_list[1] == 0) {
				trigger_walking_node.setValue(int(i));
				if (verbose and log_level > 0) {
					print ("    found trigger: loading animation for walking to position ",i);
				}
				triggers_list[1] = 1;
				trig_c += 1;
			} else {
				print ("  ignoring duplicate trigger (",i,") for walking");
				bluebird.popupTip2("Trigger walking set to position ("~trigger_walking_node.getValue()~")",5);
				gui.popupTip("Ignoring duplicate trigger ("~i~") for walking",6);
			}
		} elsif (t == "Running") {
			if (triggers_list[2] == 0) {
				trigger_running_node.setValue(int(i));
				if (verbose and log_level > 0) {
					print ("    found trigger: loading animation for running to position ",i);
				}
				triggers_list[2] = 1;
				trig_c += 2;
			} else {
				print ("  ignoring duplicate trigger (",i,") for running");
				bluebird.popupTip2("Trigger running set to position ("~trigger_running_node.getValue()~")",5);
				gui.popupTip("Ignoring duplicate trigger ("~i~") for running",6);
			}
		} elsif (t == "Backwards") {
			if (triggers_list[3] == 0) {
				trigger_backwards_node.setValue(int(i));
				if (verbose and log_level > 0) {
					print ("    found trigger: loading animation for backwards to position ",i);
				}
				triggers_list[3] = 1;
				trig_c += 4;
			} else {
				print ("  ignoring duplicate trigger (",i,") for backwards");
				bluebird.popupTip2("Trigger backwards set to position ("~trigger_backwards_node.getValue()~")",5);
				gui.popupTip("Ignoring duplicate trigger ("~i~") for backwards",6);
			}
		} elsif (t == "Standing") {
			if (triggers_list[0] == 0) {
				trigger_standing_node.setValue(int(i));
				if (verbose and log_level > 0) {
					print ("    found trigger: loading animation for standing to position ",i);
				}
				triggers_list[0] = 1;
				trig_c += 8;
			} else {
				print ("  ignoring duplicate trigger (",i,") for standing");
				bluebird.popupTip2("Trigger standing set to position ("~trigger_standing_node.getValue()~")",5);
				gui.popupTip("Ignoring duplicate trigger ("~i~") for standing",6);
			}
		} elsif (t == "Falling") {
			if (triggers_list[4] == 0) {
				trigger_falling_node.setValue(int(i));
				if (verbose and log_level > 0) {
					print ("    found trigger: loading animation for falling to position ",i);
				}
				triggers_list[4] = 1;
				trig_c += 16;
			} else {
				print ("  ignoring duplicate trigger (",i,") for falling");
				bluebird.popupTip2("Trigger falling set to position ("~trigger_falling_node.getValue()~")",5);
				gui.popupTip("Ignoring duplicate trigger ("~i~") for falling",6);
			}
		} elsif (t == "Open-Parachute") {
			if (triggers_list[5] == 0) {
				trigger_open_parachute_node.setValue(int(i));
				if (verbose and log_level > 0) {
					print ("    found trigger: loading animation for open-parachute to position ",i);
				}
				triggers_list[5] = 1;
				trig_c += 32;
			} else {
				print ("  ignoring duplicate trigger (",i,") for open-parachute");
				bluebird.popupTip2("Trigger open-parachute set to position ("~trigger_open_parachute_node.getValue()~")",5);
				gui.popupTip("Ignoring duplicate trigger ("~i~") for open-parachute",6);
			}
		} elsif (t == "Landing") {
			if (triggers_list[6] == 0) {
				trigger_landing_node.setValue(int(i));
				if (verbose and log_level > 0) {
					print ("    found trigger: loading animation for landing to position ",i);
				}
				triggers_list[6] = 1;
				trig_c += 64;
			} else {
				print ("  ignoring duplicate trigger ((",i,")) for landing");
				bluebird.popupTip2("Trigger landing set to position ("~trigger_landing_node.getValue()~")",5);
				gui.popupTip("Ignoring duplicate trigger ("~i~") for landing",6);
			}
		} elsif (t == "Crashing") {
			if (triggers_list[7] == 0) {
				trigger_crashing_node.setValue(int(i));
				if (verbose and log_level > 0) {
					print ("    found trigger: loading animation for crashing to position ",i);
				}
				triggers_list[7] = 1;
				trig_c += 128;
			} else {
				print ("  ignoring duplicate trigger (",i,") for crashing");
				bluebird.popupTip2("Trigger crashing set to position ("~trigger_crashing_node.getValue()~")",5);
				gui.popupTip("Ignoring duplicate trigger ("~i~") for crashing",6);
			}
		} elsif (t == "free1") {
			if (triggers_list[8] == 0) {
				trigger_free1_node.setValue(int(i));
				if (verbose and log_level > 0) {
					print ("    found trigger: loading animation free1 to position ",i);
				}
				triggers_list[8] = 1;
				trig_c += 32;
			} else {
				print ("  ignoring duplicate trigger (",i,") free1");
				bluebird.popupTip2("Trigger free1 set to position ("~trigger_open_parachute_node.getValue()~")",5);
				gui.popupTip("Ignoring duplicate trigger ("~i~") free1",6);
			}
		}
	}
	for (var i = 0; i <= 7; i += 1) {
		if (triggers_list[i] == 0) {
			setprop("sim/model/walker[1]/animate/triggers/" ~ triggers_names[i], -1);
		}
	}
	# add listener for each animation.
	if (trig_c > 0) {
		if (tm_L_id == nil) {
			tm_L_id = setlistener("sim/walker/walking-momentum", func {
				check_walk_animations();
			},, 0);
		}

		if (tr_L_id == nil) {
			tr_L_id = setlistener("sim/walker/key-triggers/speed", func(n) {
				w_key_speed = n.getValue();
				check_walk_animations();
			},, 0);
		}

		if (ta_L_id == nil) {
			ta_L_id = setlistener("sim/walker/airborne", func(n) {
				in_air = n.getValue();
				if (w_outside and triggers_enabled) {
					var s = nil;
					if (in_air) {
						if (triggers_list[4]) {
							s = int(trigger_falling_node.getValue());
						}
					} else {
						var crash_landing = getprop("sim/walker/crashed");
						if (!crash_landing and triggers_list[6] and getprop("sim/walker/parachute-opened-sec") > 2) {
							s = int(trigger_landing_node.getValue());
						} elsif (crash_landing and triggers_list[7]) {
							s = int(trigger_crashing_node.getValue());
						} else {
							stop_animation();
						}
					}
					if ((s != nil) and (s >= 0)) {
						triggered_seq_node = props.globals.getNode("sim/model/walker[1]/animate/list/sequence[" ~ s ~ "]", 1);
						start_animation(triggered_seq_node, s);
					} else {
						stop_animation();
					}
				}
			},, 0);
		}

		if (tj_L_id == nil) {
			tj_L_id = setlistener("sim/walker/parachute-opened-altitude-ft", func(n) {
				parachute_deployed_ft = n.getValue();
				if (w_outside and triggers_enabled) {
					var s = nil;
					if (parachute_deployed_ft > 0) {
						if (in_air) {
							if (triggers_list[5]) {
								s = int(trigger_open_parachute_node.getValue());
							}
						}
						if ((s != nil) and (s >= 0)) {
							triggered_seq_node = props.globals.getNode("sim/model/walker[1]/animate/list/sequence[" ~ s ~ "]", 1);
							start_animation(triggered_seq_node, s);
						} else {
							stop_animation();
						}
					}
				}
			},, 0);
		}

		if (to_L_id == nil) {
			to_L_id = setlistener("sim/walker/outside", func(n) {
				if (n.getValue() == 0) {
					stop_animation();
					animate.reset_position();
				}
			},, 0);
		}

	} else {
		stop_animation();
	}
}

var init_walker = func {
	sequence_node = w1a_list_node.getNode("sequence[" ~ int(w1a_sequence_selected_node.getValue()) ~ "]", 1);
	position_count = size(sequence_node.getChildren("position"));
	w1a_dialog_position_node.setValue(0);
	setlistener("sim/model/walker[1]/animate/enabled-triggers", func(n) {
		triggers_enabled = n.getValue();
		stop_animation();
		if (triggers_enabled) {
			animate.reset_position();
		}
	}, 1, 0);

	am_L_id = setlistener("sim/gui/dialogs/position-modified", func {
		if (!anim_enabled and (anim_running == -1)) {
			animate.reloadDialog();
		}
	}, 0, 0);

	setlistener("sim/walker/speed-mps", func(n) { w_speed_mps = n.getValue() }, 1, 0);

	setlistener("sim/walker/outside", func(n) { w_outside = n.getValue() }, 1, 0);

	setlistener("sim/model/walker[1]/animate/enabled-current", func(n) {
		anim_enabled = n.getValue();
		if (anim_enabled) {
			var seqId = int(w1a_sequence_selected_node.getValue());
			start_animation(sequence_node, seqId);
		} else {
			if (anim_running >= 0) {
				stop_animation();
			}
		}
	}, 1, 0);

	# remember trigger settings for the two versions of standing
	aircraft.data.add("sim/model/walker[1]/animate/list/sequence[0]/trigger-upon");
	aircraft.data.add("sim/model/walker[1]/animate/list/sequence[8]/trigger-upon");

	discover_triggers(1);
}
settimer(init_walker,0);
