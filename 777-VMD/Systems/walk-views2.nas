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
         walkview.makePolylinePath(
             [
              [ -18.3171,  -1.350000,  -0.50],
              [ -18.3171,  -0.757538,  -0.50],
              [ -18.3171,  -0.665787,  -0.30],
              [ -18.3171,  -0.561585,  -0.10],
              [ -18.3171,  -0.45739,    0.10],
              [ -18.3171,  -0.198494,   0.30],
              [ -18.0428,  -0.198494,   0.50],
              [ -17.9386,  -0.198494,   0.70],
              [ -17.8344,  -0.198494,   0.90],
              [ -17.7302,  -0.198494,   0.90],
              [ -17.6196,  -0.198494,   0.90],
              [ -17.5402,  -0.198494,   0.90],
              [ -13.6204,  -0.198494,   0.90],
             ],
             0.20)
        ]);
# Create the walker for the named view and the given movement restrictions.

    var rigger_walker = walkview.Walker.new("Passe View",
                                            plantConstraint);
  


