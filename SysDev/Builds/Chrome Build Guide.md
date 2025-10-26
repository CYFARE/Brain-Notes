
# For Arch Linux Only


## Install build deps

```bash
sudo pacman -Syu --needed git python nodejs npm clang lld llvm rust \
  ninja gn yasm nasm pkgconf \
  libva pipewire wayland mesa base-devel
```

## Get depot_tools & source

```bash
# 1) depot_tools
mkdir -p ~/src && cd ~/src
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$PWD/depot_tools:$PATH"

# 2) fetch Chromium
mkdir -p ~/chromium && cd ~/chromium
fetch --nohooks chromium
gclient sync
```

## Create build dir

```bash
cd ~/chromium/src
gn args out/Release
```

## Chromium/GN

```yaml
# ---- Build type / optimization
is_debug = false                 # like --enable-release / --disable-debug
is_official_build = true         # enables extra release hardening/defs
symbol_level = 0                 # no debug symbols (strip at link)
blink_symbol_level = 0

use_lld = true                   # --linker=lld
use_thin_lto = false              # --enable-lto=full (ThinLTO in Chromium) or else it's full LTO
treat_warnings_as_errors = false # less brittle on non-Google envs

# ---- Toolchain & plugins
clang_use_chrome_plugins = true  # similar to --enable-clang-plugin

# ---- Trim features/tests we don't need in a browser build
is_component_build = false
enable_nacl = false
rtc_use_pipewire = true          # good default on modern Linux/Wayland

# ---- Security hardening (RELRO, NOW, etc.) is enabled by default in Chromium.
# We still pass explicit ldflags below like your mozconfig.

# ---- Optional media bits (see notes below)
proprietary_codecs = true
ffmpeg_branding = "Chrome"

# ---- Ozone/Wayland + VA-API (optional but recommended on Arch)
use_ozone = true
ozone_platform = "wayland"
use_vaapi = true

# ---- CPU & link tuning akin to your mozconfig
# (Chromium ignores shell CFLAGS; use these GN "extra_*" args)
extra_cflags = [
  "-O3",
  "-march=x86-64-v3",
  "-mavx2","-maes","-msse4.2","-mbmi","-mbmi2","-mfma","-mlzcnt","-mpopcnt",
  "-fno-semantic-interposition",
  "-fomit-frame-pointer",
  "-fdata-sections","-ffunction-sections",
  "-fno-plt",
  "-funroll-loops",
  "-fno-math-errno","-freciprocal-math","-fno-trapping-math",
  "-fno-common",
]

extra_cxxflags = extra_cflags

extra_ldflags = [
  "-Wl,-O3",
  "-Wl,--gc-sections",
  "-Wl,-z,now","-Wl,-z,relro",
  "-Wl,--icf=all",
  "-Wl,--as-needed",
  "-Wl,--hash-style=gnu",
  "-Wl,--sort-common",
  "-Wl,--build-id=none",
]
```

## Generate build files & compile

```bash
# Generate with your args
gn gen out/Release

# Build Chromium (max parallelism)
autoninja -C out/Release chrome
```

## Test run

```bash
./out/Release/chrome --enable-features=VaapiVideoDecodeLinuxGL --ozone-platform=wayland
```
