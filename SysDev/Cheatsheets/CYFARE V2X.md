## Dependencies

Before using the below, make sure to install:

- Nvidia CUDA drivers
- NVCC
- CUDNN
- FFMPEG with CUDA support (build if required after driver install & reboot)
- Download latest Video2x appimage from official repo: https://github.com/k4yt3x/video2x/releases 

After installing, reboot and make sure **nvidia-smi** command detects GPU.

## CYFARE V2X

Instead of using v2x command or trying to build the official GUI on Arch or similar systems where the build process mostly fails due to dependencies, you may use this python GUI:

- https://github.com/CYFARE/CYFARE-V2X

## Cross Platform Linux Appimage

## Upscale: RealESRGAN

```bash
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia PATH="/home/USERNAME/ffmpeg:$PATH" ./Video2X-x86_64.AppImage -i raw.mp4 -o out_realesrgan.mp4 -p realesrgan --realesrgan-model realesrgan-plus -s 4 -a none -d 0 -c hevc_nvenc --pix-fmt p010le --gop-size 240 --max-b-frames 3 -e rc=constqp -e qp=14 -e preset=p1 -e profile=main10
```

## Upscale: RealCUGAN

### h264_nvenc

**-> Reliable, Fast**
-> This method is used in **CYFARE-V2X** project!

```bash
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json \
      __NV_PRIME_RENDER_OFFLOAD=1 \
      __GLX_VENDOR_LIBRARY_NAME=nvidia \
      PATH="/home/USERNAME/ffmpeg:$PATH" \
      ./Video2X-x86_64.AppImage \
        -i raw.mpg -o out.mkv \
        -p realcugan --realcugan-model models-se -s 4 \
        -c h264_nvenc \
        -e preset=llhq -e rc-lookahead=0 -e no-scenecut=1 -e zerolatency=1 -e delay=0 -e aud=1
```

### hvenc

May give errors with many old videos!

```bash
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia PATH="/home/USERNAME/ffmpeg:$PATH" ./Video2X-x86_64.AppImage -i raw.mp4 -o out.mp4 -p realcugan --realcugan-model models-se --realcugan-threads 8 -s 4 -a none -d 0 -c hevc_nvenc --pix-fmt p010le --gop-size 240 --max-b-frames 3 -e rc=constqp -e qp=14 -e preset=p1 -e profile=main10
```

## Rife

```bash
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia PATH="/home/USERNAME/ffmpeg:$PATH" ./Video2X-x86_64.AppImage -i raw.mp4 -o out_rife.mp4 -p rife --rife-model rife-v4.6 -m 2 -a none -d 0 -c hevc_nvenc --pix-fmt p010le --gop-size 240 --max-b-frames 3 -e rc=constqp -e qp=14 -e preset=p1 -e profile=main10
```