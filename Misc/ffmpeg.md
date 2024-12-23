```bash
./configure --prefix=/home/klx/Documents/afl/ffmpeg-7.1/build \
            --enable-static \
            --disable-shared \
            --enable-small \
            --disable-runtime-cpudetect \
            --disable-asm \
            --disable-altivec \
            --disable-vsx \
            --disable-power8 \
            --disable-amd3dnow \
            --disable-amd3dnowext \
            --disable-mmx \
            --disable-mmxext \
            --disable-sse \
            --disable-sse2 \
            --disable-sse3 \
            --disable-ssse3 \
            --disable-sse4 \
            --disable-sse42 \
            --disable-avx \
            --disable-xop \
            --disable-fma3 \
            --disable-fma4 \
            --disable-avx2 \
            --disable-avx512 \
            --disable-avx512icl \
            --disable-aesni \
            --disable-armv5te \
            --disable-armv6 \
            --disable-armv6t2 \
            --disable-vfp \
            --disable-neon \
            --disable-dotprod \
            --disable-i8mm \
            --disable-inline-asm \
            --disable-x86asm \
            --disable-mipsdsp \
            --disable-mipsdspr2 \
            --disable-msa \
            --disable-mipsfpu \
            --disable-mmi \
            --disable-lsx \
            --disable-lasx \
            --disable-rvv \
            --disable-fast-unaligned \
            --disable-debug \
            --enable-debug=2 \
            --disable-optimizations \
            --enable-extra-warnings \
            --disable-stripping \
            --assert-level=2 \
            --enable-memory-poisoning \
            --valgrind=valgrind \
            --enable-ossfuzz \
            --extra-cflags="-fsanitize=address -fno-stack-protector -fno-omit-frame-pointer -fno-common -fno-strict-aliasing -fno-strict-overflow -fno-delete-null-pointer-checks -fno-optimize-sibling-calls -fno-pie -no-pie -g -O2" \
            --extra-ldflags="-fsanitize=address -fno-pie -no-pie" \
            --cc=afl-clang-lto \
            --cxx=afl-clang-lto++ \
            --enable-cross-compile
```

```bash
make -j$(nproc)
sudo make install
```

fuzzing sbc frame extraction:

```bash
AFL_CMPLOG_ONLY_NEW=1 \
AFL_LLVM_CTX=1 \
AFL_AUTORESUME=1 \
AFL_IMPORT_FIRST=1 \
AFL_NO_AFFINITY=1 \
AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 \
AFL_CRASH_EXITCODE=99 \
AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so \
afl-fuzz -L 0 -T all -M master \
  -i /tmp/afl/corpus \
  -o /tmp/afl/sync \
  -m none \
  -t 50000 \
  -P explore=100 \
  -- ./ffmpeg -f sbc -i @@ 2>/dev/null
```

###### fuzzing wav audio

create an allowlist.txt:

```bash
src:.*libavformat/wav.*
src:.*libavformat/pcm.*
```



compile and then run: 

```bash
AFL_ALLOW_TMP=1 afl-cmin -T all -i /media/klx/EXTREMESSD/corpus/wav -o /tmp/afl/corpus -- ./ffmpeg -v error -hide_banner -nostats -threads 1 -i @@ -f null - 2>/dev/null
```


```bash
AFL_CMPLOG_ONLY_NEW=1 \
AFL_LLVM_CTX=1 \
AFL_AUTORESUME=1 \
AFL_IMPORT_FIRST=1 \
AFL_NO_AFFINITY=1 \
AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 \
AFL_CRASH_EXITCODE=99 \
AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so \
afl-fuzz -L 0 -T all -M master \
  -i /tmp/afl/corpus \
  -o /tmp/afl/sync \
  -m none \
  -t 50000 \
  -P explore=100 \
  -- ./ffmpeg -v error -hide_banner -nostats -threads 1 -i @@ -f null - 2>/dev/null
```
