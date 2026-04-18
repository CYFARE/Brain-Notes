
# CPU Inference Optimized Setup

## Setup & Building

- https://github.com/ggml-org/llama.cpp.git

### System Setup

```bash
sudo apt update
sudo apt install -y build-essential cmake ninja-build ccache git libcurl4-openssl-dev
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo core | sudo tee /proc/sys/kernel/core_pattern
```

### Fix nproc 1 error

- Make sure nproc shows all cpu cores
- If not, use these steps:

```bash
# ============================================================
# FIX: nproc shows 1 core instead of N (CPU affinity issue)
# ============================================================

# --- 1. DIAGNOSE ---
nproc --all                                          # true core count (should be N)
nproc                                                # what current shell sees
grep Cpus_allowed_list /proc/self/status             # shell's allowed CPUs
taskset -p $$                                        # shell's affinity mask
taskset -p 1                                         # PID 1 (systemd) affinity — key tell

# --- 2. FIND THE CULPRIT ---
sudo grep -rE "AllowedCPUs|CPUAffinity" /etc/systemd/ 2>/dev/null
grep -nE "taskset|sched_setaffinity" ~/.bashrc ~/.zshrc ~/.profile ~/.zshenv /etc/profile /etc/zsh/* 2>/dev/null

# Common culprits:
#   /etc/systemd/system.conf.d/*.conf         → CPUAffinity=0  (restricts ALL systemd-spawned procs)
#   /etc/systemd/system.control/user-*.slice.d/*.conf → AllowedCPUs= (stale runtime override)

# --- 3. QUICK FIX (current shell only) ---
taskset -cp 0-$(($(nproc --all)-1)) $$

# --- 4. PERMANENT FIX ---
# Disable any offending CPUAffinity/AllowedCPUs drop-ins:
sudo mv /etc/systemd/system.conf.d/perf.conf /etc/systemd/system.conf.d/perf.conf.disabled 2>/dev/null

# Clear stale systemd runtime control overrides:
sudo rm -rf /etc/systemd/system.control/user-*.slice.d

# (Optional) Force user slices to use all CPUs:
sudo mkdir -p /etc/systemd/system/user-.slice.d
echo -e "[Slice]\nAllowedCPUs=0-$(($(nproc --all)-1))" | sudo tee /etc/systemd/system/user-.slice.d/cpus.conf

sudo systemctl daemon-reload
sudo reboot                                          # required — PID 1 affinity persists until reboot

# --- 5. VERIFY ---
nproc                                                # should equal nproc --all
taskset -p 1                                         # mask should cover all cores (e.g. ffffffff for 32)
```

### Compile

```bash
git clone https://github.com/ggml-org/llama.cpp.git

cd llama.cpp

cmake -S . -B build -G Ninja \ -DCMAKE_BUILD_TYPE=Release \ -DCMAKE_C_COMPILER_LAUNCHER=ccache \ -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \ -DGGML_NATIVE=ON \ -DGGML_LTO=ON \ -DGGML_CCACHE=ON \ -DGGML_CUDA=OFF \ -DGGML_BLAS=OFF \ -DGGML_IQK_MUL_MAT=ON \ -DGGML_IQK_FLASH_ATTENTION=ON \ -DGGML_OPENMP=ON \ -DLLAMA_CURL=ON \ -DCMAKE_C_FLAGS="-O3 -march=native -mtune=native -pipe" \ -DCMAKE_CXX_FLAGS="-O3 -march=native -mtune=native -pipe"

cmake --build build --config Release -j $(nproc)
```


## Optimized Runtime for Gemma4

- SuperGemma4 Uncensored Tested: https://huggingface.co/Jiunsong/supergemma4-26b-uncensored-gguf-v2

```bash
mkdir -p ~/models && cd ~/models

hf download Jiunsong/supergemma4-26b-uncensored-gguf-v2 \ supergemma4-26b-uncensored-fast-v2-Q4_K_M.gguf \ --local-dir ~/models/supergemma4
```

### Running

```bash
cd ~/llama.cpp

MODEL=~/models/supergemma4/supergemma4-26b-uncensored-fast-v2-Q4_K_M.gguf

taskset -c 0,2,4,6,8,10,12,14 ./build/bin/llama-server -m "$MODEL" -t 8 -tb 8 -fa on -ctk q8_0 -ctv q8_0 -c 131072 -b 2048 -ub 512 --jinja --mlock --host 127.0.0.1 --port 8080
```


## Automated Script

```bash
#!/bin/bash

# ==============================================================================
# Gemma 4 CPU-Optimized Setup Script
# ==============================================================================
# This script automs the installation of dependencies, the nproc fix,
# llama.cpp building, and model downloading.
# ==============================================================================

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\0로33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Gemma 4 Optimized Setup ===${NC}"

# --- 1. SYSTEM SETUP ---
install_system() {
    echo -e "${YELLOW}Step 1: Installing system dependencies...${NC}"
    sudo apt update
    sudo apt install -y build-essential cmake ninja-build ccache git libcurl4-openssl-dev huggingface-cli
    
    echo -e "${YELLOW}Setting CPU scaling governor to 'performance'...${NC}"
    echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
    
    echo -e "${YELLOW}Setting kernel core_pattern...${NC}"
    echo core | sudo tee /proc/sys/kernel/core_pattern
    echo -e "${GREEN}System setup complete.${NC}"
}

# --- 2. NPROC FIX (The Nuclear Option) ---
fix_nproc() {
    echo -e "${YELLOW}Step 2: Applying nproc/affinity fixes...${NC}"
    echo "This will modify systemd configs to ensure all cores are visible to processes."
    read -p "Do you want to proceed with the nproc fix? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Disable existing overrides
        sudo mv /etc/systemd/system.conf.d/perf.conf /etc/systemd/system.conf.d/perf.conf.disabled 2>/dev/null || true
        
        # Clear stale overrides
        sudo rm -rf /etc/systemd/system.control/user-*.slice.d 2>/dev/null || true
        
        # Force user slices to use all CPUs
        local CORES=$(($(nproc --all)-1))
        sudo mkdir -p /etc/systemd/system/user-.slice.d
        echo -e "[Slice]\nAllowedCPUs=0-$CORES" | sudo tee /etc/systemd/system/user-.slice.d/cpus.conf
        
        sudo systemctl daemon-reload
        echo -e "${GREEN}Fix applied. The system will reboot shortly to finalize affinity changes.${NC}"
        read -p "Reboot now? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo reboot
        fi
    else
        echo -e "${GREEN}Skipping nproc fix.${NC}"
    fi
}

# --- s3. BUILD LLAMA.CPP ---
build_llama() {
    echo -e "${YELLOW}Step 3: Cloning and building llama.cpp...${NC}"
    if [ ! -d "llama.cpp" ]; then
        git clone https://github.com/ggml-org/llama.cpp.git
    fi
    cd llama.cpp

    echo -e "${YELLOW}Running CMake with optimization flags...${NC}"
    cmake -S . -B build -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER_LAUNCHER=ccache \
        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
        -DGGML_NATIVE=ON \
        -DGGML_LTO=ON \
        -DGGML_CCACHE=ON \
        -DGGML_CUDA=OFF \
        -DGGML_BLAS=OFF \
        -DGGML_IQK_MUL_MAT=ON \
        -DGGML_IQK_FLASH_ATTENTION=ON \
        -DGGML_OPENMP=ON \
        -DLLAMA_CURL=ON \
        -DCMAKE_C_FLAGS="-O3 -march=to-native -mtune=native -pipe" \
        -DCMAKE_CXX_FLAGS="-O3 -march=to-native -mtune=native -pipe"

    cmake --build build --config Release -j "$(nproc)"
    echo -e "${GREEN}Build complete.${NC}"
    cd ..
}

# --- 4. DOWNLOAD MODEL ---
download_model() {
    echo -e "${YELLOW}Step 4: Downloading Gemma 4 model via HuggingFace...${NC}"
    mkdir -p ~/models
    cd ~/models
    
    # Using huggingface-cli as the 'hf download' shorthand
    huggingface-cli download Jiunsong/supergemma4-26b-uncensored-gguf-v2 \
        supergemma4-26b-uncensored-fast-v2-Q4_K_M.gguf \
        --local-dir ./supergemma4
    
    echo -e "${GREEN}Model download complete.${NC}"
    cd ..
}

# --- 5. RUN SERVER ---
run_server() {
    echo -e "${YELLOW}Step 5: Starting the optimized server...${NC}"
    cd ~/llama.cpp
    
    # Define the model path based on the user's directory structure
    MODEL_PATH="$HOME/models/supergemma4/supergemma4-26b-uncensored-fast-v2-Q4_K_M.gguf"
    
    if [ ! -f "$MODEL_PATH" ]; then
        echo -e "${RED}ERROR: Model not found at $MODEL_PATH${NC}"
        return
    fi

    # Running with even-core affinity for better performance on many-core systems
    echo -e "${BLUE}Launching server...${NC}"
    taskset -c 0,2,4,6,8,10,12,14 ./build/bin/llama-server \
        -m "$MODEL_PATH" \
        -t 8 -tb 8 -fa on -ctk q8_0 -ctv q8_0 \
        -c 131072 -b 2048 -ub 512 --jinja --mlock \
        --host 127.0.0.1 --port 8080
}

# --- MAIN MENU ---
echo "Select an option:"
echo "1) Full Setup (System -> Fix -> Build -> Download)"
echo "2) Install System & Fix nproc only"
echo "3) Build llama.cpp only"
echo "4) Download Model only"
echo "5) Run the Server (after setup is complete)"
echo "q) Quit"
read -p "Enter choice [1-5/q]: " choice

case $choice in
    1) install_system; fix_nproc; build_llama; download_model; run_server ;;
    2) install_system; fix_nproc ;;
    3) build_llama ;;
    4) download_model ;;
    5) run_server ;;
    q|Q) exit 0 ;;
    *) echo "Invalid choice." ;;
esac

```