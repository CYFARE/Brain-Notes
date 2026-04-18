
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

```bash
sudo apt install llvm-bolt -y
perf record -e cycles:u -j any,u -o perf.data -- ./objdir-opt/dist/bin/firefox
perf2bolt -p perf.data -o perf.fdata ./objdir-opt/dist/bin/firefox
llvm-bolt ./objdir-opt/dist/bin/libxul.so -o ./objdir-opt/dist/bin/libxul.so.bolt -data=perf.fdata -reorder-blocks=ext-tsp -reorder-functions=cdsort -split-functions -split-all-cold -dyno-stats -icf=1 -use-gnu-stack && mv ./objdir-opt/dist/bin/libxul.so.bolt ./objdir-opt/dist/bin/libxul.so
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
