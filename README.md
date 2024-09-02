# BGFX w/ SDL2 in Zig

This is a blank "hello triangle" project that links the static libraries for bgfx and SDL2 and renders a very basic triangle. I found it very difficult to accomplish this because I had very little knowledge about toolchains, libraries, or compiling C libraries, and then using them with Zig. Hopefully, this provides some ease of use. I've furthermore documented the process I used to set it up so I remember the exact steps I took.

#### Libraries used:
- [SDL2](https://www.libsdl.org/): This was very easy to get working as they upload the latest release compiled in a static library on their [github releases](https://github.com/libsdl-org/SDL/releases/latest).
- [BGFX](https://bkaradzic.github.io/bgfx/overview.html): This was more cumbersome to download and get working as the resources online are very little, and further how to implement it in Zig was even more sparse. 


## How to compile the static library
I've only used these steps for Windows, and there could be better more efficient ways, but this is how I did it and got it working. 

### Prerequisites
1. Zig
2. [make](http://gnuwin32.sourceforge.net/packages/make.htm)

These are listed from the BGFX official documentation so I'd recommend installing them as well

3. [coreutils](http://gnuwin32.sourceforge.net/packages/coreutils.htm)
4. [libiconv](http://gnuwin32.sourceforge.net/packages/libiconv.htm)
5. [libintl](http://gnuwin32.sourceforge.net/packages/libintl.htm)

### Steps

1. First download the three repositories required for bgfx

```
git clone https://github.com/bkaradzic/bx.git
git clone https://github.com/bkaradzic/bimg.git
git clone https://github.com/bkaradzic/bgfx.git
```

2. Once these are downloaded, `cd` into the `bgfx` folder. This is where you'll be running the tools.
3. Run the following command to generate the required makefiles
```
..\bx\tools\bin\windows\genie.exe --gcc=mingw-gcc --with-sdl --with-tools gmake
```
4. `cd` into the `.build\projects\gmake-mingw-gcc` folder. If you are on an Arm chip, or a different operating system this will be different.
5. I didn't want to go through the process of installing and setting up MINGW so I used Zig's drop-in C and C++ compiler

```
make config=release64 CC="zig cc" CXX="zig c++" AR="zig ar" bx bimg bgfx shaderc
```
This should take a few minutes and compile everything you need for the project in the `.build\win64_mingw-gcc` folder



