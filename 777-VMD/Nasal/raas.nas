# Copyright (C) 2014  onox
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

var sin = func(a) { math.sin(a * globals.D2R) }
var cos = func(a) { math.cos(a * globals.D2R) }
var max = func(a, b) { a > b ? a : b }

var mod = func (n, m) {
    return n - m * math.floor(n / m);
}

var Observable = {

    new: func {
        var m = {
            parents: [Observable]
        };
        m.observers = {};
        return m;
    },

    connect: func (signal, callback) {
        if (!contains(me.observers, signal)) {
            me.observers[signal] = [];
        }
        var listener_id = setlistener("/sim/signals/runway-announcer/" ~ signal, callback);
        append(me.observers[signal], listener_id);
        return listener_id;
    },

    notify_observers: func (signal, arguments) {
        if (contains(me.observers, signal)) {
            setprop("/sim/signals/runway-announcer/" ~ signal, arguments);
        }
    }
};

var RunwayAnnounceClass = {

    new: func {
        var m = {
            parents: [RunwayAnnounceClass, Observable.new()]
        };
        m.mode = "";
        return m;
    },

    set_mode: func (mode) {
        # Set the mode. Depending on the mode this object will or
        # will not notify certain observers.

        me.mode = mode;
    },

    _check_runway: func (apt, runway, self) {
        self.set_alt(apt.elevation);

        var rwy = apt.runway(runway);
        var rwy_coord = geo.Coord.new().set_latlon(rwy.lat, rwy.lon, apt.elevation);

        var rwy_start_coord = geo.Coord.new().set(rwy_coord);

        # Modify current coord by applying a heading and RWY length to
        # transform it to the opposite RWY
        rwy_coord.apply_course_distance(rwy.heading, rwy.length);

        var distance = self.distance_to(rwy_coord);
        var course = self.course_to(rwy_coord);

        var crosstrack_error = distance * abs(sin(course - rwy.heading));
        var distance_stop = distance * cos(course - rwy.heading);
        var edge_rem = max(rwy.width / 2, crosstrack_error) - rwy.width / 2;

        var on_rwy = edge_rem == 0 and 0 <= distance_stop and distance_stop <= rwy.length;

        var distance_start = self.distance_to(rwy_start_coord) * cos(course - rwy.heading);

        return {
            on_runway:          on_rwy,
            # True if on the runway, false otherwise

            distance_start:     distance_start,
            # Distance to the start of the runway. The distance is
            # parallel to the runway.

            distance_stop:      distance_stop,
            # Distance to the edge of the opposite runway. The distance
            # is parallel to the runway.

            crosstrack_error:   crosstrack_error,
            # Distance to the center line of the runway. The distance
            # is orthogonal to the center line.

            edge_rem:           edge_rem,
            # Distance from outside the runway to the nearest side edge
            # of the RWY. 0 if on_runway is true. Orthogonal to the runway.

            runway:             rwy
        };
    }

};

var TakeoffRunwayAnnounceConfig = {

    diff_runway_heading_deg: 20,
    # Difference in heading between runway and aircraft in order to
    # get an announcement that the aircraft is on the runway for takeoff
    # or approaching while airborne.

    diff_approach_heading_deg: 40,
    # Maximum angle at which the aircraft should approach the runway.
    # Must be higher than 0 and lower than 90.

    distance_center_line_m: 10,
    # The distance in meters from the center line of the runway

    distance_edge_min_m: 20,
    distance_edge_max_m: 80,
    # Minimum and maximum distance in meters from the edge of the runway
    # for announcing approaches.

    nominal_distance_takeoff_m: 3000,
    # Minimum distance in meters required for a normal takeoff. If
    # remaining distance when entering the runway is less than the distance
    # required for a normal takeoff, then the on-short-runway instead of
    # on-runway signal will be emitted.

    nominal_distance_landing_m: 2000,
    # Minimum distance in meters required for a normal landing. If
    # runway length when approaching the runway is less than the distance
    # required for a normal landing, then the approaching-short-runway
    # instead of approaching-runway signal will be emitted.

    distances_unit: "meter",
    # The unit to use for the remaining distance of short runways. Can
    # be "meter" or "feet".

    groundspeed_max_kt: 40,
    # Maximum groundspeed in knots for approaching runway callouts

    approach_afe_min_ft: 300,
    approach_afe_max_ft: 750,
    # Minimum and maximum altitude Above Field Elevation in feet. Used to
    # decide whether to announce that the aircraft is approaching a runway.

    approach_distance_max_nm: 3.0,
    # Maximum distance in nautical miles of the aircraft to the
    # approaching runway

};

var TakeoffRunwayAnnounceClass = {

    period: 0.5,

    # Announce when approaching a runway or when on a runway ready for
    # takeoff. Valid modes and the signals they emit are:
    #
    # - taxi-and-takeoff:   approaching-runway, on-runway, on-short-runway
    # - takeoff:            on-runway, on-short-runway
    # - approach:           approaching-runway, approaching-short-runway

    new: func (config) {
        var m = {
            parents: [TakeoffRunwayAnnounceClass, RunwayAnnounceClass.new()]
        };
        m.timer = maketimer(TakeoffRunwayAnnounceClass.period, func m._check_position());
        m.config = config;

        m.last_announced_runway = "";
        m.last_announced_approach = "";

        return m;
    },

    start: func {
        # Start monitoring the location of the aircraft relative to the
        # runways of the current airport.

        me.timer.start();
    },

    stop: func {
        # Stop monitoring the location of the aircraft.
        #
        # You should call this function after takeoff.

        me.timer.stop();

        me.last_announced_runway = "";
        me.last_announced_approach = "";
    },

    get_short_runway_distance: func {
        return getprop("/sim/runway-announcer/short-runway-distance");
    },

    _check_position: func {
        if (me.mode == "") {
            return;
        }

        var apt = airportinfo();
        var self_heading = getprop("/orientation/heading-deg");
        var gear_agl_ft = getprop("/position/gear-agl-ft");

        var approaching_runways = {};
        var approaching_runways_airborne = {};

        foreach (var runway; keys(apt.runways)) {
            var self = geo.aircraft_position();
            var result = me._check_runway(apt, runway, self);

            # Reset flag for announced approaching runway, so that
            # the airplane could turn around, approach the same runway,
            # and read/hear the announcement again
            if (me.mode == "taxi-and-takeoff") {
                if (runway == me.last_announced_approach
                  and gear_agl_ft < 5.0
                  and result.edge_rem > me.config.distance_edge_max_m) {
                    me.last_announced_approach = "";
                }
            }

            var runway_heading = result.runway.heading;
            var runway_heading_error = abs(runway_heading - self_heading);

            if (result.on_runway) {
                if (me.mode == "taxi-and-takeoff" or me.mode == "takeoff") {
                    if (me.last_announced_runway != runway
                      and gear_agl_ft < 5.0
                      and runway_heading_error <= me.config.diff_runway_heading_deg
                      and result.crosstrack_error <= me.config.distance_center_line_m) {
                        if (result.distance_stop >= me.config.nominal_distance_takeoff_m) {
                            me.notify_observers("on-runway", runway);
                        }
                        else {
                            me._on_short_runway(runway, result.distance_stop);
                        }
                        me.last_announced_runway = runway;
                    }
                }
            }
            else {
                if (me.mode == "taxi-and-takeoff" or me.mode == "takeoff") {
                    # If aircraft is no longer on the last announced runway
                    # (when it has vacated onto a taxiway for example), then
                    # reset last_announced_runway field so that on-runway signal
                    # will be emitted if the aircraft enters this same runway again.
                    if (me.last_announced_runway == runway) {
                        me.last_announced_runway = "";
                    }
                }

                if (me.mode == "taxi-and-takeoff") {
                    var groundspeed = getprop("/velocities/groundspeed-kt");

                    var ac_angle1 = cos(90.0 - (mod(runway_heading, 180) - self_heading));
                    var ac_angle2 = cos(90.0 - (self_heading - mod(runway_heading, 180)));
                    var ac_angle = max(ac_angle1, ac_angle2);

                    if (gear_agl_ft < 5.0
                      and me.config.distance_edge_min_m <= result.edge_rem
                      and result.edge_rem <= me.config.distance_edge_max_m
                      and ac_angle > 0 and ac_angle >= cos(me.config.diff_approach_heading_deg)
                      and groundspeed < me.config.groundspeed_max_kt) {
                        self.apply_course_distance(self_heading, result.crosstrack_error / ac_angle);
                        var result_future = me._check_runway(apt, runway, self);

                        # If in the future we are on the runway, we are approaching it
                        if (result_future.on_runway) {
                            approaching_runways[runway] = result.distance_start;
                        }
                    }
                }
                if (me.mode == "approach") {
                    var afe_ft = getprop("/position/altitude-ft") - apt.elevation * globals.M2FT;

                    if (runway_heading_error <= me.config.diff_runway_heading_deg
                      and result.crosstrack_error <= result.runway.width + 200 * globals.FT2M
                      and result.runway.length < result.distance_stop
                      and result.distance_start < result.distance_stop
                      and result.distance_start <= me.config.approach_distance_max_nm * globals.NM2M
                      and me.config.approach_afe_min_ft <= afe_ft
                      and afe_ft <= me.config.approach_afe_max_ft
                      and !(450 <= afe_ft and afe_ft <= 550)) {
                        approaching_runways_airborne[runway] = runway_heading_error;
                    }
                }
            }
        }

        # Every runway also has an opposite runway. Choose the runway that
        # is closest to the aircraft.
        if (size(approaching_runways) == 2) {
            var start_distance_compare = func (a, b) {
                return approaching_runways[a] - approaching_runways[b];
            };
            closest_runway = sort(keys(approaching_runways), start_distance_compare);

            runway = closest_runway[0];
            if (me.last_announced_approach != runway) {
                me.notify_observers("approaching-runway", runway);
                me.last_announced_approach = runway;
            }
        }

        if (size(approaching_runways_airborne) > 0) {
            var start_heading_compare = func (a, b) {
                return approaching_runways_airborne[a] - approaching_runways_airborne[b];
            };
            aligned_runway = sort(keys(approaching_runways_airborne), start_heading_compare);

            runway = aligned_runway[0];
            if (me.last_announced_approach != runway) {
                var distance_available = apt.runways[runway].length;
                if (distance_available >= me.config.nominal_distance_landing_m) {
                    me.notify_observers("approaching-runway", runway);
                }
                else {
                    me._approaching_short_runway(runway, distance_available);
                }
                me.last_announced_approach = runway;
            }
        }
    },

    _on_short_runway: func (runway, distance_remaining) {
        var distance = me._get_rounded_distance(distance_remaining);
        setprop("/sim/runway-announcer/short-runway-distance", distance);
        me.notify_observers("on-short-runway", runway);
    },

    _approaching_short_runway: func (runway, distance_available) {
        var distance = me._get_rounded_distance(distance_available);
        setprop("/sim/runway-announcer/short-runway-distance", distance);
        me.notify_observers("approaching-short-runway", runway);
    },

    _get_rounded_distance: func (distance_remaining) {
        var distance = distance_remaining;
        if (me.config.distances_unit == "feet") {
            distance = distance * globals.M2FT;
        }

        # Round down to nearest multiple of 100
        return int(distance / 100) * 100;
    }

};

var LandingRunwayAnnounceConfig = {

    distances_meter: [100,  300,  600,  900, 1200, 1500],

    distances_feet:  [500, 1000, 2000, 3000, 4000, 5000],

    distances_unit: "meter",
    # The unit to use for the remaining distance. Can be "meter" or "feet"

    distance_center_nose_m: 0,
    # Distance from the center to the nose in meters

    diff_runway_heading_deg: 20,
    # Difference in heading between runway and aircraft in order to
    # detect the correct runway on which the aircraft is landing.

    groundspeed_min_kt: 40,
    # Minimum groundspeed in knots for remaining distance callouts

    agl_max_ft: 100,
    # Maximum AGL in feet for remaining distance callouts

};

var LandingRunwayAnnounceClass = {

    period: 0.1,

    # Announce remaining distance after landing on a runway. Valid modes
    # and the signals they emit are:
    #
    # - takeoff: remaining-distance, vacated-runway
    # - landing: remaining-distance, landed-runway, vacated-runway, landed-outside-runway

    new: func (config) {
        var m = {
            parents: [LandingRunwayAnnounceClass, RunwayAnnounceClass.new()]
        };
        m.timer = maketimer(LandingRunwayAnnounceClass.period, func m._check_position());
        m.config = config;

        m.last_announced_runway = "";
        m.landed_runway = "";
        m.last_announced_distance = nil;
        m.last_announced_end = nil;
        m.gs_max_kt = 0;

        return m;
    },

    start: func {
        # Start monitoring the location of the aircraft on the runway.

        me.timer.start();
    },

    stop: func {
        # Stop monitoring the location of the aircraft.
        #
        # You should call this function after vacating the runway.

        me.set_mode("");

        me.timer.stop();

        me.last_announced_runway = "";
        me.landed_runway = "";
        me.last_announced_distance = nil;
        me.last_announced_end = nil;
    },

    _check_position: func {
        if (me.mode == "") {
            return;
        }

        var apt = airportinfo();
        var self_heading = getprop("/orientation/heading-deg");

        var on_number_of_rwys = 0;

        foreach (var runway; keys(apt.runways)) {
            var self = geo.aircraft_position();
            var result = me._check_runway(apt, runway, self);

            if (me.mode == "landing" or me.mode == "takeoff") {
                if (result.on_runway) {
                    on_number_of_rwys += 1;
                    me._on_runway(runway, result, self_heading);
                }
                else {
                    me._not_on_runway(runway);
                }
            }
        }

        # Make landed_runway nil to prevent emitting landed-runway signal
        # in case we landed on anything but a runway (taxiway for example)
        if (me.mode == "landing" and on_number_of_rwys == 0) {
            if (me.landed_runway == "") {
                me.notify_observers("landed-outside-runway", "");
            }
            me.landed_runway = nil;
        }
    },

    _on_runway: func (runway, result, self_heading) {
        var runway_heading = result.runway.heading;
        var runway_heading_error = abs(runway_heading - self_heading);

        # If aircraft is aligned with this runway, then we just landed
        # on this runway (the only other possible runway is the opposite
        # runway)
        if (me.landed_runway != runway
          and runway_heading_error <= me.config.diff_runway_heading_deg) {
            var prev_landed_runway = me.landed_runway;
            me.landed_runway = runway;
            me.last_announced_distance = nil;
            if (me.mode == "landing" and prev_landed_runway == "") {
                me.notify_observers("landed-runway", runway);
            }
        }

        var groundspeed = getprop("/velocities/groundspeed-kt");
        var gear_agl_ft = getprop("/position/gear-agl-ft");

        # Reset the maximum groundspeed. This is needed if the aircraft
        # does a rejected takeoff and then decides to do another takeoff
        # without leaving the runway
        if (groundspeed < me.config.groundspeed_min_kt) {
            me.gs_max_kt = 0;
        }

        # Aircraft has already landed on the given runway and is now
        # rolling out
        if (me.landed_runway == runway
          and groundspeed > me.config.groundspeed_min_kt
          and gear_agl_ft < me.config.agl_max_ft) {
            var nose_distance = result.distance_stop - me.config.distance_center_nose_m;

            if (me.mode == "landing") {
                var extra_conditions_ok = 1;
            }
            elsif (me.mode == "takeoff") {
                me.gs_max_kt = max(groundspeed, me.gs_max_kt);

                # Past 50 % of runway and GS < max groundspeed - 7
                var past_half_runway = (nose_distance / result.runway.length) < 0.50;
                var below_rto_speed  = groundspeed < me.gs_max_kt - 7;

                var extra_conditions_ok = past_half_runway and below_rto_speed;
            }

            if (extra_conditions_ok) {
                if (me.config.distances_unit == "meter") {
                    var unit_ps = getprop("/velocities/uBody-fps") * globals.FT2M;
                    var distances = me.config.distances_meter;
                    var remaining_distance = nose_distance;
                }
                elsif (me.config.distances_unit == "feet") {
                    var unit_ps = getprop("/velocities/uBody-fps");
                    var distances = me.config.distances_feet;
                    var remaining_distance = nose_distance * globals.M2FT;
                }

                var max_index = size(me.config.distances_meter) - 1;
                for (var index = max_index; index >= 0; index = index - 1) {
                    if (me.last_announced_distance != index) {
                        # Distance travelled in two timer periods
                        var dist_upper = distances[index];
                        var dist_lower = dist_upper - unit_ps * LandingRunwayAnnounceClass.period * 2;

                        if (dist_lower <= remaining_distance and remaining_distance <= dist_upper) {
                            me.notify_observers("remaining-distance", dist_upper);
                            me.last_announced_distance = index;
                        }
                    }
                }
            }
        }

        if (runway_heading_error <= me.config.diff_runway_heading_deg
          and groundspeed < me.config.groundspeed_min_kt
          and gear_agl_ft < 5.0) {
            var nose_distance = result.distance_stop - me.config.distance_center_nose_m;

            if (me.config.distances_unit == "meter") {
                var remaining_distance = nose_distance;
                var dist_upper = 30;
            }
            elsif (me.config.distances_unit == "feet") {
                var remaining_distance = nose_distance * globals.M2FT;
                var dist_upper = 100;
            }

            # This is the lowest distance that is announced, so no need
            # to check lower bound like above
            if (me.last_announced_end != runway and remaining_distance <= dist_upper) {
                me.notify_observers("remaining-distance", dist_upper);
                me.last_announced_end = runway;
            }
        }
    },

    _not_on_runway: func (runway) {
        # Aircraft is no longer on the runway it landed on, so it must
        # have vacated the runway
        if (runway == me.landed_runway) {
            me.last_announced_distance = nil;
            if (me.last_announced_runway != runway) {
                me.notify_observers("vacated-runway", runway);
                me.last_announced_runway = runway;
            }
        }
    }

};

var runway_number_filter = func (value) {
    var value_array = split("", value);

    if (size(value_array) != 2 and size(value_array) != 3) {
        return value;
    }

    var last_value = value_array[-1];
    var lcr = { "L": "left", "C": "center", "R": "right" };

    if (contains(lcr, last_value)) {
        value_array[-1] = lcr[last_value];
    }

    return string.join(" .. ", value_array);
};

var make_betty_cb = func (betty_say, format, action=nil, filter=nil) {
    if (format != nil and typeof(betty_say) != "func") {
        die("Error: betty_say is not a function");
    }

    return func (data=nil) {
        if (format != nil) {
            if (typeof(format) == "func") {
                var message_format = format();
            }
            else {
                var message_format = format;
            }

            if (filter != nil and typeof(filter) == "func") {
                var value = filter(data.getValue());
            }
            else {
                var value = data.getValue();
            }

            if (data != nil) {
                var message = sprintf(message_format, value);
            }
            else {
                var message = message_format;
            }

            # Let Betty announce the message
            betty_say(message);
        }

        if (typeof(action) == "func") {
            action();
        }
    };
};

var make_stop_announcer_func = func (takeoff_announcer, landing_announcer) {
    return func {
        landing_announcer.stop();
#        logger.warn("Stopping landing announcer");

        takeoff_announcer.set_mode("taxi-and-takeoff");
#        logger.warn(sprintf("Takeoff mode: %s", takeoff_announcer.mode));
    };
};

var make_switch_to_takeoff_func = func (takeoff_announcer, landing_announcer) {
    return func {
        if (takeoff_announcer.mode == "taxi-and-takeoff") {
            takeoff_announcer.set_mode("takeoff");
#            logger.warn(sprintf("Takeoff mode: %s", takeoff_announcer.mode));

            landing_announcer.set_mode("takeoff");
            landing_announcer.start();
#            logger.warn(sprintf("Starting landing (%s) announcer", landing_announcer.mode));
        }
    };
};

var make_set_ground_func = func (takeoff_announcer, landing_announcer) {
    return func (on_ground) {
        if (on_ground) {
            takeoff_announcer.set_mode("");

            landing_announcer.set_mode("landing");
            landing_announcer.start();
#            logger.warn(sprintf("Starting landing (%s) announcer", landing_announcer.mode));

            takeoff_announcer.start();
#            logger.warn(sprintf("Starting takeoff (%s) announcer", takeoff_announcer.mode));
        }
        else {
            takeoff_announcer.set_mode("approach");
#            logger.warn(sprintf("Takeoff mode: %s", takeoff_announcer.mode));

            landing_announcer.stop();
#            logger.warn("Stopping landing announcer");
        }
    };
};

var make_init_func = func (takeoff_announcer) {
    return func {
        takeoff_announcer.set_mode("taxi-and-takeoff");
#        logger.warn(sprintf("Takeoff mode: %s", takeoff_announcer.mode));

        takeoff_announcer.start();
#        logger.warn(sprintf("Starting takeoff (%s) announcer", takeoff_announcer.mode));
    };
};
