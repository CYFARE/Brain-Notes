
For GNU/Linux only!

### Setup

- Choose Non-Artifact Desktop version for build
- After initial setup is complete, enter folder and run:

```bash
git pull
./mach clobber
touch mozcofig
```

- Get optimized mozconfig from: https://github.com/CYFARE/HellFire/tree/main/MozConfigs/Linux64 and use text editor to copy-paste content to mozconfig created in folder.

### Post Build Optimizations

#### BOLT Optimization

Arch / CachyOS Specific:

```bash
# Install tools — llvm-bolt + perf2bolt ship inside Arch/CachyOS's llvm package
sudo pacman -S --needed llvm perf
command -v llvm-bolt perf2bolt
paru -S execstack

# Allow user-space perf profiling
sudo sysctl kernel.perf_event_paranoid=-1 kernel.kptr_restrict=0
```

```bash
./mach build

perf record -e cycles:u -j any,u -o perf.data -- ./objdir-opt/dist/bin/firefox

perf2bolt -p perf.data -o perf.fdata ./objdir-opt/dist/bin/libxul.so

cp ./objdir-opt/dist/bin/libxul.so{,.orig}

llvm-bolt ./objdir-opt/dist/bin/libxul.so \
  -o ./objdir-opt/dist/bin/libxul.so.bolt \
  -data=perf.fdata \
  -reorder-blocks=ext-tsp \
  -dyno-stats -icf=all
execstack -c ./objdir-opt/dist/bin/libxul.so.bolt
and mv ./objdir-opt/dist/bin/libxul.so{.bolt,}

./mach run
```

If BOLT errors:

```bash
# Check exec stack if firefox doesn't open
readelf -lW ./objdir-opt/dist/bin/libxul.so | grep GNU_STACK

# Add Exec Stack Post BOLT Rewrite if read elf empty
python3 -c '
  import struct
  p = "objdir-opt/dist/bin/libxul.so"
  d = bytearray(open(p, "rb").read())
  ph = struct.unpack_from("<Q", d, 0x20)[0]
  es = struct.unpack_from("<H", d, 0x36)[0]
  n = struct.unpack_from("<H", d, 0x38)[0]
  gs = None
  last_note = None
  for i in range(n):
      o = ph + i * es
      t = struct.unpack_from("<I", d, o)[0]
      if t == 0x6474E551:
          gs = o
      elif t == 4:
          last_note = o
  if gs is not None:
      flags = struct.unpack_from("<I", d, gs + 4)[0]
      with open(p, "r+b") as f:
          f.seek(gs + 4)
          f.write(struct.pack("<I", flags & ~1))
      print("GNU_STACK existed, flags", hex(flags), "->", hex(flags & ~1))
  elif last_note is not None:
      with open(p, "r+b") as f:
          f.seek(last_note)
          f.write(struct.pack("<IIQQQQQQ", 0x6474E551, 6, 0, 0, 0, 0, 0, 0x10))
      print("no GNU_STACK; converted a PT_NOTE into one (RW)")
  else:
      print("no GNU_STACK and no PT_NOTE to convert")
  '
# OR restore old libxul.so and repatch
cd objdir-opt/dist/bin
mv libxul.so libxul.so.bolt
cp libxul.so.orig libxul.so
rm perf.data
```

## Multi-Language Support

```bash
./mach package
```

```bash
./mach package-multi-locale --locales ach af ak an ar as ast az be bg bn-BD bn-IN bn bo br brx bs ca-valencia ca cak ckb crh cs csb cy da de dsb el en-CA en-GB en-ZA eo es-AR es-CL es-ES es-MX et eu fa ff fi fr frp fur fy-NL ga-IE gd gl gn gu-IN gv he hi-IN hr hsb hto hu hy-AM hye ia id ilo is it ixl ja-JP-mac ja ka kab kk km kn ko kok ks ku lb lg lij lo lt ltg lv mai meh mix mk ml mn mr ms my nb-NO ne-NP nl nn-NO nr nso ny oc or pa-IN pai pbb pl ppl pt-BR pt-PT quy qvi rm ro ru rw sah sat sc scn sco si sk skr sl son sq sr ss st sv-SE sw szl ta-LK ta te tg th tl tn tr trs ts tsz uk ur uz ve vi wo xcl xh zam zh-CN zh-TW zu
```


## Patching / Unpatching

Downloading patch file: 
```bash
wget -O nvidia-blocklist.patch "https://aur.archlinux.org/cgit/aur.git/plain/0001-remove-nvidia-blocklist.patch?h=firefox-vaapi"
```

Applying:
```bash
patch -p1 --fuzz=3 < nvidia-blocklist.patch
```

Unapplying:
```bash
patch -p1 -R --fuzz=3 < nvidia-blocklist.patch
```
