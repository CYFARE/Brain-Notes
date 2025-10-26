# deps (CachyOS/Arch)

```bash
sudo pacman -Syu
sudo pacman -S --needed base-devel git nasm yasm pkgconf cuda ffnvcodec-headers nvidia-utils
```

# env (fish)

```bash
set -x CUDA_PATH /opt/cuda
set -x PATH $CUDA_PATH/bin $PATH
set -x LD_LIBRARY_PATH $CUDA_PATH/lib64 $LD_LIBRARY_PATH
set -x NVCC_GENCODE (nvidia-smi --query-gpu=compute_cap --format=csv,noheader | awk -F. '{printf "-gencode=arch=compute_%d%d,code=sm_%d%d",$1,$2,$1,$2}')
```

# source

```bash
git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
cd ffmpeg
```

# configure (performance + CUDA)

```bash
./configure \
  --prefix=/usr/local \
  --enable-gpl \
  --enable-version3 \
  --enable-nonfree \
  --disable-debug \
  --enable-lto \
  --enable-fast-unaligned \
  --enable-cuda-nvcc \
  --enable-nvenc \
  --enable-nvdec \
  --extra-cflags="-O3 -pipe -fomit-frame-pointer -march=native -mtune=native -ffunction-sections -fdata-sections -I$CUDA_PATH/include" \
  --extra-ldflags="-Wl,-O1,--as-needed,-z,relro,-z,now -Wl,--gc-sections -L$CUDA_PATH/lib64" \
  --nvccflags="$NVCC_GENCODE -O3"
```

# build & install

```bash
make -j (nproc)
sudo make install
```

# quick verification

```bash
ffmpeg -hide_banner -filters | grep -E 'cuda|nvenc|nvdec'
ffmpeg -hide_banner -hwaccels
```

