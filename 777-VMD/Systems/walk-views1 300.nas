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
              [ -23.51,   -2.00,   -0.50],
              [ -23.70,   -5.03,   -0.50],
              [ -23.73,   -5.40,   -0.66],
              [ -23.92,   -5.77,   -0.89],
              [ -23.81,   -6.13,   -1.15],
              [ -23.84,   -6.50,   -1.42],
              [ -23.88,   -6.87,   -1.68],
              [ -23.92,   -7.23,   -1.94],
              [ -23.95,   -7.60,   -2.21],
              [ -23.99,   -7.97,   -2.46],
              [ -24.03,   -8.34,   -2.71],
              [ -24.06,   -8.71,   -2.98],
              [ -24.10,   -9.07,   -3.24],
              [ -24.14,   -9.44,   -3.49],
              [ -24.17,   -9.81,   -3.74],
              [ -24.21,  -10.18,   -4.00],
              [ -24.25,  -10.55,   -4.25],
              [ -24.29,  -10.91,   -4.50],
              [ -24.32,  -11.28,   -4.77],
              [ -24.36,  -11.65,   -5.00],
              [ -24.40,  -11.85,   -5.31],
              [ -24.44,  -20.00,   -5.40],
             ],
             0.80),
        ]);
# Create the walker for the named view and the given movement restrictions.

    var rigger_walker = walkview.Walker.new("Passerelle View",
                                            plantConstraint);
  


