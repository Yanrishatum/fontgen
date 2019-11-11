@ECHO off
REM resetvars
REM vcvarsall
REM pushd native\msdfgen
REM cmake -DCMAKE_BUILD_TYPE=Release .
REM nmake clean
REM nmake
REM popd
pushd native
REM del msdfgen.obj
REM del msdfgen.exp
REM del msdfgen.dll
nmake Makefile.win
popd
cp native/msdfgen_lib.dll bin
haxe build.hxml -D ammer.hl.hlInclude=E:/HaxeToolkit/hl/include -D ammer.hl.hlLibrary=E:/HaxeToolkit/hl
pushd bin
hl fontgen.hl ../test/config.json -verbose
popd