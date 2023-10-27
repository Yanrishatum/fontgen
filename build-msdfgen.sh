cd native/msdfgen
cmake .
make
cd ..
make -f Makefile.osx clean
make -f Makefile.osx
