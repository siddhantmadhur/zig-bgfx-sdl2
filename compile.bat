mkdir src/compiled
start shadercRelease -f shaders/vs_triangle.sc -o src/compiled/vs_triangle --type v -p s_5_0 -i include/bgfx
start shadercRelease -f shaders/fs_triangle.sc -o src/compiled/fs_triangle --type f -p s_5_0 -i include/bgfx