#!/usr/bin/env python
import sys
def setVdbgMode(mode=0, carrier=0):
    """
    Configure VDBG output (JANUS)
    Mode: 0=OFF, 1=ADC output 2=RAD DFE input 3=RAD DFE FLT1 output
    """
    # Select mode
    if mode==1:
        """ ADC output """
        VDBG_SEL = (1+carrier)
        RAD_DFE_VDBG_CONTROL = 3
        RAD_ULP_VDBG_CONTROL = 0
        RAD_DFE_RAD_DEBUG_SEL = 0
    elif mode==2:
        """ RAD DFE input """
        VDBG_SEL = (1+carrier)
        RAD_DFE_VDBG_CONTROL = 1
        RAD_ULP_VDBG_CONTROL = 0
        RAD_DFE_RAD_DEBUG_SEL = 1
    elif mode==3:
        """ RAD DFE FLT1 output """
        VDBG_SEL = (1+carrier)
        RAD_DFE_VDBG_CONTROL = 1
        RAD_ULP_VDBG_CONTROL = 0
        RAD_DFE_RAD_DEBUG_SEL = 4
    else:
        """ OFF """
        VDBG_SEL = 0
        RAD_DFE_VDBG_CONTROL = 0
        RAD_ULP_VDBG_CONTROL = 0
        RAD_DFE_RAD_DEBUG_SEL = 0

    # Write VDBG regs
    print 'write_reg "reg=%s value=0x%x idx=-1 inst=0"' %('VDBG_SEL', VDBG_SEL)
    print 'write_reg "reg=%s value=0x%x idx=-1 inst=%s"' %('RAD_DFE_VDBG_CONTROL', RAD_DFE_VDBG_CONTROL, str(carrier))
    print 'write_reg "reg=%s value=0x%x idx=-1 inst=%s"' %('RAD_ULP_VDBG_CONTROL', RAD_ULP_VDBG_CONTROL, str(carrier))
    print 'write_reg "reg=%s value=0x%x idx=-1 inst=%s"' %('RAD_DFE_RAD_DEBUG_SEL', RAD_DFE_RAD_DEBUG_SEL, str(carrier))

if (sys.argv[1] == "--help"):
    print "1: ADC output"
    print "2: RAD DFE input"
    print "3: RAD DFE FLT1 output"
    print "0: Off"
else:
    mode=int(sys.argv[1],10)
    setVdbgMode(mode)
