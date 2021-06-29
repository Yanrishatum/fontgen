call vcvars
@REM @ECHO off
haxe build-hlc.hxml
pushd bin\hlc
cl /Ox fontgen.c -I . -I %HLPATH%\include %HLPATH%\libhl.lib ..\..\native\hl\ammer_msdfgen_lib.lib
popd
copy native\hl\ammer_msdfgen_lib.hl.dll bin\hlc\
copy native\msdfgen_lib.dll bin\hlc\
