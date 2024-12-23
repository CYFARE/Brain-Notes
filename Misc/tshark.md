cmake .. \
    -DCMAKE_C_COMPILER=afl-clang-lto \
    -DCMAKE_CXX_COMPILER=afl-clang-lto++ \
    -DCMAKE_C_FLAGS="-fsanitize=address -fno-stack-protector -fno-omit-frame-pointer -fno-common -fno-strict-aliasing -fno-strict-overflow -fno-delete-null-pointer-checks -fno-optimize-sibling-calls -g -O0" \
    -DCMAKE_CXX_FLAGS="-fsanitize=address -fno-stack-protector -fno-omit-frame-pointer -fno-common -fno-strict-aliasing -fno-strict-overflow -fno-delete-null-pointer-checks -fno-optimize-sibling-calls -g -O0" \
    -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=address -fno-stack-protector -fno-omit-frame-pointer -fno-common -fno-strict-aliasing -fno-strict-overflow -fno-delete-null-pointer-checks -fno-optimize-sibling-calls -g -O0" \
    -DCMAKE_BUILD_TYPE=Debug