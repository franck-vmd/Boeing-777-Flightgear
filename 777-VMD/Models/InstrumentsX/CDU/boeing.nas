var cduInitialize = func(){
	props.getNode("/",1).setValue("autopilot/settings/transition-altitude",18000);
}
cduInitialize();

var input = func(v) {
	setprop("instrumentation/cdu/input",getprop("instrumentation/cdu/input")~v);
}

var _cduPageParent = {
  LSK_LEFT_KEYS : [ "LSK1L", "LSK2L", "LSK3L", "LSK4L", "LSK5L", "LSK6L" ],
  LSK_RIGHT_KEYS : [ "LSK1R", "LSK2R", "LSK3R", "LSK4R", "LSK5R", "LSK6R" ],
  
  scrollPage : func(direction) {}, # abstract function...
  isLSKLeft : func(v) {
    for (var i=0; i<6; i=i+1) {
      if (v == me.LSK_LEFT_KEYS[i]) return 1;
    }
    return 0;
  },
  isLSKRight : func(v) {
    for (var i=0; i<6; i=i+1) {
      if (v == me.LSK_RIGHT_KEYS[i]) return 1;
    }
    return 0;
  },
  getLSKLine : func(v) {
    for (var i=0; i<6; i=i+1) {
      if (v == me.LSK_LEFT_KEYS[i] or v == me.LSK_RIGHT_KEYS[i]) {
        return i;
      }
    }
    return -1;
  },
  calculatePageCount : func(dataCount, diplayedDataCount) {
    var pages = int(dataCount / diplayedDataCount);
    return (dataCount > pages * diplayedDataCount) ? pages + 1 : pages;
  }
};

var _cduDepartureArrivalParent = {
  parents : [ _cduPageParent ],
  airport : nil,
  selectedRunway : nil,
  selectedSid : "(none)",
  selectedSidTrans : nil,
  selectedApproach : "(none)",
  selectedStar : "(none)",
  selectedStarTrans : nil,
  hasSelectedRunway : func() { return me.selectedRunway != nil and me.selectedRunway != ""; },
  hasSelectedSid : func() { return me.selectedSid != nil and me.selectedSid != ""; },
  hasSelectedSidTrans : func() { return me.selectedSidTrans != nil and me.selectedSidTrans != ""; },
  hasSelectedApproach : func() { return me.selectedApproach != nil and me.selectedApproach != ""; },
  hasSelectedStar : func() { return me.selectedStar != nil and me.selectedStar != ""; },
  hasSelectedStarTrans : func() { return me.selectedStarTrans != nil and me.selectedStarTrans != ""; },
  
  getRunways : func() {
    var rwys = [];
    if ( me.airport != nil ) {
        foreach(var rwy; keys(me.airport.runways)) {
          append(rwys, rwy);
        }
        rwys = sort(rwys, func(a, b) { return cmp(a,b); });
    }
    return rwys;
  },
  
  getApproaches : func() {
    var approaches = [ "(none)" ];
    if ( me.airport != nil and me.hasSelectedRunway() ) {
      var apt = me.airport;
      var rwy = flightplan().destination_runway;
      var approachList = apt.getApproachList(rwy);
      if (size(approachList) == 0) {
        append(approaches, "DEFAULT");
      }
      else {
        foreach (var s; approachList) {
          append(approaches, s);
        }
        approaches = sort(approaches, func(a, b) { return cmp(a,b); });
      }  
    }
    return approaches;
  },
  
  getSids : func() {
    var sids = [ "(none)" ];
    if ( me.airport != nil and me.hasSelectedRunway() ) {
      var apt = me.airport;
      var rwy = flightplan().departure_runway;
      if (size(apt.sids(rwy)) == 0) {
        append(sids, "DEFAULT");
      }
      else {
        foreach (var s; apt.sids(rwy)) {
          append(sids, s);
        }
        sids = sort(sids, func(a, b) { return cmp(a,b); });
      }  
    }
    return sids;
  },
  
  getStars : func() {
    var stars = [ "(none)" ];
    if (me.airport != nil and me.hasSelectedRunway() ) {
      var apt = me.airport;
      var rwy = flightplan().destination_runway;
      foreach (var s; apt.stars(rwy)) {
          append(stars, s);
      }
      stars = sort(stars, func(a, b) { return cmp(a,b); });
    }
    return stars;
  },
  
  getSidTransitions : func() {
    var trans = [];
    
    if (me.airport != nil and me.hasSelectedSid() != nil) {
      var sid = me.airport.getSid(me.selectedSid);
      if (sid != nil) {
       trans = sid.transitions;
      }
    }
    return trans;
  },
  
  getStarTransitions : func() {
    var trans = [];
    
    if (me.airport != nil and me.hasSelectedStar() != nil) {
      var star = me.airport.getStar(me.selectedStar);
      if (star != nil) {
       trans = star.transitions;
      }
    }
    return trans;
  }
};

var cduArrival = {
  parents : [ _cduDepartureArrivalParent ],
  initialized : 0,
  page : 0,
  
  lskPressed : func(key, cduInput) {
     var line = me.getLSKLine(key);
     if (me.isLSKRight(key)) {
      if (line >=0 and line <5) {
        # runway or approach selection...
        if (!me.hasSelectedRunway()) {
          # runway selection
          me.selectRunway(line);
          return "";
        }
        else {
          if (line == 0) {
            # select another runway
            me.selectedRunway = nil;
            me.selectedStar = nil;
          }
          else if (!me.hasSelectedApproach()) {
            # an approach has been selected
            me.selectApproach(line);
            return "";
          }
          else if (line==1) {
            me.selectedApproach = 0;
          }
        }
      }
      else {
        # handle LSK6R...
      }
    }
    else if (me.isLSKLeft(key)) {
      if (line >=0 and line <5) {
        # stars and trans selection...
        if (!me.hasSelectedStar()) {
          # select a star...
          me.selectStar(line);
          return "";
        }
        else if (line==0) {
          # select another star...
          me.selectedStar = nil;
        }
      }
      else if (line==5 and (me.selectedRunway != nil or me.selectedStar != nil or me.selectedApproach != nil)) {
        # Erase
        me.airport = nil;
        me.selectedRunway = "";
        me.selectedApproach = "";
        me.selectedStar = "";
        me.selectedStarTrans = "";
        me.initialized = 0;
        me.storeArrivalInfo();
      }
    }
    return cduInput;
  },
  
  selectRunway : func(line) {
    var rwys = me.getRunways();
    var i = line + (me.page * 5);
    if (i < size(rwys)) {
      if (me.selectedRunway != rwys[i]) {
        me.selectedApproach = nil;
        me.selectedStar = nil;
      }
      me.selectedRunway = rwys[i];
      me.page = 0; # selected, return to page 0
      me.storeArrivalInfo();
    }
  },
  
  selectStar : func(line) {
    var stars = me.getStars();
    var i = line + (me.page * 5);
    if (i < size(stars)) {
      me.selectedStar = stars[i];
      me.selectedStarTrans = nil;
      me.page = 0;
      me.storeArrivalInfo();
    }
  },
  
  selectApproach : func(line) {
    var apprs = me.getApproaches();
    var i = (line-1) + (me.page * 4);
    if (i >= 0 and i < size(apprs)) {
      me.selectedApproach = apprs[i];
      me.page = 0;
      me.storeArrivalInfo();
    }
  },
  
  storeArrivalInfo : func() {
    var nilIsNone = func(o) { return (o==nil) ? "(none)" : o; };
    setprop("autopilot/route-manager/destination/runway", me.selectedRunway);
    setprop("autopilot/route-manager/destination/star", nilIsNone(me.selectedStar));
    setprop("autopilot/route-manager/destination/approach", nilIsNone(me.selectedApproach));
    print("Storing Rwy: ", me.selectedRunway, ", STAR: ", nilIsNone(me.selectedSid), " APPR: ", nilIsNone(me.selectedApproach));
  },
  
  render : func(output) {
    if (me.initialized == 0) {
      me.initialize();
    }
    var dataCount = 2;
    var max = func(a,b) { return (a>b) ? a : b; };
    
    output.title = (me.airport != nil) ? me.airport.id ~ " ARRIVALS" : "ARRIVALS";
		output.leftTitle[0] = me.hasSelectedSid() ? "STAR" : "STARS";
    output.rightTitle[0] = me.hasSelectedRunway() ? "RUNWAY" : "RUNWAYS";
		
    if (me.hasSelectedStar()) {
      output.left[0] = me.selectedStar;
      output.leftTitle[1] = "TRANS";
      if (me.hasSelectedStarTrans()) {
        output.left[1] = me.selectedStarTrans;
      }
      else {
        var transitions = me.getStarTransitions();
        var line = 1;
        for (var i=0; i<size(transitions) and line<5; i=i+1) {
          output.left[line] = transitions[i];
          line = line + 1;
        }
        dataCount = max(dataCount, size(transitions) + 1);
      }
    } else {
      var stars = me.getStars();
      var line = 0;
      for (var i=(me.page * 5); i<size(stars) and line <5; i=i+1) {
        output.left[line] = stars[i];
        line = line + 1;
      }
      dataCount = max(dataCount, size(stars));
    }
    
    if (me.hasSelectedRunway()) {
      output.right[0] = me.selectedRunway;
      if (me.hasSelectedApproach()) {
        output.rightTitle[1] = "APPROACH";
        output.right[1] = me.selectedApproach;
      }
      else {
        output.rightTitle[1] = "APPROACHES";
        var approaches = me.getApproaches();
        var line = 1;
        for (var i=(me.page * 4); i<size(approaches) and line<5; i=i+1) {
          output.right[line] = approaches[i];
          line = line + 1;
        }
        dataCount = max(dataCount, size(approaches) + 1);
      }
    } 
    else {
      var rwys = me.getRunways();
      var line = 0;
      for (var i=(me.page * 5); i<size(rwys) and line<5; i=i+1) {
        output.right[line] = rwys[i];
        line = line + 1;
      }
      dataCount = max(dataCount, size(rwys));
    }
		
    output.page = (me.page + 1) ~ "/" ~ me.calculatePageCount(dataCount, 5);
    
    output.leftTitle[5]  = "-----------------------";
    output.rightTitle[5] = "-----------------------";
    if ( me.selectedRunway != nil or me.selectedStar != nil or me.selectedApproach != nil) {
      output.left[5] = "<ERASE";
    }
		output.right[5] = "ROUTE>";
  },
  
  scrollPage : func(direction) {
    me.page = me.page + direction;
    if (me.page < 0) me.page = 0;
    
    var cnt = 2;
    var pageSize = (!me.hasSelectedRunway() or !me.hasSelectedStar()) ? 5 : 4;
    
    if (!me.hasSelectedRunway()) {
      cnt = size(me.getRunways());
    }
    else {
      if (!me.hasSelectedStar()) cnt = size(me.getStars());
      if (!me.hasSelectedApproach()) {
        var max = func(a,b) { return (a>b) ? a : b; };
        cnt = max(cnt, size(me.getApproaches()) + 1);
      }
    }
    var pageCnt = me.calculatePageCount(cnt, pageSize);
    
    if (me.page >= pageCnt) me.page = pageCnt - 1;
  },
  
  initialize : func() {
    me.airport = flightplan().destination;
    me.selectedRunway = getprop("autopilot/route-manager/destination/runway");
    me.selectedStar = getprop("autopilot/route-manager/destination/star");
    me.selectedArrival = getprop("autopilot/route-manager/destination/approach");
    me.initialized = 1;
  }
};

var cduDeparture = {
  parents : [ _cduDepartureArrivalParent ],
  initialized : 0,
  page : 0,
  
  scrollPage : func(direction) {
    me.page = me.page + direction;
    if (me.page < 0) me.page = 0;
    
    var cnt = 2;
    if (!me.hasSelectedRunway()) cnt = size(me.getRunways());
    else if (!me.hasSelectedSid()) cnt = size(me.getSids());
    var pageCnt = me.calculatePageCount(cnt, 5);
    
    if (me.page >= pageCnt) me.page = pageCnt - 1;
  },
  lskPressed : func(key, cduInput) {
    var line = me.getLSKLine(key); 
    if (me.isLSKRight(key)) {
      if (!me.hasSelectedRunway()) {
        if (line >=0 and line <5) {
          me.selectRunway(line);
          return "";
        }
      }
      else {
        if (line == 0) {
          me.selectedRunway = nil;
          me.selectedSid = "(none)";
        }
      }
    }
    else if (me.isLSKLeft(key)) {
      if (me.hasSelectedSid()) {
        if (line == 0) me.selectedSid = nil;
      }
      else {
        if (line>=0 and line<5 ) {
          me.selectSid(line);
        }
      }
      if (line==5 and (me.selectedRunway != nil or me.selectedSid != nil)) {
        # Erase
        me.airport = nil;
        me.selectedRunway = "";
        me.selectedSid = "";
        me.selectedSidTrans = "";
        me.initialized = 0;
        me.storeDepartureInfo();
      }
    }
    return cduInput;
  },
  
  selectRunway : func(line) {
    var rwys = me.getRunways();
    var i = line + (me.page * 5);
    if (i < size(rwys)) {
      me.selectedRunway = rwys[i];
      me.page = 0; # selected, return to page 0
      me.storeDepartureInfo();
    }
  },
  
  selectSid : func(line) {
    var sids = me.getSids();
    var i = line + (me.page * 5);
    if (i < size(sids)) {
      me.selectedSid = sids[i];
      me.page = 0; # selected, return to page 0
      me.storeDepartureInfo();
    }
  },
  
  storeDepartureInfo : func() {
    setprop("autopilot/route-manager/departure/runway", me.selectedRunway);
    setprop("autopilot/route-manager/departure/sid", me.selectedSid);
    print("Storing Rwy: ", me.selectedRunway, ", SID: ", me.selectedSid);
  },
  
  render : func(output) {
    if (me.initialized == 0) {
      me.initialize();
    }
    var dataCount = 2;
    var max = func(a,b) { return (a>b) ? a : b; };
    
    output.title = (me.airport != nil) ? me.airport.id ~ " DEPARTURES" : "DEPARTURES";
		output.leftTitle[0] = me.hasSelectedSid() ? "SID" : "SIDS";
    output.rightTitle[0] = me.hasSelectedRunway() ? "RWY" : "RUNWAYS";
		
    if (me.hasSelectedSid()) {
      output.left[0] = me.selectedSid;
      output.leftTitle[1] = "TRANS";
      if (me.hasSelectedSidTrans()) {
        output.left[1] = me.selectedSidTrans;
      }
      else {
        var transitions = me.getSidTransitions();
        var line = 1;
        for (var i=0; i<size(transitions) and line<5; i=i+1) {
          output.left[line] = transitions[i];
          line = line + 1;
        }
        dataCount = max(dataCount, size(transitions) + 1);
      }
    } else {
      var sids = me.getSids();
      var line = 0;
      for (var i=(me.page * 5); i<size(sids) and line <5; i=i+1) {
        output.left[line] = sids[i];
        line = line + 1;
      }
      dataCount = max(dataCount, size(sids));
    }
    
    if (me.hasSelectedRunway()) {
      output.right[0] = me.selectedRunway;
    } 
    else {
      var rwys = me.getRunways();
      var line = 0;
      for (var i=(me.page * 5); i<size(rwys) and line<5; i=i+1) {
        output.right[line] = rwys[i];
        line = line + 1;
      }
      dataCount = max(dataCount, size(rwys));
    }
		
    output.page = (me.page + 1) ~ "/" ~ me.calculatePageCount(dataCount, 5);
    
    output.leftTitle[5]  = "-----------------------";
    output.rightTitle[5] = "-----------------------";
    if ( me.selectedRunway != nil or me.selectedSid != nil ) {
      output.left[5] = "<ERASE";
    }
		output.right[5] = "ROUTE>";
  },
  
  initialize : func() {
    me.airport = flightplan().departure;
    me.selectedRunway = getprop("autopilot/route-manager/departure/runway");
    #me.selectedSid =    getprop("autopilot/route-manager/departure/sid");
    me.initialized = 1;
  },
  
};

var cduLegs = {
  parents: [ _cduPageParent ],
  page: 0,
  selectedWpIndex: -1,
  
  scrollPage : func(direction) {
    var newPage = me.page + direction;
    if (newPage>=0 and newPage<me.getPageCount()) {
      me.page = newPage;
    }
  },
  
  lskPressed : func(key, cduInput) {
    var line = me.getLSKLine(key);
    
    if (me.isLSKLeft(key)) {
      if (line >=0 and line <5) {
        return me.addOrDeleteWaypoint(me.page * 5 + line, cduInput);
      }
    }
    else if (me.isLSKRight(key)) {
      if (line >=0 and line <5) {
        me.setAltitude(me.page * 5 + line, cduInput);
        return "";
      }
      if (line == 5) {
        setprop("autopilot/route-manager/input","@ACTIVATE");
        return "";
      }
    }
    else if (key == "exec"){
      return me.jumpToSelectedWaypoint(cduInput);
    }
  },
  
  addOrDeleteWaypoint : func(wpIndex, cduInput) {
    me.selectedWpIndex = -1;
    if (cduInput == nil or cduInput == "") {
      var curWp = getprop("autopilot/route-manager/route/wp["~wpIndex~"]/id");
      if ( curWp != nil){
        me.selectedWpIndex = wpIndex;
        return curWp;
      }
      else {
        return "";
      }
    } 
    else if (cduInput == "DELETE"){
      setprop("autopilot/route-manager/input","@DELETE"~wpIndex);
      return "";
    }
    else {
      setprop("autopilot/route-manager/input","@INSERT"~wpIndex~":"~cduInput);
      return "";
    }
    if (cduInput == "EXEC"){
      setprop("autopilot/route-manager/input","@JUMP"~wpIndex);
      return "";
    }
  },
  
  setAltitude : func(wpIndex, altitude) {
    
    setprop("autopilot/route-manager/route/wp["~wpIndex~"]/altitude-ft",altitude);
    if (substr(altitude,0,2) == "FL"){
      setprop("autopilot/route-manager/route/wp["~wpIndex~"]/altitude-ft",substr(altitude,2)*100);
    }
  },
  
  jumpToSelectedWaypoint : func(cduInput) {
    var wps = me.getWaypoints();
    if (me.selectedWpIndex>=0 and me.selectedWpIndex < size(wps)) {
      var wpNode = wps[me.selectedWpIndex];
      if (wpNode != nil) {
        var ident = wpNode.getChild("id").getValue();
        if (ident == cduInput) {
          setprop("autopilot/route-manager/current-wp", me.selectedWpIndex);
          return "";
        }
      }
    }
    return cduInput;
  },
  
  render : func(output) {
    output.title = (getprop("autopilot/route-manager/active") == 1)
        ? "ACT RTE 1 LEGS"
        : "RTE 1 LEGS";
        
    var activeWp = me.getActiveWP();
    var waypoints = me.getWaypoints();
    var fp = flightplan();
    var waypointsLength = size(waypoints);
    
    if (me.page >= me.getPageCount()) {
      me.page = 0;
    }
    
    output.page = (me.page+1) ~ "/" ~ me.getPageCount();
    
    for (var line=0; line<5; line=line+1) {
      var currentWpIndex = me.page * 5 + line;
      
      
      if (currentWpIndex < waypointsLength) {
        var currentWpNode = waypoints[currentWpIndex];
        var ident = currentWpNode.getChild("id").getValue();
        var alt = currentWpNode.getChild("altitude-ft").getValue();
        var speedNode = currentWpNode.getChild("speed-kts");
        var fp = flightplan();
        
        
        output.left[line] = ident;
        output.center[line] = (currentWpIndex == activeWp) ? "<---ACTIVE" : "";
        output.right[line] = ((speedNode==nil) ? "---" : sprintf("%3.0f", speedNode.getValue())) 
            ~ "/"
            ~ ((alt==nil or alt < 0) ? "-----" : int(alt));
        
        if (currentWpIndex>0) {
          var bearing = waypoints[currentWpIndex-1].getChild("leg-bearing-true-deg").getValue();
          var distance = waypoints[currentWpIndex-1].getChild("leg-distance-nm").getValue();
          
          output.leftTitle[line] = sprintf("%3.0f", bearing);
          output.centerTitle[line] = sprintf("%3.0f", distance) ~ " NM";
        }
        
      }
    }
    
    output.left[5] = "<RTE 2 LEGS";
		output.right[5] = (getprop("autopilot/route-manager/active") == 1)
        ? "RTE DATA>"
        : "ACTIVATE>";
  },
  
  getActiveWP: func() {
    return int(getprop("autopilot/route-manager/current-wp"));
  },
  getWaypoints: func() {
    return props.globals.getNode("autopilot/route-manager/route").getChildren("wp");
  },
  getPageCount: func() {
    return me.calculatePageCount(size(me.getWaypoints()), 5);
  }
};

var cduHold = {
  active : 0,
  fix : "",
  hdg : 0,
  minutes : 4,
  speedKts : 240.0,
  distance : 4.0,
  radius   : 1.0,
  turnLeft : 1,
  holdLegs : [],
  holdListenerID : nil,
  entryWP : -1,
  exitWP : -1,
  
  render : func(output) {
    output.title          = "HOLD";
    output.leftTitle[0]   = "Hold fix";
    output.left[0]        = me.fix;
    output.leftTitle[1]   = "Heading";
    output.left[1]        = sprintf("%3d",me.hdg);
    output.leftTitle[2]   = "Turn";
    output.left[2]        = (me.turnLeft) ? "LEFT" : "RIGHT"; 
    output.rightTitle[0]  = "Time in Hold [min]";
    output.right[0]       = sprintf("%2.1f", me.minutes);
    output.rightTitle[1]  = "Speed [kts]";
    output.right[1]       = sprintf("%3.1f", me.speedKts);
    output.right[5]       = (me.active) ? "LEAVE HOLD>" : "ENTER HOLD>";    
  },
  
  lskPressed : func(key, cduInput) {
    if (key == "LSK1L") {
      me.fix = cduInput;
    }
    else if ( key == "LSK2L" ) {
      me.hdg = cduInput;
    }
    else if ( key == "LSK3L" ) {
      me.turnLeft = (me.turnLeft) ? 0 : 1;
      return cduInput;
    }
    else if ( key == "LSK1R" ) {
      me.minutes = cduInput;
    }
    else if ( key == "LSK2R" ) {
      me.speedKts = cduInput;
    }
    else if ( key == "LSK6R" ) {
      me.active = (me.active) ? 0 : 1;
      if (me.active) {
        
        me.createHoldWPs();
        
        var loop = func() {
          var cur = flightplan().current;
          if (cur == cduHold.exitWP-1 ) {
            print("DEBUG: CDU Hold, end of hold reached... preparing for another round!");
            var oneLoopBefore = flightplan().current - size(cduHold.holdLegs);
            setprop('autopilot/route-manager/current-wp', oneLoopBefore);
          }
          else {
            print("DEBUG: CDU Hold, loop on WP ", flightplan().current);
          }
        };
        me.holdListenerID = setlistener('/autopilot/route-manager/current-wp', loop);
        
      }
      else {
        if (me.holdListenerID != nil) {
          print("DEBUG: CDU Hold, deactivate hold.");
          removelistener(me.holdListenerID);
          
          # premature end... (if on the final leg of the hold)
          var oneLoopAhead = flightplan().current + size(cduHold.holdLegs);
          if (oneLoopAhead < me.exitWP) {
            print("DEBUG: CDU Hold, exiting hold earlier.");
            flightplan().current = oneLoopAhead;
          }
        }
      }
      return cduInput;
    }
    return "";
  },  
  
  createHoldWPs : func() {
    if (me.active) {
      # calculate distance and radius...
      me.distance = me.minutes * me.speedKts / 250;
      me.radius = me.distance / math.pi;
      
      
      var _deg = func(hdg) { return (hdg < 0) ? (hdg + 360) : ( (hdg >= 360) ? (hdg - 360) : hdg ); };
      var _formatPos = func(pos) { return pos.lon() ~ ',' ~ pos.lat(); }; 
      
      # calculate WP 3 miles ahead
      var ahead = geo.Coord.new();
      ahead.set_latlon(getprop('position/latitude-deg'), getprop('position/longitude-deg'));
      ahead.apply_course_distance(getprop('orientation/heading-deg'), 3 * 1852 ); 
      
      
      # calculate waypoints...
      var turn = (me.turnLeft) ? -1 : 1;
      var rm = me.radius * 1852;
      var m1 = me._getNavaidPosition(me.fix).apply_course_distance(_deg(me.hdg + turn * 90), rm);
      var m2 = (geo.Coord.new(m1)).apply_course_distance(_deg(me.hdg + 180), me.distance * 1852);
      
      var _createArcPoint = func(m, r, c) {
        var p = (geo.Coord.new(m)).apply_course_distance(_deg(me.hdg + turn * (c - 90)), r);
        return _formatPos(p);
      }
      
      
      var entryLeg = [
        _formatPos(ahead),
        _createArcPoint(m2, rm, 0),
        me.fix,  
      ];
      
      me.holdLegs = [
        _createArcPoint(m1, rm, 20),
        _createArcPoint(m1, rm, 40),
        _createArcPoint(m1, rm, 60),
        _createArcPoint(m1, rm, 80),
        _createArcPoint(m1, rm, 100),
        _createArcPoint(m1, rm, 120),
        _createArcPoint(m1, rm, 140),
        _createArcPoint(m1, rm, 160),
        _createArcPoint(m1, rm, 180),
        _createArcPoint(m2, rm, 180),
        _createArcPoint(m2, rm, 200),
        _createArcPoint(m2, rm, 220),
        _createArcPoint(m2, rm, 240),
        _createArcPoint(m2, rm, 260),
        _createArcPoint(m2, rm, 280),
        _createArcPoint(m2, rm, 300),
        _createArcPoint(m2, rm, 320),
        _createArcPoint(m2, rm, 340),
        _createArcPoint(m2, rm, 0),
        me.fix
      ];
      
      var curWpIdx = getprop("autopilot/route-manager/current-wp");
      
      me.entryWP = me.insertLegs(entryLeg, curWpIdx);
      me.exitWP = me.insertLegs(me.holdLegs, me.entryWP);
      
      setprop("autopilot/route-manager/current-wp", curWpIdx);
    }
  },
  
  insertLegs: func(legs, index) {
    for (i=0; i<size(legs); i += 1) {
      print("DEBUG: CDU Hold: Inserting HOLD at ", index + i , ": ", legs[i]);
      setprop("autopilot/route-manager/input","@INSERT"~(index + i)~":"~legs[i]);
    }
    return index + size(legs);
  },
  
  _getNavaidPosition: func(ident) {
    var navaids = positioned.sortByRange( positioned.findByIdent( ident , "fix,vor,ndb,tacan,airport") );
    foreach ( var navaid ; navaids) {
      if (ident == navaid.id) {    
        var pos = geo.Coord.new();
        pos.set_latlon( navaid.lat, navaid.lon );
        return pos;
      }
    }
    return nil;
  }
  
};

# ==========
# CDU Pages

var cduPages = {
  "HOLD"  : cduHold,
  "RTE1_LEGS" : cduLegs,
  "RTE1_DEP" : cduDeparture,
  "RTE1_ARR" : cduArrival
};


var key = func(v) {
		var cduDisplay = getprop("instrumentation/cdu/display");
		var serviceable = getprop("instrumentation/cdu/serviceable");
		var eicasDisplay = getprop("instrumentation/eicas/display");
		var cduInput = getprop("instrumentation/cdu/input");
		
		if (serviceable == 1){
      # dispatch by page (new)
      if (contains(cduPages, cduDisplay)) {
        var page = cduPages[cduDisplay];
        if (v == "NEXT_PAGE") {
          page.scrollPage(1);
        } else if (v == "PREV_PAGE") {
          page.scrollPage(-1);
        }
        else {
          cduInput = page.lskPressed(v, cduInput);
        }
      }
      
      else { # dispatch by key (old)  
        if (v == "LSK1L"){
          if (cduDisplay == "DEP_ARR_INDEX"){
            cduDisplay = "RTE1_DEP";
          }
          if (cduDisplay == "EICAS_MODES"){
            eicasDisplay = "ENG";
          }
          if (cduDisplay == "EICAS_SYN"){
            eicasDisplay = "ELEC";
          }
          if (cduDisplay == "INIT_REF"){
            cduDisplay = "IDENT";
          }
          if (cduDisplay == "MENU"){
            cduDisplay = "FMC";
          }
          if (cduDisplay == "NAV_RAD"){
            setprop("instrumentation/nav[0]/frequencies/selected-mhz",cduInput);
            cduInput = "";
          }
          if (cduDisplay == "RTE1_1"){
            setprop("autopilot/route-manager/departure/airport",cduInput);
            cduInput = "";
          }
          if (cduDisplay == "TO_REF"){
            setprop("instrumentation/fmc/to-flap",cduInput);
            cduInput = "";
          }
        }
        if (v == "LSK1R"){
          if (cduDisplay == "EICAS_MODES"){
            eicasDisplay = "FUEL";
          }
          if (cduDisplay == "EICAS_SYN"){
            eicasDisplay = "HYD";
          }
          if (cduDisplay == "NAV_RAD"){
            setprop("instrumentation/nav[1]/frequencies/selected-mhz",cduInput);
            cduInput = "";
          }
          if (cduDisplay == "PERF_INIT"){
             setprop("autopilot/route-manager/cruise/altitude-ft",cduInput);
             cduInput = "";
          }
          if (cduDisplay == "RTE1_1"){
            setprop("autopilot/route-manager/destination/airport",cduInput);
            cduInput = "";
          }
        }
        if (v == "LSK2L"){
          if (cduDisplay == "EICAS_MODES"){
            eicasDisplay = "STAT";
          }
          if (cduDisplay == "EICAS_SYN"){
            eicasDisplay = "ECS";
          }
          if (cduDisplay == "NAV_RAD"){
            setprop("instrumentation/nav[0]/radials/selected-deg",cduInput);
            cduInput = "";
          }
          if (cduDisplay == "POS_INIT"){
            setprop("instrumentation/fmc/ref-airport",cduInput);
            cduInput = "";;
          }
          if (cduDisplay == "INIT_REF"){
            cduDisplay = "POS_INIT";
          }
          if (cduDisplay == "RTE1_1"){
            setprop("autopilot/route-manager/departure/runway",cduInput);
            cduInput = "";;
          }
        }
        if (v == "LSK2R"){
          if (cduDisplay == "PERF_INIT"){
             setprop("autopilot/route-manager/cruise/speed-kts",cduInput);
             cduInput = "";
          }
          if (cduDisplay == "DEP_ARR_INDEX"){
            cduDisplay = "RTE1_ARR";
          }
          else if (cduDisplay == "EICAS_MODES"){
            eicasDisplay = "GEAR";
          }
          else if (cduDisplay == "EICAS_SYN"){
            eicasDisplay = "DRS";
          }
          if (cduDisplay == "NAV_RAD"){
            setprop("instrumentation/nav[1]/radials/selected-deg",cduInput);
            cduInput = "";
          }
          else if (cduDisplay == "MENU"){
            eicasDisplay = "EICAS_MODES";
          }
        }
        if (v == "LSK3L"){
          if (cduDisplay == "INIT_REF"){
            cduDisplay = "PERF_INIT";
          }
          if (cduDisplay == "NAV_RAD"){
            setprop("instrumentation/adf[0]/frequencies/selected-khz",cduInput);
            cduInput = "";
          }
        }
        if (v == "LSK3R"){
          if (cduDisplay == "VNAV")
	  {
	          if (num(cduInput) != nil)
	          {
	       setprop("autopilot/settings/transition-altitude",cduInput);
	       cduInput = "";
		}
	  }
          if (cduDisplay == "PERF_INIT"){
             setprop("autopilot/settings/counter-set-altitude-ft",cduInput);
             cduInput = "";
          }
          if (cduDisplay == "NAV_RAD") {
          setprop("instrumentation/adf[1]/frequencies/selected-khz",cduInput);
            cduInput = "";
         }
        }
        if (v == "LSK4L"){
          if (cduDisplay == "INIT_REF"){
            cduDisplay = "THR_LIM";
          }
        }
        if (v == "LSK4R"){
          if (cduDisplay == "PERF_INIT"){
             setprop("autopilot/settings/target-speed-kt",cduInput);
             cduInput = "";
          }
        }
        if (v == "LSK5L"){
          if (cduDisplay == "INIT_REF"){
            cduDisplay = "TO_REF";
          }
        }
        if (v == "LSK5R"){
          if (cduDisplay == "NAV_RAD") {
            var nav0freq = getprop("instrumentation/nav[0]/frequencies/selected-mhz");
            var nav0rad = getprop("instrumentation/nav[0]/radials/selected-deg");
            var nav1freq = getprop("instrumentation/nav[1]/frequencies/selected-mhz");
            var nav1rad = getprop("instrumentation/nav[1]/radials/selected-deg");
            
            print("VOR1"~nav0freq);
            
            setprop("instrumentation/nav[0]/frequencies/selected-mhz",nav1freq);
            setprop("instrumentation/nav[0]/radials/selected-deg",nav1rad);
            setprop("instrumentation/nav[1]/frequencies/selected-mhz",nav0freq);
            setprop("instrumentation/nav[1]/radials/selected-deg",nav0rad);
          }
        }
        if (v == "LSK6L"){
          if (cduDisplay == "INIT_REF"){
            cduDisplay = "APP_REF";
          }
          if (cduDisplay == "APP_REF"){
            cduDisplay = "INIT_REF";
          }
          if ((cduDisplay == "IDENT") or (cduDisplay = "MAINT") or (cduDisplay = "PERF_INIT") or (cduDisplay = "POS_INIT") or (cduDisplay = "POS_REF") or (cduDisplay = "THR_LIM") or (cduDisplay = "TO_REF")){
            cduDisplay = "INIT_REF";
          }
        }
        if (v == "LSK6R"){
          if (cduDisplay == "THR_LIM"){
            cduDisplay = "TO_REF";
          }
          else if (cduDisplay == "APP_REF"){
            cduDisplay = "THR_LIM";
          }
          else if ((cduDisplay == "RTE1_1")){
            setprop("autopilot/route-manager/input","@ACTIVATE");
          }
          else if ((cduDisplay == "POS_INIT") or (cduDisplay == "DEP") or (cduDisplay == "RTE1_ARR") or (cduDisplay == "RTE1_DEP")){
            cduDisplay = "RTE1_1";
          }
          else if ((cduDisplay == "IDENT") or (cduDisplay == "TO_REF")){
            cduDisplay = "POS_INIT";
          }
          else if (cduDisplay == "EICAS_SYN"){
            cduDisplay = "EICAS_MODES";
          }
          else if (cduDisplay == "EICAS_MODES"){
            cduDisplay = "EICAS_SYN";
          }
          else if (cduDisplay == "INIT_REF"){
            cduDisplay = "MAINT";
          }
        }
        
      }
			
			setprop("instrumentation/cdu/display",cduDisplay);
			if (eicasDisplay != nil){
				setprop("instrumentation/eicas/display",eicasDisplay);
			}
			setprop("instrumentation/cdu/input",cduInput);
		}
	}
	
var delete = func {
		var length = size(getprop("instrumentation/cdu/input")) - 1;
		setprop("instrumentation/cdu/input",substr(getprop("instrumentation/cdu/input"),0,length));
	}
	
var i = 0;

var plusminus = func {	
	var end = size(getprop("instrumentation/cdu/input"));
	var start = end - 1;
	var lastchar = substr(getprop("instrumentation/cdu/input"),start,end);
	if (lastchar == "+"){
		me.delete();
		me.input('-');
		}
	if (lastchar == "-"){
		me.delete();
		me.input('+');
		}
	if ((lastchar != "-") and (lastchar != "+")){
		me.input('+');
		}
	}

var cdu = func{
		var display = getprop("instrumentation/cdu/display");
		var serviceable = getprop("instrumentation/cdu/serviceable");
    var output = {
      title : "",
      page : "",
      leftTitle : [ "", "", "", "", "", "" ],
      left : [ "", "", "", "", "", "" ],
      centerTitle : [ "", "", "", "", "", "" ],
      center : [ "", "", "", "", "", "" ],
      rightTitle : [ "", "", "", "", "", "" ],
      right : [ "", "", "", "", "", "" ],
    };
		output.right[0] = "";	output.right[1] = "";	output.right[2] = "";	output.right[3] = "";	output.right[4] = "";	output.right[5] = "";
		
    if (contains(cduPages, display)) {
      var page = cduPages[display];
      page.render(output);
    }
    else {
      
      if (display == "MENU") {
        output.title = "MENU";
        output.left[0] = "<FMC";
        output.rightTitle[0] = "EFIS CP";
        output.right[0] = "SELECT>";
        output.left[1] = "<ACARS";
        output.rightTitle[1] = "EICAS CP";
        output.right[1] = "SELECT>";
        output.left[5] = "<ACMS";
        output.right[5] = "CMC>";
      }
      if (display == "ALTN_NAV_RAD") {
        output.title = "ALTN NAV RADIO";
      }
      if (display == "FMC") {
        output.title = "JUMP TO";
      }
      if (display == "VNAV") {
	output.title = "ACT ECON CLB";
	output.rightTitle[2] = "TRANS ALT";
	output.right[2]  = sprintf("%2.0f",getprop("autopilot/settings/transition-altitude"));
      }
      if (display == "APP_REF") {
        output.title = "APPROACH REF";
        output.leftTitle[0] = "GROSS WT";
        output.rightTitle[0] = "FLAPS    VREF";
        if (getprop("instrumentation/fmc/vspeeds/Vref") != nil){
          output.left[0] = getprop("instrumentation/fmc/vspeeds/Vref");
        }
        if (getprop("autopilot/route-manager/destination/airport") != nil){
          output.leftTitle[3] = getprop("autopilot/route-manager/destination/airport");
        }
        output.left[5] = "<INDEX";
        output.right[5] = "THRUST LIM>";
      }
      if (display == "DEP_ARR_INDEX") {
        output.title = "DEP/ARR INDEX";
        output.left[0] = "<DEP";
        output.centerTitle[0] = "RTE 1";
        if (getprop("autopilot/route-manager/departure/airport") != nil){
          output.center[0] = getprop("autopilot/route-manager/departure/airport");
        }
        output.right[0] = "";
        if (getprop("autopilot/route-manager/destination/airport") != nil){
          output.center[1] = getprop("autopilot/route-manager/destination/airport");
        }
        output.right[1] = "ARR>";
        output.left[2] = "";
        output.right[2] = "";
        output.right[3] = "";
        output.leftTitle[5] ="DEP";
        output.left[5] = "<----";
        output.center[5] = "OTHER";
        output.rightTitle[5] ="ARR";
        output.right[5] = "---->";
      }
      if (display == "EICAS_MODES") {
        output.title = "EICAS MODES";
        output.left[0] = "<ENG";
        output.right[0] = "FUEL>";
        output.left[1] = "<STAT";
        output.right[1] = "GEAR>";
        output.left[4] = "<CANC";
        output.right[4] = "RCL>";
        output.right[5] = "SYNOPTICS>";
      }
      if (display == "EICAS_SYN") {
        output.title = "EICAS SYNOPTICS";
        output.left[0] = "<ELEC";
        output.right[0] = "HYD>";
        output.left[1] = "<ECS";
        output.right[1] = "DOORS>";
        output.left[4] = "<CANC";
        output.right[4] = "RCL>";
        output.right[5] = "MODES>";
      }
      if (display == "FIX_INFO") {
        output.title = "FIX INFO";
        output.left[0] = sprintf("%3.2f", getprop("instrumentation/nav[0]/frequencies/selected-mhz-fmt"));
        output.right[0] = sprintf("%3.2f", getprop("instrumentation/nav[1]/frequencies/selected-mhz-fmt"));
        output.left[1] = sprintf("%3.2f", getprop("instrumentation/nav[0]/radials/selected-deg"));
        output.right[1] = sprintf("%3.2f", getprop("instrumentation/nav[1]/radials/selected-deg"));
        output.left[5] = "<ERASE FIX";
      }
      if (display == "IDENT") {
        output.title = "IDENT";
        output.leftTitle[0] = "MODEL";
        if (getprop("instrumentation/cdu/ident/model") != nil){
          output.left[0] = getprop("instrumentation/cdu/ident/model");
        }
        output.rightTitle[0] = "ENGINES";
        output.leftTitle[1] = "NAV DATA";
        if (getprop("instrumentation/cdu/ident/engines") != nil){
          output.right[0] = getprop("instrumentation/cdu/ident/engines");
        }
        output.left[5] = "<INDEX";
        output.right[5] = "POS INIT>";
      }
      if (display == "INIT_REF") {             
        output.title = "INIT/REF INDEX";
        output.left[0] = "<IDENT";
        output.right[0] = "NAV DATA>";
        output.left[1] = "<POS";
        output.left[2] = "<PERF";
        output.left[3] = "<THRUST LIM";
        output.left[4] = "<TAKEOFF";
        output.left[5] = "<APPROACH";
        output.right[5] = "MAINT>";
      }
      if (display == "MAINT") {
        output.title = "MAINTENANCE INDEX";
        output.left[0] = "<CROS LOAD";
        output.right[0] = "BITE>";
        output.left[1] = "<PERF FACTORS";
        output.left[2] = "<IRS MONITOR";
        output.left[5] = "<INDEX";
      }
      if (display == "NAV_RAD") {
        output.title = "NAV RADIO";
        output.leftTitle[0] = "VOR L";
        output.left[0] = sprintf("%3.2f", getprop("instrumentation/nav[0]/frequencies/selected-mhz-fmt"));
        output.rightTitle[0] = "VOR R";
        output.right[0] = sprintf("%3.2f", getprop("instrumentation/nav[1]/frequencies/selected-mhz-fmt"));
        output.leftTitle[1] = "CRS";
        output.centerTitle[1] = "RADIAL";
        output.center[1] = sprintf("%3.2f", getprop("instrumentation/nav[0]/radials/selected-deg"))~"   "~sprintf("%3.2f", getprop("instrumentation/nav[1]/radials/selected-deg"));
        output.rightTitle[1] = "CRS";
        output.leftTitle[2] = "ADF L";
        output.left[2] = sprintf("%3.2f", getprop("instrumentation/adf[0]/frequencies/selected-khz"));
        output.rightTitle[2] = "ADF R";
        output.right[2] = sprintf("%3.2f", getprop("instrumentation/adf[1]/frequencies/selected-khz"));
        output.right[4] = "SWITCH>";
      }
      if (display == "PERF_INIT") {
        output.title = "PERF INIT";
        output.leftTitle[0] = "GR WT";
        output.rightTitle[0] = "CRZ ALT";
        output.right[0] = sprintf("%2.0f", getprop("autopilot/route-manager/cruise/altitude-ft"));
        output.rightTitle[1] = "CRZ SPD";
        output.right[1] = sprintf("%2.0f", getprop("autopilot/route-manager/cruise/speed-kts"));
        output.rightTitle[2] = "ALT";
        output.right[2] = sprintf("%2.0f", getprop("autopilot/settings/counter-set-altitude-ft"));
        output.leftTitle[1] = "FUEL";
        output.leftTitle[2] = "ZFW";
        output.leftTitle[3] = "RESERVES";
        output.rightTitle[3] = "SPD";
        output.right[3] = sprintf("%2.0f", getprop("autopilot/settings/target-speed-kt"));
        output.leftTitle[4] = "COST INDEX";
        output.rightTitle[4] = "STEP SIZE";
        output.left[5] = "<INDEX";
        output.right[5] = "THRUST LIM>";	
        if (getprop("sim/flight-model") == "jsb") {
          output.left[0] = sprintf("%3.1f", (getprop("fdm/jsbsim/inertia/weight-lbs")/1000));
          output.left[1] = sprintf("%3.1f", (getprop("fdm/jsbsim/propulsion/total-fuel-lbs")/1000));
          output.left[2] = sprintf("%3.1f", (getprop("fdm/jsbsim/inertia/empty-weight-lbs")/1000));
        }
        elsif (getprop("sim/flight-model") == "yasim") {
          output.left[0] = sprintf("%3.1f", (getprop("yasim/gross-weight-lbs")/1000));
          output.left[1] = sprintf("%3.1f", (getprop("consumables/fuel/total-fuel-lbs")/1000));

          yasim_emptyweight = getprop("yasim/gross-weight-lbs");
          yasim_emptyweight -= getprop("consumables/fuel/total-fuel-lbs");
          yasim_weights = props.globals.getNode("sim").getChildren("weight");
          for (i = 0; i < size(yasim_weights); i += 1) {
            yasim_emptyweight -= yasim_weights[i].getChild("weight-lb").getValue();
          }

          output.left[2] = sprintf("%3.1f", yasim_emptyweight/1000);
        }
      }
      if (display == "POS_INIT") {
        output.title = "POS INIT";
        output.left[5] = "<INDEX";
        output.right[5] = "ROUTE>";
      }
      if (display == "POS_REF") {
        output.title = "POS REF";
        output.leftTitle[0] = "FMC POST";
        output.left[0] = getprop("position/latitude-string")~" "~getprop("position/longitude-string");
        output.rightTitle[0] = "GS";
        output.right[0] = sprintf("%3.0f", getprop("velocities/groundspeed-kt"));
        output.left[4] = "<PURGE";
        output.right[4] = "INHIBIT>";
        output.left[5] = "<INDEX";
        output.right[5] = "BRG/DIST>";
      }
      if (display == "RTE1_1") {
        output.title = "RTE 1";
        output.page = "1/2";
        output.leftTitle[0] = "ORIGIN";
        if (getprop("autopilot/route-manager/departure/airport") != nil){
          output.left[0] = getprop("autopilot/route-manager/departure/airport");
        }
        output.rightTitle[0] = "DEST";
        if (getprop("autopilot/route-manager/destination/airport") != nil){
          output.right[0] = getprop("autopilot/route-manager/destination/airport");
        }
        output.leftTitle[1] = "RUNWAY";
        if (getprop("autopilot/route-manager/departure/runway") != nil){
          output.left[1] = getprop("autopilot/route-manager/departure/runway");
        }
        output.rightTitle[1] = "FLT NO";
        output.right[1] = getprop("instrumentation/fmc/flight-number") or " ";
        output.rightTitle[2] = "CO ROUTE";
        output.left[4] = "<RTE COPY";
        output.left[5] = "<RTE 2";
        if (getprop("autopilot/route-manager/active") == 1){
          output.right[5] = "PERF INIT>";
          }
        else {
          output.right[5] = "ACTIVATE>";
          }
      }
      if (display == "RTE1_2") {
        output.title = "RTE 1";
        output.page = "2/2";
        output.leftTitle[0] = "VIA";
        output.rightTitle[0] = "TO";
        if (getprop("autopilot/route-manager/route/wp[1]/id") != nil){
          output.right[0] = getprop("autopilot/route-manager/route/wp[1]/id");
          }
        if (getprop("autopilot/route-manager/route/wp[2]/id") != nil){
          output.right[1] = getprop("autopilot/route-manager/route/wp[2]/id");
          }
        if (getprop("autopilot/route-manager/route/wp[3]/id") != nil){
          output.right[2] = getprop("autopilot/route-manager/route/wp[3]/id");
          }
        if (getprop("autopilot/route-manager/route/wp[4]/id") != nil){
          output.right[3] = getprop("autopilot/route-manager/route/wp[4]/id");
          }
        if (getprop("autopilot/route-manager/route/wp[5]/id") != nil){
          output.right[4] = getprop("autopilot/route-manager/route/wp[5]/id");
          }
        output.left[5] = "<RTE 2";
        output.right[5] = "ACTIVATE>";
      }
      if (display == "RTE1_ARR") {
        if (getprop("autopilot/route-manager/destination/airport") != nil){
          output.title = getprop("autopilot/route-manager/destination/airport")~" ARRIVALS";
        }
        else{
          output.title = "ARRIVALS";
        }
        output.leftTitle[0] = "STARS";
        output.rightTitle[0] = "APPROACHES";
        if (getprop("autopilot/route-manager/destination/runway") != nil){
          output.right[0] = getprop("autopilot/route-manager/destination/runway");
        }
        output.leftTitle[1] = "TRANS";
        output.rightTitle[2] = "RUNWAYS";
        output.left[5] = "<INDEX";
        output.right[5] = "ROUTE>";
      }
      if (display == "THR_LIM") {
        output.title = "THRUST LIM";
        output.leftTitle[0] = "SEL";
        output.centerTitle[0] = "OAT";
        output.center[0] = sprintf("%2.0f", getprop("environment/temperature-degc"))~"*c";
        output.rightTitle[0] = "TO 1 N1";
        output.left[1] = "<TO";
        output.right[1] = "CLB>";
        output.leftTitle[2] = "TO 1";
        output.left[2] = "<-10%";
        output.center[2] = "<SEL><ARM>";
        output.right[2] = "CLB1>";
        output.leftTitle[3] = "TO 2";
        output.left[3] = "<-20%";
        output.right[3] = "CLB2>";
        output.left[5] = "<INDEX";
        output.right[5] = "TAKEOFF>";
      }
      if (display == "TO_REF") {
        output.title = "TAKEOFF REF";
        output.leftTitle[0] = "FLAP/ACCEL HT";
        output.left[0] = sprintf("%2.0f", getprop("instrumentation/fmc/to-flap"));
        output.rightTitle[0] = "REF V1";
        if (getprop("instrumentation/fmc/vspeeds/V1") != nil){
          output.right[0] = sprintf("%3.0f", getprop("instrumentation/fmc/vspeeds/V1"));
        }
        output.leftTitle[1] = "E/O ACCEL HT";
        output.rightTitle[1] = "REF VR";
        if (getprop("instrumentation/fmc/vspeeds/VR") != nil){
          output.right[1] = sprintf("%3.0f", getprop("instrumentation/fmc/vspeeds/VR"));
        }
        output.leftTitle[2] = "THR REDUCTION";
        output.rightTitle[2] = "REF V2";
        if (getprop("instrumentation/fmc/vspeeds/V2") != nil){
          output.right[2] = sprintf("%3.0f", getprop("instrumentation/fmc/vspeeds/V2"));
        }
        output.leftTitle[3] = "WIND/SLOPE";
        output.rightTitle[3] = "TRIM   CG";
        output.rightTitle[4] = "POS SHIFT";
        output.left[5] = "<INDEX";
        output.right[5] = "POS INIT>";
      }
    }
		
		if (serviceable != 1){
			output.title = "";		output.page = "";
			output.title = "";
      output.page = "";
      output.leftTitle = [ "", "", "", "", "", "" ];
      output.left = [ "", "", "", "", "", "" ];
      output.centerTitle = [ "", "", "", "", "", "" ];
      output.center = [ "", "", "", "", "", "" ];
      output.rightTitle = [ "", "", "", "", "", "" ];
      output.right = [ "", "", "", "", "", "" ];
		}
		
		setprop("instrumentation/cdu/output/title",output.title);
		setprop("instrumentation/cdu/output/page",output.page);
    for (i = 0; i < 6;  i += 1) { 
		  setprop("instrumentation/cdu/output/line"~( i + 1 )~"/left-title",output.leftTitle[i]);
      setprop("instrumentation/cdu/output/line"~( i + 1 )~"/left",output.left[i]);
		  setprop("instrumentation/cdu/output/line"~( i + 1 )~"/center-title",output.centerTitle[i]);
      setprop("instrumentation/cdu/output/line"~( i + 1 )~"/center",output.center[i]);
		  setprop("instrumentation/cdu/output/line"~( i + 1 )~"/right-title",output.rightTitle[i]);
      setprop("instrumentation/cdu/output/line"~( i + 1 )~"/right",output.right[i]);
    }
		settimer(cdu,0.2);
    }
_setlistener("sim/signals/fdm-initialized", cdu); 
