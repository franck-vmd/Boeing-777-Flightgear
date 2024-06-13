###############################################################################
##
## Short Empire flying boat for FlightGear.
## Walk view configuration.
##
##  Copyright (C) 2010  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license v2 or later.
##
###############################################################################

# Constraints
var plantConstraint =
    walkview.makeUnionConstraint(
        [
         walkview.SlopingYAlignedPlane.new([-22.0, -2.0, -0.5], 
                                           [ 25.0,  2.0, -0.5]),
        ]);
# Create the walker for the named view and the given movement restrictions.

    var rigger_walker = walkview.Walker.new("Passenger View",
                                            plantConstraint);
  


