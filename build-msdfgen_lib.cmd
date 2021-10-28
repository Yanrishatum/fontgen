pushd native
del msdfgen_lib.obj
del msdfgen_lib.exp
del msdfgen_lib.lib
del msdfgen_lib.dll
vcvars && nmake Makefile.win