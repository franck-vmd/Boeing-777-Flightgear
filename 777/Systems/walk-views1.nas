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
              [ -18.16,   -2.00,   -0.50],
              [ -18.35,   -5.03,   -0.50],
              [ -18.38,   -5.40,   -0.66],
              [ -18.42,   -5.77,   -0.89],
              [ -18.46,   -6.13,   -1.15],
              [ -18.49,   -6.50,   -1.42],
              [ -18.53,   -6.87,   -1.68],
              [ -18.57,   -7.23,   -1.94],
              [ -18.60,   -7.60,   -2.21],
              [ -18.64,   -7.97,   -2.46],
              [ -18.68,   -8.34,   -2.71],
              [ -18.71,   -8.71,   -2.98],
              [ -18.75,   -9.07,   -3.24],
              [ -18.79,   -9.44,   -3.49],
              [ -18.82,   -9.81,   -3.74],
              [ -18.86,  -10.18,   -4.00],
              [ -18.90,  -10.55,   -4.25],
              [ -18.94,  -10.91,   -4.50],
              [ -18.97,  -11.28,   -4.77],
              [ -19.01,  -11.65,   -5.00],
              [ -19.05,  -11.85,   -5.31],
              [ -19.09,  -20.00,   -5.40],
             ],
             0.80),
        ]);
# Create the walker for the named view and the given movement restrictions.

    var rigger_walker = walkview.Walker.new("Passerelle View",
                                            plantConstraint);
  


