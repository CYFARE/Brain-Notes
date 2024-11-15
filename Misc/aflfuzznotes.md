// Instrumenting binary using e9afl (pdftools example):
e9afl -i pdfinfo -o pdfinfo.afl

// Instrumenting source: example xpdf

export CC=afl-clang-fast
export CXX=afl-clang-fast++
export CFLAGS="-fsanitize=address -g -O2"
export CXXFLAGS="-fsanitize=address -g -O2"
export LDFLAGS="-fsanitize=address"
mkdir build
cd build
cmake .. \
    -DCMAKE_C_COMPILER=afl-clang-fast \
    -DCMAKE_CXX_COMPILER=afl-clang-fast++ \
    -DCMAKE_C_FLAGS="-fsanitize=address -g -O2" \
    -DCMAKE_CXX_FLAGS="-fsanitize=address -g -O2" \
    -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=address" \
    -DCMAKE_BUILD_TYPE=Debug
make clean  # If rebuilding OR
make -j$(nproc)

mkdir -p /tmp/afl_sync_dir

// creating minimal corpus - optional //
afl-cmin -i /media/klx/EXTREMESSD/corpus/pdfs -o /media/klx/EXTREMESSD/corpus/minpdfs -- ./pdfinfo @@

// copy all pdfs in folders to current directory
find . -type f -name "*.pdf" -exec mv {} . \

// delete larger files in corpus
find . -name "*.pdf" -size +100k -delete

// set cpu performance governor
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
ulimit -n 65536

// fuzzing
export AFL_FAST_CAL=1
export AFL_SKIP_CPUFREQ=1
export AFL_NO_AFFINITY=1

ASAN_OPTIONS=detect_leaks=1,detect_invalid_pointers=1,detect_stack_use_after_return=1,detect_invalid_freelist=1,detect_container_overflow=1,detect_use_after_free=1,detect_heap_leak=1,detect_invalid_load=1,detect_invalid_store=1,abort_on_error=1,symbolize=0 afl-fuzz -M master -i /media/klx/EXTREMESSD/corpus/minpdfs -o /tmp/afl_sync_dir -m none -- ./pdfinfo @@ -f 100 -t 10000

ASAN_OPTIONS=detect_leaks=1,detect_invalid_pointers=1,detect_stack_use_after_return=1,detect_invalid_freelist=1,detect_container_overflow=1,detect_use_after_free=1,detect_heap_leak=1,detect_invalid_load=1,detect_invalid_store=1,abort_on_error=1,symbolize=0 afl-fuzz -M master -i /media/klx/EXTREMESSD/corpus/minpdfs -o /tmp/afl_sync_dir -m none -- ./pdfinfo @@ -D -f 100 -t 5

// debugging crash
ASAN_OPTIONS=symbolize=1 ./pdfinfo crash-file.pdf
