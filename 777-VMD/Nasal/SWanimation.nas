#############################################################################
#############################################################################

var duration = getprop("/sim/shutterspeed");
var BATTST = aircraft.door.new("controls/switches/BATTSwitchTimer", duration);
var APUGST = aircraft.door.new("controls/switches/APUGSwitchTimer", duration);
var LBUSST = aircraft.door.new("controls/switches/LBUSSwitchTimer", duration);
var RBUSST = aircraft.door.new("controls/switches/RBUSSwitchTimer", duration);
var LGENST = aircraft.door.new("controls/switches/LGENSwitchTimer", duration);
var RGENST = aircraft.door.new("controls/switches/RGENSwitchTimer", duration);
var LGENBUST = aircraft.door.new("controls/switches/LGENBUSwitchTimer", duration);
var RGENBUST = aircraft.door.new("controls/switches/RGENBUSwitchTimer", duration);
var LPUMP1ST = aircraft.door.new("controls/switches/LPUMP1SwitchTimer", duration);
var LPUMP2ST = aircraft.door.new("controls/switches/LPUMP2SwitchTimer", duration);
var CPUMP1ST = aircraft.door.new("controls/switches/CPUMP1SwitchTimer", duration);
var CPUMP2ST = aircraft.door.new("controls/switches/CPUMP2SwitchTimer", duration);
var RPUMP1ST = aircraft.door.new("controls/switches/RPUMP1SwitchTimer", duration);
var RPUMP2ST = aircraft.door.new("controls/switches/RPUMP2SwitchTimer", duration);
var XFDFWDST = aircraft.door.new("controls/switches/XFDFWDSwitchTimer", duration);
var XFDAFTST = aircraft.door.new("controls/switches/XFDAFTSwitchTimer", duration);
var AUTOSTARTST = aircraft.door.new("controls/switches/AUTOSTARTSwitchTimer", duration);
var LENG_EECST = aircraft.door.new("controls/switches/LENG_EECSwitchTimer", duration);
var RENG_EECST = aircraft.door.new("controls/switches/RENG_EECSwitchTimer", duration);
var BCNST = aircraft.door.new("controls/switches/BCNSwitchTimer", duration);
var NAVST = aircraft.door.new("controls/switches/NAVSwitchTimer", duration);
var LOGOST = aircraft.door.new("controls/switches/LOGOSwitchTimer", duration);
var WINGST = aircraft.door.new("controls/switches/WINGSwitchTimer", duration);
var STRMST = aircraft.door.new("controls/switches/STRMSwitchTimer", duration);
var LENGST = aircraft.door.new("controls/switches/LENGSwitchTimer", duration);
var RENGST = aircraft.door.new("controls/switches/RENGSwitchTimer", duration);
var C1ELECST = aircraft.door.new("controls/switches/C1ELECSwitchTimer", duration);
var C2ELECST = aircraft.door.new("controls/switches/C2ELECSwitchTimer", duration);
var JTSNARMST = aircraft.door.new("controls/switches/JTSNARMSwitchTimer", duration);
var JTSNMANST = aircraft.door.new("controls/switches/JTSNMANSwitchTimer", duration);
var NOZZLELST = aircraft.door.new("controls/switches/NOZZLELSwitchTimer", duration);
var NOZZLERST = aircraft.door.new("controls/switches/NOZZLERSwitchTimer", duration);
var WHLSST = aircraft.door.new("controls/switches/WHLSSwitchTimer", duration);
var WHLFST = aircraft.door.new("controls/switches/WHLFSwitchTimer", duration);
var WHRFST = aircraft.door.new("controls/switches/WHRFSwitchTimer", duration);
var WHRSST = aircraft.door.new("controls/switches/WHRSSwitchTimer", duration);
var ADIRUST = aircraft.door.new("controls/switches/ADIRUSwitchTimer", duration);
var THASYMST = aircraft.door.new("controls/switches/THASYMSwitchTimer", duration);
var EQIPCOOLST = aircraft.door.new("controls/switches/EQIPCOOLSwitchTimer", duration);
var GASPERST = aircraft.door.new("controls/switches/GASPERSwitchTimer", duration);
var RECIRCUPST = aircraft.door.new("controls/switches/RECIRCUPSwitchTimer", duration);
var RECIRCLOST = aircraft.door.new("controls/switches/RECIRCLOSwitchTimer", duration);
var LPACKST = aircraft.door.new("controls/switches/LPACKSwitchTimer", duration);
var RPACKST = aircraft.door.new("controls/switches/RPACKSwitchTimer", duration);
var LTRIMST = aircraft.door.new("controls/switches/LTRIMSwitchTimer", duration);
var RTRIMST = aircraft.door.new("controls/switches/RTRIMSwitchTimer", duration);
var OFVFWDST = aircraft.door.new("controls/switches/OFVFWDSwitchTimer", duration);
var OFVAFTST = aircraft.door.new("controls/switches/OFVAFTSwitchTimer", duration);
var ISLNLST = aircraft.door.new("controls/switches/ISLNLSwitchTimer", duration);
var ISLNCST = aircraft.door.new("controls/switches/ISLNCSwitchTimer", duration);
var ISLNRST = aircraft.door.new("controls/switches/ISLNRSwitchTimer", duration);
var BLDAPUST = aircraft.door.new("controls/switches/BLDAPUSwitchTimer", duration);
var BLDENGLST = aircraft.door.new("controls/switches/BLDENGLSwitchTimer", duration);
var BLDENGRST = aircraft.door.new("controls/switches/BLDENGRSwitchTimer", duration);
var FIREARMCARGOFWD = aircraft.door.new("controls/switches/FIREARMCARGOFWDSwitchTimer", duration);
var FIREARMCARGOAFT = aircraft.door.new("controls/switches/FIREARMCARGOAFTSwitchTimer", duration);
var FLAPOVRDST = aircraft.door.new("controls/switches/FOVRDSwitchTimer", duration);
var GLAPOVRDST = aircraft.door.new("controls/switches/GOVRDSwitchTimer", duration);
var TLAPOVRDST = aircraft.door.new("controls/switches/TOVRDSwitchTimer", duration);
var LNAVST = aircraft.door.new("controls/switches/LNAVSwitchTimer", duration);
var LDSPLST = aircraft.door.new("controls/switches/LDSPLSwitchTimer", duration);
var LAIRDATAST = aircraft.door.new("controls/switches/LAIRDATASwitchTimer", duration);
var RNAVST = aircraft.door.new("controls/switches/RNAVSwitchTimer", duration);
var RDSPLST = aircraft.door.new("controls/switches/RDSPLSwitchTimer", duration);
var RAIRDATAST = aircraft.door.new("controls/switches/RAIRDATASwitchTimer", duration);
var CDSPLST = aircraft.door.new("controls/switches/CDSPLSwitchTimer", duration);
var AFAST = aircraft.door.new("controls/switches/AFASwitchTimer", duration);
var XPDRSWITCH = getprop("instrumentation/transponder/mode-switch");

setlistener("controls/electric/battery-switch", func {
        if(getprop("controls/electric/battery-switch")) BATTST.open();
        else BATTST.close();
});
setlistener("controls/APU/apu-gen-switch", func {
        if(getprop("controls/APU/apu-gen-switch")) APUGST.open();
        else APUGST.close();
});
setlistener("controls/electric/engine[0]/bus-tie", func {
        if(getprop("controls/electric/engine[0]/bus-tie")) LBUSST.open();
        else LBUSST.close();
});
setlistener("controls/electric/engine[1]/bus-tie", func {
        if(getprop("controls/electric/engine[1]/bus-tie")) RBUSST.open();
        else RBUSST.close();
});
setlistener("controls/electric/engine[0]/gen-switch", func {
        if(getprop("controls/electric/engine[0]/gen-switch")) LGENST.open();
        else LGENST.close();
});
setlistener("controls/electric/engine[1]/gen-switch", func {
        if(getprop("controls/electric/engine[1]/gen-switch")) RGENST.open();
        else RGENST.close();
});
setlistener("controls/electric/engine[0]/gen-bu-switch", func {
        if(getprop("controls/electric/engine[0]/gen-bu-switch")) LGENBUST.open();
        else LGENBUST.close();
});
setlistener("controls/electric/engine[1]/gen-bu-switch", func {
        if(getprop("controls/electric/engine[1]/gen-bu-switch")) RGENBUST.open();
        else RGENBUST.close();
});
setlistener("controls/fuel/tank/boost-pump-switch", func {
        if(getprop("controls/fuel/tank/boost-pump-switch")) LPUMP1ST.open();
        else LPUMP1ST.close();
});
setlistener("controls/fuel/tank/boost-pump-switch[1]", func {
        if(getprop("controls/fuel/tank/boost-pump-switch[1]")) LPUMP2ST.open();
        else LPUMP2ST.close();
});
setlistener("controls/fuel/tank[1]/boost-pump-switch", func {
        if(getprop("controls/fuel/tank[1]/boost-pump-switch")) CPUMP1ST.open();
        else CPUMP1ST.close();
});
setlistener("controls/fuel/tank[1]/boost-pump-switch[1]", func {
        if(getprop("controls/fuel/tank[1]/boost-pump-switch[1]")) CPUMP2ST.open();
        else CPUMP2ST.close();
});
setlistener("controls/fuel/tank[2]/boost-pump-switch", func {
        if(getprop("controls/fuel/tank[2]/boost-pump-switch")) RPUMP1ST.open();
        else RPUMP1ST.close();
});
setlistener("controls/fuel/tank[2]/boost-pump-switch[1]", func {
        if(getprop("controls/fuel/tank[2]/boost-pump-switch[1]")) RPUMP2ST.open();
        else RPUMP2ST.close();
});
setlistener("controls/fuel/xfeedfwd-switch", func {
        if(getprop("controls/fuel/xfeedfwd-switch")) XFDFWDST.open();
        else XFDFWDST.close();
});
setlistener("controls/fuel/xfeedaft-switch", func {
        if(getprop("controls/fuel/xfeedaft-switch")) XFDAFTST.open();
        else XFDAFTST.close();
});
setlistener("controls/fuel/jitteson-arm-switch", func {
        if(getprop("controls/fuel/jitteson-arm-switch")) JTSNARMST.open();
        else JTSNARMST.close();
});
setlistener("controls/fuel/tank[0]/nozzle-switch", func {
        if(getprop("controls/fuel/tank[0]/nozzle-switch")) NOZZLELST.open();
        else NOZZLELST.close();
});
setlistener("controls/fuel/tank[2]/nozzle-switch", func {
        if(getprop("controls/fuel/tank[2]/nozzle-switch")) NOZZLERST.open();
        else NOZZLERST.close();
});
setlistener("controls/engines/autostart", func {
        if(getprop("controls/engines/autostart")) AUTOSTARTST.open();
        else AUTOSTARTST.close();
});
setlistener("controls/engines/engine[0]/eec-switch", func {
        if(getprop("controls/engines/engine[0]/eec-switch")) LENG_EECST.open();
        else LENG_EECST.close();
});
setlistener("controls/engines/engine[1]/eec-switch", func {
        if(getprop("controls/engines/engine[1]/eec-switch")) RENG_EECST.open();
        else RENG_EECST.close();
});
setlistener("controls/lighting/beacon", func {
        if(getprop("controls/lighting/beacon")) BCNST.open();
        else BCNST.close();
});
setlistener("controls/lighting/nav-lights", func {
        if(getprop("controls/lighting/nav-lights")) NAVST.open();
        else NAVST.close();
});
setlistener("controls/lighting/logo-lights", func {
        if(getprop("controls/lighting/logo-lights")) LOGOST.open();
        else LOGOST.close();
});
setlistener("controls/lighting/wing-lights", func {
        if(getprop("controls/lighting/wing-lights")) WINGST.open();
        else WINGST.close();
});
setlistener("controls/lighting/cockpit", func {
        if(getprop("controls/lighting/cockpit")) STRMST.open();
        else STRMST.close();
});
setlistener("controls/hydraulics/system/LENG_switch", func {
        if(getprop("controls/hydraulics/system/LENG_switch")) LENGST.open();
        else LENGST.close();
});
setlistener("controls/hydraulics/system[2]/RENG_switch", func {
        if(getprop("controls/hydraulics/system[2]/RENG_switch")) RENGST.open();
        else RENGST.close();
});
setlistener("controls/hydraulics/system[1]/C1ELEC-switch", func {
        if(getprop("controls/hydraulics/system[1]/C1ELEC-switch")) C1ELECST.open();
        else C1ELECST.close();
});
setlistener("controls/hydraulics/system[2]/C2ELEC-switch", func {
        if(getprop("controls/hydraulics/system[2]/C2ELEC-switch")) C2ELECST.open();
        else C2ELECST.close();
});
setlistener("controls/anti-ice/window-heat-ls-switch", func {
        if(getprop("controls/anti-ice/window-heat-ls-switch")) WHLSST.open();
        else WHLSST.close();
});
setlistener("controls/anti-ice/window-heat-lf-switch", func {
        if(getprop("controls/anti-ice/window-heat-lf-switch")) WHLFST.open();
        else WHLFST.close();
});
setlistener("controls/anti-ice/window-heat-rf-switch", func {
        if(getprop("controls/anti-ice/window-heat-rf-switch")) WHRFST.open();
        else WHRFST.close();
});
setlistener("controls/anti-ice/window-heat-rs-switch", func {
        if(getprop("controls/anti-ice/window-heat-rs-switch")) WHRSST.open();
        else WHRSST.close();
});
setlistener("controls/flight/adiru-switch", func {
        if(getprop("controls/flight/adiru-switch")) ADIRUST.open();
        else ADIRUST.close();
});
setlistener("controls/flight/thrust-asym-switch", func {
        if(getprop("controls/flight/thrust-asym-switch")) THASYMST.open();
        else THASYMST.close();
});
setlistener("controls/air/equip-cool-switch", func {
        if(getprop("controls/air/equip-cool-switch")) EQIPCOOLST.open();
        else EQIPCOOLST.close();
});
setlistener("controls/air/gasper-switch", func {
        if(getprop("controls/air/gasper-switch")) GASPERST.open();
        else GASPERST.close();
});
setlistener("controls/air/recircup-switch", func {
        if(getprop("controls/air/recircup-switch")) RECIRCUPST.open();
        else RECIRCUPST.close();
});
setlistener("controls/air/recirclo-switch", func {
        if(getprop("controls/air/recirclo-switch")) RECIRCLOST.open();
        else RECIRCLOST.close();
});
setlistener("controls/air/lpack-switch", func {
        if(getprop("controls/air/lpack-switch")) LPACKST.open();
        else LPACKST.close();
});
setlistener("controls/air/rpack-switch", func {
        if(getprop("controls/air/rpack-switch")) RPACKST.open();
        else RPACKST.close();
});
setlistener("controls/air/ltrim-switch", func {
        if(getprop("controls/air/ltrim-switch")) LTRIMST.open();
        else LTRIMST.close();
});
setlistener("controls/air/rtrim-switch", func {
        if(getprop("controls/air/rtrim-switch")) RTRIMST.open();
        else RTRIMST.close();
});
setlistener("controls/air/ofvfwd-switch", func {
        if(getprop("controls/air/ofvfwd-switch")) OFVFWDST.open();
        else OFVFWDST.close();
});
setlistener("controls/air/ofvaft-switch", func {
        if(getprop("controls/air/ofvaft-switch")) OFVAFTST.open();
        else OFVAFTST.close();
});
setlistener("controls/air/islationl-switch", func {
        if(getprop("controls/air/islationl-switch")) ISLNLST.open();
        else ISLNLST.close();
});
setlistener("controls/air/islationc-switch", func {
        if(getprop("controls/air/islationc-switch")) ISLNCST.open();
        else ISLNCST.close();
});
setlistener("controls/air/islationr-switch", func {
        if(getprop("controls/air/islationr-switch")) ISLNRST.open();
        else ISLNRST.close();
});
setlistener("controls/air/bleedapu-switch", func {
        if(getprop("controls/air/bleedapu-switch")) BLDAPUST.open();
        else BLDAPUST.close();
});
setlistener("controls/air/bleedengl-switch", func {
        if(getprop("controls/air/bleedengl-switch")) BLDENGLST.open();
        else BLDENGLST.close();
});
setlistener("controls/air/bleedengr-switch", func {
        if(getprop("controls/air/bleedengr-switch")) BLDENGRST.open();
        else BLDENGRST.close();
});
setlistener("controls/switches/fire/cargo-fwd-switch", func {
        if(getprop("controls/switches/fire/cargo-fwd-switch")) FIREARMCARGOFWD.open();
        else FIREARMCARGOFWD.close();
});
setlistener("controls/switches/fire/cargo-aft-switch", func {
        if(getprop("controls/switches/fire/cargo-aft-switch")) FIREARMCARGOAFT.open();
        else FIREARMCARGOAFT.close();
});
setlistener("controls/switches/gpws/flap_ovrd_switch", func {
        if(getprop("controls/switches/gpws/flap_ovrd_switch")) FLAPOVRDST.open();
        else FLAPOVRDST.close();
});
setlistener("controls/switches/gpws/gear_ovrd_switch", func {
        if(getprop("controls/switches/gpws/gear_ovrd_switch")) GLAPOVRDST.open();
        else GLAPOVRDST.close();
});
setlistener("controls/switches/gpws/terrain_ovrd_switch", func {
        if(getprop("controls/switches/gpws/terrain_ovrd_switch")) TLAPOVRDST.open();
        else TLAPOVRDST.close();
});
setlistener("controls/switches/l_nav_switch", func {
        if(getprop("controls/switches/l_nav_switch")) LNAVST.open();
        else LNAVST.close();
});
setlistener("controls/switches/l_dspl_switch", func {
        if(getprop("controls/switches/l_dspl_switch")) LDSPLST.open();
        else LDSPLST.close();
});
setlistener("controls/switches/l_airdata_switch", func {
        if(getprop("controls/switches/l_airdata_switch")) LAIRDATAST.open();
        else LAIRDATAST.close();
});
setlistener("controls/switches/r_nav_switch", func {
        if(getprop("controls/switches/r_nav_switch")) RNAVST.open();
        else RNAVST.close();
});
setlistener("controls/switches/r_dspl_switch", func {
        if(getprop("controls/switches/r_dspl_switch")) RDSPLST.open();
        else RDSPLST.close();
});
setlistener("controls/switches/r_airdata_switch", func {
        if(getprop("controls/switches/r_airdata_switch")) RAIRDATAST.open();
        else RAIRDATAST.close();
});
setlistener("controls/switches/c_dspl_switch", func {
        if(getprop("controls/switches/c_dspl_switch")) CDSPLST.open();
        else CDSPLST.close();
});
setlistener("controls/switches/afa_switch", func {
        if(getprop("controls/switches/afa_switch")) AFAST.open();
        else AFAST.close();
});
setlistener("controls/fuel/tank[0]/nozzle-switch", func {
    setprop("controls/fuel/tank[0]/b-nozzle", 0);
    settimer(func { setprop("controls/fuel/tank[0]/b-nozzle", 1) }, 5.0);
});
setlistener("controls/fuel/tank[2]/nozzle-switch", func {
    setprop("controls/fuel/tank[2]/b-nozzle", 0);
    settimer(func { setprop("controls/fuel/tank[2]/b-nozzle", 1) }, 5.0);
});
setlistener("instrumentation/transponder/mode-switch", func {
    XPDRSWITCH = getprop("instrumentation/transponder/mode-switch");
    if(XPDRSWITCH == 0) {
    setprop("instrumentation/transponder/inputs/knob-mode", 1);
    } elsif (XPDRSWITCH == 1) {
    setprop("instrumentation/transponder/inputs/knob-mode", 4);
    } else {
    setprop("instrumentation/transponder/inputs/knob-mode", 5);
    }
});



