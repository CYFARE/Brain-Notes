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
fast_unwind_on_malloc=0:\
external_symbolizer_path=/usr/lib/llvm-16/bin/llvm-symbolizer:\
strip_path_prefix=/home/klx/Documents/experiments/aflfuzz/xpdf/xpdf-4.05:\
detect_invalid_downcast=1:\
detect_use_after_dtor=1:\
detect_bad_cast=1:\
detect_stack_buffer_overflow=1:\
detect_global_buffer_overflow=1:\
detect_use_of_uninitialized_value=1:\
detect_invalid_load=1:\
detect_invalid_store=1:\
detect_invalid_free=1:\
halt_on_error=1:\
detect_heap_use_after_free=1:\
detect_double_free=1:\
detect_invalid_pointer_arithmetic=1:\
detect_invalid_shift=1:\
detect_invalid_comparison=1:\
detect_invalid_bitwise_operation=1:\
detect_invalid_division=1:\
detect_invalid_modulus=1:\
detect_invalid_pointer_comparison=1:\
detect_invalid_array_index=1:\
detect_invalid_string_operation=1:\
detect_invalid_format_string=1:\
detect_invalid_printf_format=1:\
detect_invalid_scanf_format=1:\
detect_invalid_fprintf_format=1:\
detect_invalid_snprintf_format=1:\
detect_invalid_vfprintf_format=1:\
detect_invalid_vsnprintf_format=1:\
detect_invalid_vprintf_format=1:\
detect_invalid_vsprintf_format=1:\
detect_invalid_strcpy=1:\
detect_invalid_strncpy=1:\
detect_invalid_strcat=1:\
detect_invalid_strncat=1:\
detect_invalid_sprintf=1:\
detect_invalid_snprintf=1:\
detect_invalid_vsprintf=1:\
detect_invalid_vsprintf=1:\
detect_invalid_strtok=1:\
detect_invalid_strtok_r=1:\
detect_invalid_gets=1:\
detect_invalid_fgets=1:\
detect_invalid_fread=1:\
detect_invalid_fwrite=1:\
detect_invalid_fprintf=1:\
detect_invalid_fscanf=1:\
detect_invalid_scanf=1:\
detect_invalid_printf=1:\
detect_invalid_vprintf=1:\
detect_invalid_vfprintf=1:\
detect_invalid_vfscanf=1:\
detect_invalid_vscanf=1:\
detect_invalid_strftime=1:\
detect_invalid_strptime=1:\
detect_invalid_strxfrm=1:\
detect_invalid_strcoll=1:\
detect_invalid_strcasecmp=1:\
detect_invalid_strncasecmp=1:\
detect_invalid_strchr=1:\
detect_invalid_strrchr=1:\
detect_invalid_strspn=1:\
detect_invalid_strcspn=1:\
detect_invalid_strpbrk=1:\
detect_invalid_strstr=1:\
detect_invalid_strtok=1:\
detect_invalid_strxfrm=1:\
detect_invalid_wcschr=1:\
detect_invalid_wcsrchr=1:\
detect_invalid_wcspbrk=1:\
detect_invalid_wcsstr=1:\
detect_invalid_wcsxfrm=1:\
detect_invalid_wcscmp=1:\
detect_invalid_wcscasecmp=1:\
detect_invalid_wcscoll=1:\
detect_invalid_wcsncmp=1:\
detect_invalid_wcsncasecmp=1:\
detect_invalid_wcstok=1:\
detect_invalid_wcstok_s=1:\
detect_invalid_wmemchr=1:\
detect_invalid_wmemcmp=1:\
detect_invalid_wmemcpy=1:\
detect_invalid_wmemmove=1:\
detect_invalid_wmemset=1:\
detect_invalid_wprintf=1:\
detect_invalid_wscanf=1:\
detect_invalid_fwprintf=1:\
detect_invalid_fwscanf=1:\
detect_invalid_swprintf=1:\
detect_invalid_swscanf=1:\
detect_invalid_vwprintf=1:\
detect_invalid_vwscanf=1:\
detect_invalid_vfwprintf=1:\
detect_invalid_vfwscanf=1:\
detect_invalid_vswprintf=1:\
detect_invalid_vswscanf=1:\
detect_invalid_wcsftime=1:\
detect_invalid_wcsptime=1:\
detect_invalid_wcstod=1:\
detect_invalid_wcstof=1:\
detect_invalid_wcstold=1:\
detect_invalid_wcstoul=1:\
detect_invalid_wcstoull=1:\
detect_invalid_wcstoll=1:\
detect_invalid_wcstoull=1" \
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
afl-fuzz -L0 -T all -M master \
  -i /tmp/afl/corpus \
  -o /tmp/afl/sync \
  -m none \
  -t 20000 \
  -P exploit \
  -- ./pdftotext @@ 2>/dev/null

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
