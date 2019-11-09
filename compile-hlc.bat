@ECHO off
haxe build-hlc.hxml -D ammer.hl.hlInclude=E:/HaxeToolkit/hl/include -D ammer.hl.hlLibrary=E:/HaxeToolkit/hl
pushd bin\hlc
cl /Ox fontgen.c -I . -I E:\HaxeToolkit\hl\include E:\HaxeToolkit\hl\libhl.lib ..\..\native\hl\ammer_msdfgen.hl.lib
popd