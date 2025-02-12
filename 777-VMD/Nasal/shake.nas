########################################################
#		Franck VMD
#		Boeing 777-VMD for Flightgear 12 February 2025
########################################################


var shakeEffect777 = props.globals.initNode("b777/shake-effect/effect",0,"BOOL");
var shake777	   = props.globals.initNode("b777/shake-effect/shaking",0,"DOUBLE");
var rSpeed = 0;
var sf = 0;
var ge_a_r  = 0;

var theShakeEffect = func{
		ge_a_r = getprop("/gear/gear[0]/compression-m") or 0;
		rSpeed = getprop("/gear/gear/rollspeed-ms") or 0;
		sf = rSpeed / 94000;
	    
		if(shakeEffect777.getBoolValue() and ge_a_r > 0){
		  interpolate("b777/shake-effect/shaking", sf, 0.03);
		  settimer(func{
		  	 interpolate("b777/shake-effect/shaking", -sf*2, 0.03); 
		  }, 0.03);
		  settimer(func{
		  	interpolate("b777/shake-effect/shaking", sf, 0.03);
		  }, 0.06);
			settimer(theShakeEffect, 0.09);	
		}else{
		  	setprop("b777/shake-effect/shaking", 0);	
			setprop("b777/shake-effect/effect",0);		
		}	    
}
setlistener("b777/shake-effect/effect", func(state){
	if(state.getBoolValue()){
		theShakeEffect();
	}
},1,0);

