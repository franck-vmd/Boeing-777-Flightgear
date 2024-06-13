#Simple boucle pour initialiser le <property>/systems/refuel/contact</property> ====



     initialized = 0;
     enabled = 0;
     Contact = 0;

    print ("permanent loop:  update  /systems/refuel/contact");
    updateTanker = func {
                    if (initialized  != 1 ) {
                    init_contact();}
    var AllAircraft = props.globals.getNode("ai/models").getChildren("tanker");
    var AllMultiplayer = props.globals.getNode("ai/models").getChildren("multiplayer");


    var selectedTankers = [];

            if ( enabled) {
                if (Contact) {
                setprop("/systems/refuel/contact", 1);
                }else{
                setprop("/systems/refuel/contact", 0);
                }
#print("Debut");
            Contact = 0;
            foreach(a; AllAircraft) {
                                        var  id_node = a.getNode("valid" , 1 );
                                        var  id = id_node.getValue();
#print("id",id);
            if ( id != nil ) {
                        var  contact_node = a.getNode( "refuel/contact" );
                        var tanker_node = a.getNode( "tanker" );


                        var contact = contact_node.getValue();
                        var tanker = tanker_node.getValue();

#print ("contact ", contact , " tanker " , tanker );

            if (tanker and contact) {
                            append(selectedTankers, a);
                            Contact = 1;
setprop("/systems/refuel/contact", 1);
            }

    }
}

    foreach(m; AllMultiplayer) {
        var   id_node = m.getNode("valid" , 1 );
        var  id = id_node.getValue();

            if ( id != nil ) {
                var  contact_node = m.getNode("refuel/contact");
                    var  tanker_node = m.getNode("tanker");

                    var  contact = contact_node.getValue();
                    var  tanker = tanker_node.getValue();

#print (" mp contact ", contact , " tanker " , tanker );

            if (tanker and contact) {
                            append(selectedTankers, m);
                            Contact = 1;
            }

        }
    }
}


#print("Boucle");
                settimer(updateTanker,0.3);
    }


    init_contact = func {

        var  AI_Enabled = props.globals.getNode("sim/ai/enabled");
        enabled = AI_Enabled.getValue();
        initialized = 1;
    }



updateTanker();