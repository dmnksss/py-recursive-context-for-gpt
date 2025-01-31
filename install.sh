#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display informational messages
function echo_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

# Function to display error messages
function echo_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
}

# Function to check if a command exists
function command_exists() {
    command -v "$1" &> /dev/null
}

# Check for required commands: python3, git
REQUIRED_CMDS=(python3 git)

for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command_exists "$cmd"; then
        echo_error "$cmd is not installed. Please install $cmd and try again."
        exit 1
    fi
done

# Check for pip3 installation
if ! command_exists pip3; then
    echo_info "pip3 not found. Attempting to install pip3."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python3 get-pip.py --user
    export PATH="$HOME/.local/bin:$PATH"
    if ! command_exists pip3; then
        echo_error "Failed to install pip3. Please install pip3 manually."
        exit 1
    fi
    rm get-pip.py
fi

# Install necessary system dependencies for pyperclip (for Linux)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if ! command_exists xclip && ! command_exists xsel; then
        echo_info "Installing xclip for clipboard support on Linux."
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y xclip
        elif command_exists yum; then
            sudo yum install -y xclip
        elif command_exists pacman; then
            sudo pacman -S --noconfirm xclip
        else
            echo_error "Unsupported package manager. Please install xclip manually."
            exit 1
        fi
    fi
fi

# Install the package globally via pip3 from GitHub using HTTPS
echo_info "Installing py-gpt-copy globally via pip3..."
sudo pip3 install git+https://github.com/dmnksss/py-gpt-copy.git

# Ensure that /usr/local/bin is in PATH
sudo cp copy_module.py /usr/local/bin/py-gpt-copy
sudo chmod +x /usr/local/bin/py-gpt-copy

# Verify installation
if command_exists py-gpt-copy; then
    echo_info "py-gpt-copy has been successfully installed and is available globally!"
    echo_info "You can run it using the command: py-gpt-copy"
else
    echo_error "py-gpt-copy installation failed. Please check the installation steps."
    exit 1
fi