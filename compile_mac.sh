# for macos
rm -rf src/compiled
mkdir src/compiled
shaderc -f shaders/vs_triangle.sc -o src/compiled/vs_triangle --type v -p metal -i include/bgfx
shaderc -f shaders/fs_triangle.sc -o src/compiled/fs_triangle --type f -p metal -i include/bgfx