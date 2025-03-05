######################################
# b777 doors
#
#SP-WKA/Arminair

var doors =
 {
 new: func(name, transit_time)
  {
  doors[name] = aircraft.door.new("aaa/door-positions/" ~ name, transit_time);
  },
 toggle: func(name)
  {
  doors[name].toggle();
  },
 open: func(name)
  {
  doors[name].open();
  },
 close: func(name)
  {
  doors[name].close();
  },
 setpos: func(name, value)
  {
  doors[name].setpos(value);
  }
 };
doors.new("l1", 10);
doors.new("l2", 10);
doors.new("r1", 10);
doors.new("r2", 10);
doors.new("l3", 10);
doors.new("l4", 10);
doors.new("r3", 10);
doors.new("r4", 10);
doors.new("l5", 10);


doors.new("c1", 10);
doors.new("c2", 10);
doors.new("c3", 10);
doors.new("c4", 10);
doors.new("c5", 10);
doors.new("c6", 10);
doors.new("c7", 10);
doors.new("c8", 10);
doors.new("c9", 10);
doors.new("c10", 10);
doors.new("c11", 10);
doors.new("c12", 10);
doors.new("c13", 10);
doors.new("c14", 10);
doors.new("c15", 10);
doors.new("c16", 10);
doors.new("c17", 10);
doors.new("c18", 10);
doors.new("c19", 10);
doors.new("c20", 10);
doors.new("c21", 10);
doors.new("c22", 10);
doors.new("c23", 10);
doors.new("c24", 10);
doors.new("c25", 10);
doors.new("c26", 10);
doors.new("c27", 10);
doors.new("c28", 10);
doors.new("c29", 10);
doors.new("c30", 10);
doors.new("c31", 10);
doors.new("c32", 10);
doors.new("c33", 10);
doors.new("c34", 10);
doors.new("c35", 10);
doors.new("c36", 10);
doors.new("c37", 10);
doors.new("c38", 10);
doors.new("c39", 10);
doors.new("c40", 10);
doors.new("c41", 10);
doors.new("c42", 10);
doors.new("c43", 10);
doors.new("c44", 10);
doors.new("c45", 10);
doors.new("c46", 10);
doors.new("c47", 10);
doors.new("c48", 10);
doors.new("c49", 10);
doors.new("c50", 10);
doors.new("c51", 10);
doors.new("c52", 10);
doors.new("c53", 10);
doors.new("c54", 10);
doors.new("c55", 10);
doors.new("ad1", 59);
doors.new("trap", 120);
doors.new("c56", 01);
doors.new("c57", 01);
doors.new("c58", 01);
doors.new("c59", 01);
doors.new("c60", 01);
doors.new("c61", 01);
doors.new("c62", 01);
doors.new("c63", 01);
doors.new("c64", 01);
doors.new("c65", 01);
doors.new("c66", 01);
doors.new("c67", 01);
doors.new("c68", 01);
doors.new("c69", 01);
doors.new("c70", 01);
doors.new("c71", 01);

doors.new("rat", 10);

doors.new("cdoor", 3);

doors.new("pseat", 4);
doors.new("cseat", 4);
