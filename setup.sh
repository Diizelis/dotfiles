#!/bin/bash
# Aptur skriptu, ja rodas kļūda
set -e

echo "=== 1. Atjauninām sistēmas pakotnes (Unattended) ==="
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get upgrade -yq

echo "=== 2. Instalējam modernatnes CLI programmas ==="
sudo apt-get install -yq zsh fzf bat eza zoxide git htop

echo "=== 3. Uzstādām Oh My Zsh un spraudņus ==="
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Lejupielādējam Powerlevel10k motīvu un prasītos spraudņus
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

echo "=== 4. Konfigurējam .zshrc failu (Motīvs un Spraudņi) ==="
sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc
sed -i 's|^plugins=.*|plugins=(git zsh-autosuggestions zsh-syntax-highlighting zoxide)|' ~/.zshrc

# Pievienojam aliasus un integrāciju moderno rīku darbībai
if ! grep -q "alias ls='eza" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Moderno rīku konfigurācija un Nerd Fonts ikonas" >> ~/.zshrc
    echo "alias cat='batcat --style=plain'" >> ~/.zshrc
    echo "alias bat='batcat'" >> ~/.zshrc
    echo "alias ls='eza --icons'" >> ~/.zshrc
    echo "alias ll='eza -l --icons'" >> ~/.zshrc
    echo "alias la='eza -la --icons'" >> ~/.zshrc
    echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
fi

echo "=== 5. Nomainām noklusējuma shell uz Zsh ==="
sudo chsh -s $(which zsh) $USER

echo "=== Konfigurācija pabeigta! Pārlādējiet termināli ar: source ~/.zshrc ==="
