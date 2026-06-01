#!/bin/bash

set -e 

echo "Setting up the DOTFILES"


echo "Updating system..."
sudo apt update && sudo apt upgrade -y


echo "Installing packages..."

PACKAGES=(
    "zsh"
    "vim"
    "gh"
    "curl"
    "wget"
    "btop"
    "neovim"
    "fzf"
    "eza"
    "bat"
    "zoxide"
    "build-essential"
    "python3"
    "python3-pip"
    "python3-venv"
)

echo "Installing packages..."
sudo apt install -y "${PACKAGES[@]}"

echo "Packages installed successfully."

DOTFILES_DIR="$HOME/dotfiles" 
REPO_URL="https://github.com/Diizelis/dotfiles.git"

if [ -d "$DOTFILES_DIR" ]; then
    echo "📂 Updating dotfiles..."
    cd "$DOTFILES_DIR"
    git pull origin main
else
    echo "📥 Cloning dotfiles..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh (Unattended)..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

echo "Plugins for Zsh..."

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "   Downloading zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "   ✅ zsh-autosuggestions already installed."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "   Downloading zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "   ✅ zsh-syntax-highlighting already installed."
fi


P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"

if [ ! -d "$P10K_DIR" ]; then
    echo "Downloading Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo "✅ Powerlevel10k already installed."
fi


echo " Creating symbolic links..."

create_symlink() {
    local source_file="$1"
    local target_file="$2"

    if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
        echo "Backing up $target_file -> ${target_file}.backup"
        mv "$target_file" "${target_file}.backup"
    fi
    ln -sf "$source_file" "$target_file"
    echo "Symbolic link $target_file installed."
}

create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

mkdir -p "$HOME/.config"
create_symlink "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"


if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🔄 Changing default shell to Zsh..."
    sudo chsh -s $(which zsh) $USER
fi

echo "setup.sh completed successfully!"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply the changes."
