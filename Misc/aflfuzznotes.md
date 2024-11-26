// do linux optimizations for fuzzbench

GRUB_CMDLINE_LINUX_DEFAULT="quiet elevator=deadline ibpb=off ibrs=off kpti=off l1tf=off mds=off mitigations=off no_stf_barrier noibpb noibrs nopcid nopti nospec_store_bypass_disable nospectre_v1 nospectre_v2 pcid=off pti=off spec_store_bypass_disable=off spectre_v2=off stf_barrier=off"

// Instrumenting binary using e9afl (pdftools example):

e9afl -i pdfinfo -o pdfinfo.afl

// creating minimal corpus - optional //

mkdir -p /tmp/afl
mkdir -p /tmp/afl/corpus
mkdir -p /tmp/afl/sync

AFL_ALLOW_TMP=1 afl-cmin -T all -i /media/klx/EXTREMESSD/corpus/pdfs -o /tmp/afl/corpus -- ./pdftotext @@

sudo cp /tmp/afl_corpus/* /dev/shm/afl/corpus/

// copy all pdfs in folders to current directory

find . -type f -name "*.pdf" -exec mv {} ./ \;

// delete non pdf files

find . -type f -not -name '*.pdf' -delete

// delete larger files in corpus

find . -name "*.pdf" -size +100k -delete

-- testing persistent mode: xpdf with allowlist --

nano allowlist.txt

src:*/PDFDoc.cc
fun:*parse
src:*/PDFParser.cc
fun:*parse
src:*/PDFStream.cc
fun:*parse
src:*/PDFObject.cc
fun:*parse
src:*/PDFDictionary.cc
fun:*parse
src:*/PDFArray.cc
fun:*parse
src:*/PDFString.cc
fun:*parse
src:*/PDFNameTree.cc
fun:*parse
src:*/PDFXRef.cc
fun:*parse
src:*/PDFPage.cc
fun:*parse
src:*/PDFImage.cc
fun:*parse
src:*/PDFImageOutputDev.cc
fun:*parse

export AFL_LLVM_ALLOWLIST=`pwd`/allowlist.txt

cd build

-- fsanitize options --
`-fsanitize=address,undefined,memory,thread,leak -fno-omit-frame-pointer`

export AFL_LLVM_INSTRUMENT=LTO
export AFL_FAST_CAL=1
export AFL_SKIP_CPUFREQ=1
export AFL_NO_AFFINITY=1
export AFL_USE_ASAN=1
export AFL_LLVM_LAF_ALL=1
export AFL_LLVM_INJECTIONS_ALL=1
export AFL_CMPLOG_ONLY_NEW=1
export AFL_MAP_SIZE=262144
export CC=afl-clang-lto
export CXX=afl-clang-lto++
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo core | sudo tee /proc/sys/kernel/core_pattern

-- for xpdf --

cmake .. \
    -DCMAKE_C_COMPILER=afl-clang-lto \
    -DCMAKE_CXX_COMPILER=afl-clang-lto++ \
    -DCMAKE_C_FLAGS="-fsanitize=address -g" \
    -DCMAKE_CXX_FLAGS="-fsanitize=address -g" \
    -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=address" \
    -DCMAKE_BUILD_TYPE=Debug \
    -DBUILD_SHARED_LIBS=OFF

-- for poppler --

cmake .. \
    -DCMAKE_C_COMPILER=afl-clang-lto \
    -DCMAKE_CXX_COMPILER=afl-clang-lto++ \
    -DCMAKE_C_FLAGS="-fsanitize=address,leak,undefined -g" \
    -DCMAKE_CXX_FLAGS="-fsanitize=address,leak,undefined -g" \
    -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=address,leak,undefined" \
    -DCMAKE_BUILD_TYPE=Debug \
    -DBUILD_SHARED_LIBS=OFF \
    -DENABLE_QT6=OFF

-- for vim::xxd --
export CFLAGS="-fsanitize=address -fno-omit-frame-pointer -fno-stack-protector -g -O0 -fno-inline-functions -fno-strict-aliasing -fno-optimize-sibling-calls -fno-eliminate-unused-debug-symbols"

export CXXFLAGS="-fsanitize=address -fno-omit-frame-pointer -fno-stack-protector -g -O0 -fno-inline-functions -fno-strict-aliasing -fno-optimize-sibling-calls -fno-eliminate-unused-debug-symbols"

export LDFLAGS="-fsanitize=address -fno-omit-frame-pointer -fno-stack-protector -g -O0 -Wl,-z,now -Wl,-z,relro"

export CPPFLAGS="-D_FORTIFY_SOURCE=2"

cd src/xxd

make -j$(nproc)

-- asan fuzzing --

ASAN_OPTIONS="detect_leaks=1:\
leak_check_at_exit=1:\
symbolize=0:\
handle_abort=1:\
handle_segv=1:\
handle_sigill=1:\
allow_user_segv_handler=1:\
use_sigaltstack=1:\
abort_on_error=1:\
allocator_may_return_null=1:\
fast_unwind_on_malloc=1:\
external_symbolizer_path=/usr/lib/llvm-16/bin/llvm-symbolizer:\
strip_path_prefix=/home/klx/Documents/experiments/aflfuzz/xpdf/xpdf-4.05"

ASAN_OPTIONS="detect_stack_use_after_return=1:\
strict_string_checks=1:\
detect_stack_use_after_scope=1:\
detect_leaks=1:\
leak_check_at_exit=1:\
detect_invalid_pointer_pairs=2:\
strict_init_order=1:\
check_initialization_order=1:\
alloc_dealloc_mismatch=1:\
new_delete_type_mismatch=1:\
detect_odr_violation=2:\
symbolize=0:\
handle_abort=1:\
handle_segv=1:\
handle_sigill=1:\
allow_user_segv_handler=1:\
use_sigaltstack=1:\
detect_container_overflow=1:\
detect_odr_violation=2:\
abort_on_error=1:\
allocator_may_return_null=1:\
print_stats=1:\
print_scariness=1:\
paranoid=1:\
fast_unwind_on_malloc=0"
AFL_CMPLOG_ONLY_NEW=1 \
AFL_LLVM_CTX=1 \
AFL_AUTORESUME=1 \
AFL_IMPORT_FIRST=1 \
AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 \
AFL_FAST_CAL=1 \
AFL_SKIP_CPUFREQ=1 \
AFL_NO_AFFINITY=1 \
AFL_USE_ASAN=1 \
AFL_CRASH_EXITCODE=99 \
afl-fuzz -L 0 -T all -M master \
  -i /tmp/afl/corpus \
  -o /tmp/afl/sync \
  -m none \
  -t 10000 \
  -x dict.txt \
  -P crash=100 \
  -- ./xxd -r @@ 2>/dev/null

// identify unique crashes (requires python afl extras.. not working with new python3 versions)

afl-collect -e /tmp/crashes -o /tmp/unique_crashes ./pdftotext

// reconstruct min crash file

AFL_MAP_SIZE=116825 AFL_TMIN_EXACT=1 afl-tmin -i /tmp/afl_sync_dir/master/crashes/id:000000* -o min_crash_0 -- ./pdftotext @@

./build/xpdf/pdftotext min_crash_0

// reconstructing poc crash file from crash file

hexdump -C min_crash_0 > min_crash_0_hexdump.txt

-- use chatgpt --
awk '{for(i=2;i<=17;i++) if($i ~ /^[0-9a-f]{2}$/) printf "%s", $i; print ""}' min_crash_0_hexdump.txt | xxd -r -p > trigger.pdf

./build/xpdf/pdftotext min_crash_0_reconstructed.pdf
