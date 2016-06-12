#!/bin/bash
mencoder -nosound -ovc lavc -lavcopts vcodec=mpeg4:mbd=2:trell:autoaspect:vqscale=3 -vf scale=650:533 -mf type=png:fps=1 mf://@list.txt -o time-lapse.avi
