del /q native\msdfgen-bin
cd native
mkdir msdfgen-bin
cd msdfgen-bin
cmake  -DCMAKE_TOOLCHAIN_FILE=%vcpkg_path%/scripts/buildsystems/vcpkg.cmake -DCMAKE_BUILD_TYPE=Release ../msdfgen -A Win32 
cmake --build . --config Release