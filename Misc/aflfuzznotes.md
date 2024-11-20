// Instrumenting binary using e9afl (pdftools example):

e9afl -i pdfinfo -o pdfinfo.afl

// creating minimal corpus - optional //

AFL_ALLOW_TMP=1 afl-cmin -T all -i /media/klx/EXTREMESSD/corpus/pdfs -o /tmp/afl_corpus -- ./pdftotext @@

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
export AFL_PERSISTENT=1
export CC=afl-clang-lto
export CXX=afl-clang-lto++
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo core | sudo tee /proc/sys/kernel/core_pattern

-- for xpdf --

cmake .. \
    -DCMAKE_C_COMPILER=afl-clang-lto \
    -DCMAKE_CXX_COMPILER=afl-clang-lto++ \
    -DCMAKE_C_FLAGS="-fsanitize=address,undefined,leak -g" \
    -DCMAKE_CXX_FLAGS="-fsanitize=address,undefined,leak -g" \
    -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=address,undefined,leak" \
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


-- asan :: finds memory overflow issues / heaps etc.. --

AFL_AUTORESUME=1 AFL_IMPORT_FIRST=1 AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 AFL_FAST_CAL=1 AFL_SKIP_CPUFREQ=1 AFL_NO_AFFINITY=1 AFL_USE_ASAN=1 afl-fuzz -T all -i /tmp/afl_corpus -o /tmp/afl_sync_dir -m none -t 100+ -P exploit ./pdftotext @@ 2>/dev/null

// reconstruct min crash file

AFL_MAP_SIZE=116825 AFL_TMIN_EXACT=1 afl-tmin -i /tmp/afl_sync_dir/master/crashes/id:000000* -o min_crash_0 -- ./pdftotext @@

./build/xpdf/pdftotext min_crash_0

// reconstructing poc crash file from crash file

hexdump -C min_crash_0 > min_crash_0_hexdump.txt

-- use chatgpt --
awk '{for(i=2;i<=17;i++) if($i ~ /^[0-9a-f]{2}$/) printf "%s", $i; print ""}' min_crash_0_hexdump.txt | xxd -r -p > trigger.pdf

./build/xpdf/pdftotext min_crash_0_reconstructed.pdf
