
- exports

```bash
AFL_LLVM_INJECTIONS_ALL=1
AFL_USE_UBSAN=1
AFL_SKIP_CPUFREQ=1
AFL_LLVM_NOT_ZERO=1
AFL_MAP_SIZE=1000000
CXX=afl-clang-lto++
AFL_LLVM_LAF_ALL=1
AFL_NO_AFFINITY=1
AFL_FAST_CAL=1
CC=afl-clang-lto
```

- compile

```bash
./autogen.sh
./configure --prefix=/tmp/libxml2-afl --disable-shared --without-python
make clean
make -j$(nproc)
```


- fuzzing: xmllink

```bash

afl-cmin -T all -i /home/klx/fuzzing/libxml2/test -o /home/klx/fuzzing/aflin -- ./xmllint --noout --nonet --recover --huge --noenc --nodict --noblanks --nocdata --stream --pedantic @@

AFL_AUTORESUME=1 \
AFL_IMPORT_FIRST=1 \
AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 \
AFL_CRASH_EXITCODE=99 \
AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so \
afl-fuzz -L 0 -T all -M master \
  -i /home/klx/fuzzing/aflin \
  -o /home/klx/fuzzing/aflout \
  -m none \
  -t 50000 \
  -P explore=100 \
  -- ./xmllint --noout --nonet --recover --huge --noenc --nodict --noblanks --nocdata --stream --pedantic @@


AFL_AUTORESUME=1 \
AFL_IMPORT_FIRST=1 \
AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 \
AFL_CRASH_EXITCODE=99 \
AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so \
afl-fuzz -L 0 -T all -S s1 \
  -i /home/klx/fuzzing/aflin \
  -o /home/klx/fuzzing/aflout \
  -m none \
  -t 50000 \
  -P explore=100 \
  -- ./xmllint --noout --nonet --recover --huge --noenc --nodict --noblanks --nocdata --stream --pedantic @@

```