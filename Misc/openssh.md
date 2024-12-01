

git clone git://anongit.mindrot.org/openssh.git
cd openssh
mkdir install var-empty
chmod 700 var-empty
sudo chown root var-empty
autoreconf

make clean

export AFL_LLVM_INSTRUMENT=LTO
export AFL_FAST_CAL=1
export AFL_SKIP_CPUFREQ=1
export AFL_NO_AFFINITY=1
export AFL_USE_ASAN=1
export AFL_LLVM_LAF_ALL=1
export AFL_LLVM_INJECTIONS_ALL=1
export AFL_CMPLOG_ONLY_NEW=1
export AFL_MAP_SIZE=1000000
export CC=afl-clang-lto
export CXX=afl-clang-lto++
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo core | sudo tee /proc/sys/kernel/core_pattern
export LSAN_OPTIONS=detect_leaks=0

export AFL_LLVM_ALLOWLIST=`pwd`/allowlist.txt

./configure \
    CC="afl-clang-lto" \
    CXX="afl-clang-lto++" \
    CFLAGS="$CFLAGS -fsanitize=address -fno-stack-protector -fno-omit-frame-pointer -fno-common -fno-strict-aliasing -fno-strict-overflow -fno-delete-null-pointer-checks -fno-optimize-sibling-calls -fno-pie -no-pie -g -O0" \
    CXXFLAGS="$CXXFLAGS -fsanitize=address -fno-stack-protector -fno-omit-frame-pointer -fno-common -fno-strict-aliasing -fno-strict-overflow -fno-delete-null-pointer-checks -fno-optimize-sibling-calls -fno-pie -no-pie -g -O0" \
    LDFLAGS="$LDFLAGS -fsanitize=address -fno-pie -no-pie" \
    --prefix=$PWD/install \
    --with-privsep-path=$PWD/var-empty \
    --with-sandbox=no \
    --without-pie \
    --disable-security-key \
    --disable-pkcs11 \
    ac_cv_func_poll=yes \
    --with-privsep-user=$USER


make -j$(nproc)
make install

unset LSAN_OPTIONS

AFL_ALLOW_TMP=1 afl-cmin -T all -i testcase.bin -o /tmp/afl/corpus -- /home/klx/Documents/experiments/aflfuzz/openssh/sshd -d -e -p 2200 -r -f /home/klx/Documents/experiments/aflfuzz/openssh/install/etc/sshd_config -i @@

ASAN_OPTIONS="detect_stack_use_after_return=1:\
strict_string_checks=1:\
detect_stack_use_after_scope=1:\
detect_leaks=0:\
leak_check_at_exit=0:\
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
AFL_AUTORESUME=1 \
AFL_IMPORT_FIRST=1 \
AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 \
AFL_FAST_CAL=1 \
AFL_SKIP_CPUFREQ=1 \
AFL_NO_AFFINITY=1 \
AFL_USE_ASAN=1 \
AFL_CRASH_EXITCODE=99 \
AFL_QUIET=1 \
afl-fuzz -L 0 -T all -M master \
  -i /tmp/afl/corpus \
  -o /tmp/afl/sync \
  -m none \
  -t 10000 \
  -x openssh.dict \
  -P crash=100 \
  -- /home/klx/Documents/experiments/aflfuzz/openssh/sshd -d -e -p 2200 -r -f /home/klx/Documents/experiments/aflfuzz/openssh/install/etc/sshd_config -i

