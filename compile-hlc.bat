call vcvars
@REM @ECHO off
haxe build-hlc.hxml -D ammer.hl.hlInclude=%HLPATH%/include -D ammer.hl.hlLibrary=%HLPATH%
pushd bin\hlc
cl /Ox fontgen.c -I . -I %HLPATH%\include %HLPATH%\libhl.lib ..\..\native\hl\ammer_msdfgen_lib.hl.lib
popd
copy native\hl\ammer_msdfgen_lib.hl.dll bin\hlc
copy native\msdfgen_lib.dll bin\hlc
