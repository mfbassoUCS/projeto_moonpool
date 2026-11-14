@echo off
config -set "cpu cycles=50000"
tasm E08LOG.ASM > E08LOG.LOG
tlink /m E08LOG.OBJ >> E08LOG.LOG
E08LOG > E08RAP.LOG
tasm E08PIX.ASM > E08PIX.LOG
tlink /m E08PIX.OBJ >> E08PIX.LOG
E08PIX >> E08RAP.LOG
config -set "cpu cycles=auto"
tasm E08AUTO.ASM > E08AUTO.LOG
tlink /m E08AUTO.OBJ >> E08AUTO.LOG
E08AUTO >> E08RAP.LOG
