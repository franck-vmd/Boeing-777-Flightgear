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
         walkview.SlopingYAlignedPlane.new([-29.05, -2.0, -0.5], 
                                           [ 31.30,  2.0, -0.5]),
        ]);
# Create the walker for the named view and the given movement restrictions.

    var rigger_walker = walkview.Walker.new("Passenger View",
                                            plantConstraint);
  


