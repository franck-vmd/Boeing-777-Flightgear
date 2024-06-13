var fctl_canvas = {};

var aileronPosLeft = {};
var flaperonPosLeft = {};
var aileronPosRight = {};
var flaperonPosRight = {};
var rudderPos = {};
var elevPosLeft = {};
var elevPosRight = {};
var elevatorTrim = {};
var rudderTrim = {};
var rudderTrimDirection = {};
var spoilers = {};
var spoilers_scale = {};
var allSpoilers = [];
var allSpoilers_scale = [];
var fctlMode = {};
var fctlModeBox = {};

var leftInSpoilersNode = props.getNode("fcs/spoilers/left-in-final-deg", 1);
var leftOutSpoilersNode = props.getNode("fcs/spoilers/left-out-final-deg", 1);
var rightInSpoilersNode = props.getNode("fcs/spoilers/right-in-final-deg", 1);
var rightOutSpoilersNode = props.getNode("fcs/spoilers/right-out-final-deg", 1);

var canvas_fctl = {
    new : func(canvas_group)
    {
        var m = { parents: [canvas_fctl, MfDPanel.new("fctl",canvas_group,"Aircraft/777-VMD/Models/InstrumentsX/MFD-X8/fctl.svg",canvas_fctl.update)] };
        m.context = m;
        m.initSvgIds(m.group);
        return m;
    },
    initSvgIds: func(group)
    {
        aileronPosLeft = group.getElementById("aileronPosLeft");
        flaperonPosLeft = group.getElementById("flaperonPosLeft");
        aileronPosRight = group.getElementById("aileronPosRight");
        flaperonPosRight = group.getElementById("flaperonPosRight");
        rudderPos = group.getElementById("rudderPos");
        elevPosLeft = group.getElementById("elevPosLeft");
        elevPosRight = group.getElementById("elevPosRight");
        elevatorTrim = group.getElementById("elevatorTrim");
        rudderTrim = group.getElementById("rudderTrim");
        rudderTrimDirection = group.getElementById("rudderTrimDirection");
        spoilers = group.getElementById("spoilers").updateCenter();
        for (var i = 0; i < 14; i += 1){
            var id_tmp = "spoiler" ~ (i+1);
            append(allSpoilers, group.getElementById(id_tmp).updateCenter());
        }
        fctlMode = group.getElementById("fctlMode");
        fctlModeBox = group.getElementById("fctlModeBox");

        var c1 = spoilers.getCenter();
        spoilers.createTransform().setTranslation(-c1[0], -c1[1]);
        spoilers_scale = spoilers.createTransform();
        spoilers.createTransform().setTranslation(c1[0], c1[1]);
        
        forindex(i; allSpoilers){
            var c1_all = allSpoilers[i].getCenter();
            allSpoilers[i].createTransform().setTranslation(-c1_all[0], -c1_all[1]);
            append(allSpoilers_scale, allSpoilers[i].createTransform());
            allSpoilers[i].createTransform().setTranslation(c1_all[0], c1_all[1]);
        }
        
    },
    updateRudderTrim: func()
    {
        var rdTrim = getprop("controls/flight/rudder-trim");
        var rdTrimDir = "L";
        if (rdTrim > 0) rdTrimDir = "R";
        rdTrim = math.abs(rdTrim * 17);
        rudderTrim.setText(sprintf("%2.1f",math.round(rdTrim,0.1)));
        rudderTrimDirection.setText(rdTrimDir);
    },
    updateSpoilers: func()
    {
        #To be improved after seperating spoilers in 3D
         
        var spoilerTotalHeight = 77.5;
        var leftInSpoilers = leftInSpoilersNode.getValue()/60;
        var leftOutSpoilers = leftOutSpoilersNode.getValue()/60;
        var rightInSpoilers = rightInSpoilersNode.getValue()/60;
        var rightOutSpoilers = rightOutSpoilersNode.getValue()/60;
       
        forindex(i; allSpoilers){
            if(i <= 4){
                #Left out spoilers
                var spbangle = leftOutSpoilers or 0.00;
                var spoilerCurrentHeight = spbangle*spoilerTotalHeight;
                allSpoilers_scale[i].setScale(1,spbangle);
                allSpoilers_scale[i].setTranslation(0,(spoilerTotalHeight-spoilerCurrentHeight)/2);
            }
            if(i <= 6 and i > 4){
                #Left in spoilers
                var spbangle = leftInSpoilers or 0.00;
                var spoilerCurrentHeight = spbangle*spoilerTotalHeight;
                allSpoilers_scale[i].setScale(1,spbangle);
                allSpoilers_scale[i].setTranslation(0,(spoilerTotalHeight-spoilerCurrentHeight)/2);
            }
            if(i <= 8 and i > 6){
                #Right in spoilers
                var spbangle = rightInSpoilers or 0.00;
                var spoilerCurrentHeight = spbangle*spoilerTotalHeight;
                allSpoilers_scale[i].setScale(1,spbangle);
                allSpoilers_scale[i].setTranslation(0,(spoilerTotalHeight-spoilerCurrentHeight)/2);
            }
            if(i <= 13 and i > 8){
                #Right out spoilers
                var spbangle = rightInSpoilers or 0.00;
                var spoilerCurrentHeight = spbangle*spoilerTotalHeight;
                allSpoilers_scale[i].setScale(1,spbangle);
                allSpoilers_scale[i].setTranslation(0,(spoilerTotalHeight-spoilerCurrentHeight)/2);
            }
        }
        
        #var spbangle = getprop("surface-positions/speedbrake-pos-norm") or 0.00;
        #var spoilerCurrentHeight = spbangle*spoilerTotalHeight;
        #spoilers_scale.setScale(1,spbangle);
        #spoilers_scale.setTranslation(0,(spoilerTotalHeight-spoilerCurrentHeight)/2);
    },
    updateFctlMode: func()
    {
        if (getprop("/fcs/pfc-enable") == 1) {
            fctlMode.setText("NORMAL");
            fctlMode.setColor(0,1,0);
            fctlModeBox.setColor(0,1,0);
        } else {
            fctlMode.setText("DIRECT");
            fctlMode.setColor(1,0.76,0);
            fctlModeBox.setColor(1,0.76,0);
        }
    },
    update: func()
    {
        aileronPosLeft.setTranslation(0,2.2*getprop("/fcs/left-out-aileron/final-deg"));
        aileronPosRight.setTranslation(0,2.2*getprop("/fcs/right-out-aileron/final-deg"));
        elevPosLeft.setTranslation(0,2.2*getprop("/fcs/left-elevator/final-deg"));
        elevPosRight.setTranslation(0,2.2*getprop("/fcs/right-elevator/final-deg"));
        elevatorTrim.setText(sprintf("%3.2f",math.round(getprop("/fcs/stabilizer/final-deg-ind"),0.1)));
        flaperonPosLeft.setTranslation(0,2*getprop("/fcs/left-in-aileron/final-deg"));
        flaperonPosRight.setTranslation(0,2*getprop("/fcs/right-in-aileron/final-deg"));
        rudderPos.setTranslation(4.7*getprop("/fcs/rudder/final-deg"),0);

        me.updateRudderTrim();
        me.updateSpoilers();
        me.updateFctlMode();
    },
};
