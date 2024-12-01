export AFL_FAST_CAL=1
export AFL_SKIP_CPUFREQ=1
export AFL_NO_AFFINITY=1
export AFL_USE_ASAN=1
export AFL_CMPLOG_ONLY_NEW=1
export AFL_MAP_SIZE=1000000
export CC=afl-clang-fast
export CXX=afl-clang-fast++
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo core | sudo tee /proc/sys/kernel/core_pattern


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
AFL_USE_ASAN=1 \
AFL_CMPLOG_ONLY_NEW=1 \
AFL_LLVM_CTX=1 \
AFL_AUTORESUME=1 \
AFL_IMPORT_FIRST=1 \
AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 \
AFL_FAST_CAL=1 \
AFL_SKIP_CPUFREQ=1 \
AFL_NO_AFFINITY=1 \
AFL_CRASH_EXITCODE=99 \
AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so \
afl-fuzz -L 0 -T all -M master\
  -i /tmp/afl/corpus \
  -o /tmp/afl/sync \
  -m none \
  -x dict.txt \
  -P explore=100 \
  -t 40000 \
  -- ./xxd -a -b -R always @@ 2>/dev/null


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
afl-fuzz -L 0 -a text -l X -T all -M master \
  -i /tmp/afl/corpus \
  -o /tmp/afl/sync \
  -m none \
  -t 40000 \
  -P crash=100 \
  -- ./pdftotext @@ 2>/dev/null