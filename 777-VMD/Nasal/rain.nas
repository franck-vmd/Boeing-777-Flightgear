# RAIN ==============================================================
# Rain splashes will render automatically when the weather system reports
# rain via environment/rain-norm. In addition, the user can set rain
# splashes to render via environment/aircraft-effects/ground-splash-norm
# (this is intended to allow splashes to be rendered e.g. for water landings
# of aircraft equipped with floats).
#
# By default, the rain splashes impact from above (more precisely the +z
# direction in model coordinates). This may be inadequate if the aircraft
# is moving. However, the shader can not know what the airstream at the
# glass will be, so the impact vector of rain splashes has to be modeled
# aircraft-side and set via environment/aircraft-effects/splash-vector-x
# (splash-vector-y, splash-vector-z). These are likewise in model coordinates.
#
# As long as the length of the splash vector is <1, just the impact angle will
# change, as the length of the vector increases to 2, droplets will also be
# visibly moving. This allows fine control of the visuals dependent on any
# number of factors desired. 

var rtimer = maketimer(1.0, func {
   var airspeed = getprop("/velocities/airspeed-kt");
   var airspeed_max = 120;
   if (airspeed > airspeed_max) {
      airspeed = airspeed_max;
   }
   airspeed = math.sqrt(airspeed/airspeed_max);

   var splash_x = -0.1 - 2.0 * airspeed;
   var splash_z = 1.0 - 1.35 * airspeed;;

   setprop("/environment/aircraft-effects/splash-vector-x", -splash_x);
   setprop("/environment/aircraft-effects/splash-vector-y", 0.0);
   setprop("/environment/aircraft-effects/splash-vector-z", -splash_z);

#   setprop("environment/aircraft-effects/frost-level", getprop("/fdm/jsbsim/systems/ecs/windscreen-frost-amount"));

   }
);
rtimer.start();

aircraft.tyresmoke_system.new(0, 1, 2);

# If these are not random then people who just fly might accidently be on same channel by mistake.
# Or if they are previous day was fighting together with same channels, they should now have to intentionally setup, so not to enherit old fights values.
setprop("instrumentation/iff/channel-selection", int(rand()*10000));
setprop("instrumentation/datalink/channel", int(rand()*10000));