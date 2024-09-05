# for macos
rm -rf src/compiled
mkdir src/compiled
shaderc -f shaders/vs_basic.sc -o src/compiled/vs_basic --type v -p metal -i include/bgfx
shaderc -f shaders/fs_basic.sc -o src/compiled/fs_basic --type f -p metal -i include/bgfx