directory=$( pwd )
cd
sudo apt update && sudo apt upgrade -y
sudo apt-get -y install ninja-build gettext cmake unzip curl wget nodejs npm tmux fd-find ripgrep

sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t "jonathan" \
    -p git \
    -p fzf \
    -p sudo \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting

mkdir ~/.config
cd "$directory"
rm ~/.zshrc
cp .zshrc ~/.zshrc
chsh -s $(which zsh)
exec ${SHELL}

cd
git clone -b release-0.9 https://github.com/neovim/neovim 
cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
cd ../
rm -rf neovim

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit*

cd "$directory"
sh sync.sh nvim r
sh sync.sh tmux r
tmux
sh sync.sh tmux-theme r