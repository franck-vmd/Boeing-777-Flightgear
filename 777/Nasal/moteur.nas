# moteur system

var moteurP1 = props.globals.initNode("/controls/switches/passengermoteur1",0,"DOUBLE");
var moteurP2 = props.globals.initNode("/controls/switches/passengermoteur2",0,"DOUBLE");
var moteurP3 = props.globals.initNode("/controls/switches/passengermoteur3",0,"DOUBLE");
var moteurP4 = props.globals.initNode("/controls/switches/passengermoteur4",0,"DOUBLE");


var openclosemoteur = func (indevice) {
				var wdevice = props.globals.getNode(indevice) ;
				var devicevalue = wdevice.getValue();
				if ( devicevalue < 0.01 ) {
					interpolate(wdevice.getPath(), 1, 5);
				} else {
					interpolate(wdevice.getPath(), 0, 5);
				}				

}
