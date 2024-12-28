AUTOMATIC PUSHBACK FOR FLIGHTGEAR
http://gitlab.com/mdanil/flightgear-autopush

Version 0.6.2.

Copyright (c) 2018 Autopush authors:
 Michael Danilov <mike.d.ft402 -eh- gmail.com>
 Joshua Davidson http://github.com/Octal450
 Merspieler http://gitlab.com/merspieler
Some of the code (c) FlightGear
Distribute under the terms of GPLv2.


This project aims to develop a generic pushback for JSBSim and YASim
aircraft, with the following characteristics.

1. Do the pushback procedure automatically.
2. Scale to different aircraft with minimum changes to their logic.
3. Use no computer resources in flight.


INSTALLATION

Only the minimal working example is covered here. Later you will have
to provide correct steering (aliased to "/sim/model/pushback/yaw"),
pushback availability ("/sim/model/pushback/available") and chocks
control (aliased to "/sim/pushback/chocks"). Those variables are too
aircraft-specific, so they could not be implemented pushback-side.

1. Install the following files and directories in your aircraft
   while keeping the directory structure:

Models/Autopush                 cursor models and the animation for
                                FGDATA pushbacks.
Nasal/autopush.nas              basic pushback logic
Nasal/autopush_driver.nas       pushback driver
Nasal/autopush_route.nas        pushback route
Nasal/dynarr.nas                dynamical array support for Nasal
gui/dialogs/autopush.xml        GUI dialog

2. Set up the pushback logic.

Add the following under <sim><model> of your set.xml

 <pushback>
  <enabled type="int"/>
  <available type="int">1</available>
  <chocks alias="/controls/gear/wheel-chocks"/>
  <steer-cmd-norm alias="/controls/flight/rudder"/>
  <yaw alias="/gear/gear[0]/steering-norm"/>
  <yaw-mult type="float">MULTIPLIER</yaw-mult>
  <target-speed-km_h type="float">0.0</target-speed-km_h>
  <K_p type="float">1.0</K_p>
  <F_p type="float">0.1</F_p>
  <K_i type="float">0.75</K_i>
  <F_i type="float">2.0</F_i>
  <K_d type="float">0.0</K_d>
  <F_d type="float">0.0</F_d>
  <driver>
   <K_V type="float">4.0</K_V>
   <F_V type="float">8.0</F_V>
   <D_min-m type="float">5.0</D_min-m>
   <K_psi type="float">0.03</K_psi>
  </driver>
  <route>
   <show type="bool"/>
   <view type="string">Model View</view>
  </route>
  <debug type="int">0</debug>
 </pushback>

Change the aliases to point to the following data:

steer-cmd-norm  nose wheel steering command norm
yaw             nose wheel steering output norm or angle (see below)
chocks          chocks command bool (optional)
available       pushback availability bool (optional)

Replace the MULTIPLIER in yaw-mult with:

max steering angle  if yaw is norm
1.0                 if yaw is degrees
57.3                if yaw is radians

Add under <nasal> of your set.xml:

 <autopush>
  <file>Nasal/autopush.nas</file>
 </autopush>
 <autopush_driver>
  <file>Nasal/autopush_driver.nas</file>
 </autopush_driver>
 <dynarr>
  <file>Nasal/dynarr.nas</file>
 </dynarr>
 <autopush_route>
  <file>Nasal/autopush_route.nas</file>
 </autopush_route>

3. Connect the force to FDM.

 3.a. JSBSim:

  3.a.1. Add the following under <external_reactions> of your JSBSim
         XML.

 <force name="tractor" frame="BODY">
  <location unit="M">
   <x>FRONT-X</x>
   <y>FRONT-Y</y>
   <z>FRONT-Z</z>
  </location>
  <direction>
   <x>1.0</x>
   <y>0.0</y>
   <z>0.0</z>
  </direction>
 </force>

Replace FRONT-X, FRONT-Y, FRONT-Z with coordinates of your front
bogey.

  3.a.2. Add the following under <fdm><jsbsim><external_reactions> of
         your set.xml.

   <tractor>
    <magnitude alias="/sim/model/pushback/force-lbf"/>
    <x alias="/sim/model/pushback/force-x"/>
    <y alias="/sim/model/pushback/force-y"/>
   </tractor>

 3.b. YASim. Add the following under <airplane> of your YASim xml.

 <thruster x="FRONT-X" y="FRONT-Y" z="FRONT-Z" vx="1" vy="0" vz="0" thrust="100000.0">
  <control-input axis="/sim/model/pushback/force-x-yasim" control="THROTTLE" src0="-1" src1="1" dst0="-1" dst1="1"/>
 </thruster>
 <thruster x="FRONT-X" y="FRONT-Y" z="FRONT-Z" vx="0" vy="1" vz="0" thrust="100000.0">
  <control-input axis="/sim/model/pushback/force-y-yasim" control="THROTTLE" src0="-1" src1="1" dst0="-1" dst1="1"/>
 </thruster>

Replace FRONT-X, FRONT-Y, FRONT-Z with coordinates of your front
bogey.

4. Add the pushback model to your Model XML:

 <model>
  <name>Pushback</name>
  <path>MODEL</path>
  <offsets>
   <x-m>FRONT-X</x-m>
   <y-m>FRONT-Y</y-m>
   <z-m>FRONT-Z</z-m>
  </offsets>
 </model>

Replace FRONT-X, FRONT-Y, FRONT-Z with coordinates of your front
bogey. Replace MODEL with the following file name:

Autopush/Goldhofert.xml  for Goldhofer towbarless pushback

Edit all the places marked by "SETTING" of the respective file to
match your setup.

5. Add gui/dialogs/autopush.xml to your aircraft's menu (see
   FlightGear documentation for editing the menu).

6. If you have a bug tracker, please add a note, that autopush related bugs
   should be reported here: https://gitlab.com/mdanil/flightgear-autopush/issues


TUNING

There should normally be no need to change the coefficients, because
the inertia of different aircraft is already taken into account. But
the gear setup may differ enough to require some tuning.

Pushback (/sim/model/pushback):

Coefficient  Unit                   Description

K_p          ((km/h)/s)/(km/h)      Proportional coefficient of PID.
                                    Defines the start/stop throttle
                                    and immediate response to speed
                                    difference deltaV = V_set - V.

F_p          (km/h)/s               Proportional clipping.

K_i          ((km/h)/s)/((km/h)*s)  Integral coefficient of PID.
                                    Defines how fast the steady
                                    throttle is ramped during the
                                    push.

F_i          (km/h)/s               Integral clipping.

K_d          ((km/h)/s)/((km/h)/s)  Differential coefficient of PID.
                                    Stabilizes the approaching of
                                    steady throttle, but destabilizes
                                    immediate response to deltaV.

F_d          (km/h)/s               Differential clipping.

Pushback driver (/sim/model/pushback/driver):

Coefficient  Unit      Description

D_min-m      m         distance to the target when it is considered reached
K_V          km/h      towing speed per distance D/D_min
F_V          km/h      towing speed clipping
K_psi        1/deg     amount of steering per heading difference


BUGS

* It is recommended to not use time speed-up with pushback, because
  speed setting precision is decreased.
* Push-and-pull procedure is not supported.
