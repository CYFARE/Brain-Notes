```python
#!/bin/bash

# Variables
GO_INSTALL_DIR="/usr/local"
PROFILE_FILE=""

# Detect shell profile file
if [ -f "$HOME/.zshrc" ]; then
    PROFILE_FILE="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    PROFILE_FILE="$HOME/.bashrc"
else
    echo "Could not find .bashrc or .zshrc. Please manually add Go to your PATH."
    echo "Example: echo 'export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin' >> ~/.your_shell_rc_file"
    echo "Example: echo 'export GOPATH=\$HOME/go' >> ~/.your_shell_rc_file"
    # Fallback to creating .bashrc if you prefer
    # PROFILE_FILE="$HOME/.bashrc"
    # touch "$PROFILE_FILE"
    # echo "Created $PROFILE_FILE"
fi

# Function to print messages
print_message() {
    echo ""
    echo "----------------------------------------"
    echo "$1"
    echo "----------------------------------------"
}

# Function to install Go
install_go() {
    print_message "Fetching latest Go version..."
    LATEST_GO_VERSION=$(curl -sSL "https://golang.org/VERSION?m=text")
    if [ -z "$LATEST_GO_VERSION" ]; then
        echo "Failed to fetch the latest Go version. Exiting."
        exit 1
    fi
    GO_ARCHIVE_URL="https://dl.google.com/go/${LATEST_GO_VERSION}.linux-amd64.tar.gz"
    GO_ARCHIVE_NAME=$(basename "$GO_ARCHIVE_URL")

    print_message "Downloading Go ${LATEST_GO_VERSION}..."
    curl -fsSL -o "/tmp/${GO_ARCHIVE_NAME}" "$GO_ARCHIVE_URL"
    if [ $? -ne 0 ]; then
        echo "Failed to download Go. Exiting."
        exit 1
    fi

    print_message "Removing existing Go installation (if any from ${GO_INSTALL_DIR}/go)..."
    if [ -d "${GO_INSTALL_DIR}/go" ]; then
        sudo rm -rf "${GO_INSTALL_DIR}/go"
    fi

    print_message "Extracting Go archive to ${GO_INSTALL_DIR}..."
    sudo tar -C "${GO_INSTALL_DIR}" -xzf "/tmp/${GO_ARCHIVE_NAME}"
    if [ $? -ne 0 ]; then
        echo "Failed to extract Go. Exiting."
        exit 1
    fi

    print_message "Cleaning up downloaded archive..."
    rm "/tmp/${GO_ARCHIVE_NAME}"
}

# Function to set up Go environment variables
setup_go_env() {
    print_message "Setting up Go environment variables..."
    
    # Set for the current script session immediately
    export GOROOT="${GO_INSTALL_DIR}/go"
    export GOPATH="$HOME/go"
    # Add Go's bin and GOPATH's bin to PATH
    # Prepend to ensure they take precedence if there are conflicts,
    # or append if you prefer existing paths to take precedence.
    # For this script, ensuring our new Go is found first is often desired.
    export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"


    if [ -n "$PROFILE_FILE" ] && [ -f "$PROFILE_FILE" ]; then
        print_message "Updating ${PROFILE_FILE} for future sessions..."
        # Remove old Go paths if they exist to avoid clutter
        sed -i '/# GoLang Paths Start/,/# GoLang Paths End/d' "$PROFILE_FILE"
        sed -i '/export GOROOT/d' "$PROFILE_FILE" # Basic cleanup for older formats
        sed -i '/export GOPATH/d' "$PROFILE_FILE" # Basic cleanup for older formats
        # Remove specific go/bin and GOPATH/bin patterns from PATH modification lines
        # This is tricky to do perfectly with sed, be cautious.
        # A simpler approach is to ensure the new block is clean.

        echo '' >> "$PROFILE_FILE"
        echo '# GoLang Paths Start' >> "$PROFILE_FILE"
        echo "export GOROOT=\"${GO_INSTALL_DIR}/go\"" >> "$PROFILE_FILE"
        echo 'export GOPATH="$HOME/go"' >> "$PROFILE_FILE"
        echo 'export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"' >> "$PROFILE_FILE"
        echo '# GoLang Paths End' >> "$PROFILE_FILE"
        print_message "Go environment variables updated in ${PROFILE_FILE}."
    else
        print_message "Skipping automatic environment variable setup in profile file."
        echo "Please add the following lines to your shell configuration file (e.g., .bashrc, .zshrc):"
        echo "export GOROOT=\"${GO_INSTALL_DIR}/go\""
        echo "export GOPATH=\"\$HOME/go\""
        echo "export PATH=\"\$GOROOT/bin:\$GOPATH/bin:\$PATH\""
    fi

    # Create GOPATH/bin if it doesn't exist, as go install will place binaries there
    mkdir -p "$GOPATH/bin"
}

# --- Main Script ---

# 1. Install Go
install_go

# 2. Setup Go Environment (sets PATH for this script's session too)
setup_go_env

# Verify Go installation for the current script session
if ! command -v go &> /dev/null; then
    print_message "ERROR: Go command (go) could not be found after installation and PATH setup."
    echo "Please check for errors above. GOROOT/bin should be in your PATH."
    echo "Current GOROOT (in script): $GOROOT"
    echo "Current GOPATH (in script): $GOPATH"
    echo "Current PATH (in script): $PATH"
    exit 1
fi
print_message "Go version $(go version) installed and accessible within the script."

# 3. Install Go tools
print_message "Installing Go tools (will be placed in \$GOPATH/bin which is $GOPATH/bin)..."

INSTALL_COMMAND="go install -v" # -v for verbose, shows package names

print_message "Installing assetfinder (github.com/tomnomnom/assetfinder)..."
if $INSTALL_COMMAND github.com/tomnomnom/assetfinder@latest; then
    echo "assetfinder installed successfully."
else
    echo "ERROR: Failed to install assetfinder. Please check for errors above."
fi

print_message "Installing gau (github.com/lc/gau/v2/cmd/gau)..."
if $INSTALL_COMMAND github.com/lc/gau/v2/cmd/gau@latest; then
    echo "gau installed successfully."
else
    echo "ERROR: Failed to install gau. Please check for errors above."
fi

print_message "Installing anew (github.com/tomnomnom/anew)..."
if $INSTALL_COMMAND github.com/tomnomnom/anew@latest; then
    echo "anew installed successfully."
else
    echo "ERROR: Failed to install anew. Please check for errors above."
fi

# 4. Verify tool accessibility (within this script's environment)
print_message "Verifying tool accessibility within this script's final environment..."
ALL_TOOLS_ACCESSIBLE=true
TOOLS_TO_CHECK=("assetfinder" "gau" "anew")

for tool in "${TOOLS_TO_CHECK[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo "  SUCCESS: '$tool' command is accessible at: $(command -v "$tool")"
    else
        echo "  WARNING: '$tool' command was installed but 'command -v $tool' did not find it."
        echo "           It should be in \$HOME/go/bin ($GOPATH/bin)."
        echo "           This might indicate an issue or a PATH delay. Verify after sourcing your profile."
        ALL_TOOLS_ACCESSIBLE=false
    fi
done

if [ "$ALL_TOOLS_ACCESSIBLE" = true ]; then
    echo "All tools appear to be correctly installed and accessible within the script's configured PATH."
fi

print_message "Installation Script Finished!"
echo ""
echo "The Go tools (assetfinder, gau, anew) have been installed to: $GOPATH/bin"
echo ""
echo "IMPORTANT NEXT STEPS:"
echo "====================="
echo "The script has updated your shell configuration file (${PROFILE_FILE:-'your shell profile file'})"
echo "so that these tools will be available in all *new* terminal sessions."
echo ""
echo "For your *CURRENT* terminal session to find these tools, you need to:"
echo "1. Reload your shell configuration. Type:"
if [ -n "$PROFILE_FILE" ]; then
    echo "   source ${PROFILE_FILE}"
else
    echo "   source ~/.bashrc  (or ~/.zshrc, or your specific shell's profile file)"
fi
echo ""
echo "Alternatively, if you had run this script by sourcing it (e.g., 'source ./your_script_name.sh'),"
echo "the tools would be available immediately in this current terminal."
```