- Download tar release and extract

```bash
cd sudo_version_folder
mkdir build
```

- configure for fuzzing

```bash
./configure --prefix=/home/klx/Documents/afl/sudo-1.9.16p2/build \
            --enable-fuzzer-engine=afl-clang-lto \
            --enable-fuzzer-linker=afl-clang-lto \
            --disable-hardening \
            --disable-pie \
            --disable-shared \
            --disable-shared-libutil \
            --disable-ssp \
            --enable-static-sudoers \
            CC="afl-clang-lto" \
		    CXX="afl-clang-lto++" \
		    CFLAGS="$CFLAGS -fsanitize=address -fno-stack-protector -fno-omit-frame-pointer -fno-common -fno-strict-aliasing -fno-strict-overflow -fno-delete-null-pointer-checks -fno-optimize-sibling-calls -fno-pie -no-pie -g -O0" \
		    CXXFLAGS="$CXXFLAGS -fsanitize=address -fno-stack-protector -fno-omit-frame-pointer -fno-common -fno-strict-aliasing -fno-strict-overflow -fno-delete-null-pointer-checks -fno-optimize-sibling-calls -fno-pie -no-pie -g -O0" \
		    LDFLAGS="$LDFLAGS -fsanitize=address -fno-pie -no-pie"
```

```bash
make -j$(nproc)
sudo make install
```