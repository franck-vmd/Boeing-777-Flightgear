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
              [ -25.21,   -2.00,   -0.50],
              [ -25.40,   -5.03,   -0.50],
              [ -25.43,   -5.40,   -0.66],
              [ -25.47,   -5.77,   -0.89],
              [ -25.51,   -6.13,   -1.15],
              [ -25.54,   -6.50,   -1.42],
              [ -25.58,   -6.87,   -1.68],
              [ -25.62,   -7.23,   -1.94],
              [ -25.65,   -7.60,   -2.21],
              [ -25.69,   -7.97,   -2.46],
              [ -25.73,   -8.34,   -2.71],
              [ -25.76,   -8.71,   -2.98],
              [ -25.80,   -9.07,   -3.24],
              [ -25.84,   -9.44,   -3.49],
              [ -25.87,   -9.81,   -3.74],
              [ -25.91,  -10.18,   -4.00],
              [ -25.95,  -10.55,   -4.25],
              [ -25.99,  -10.91,   -4.50],
              [ -26.02,  -11.28,   -4.77],
              [ -26.06,  -11.65,   -5.00],
              [ -26.10,  -11.85,   -5.31],
              [ -26.14,  -20.00,   -5.40],
             ],
             0.80),
        ]);
# Create the walker for the named view and the given movement restrictions.

    var rigger_walker = walkview.Walker.new("Passerelle View",
                                            plantConstraint);
  


