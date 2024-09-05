mkdir src/compiled
start shadercRelease -f shaders/vs_basic.sc -o src/compiled/vs_basic --type v -p s_5_0 -i include/bgfx
start shadercRelease -f shaders/fs_basic.sc -o src/compiled/fs_basic --type f -p s_5_0 -i include/bgfx