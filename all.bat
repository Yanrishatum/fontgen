 resetvars
call vcvars
 pushd native\msdfgen
 cmake -G "NMake Makefiles"  -DCMAKE_TOOLCHAIN_FILE=%vcpkg_path%/scripts/buildsystems/vcpkg.cmake -DCMAKE_BUILD_TYPE=Release . -A Win32 
 nmake clean
 nmake
 popd
pushd native
 del msdfgen.obj
 del msdfgen.exp
 del msdfgen.dll
nmake Makefile.win
popd
copy native\msdfgen_lib.dll bin\msdfgen_lib.dll
haxe build.hxml -D ammer.hl.hlInclude=%HLPATH%/include -D ammer.hl.hlLibrary=%HLPATH%
pushd bin
hl fontgen.hl ../test/config.json -verbose
popd