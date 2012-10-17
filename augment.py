#!/usr/bin/env python

import os
import re
import sys

from optparse import OptionParser

# return string of float with 2 decimal only
def dispFloat(f):
    return"%0.2f" % f

parser = OptionParser()

parser.add_option("-n", "--net-mensuel",
                  dest="netMensuel",
                  type="float",
                  help="Salaire net mensuel")

parser.add_option("-a", "--brut-annuel",
                  dest="brutAnnuel",
                  type="float",
                  help="Salaire brut annuel")

(options, args) = parser.parse_args()

print "brut annuel : " + dispFloat(options.brutAnnuel)
print "net mensuel : " + dispFloat(options.netMensuel)

ratio = options.netMensuel/(options.brutAnnuel/12)
#print "augmentation(%) \t | augmentation (e) \t| brut annuel \t"
augments = list()
for i in range(21):

    augment = options.brutAnnuel * i/100
    newBrutAnnuel = options.brutAnnuel + augment
    newBrutMensuel = newBrutAnnuel / 12
    newNetMensuel = ratio*newBrutMensuel
    augmentMensuel = newNetMensuel - options.netMensuel
    l = [i, augment, newBrutAnnuel, newBrutMensuel, newNetMensuel]
    augments.append(l)
    print i.__repr__() + "% \t | "            + \
          dispFloat(augment) + "e \t| "       + \
          dispFloat(newBrutAnnuel) + "e \t| " + \
          dispFloat(newBrutMensuel) + "e \t|" + \
          dispFloat(newNetMensuel) + "e \t|"  + \
          dispFloat(augmentMensuel) +"e\t|"


