FROM lopsided/archlinux:devel

ENV USER pwnbox

RUN pacman -Syyu --noconfirm && pacman -S --noconfirm systemd-sysvcompat zsh && \
    sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers && \
    curl -fsSL https://blackarch.org/strap.sh | sh && \
    useradd -m -g users -G wheel -s /usr/bin/zsh $USER && touch /home/$USER/.zshrc

USER $USER
WORKDIR /home/$USER
COPY --chown=$USER:users ./config/neovim /home/$USER/.config/nvim
COPY --chown=$USER:users ./config/zsh /home/$USER

RUN sudo pacman -S --noconfirm neovim exa wget bat fzf ripgrep tmux strace net-tools \
    iputils wget ltrace mlocate ufw python-pip python-virtualenv unzip unrar pigz p7zip nodejs \
    yarn openssh openvpn afl r2ghidra ropper shellnoob binwalk foremost gnu-netcat \
    python-gmpy2 xortool gobuster exploitdb hexedit pwndbg sqlmap z3 jadx nmap \
    perl-image-exiftool mitmproxy ngrok rustscan python-pwntools python-pycryptodome yay && \
    yay -S --noconfirm metasploit-git autojump && \
    git clone --depth=1 https://github.com/niklasb/libc-database.git /home/$USER/.local/share/libc-database && \
    git clone --depth=1 https://github.com/Ganapati/RsaCtfTool.git /home/$USER/.local/share/rsactftool && \
    pip install git+https://github.com/Tib3rius/AutoRecon.git && \
    mkdir -p /home/$USER/.local/bin && ln -sf /home/$USER/.local/share/rsactftool/attacks/single_key/yafu /home/$USER/.local/bin/yafu && \
    sudo setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip /usr/sbin/nmap && \
    sudo mkdir -p /mnt/shared && ln -s /mnt/shared /home/$USER/shared && \
    pip install neovim && nvim --headless -c "autocmd User PackerComplete quitall" -c "PackerSync" && \
    cd /home/$USER/.local/share/nvim/site/pack/packer/start/coq_nvim && python3 -m coq deps && \
    nvim --headless -c "sleep 10" -c "qall" && \
    git clone https://github.com/jandamm/zgenom.git "${HOME}/.zgenom" && \
    touch /home/$USER/.hushlogin && \
    zsh -c "source /home/$USER/.zshrc && /home/$USER/.zgenom/sources/romkatv/powerlevel10k/___/gitstatus/install" && \
    yay -Scc --noconfirm && \
    sudo rm -rf /home/$USER/.zshrc.pre-oh-my-zsh /home/$USER/.zsh_history /home/$USER/.bash_profile \
    /home/$USER/.bash_logout /home/$USER/.bundle /tmp/* /var/cache && sudo updatedb

USER root
COPY ./config/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
