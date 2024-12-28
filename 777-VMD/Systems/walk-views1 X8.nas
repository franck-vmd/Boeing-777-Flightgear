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
              [ -23.81,   -2.00,   -0.50],
              [ -21.30,   -5.03,   -0.50],
              [ -21.33,   -5.40,   -0.66],
              [ -21.37,   -5.77,   -0.89],
              [ -21.41,   -6.13,   -1.15],
              [ -21.44,   -6.50,   -1.42],
              [ -21.48,   -6.87,   -1.68],
              [ -21.52,   -7.23,   -1.94],
              [ -21.55,   -7.60,   -2.21],
              [ -21.59,   -7.97,   -2.46],
              [ -21.63,   -8.34,   -2.71],
              [ -21.66,   -8.71,   -2.98],
              [ -21.70,   -9.07,   -3.24],
              [ -21.74,   -9.44,   -3.49],
              [ -21.77,   -9.81,   -3.74],
              [ -21.81,  -10.18,   -4.00],
              [ -21.85,  -10.55,   -4.25],
              [ -21.89,  -10.91,   -4.50],
              [ -21.92,  -11.28,   -4.77],
              [ -21.96,  -11.65,   -5.00],
              [ -22.00,  -11.85,   -5.31],
              [ -22.04,  -20.00,   -5.40],
             ],
             0.80),
        ]);
# Create the walker for the named view and the given movement restrictions.

    var rigger_walker = walkview.Walker.new("Passerelle View",
                                            plantConstraint);
  


