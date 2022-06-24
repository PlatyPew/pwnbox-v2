FROM lopsided/archlinux:devel

ENV USER pwnbox
ENV ZONE Asia
ENV SUBZONE Singapore

RUN pacman -Syyu --noconfirm && pacman -S --noconfirm systemd-sysvcompat zsh && \
    sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers && \
    curl -fsSL https://blackarch.org/strap.sh | sh && \
    useradd -m -g users -G wheel -s /usr/bin/zsh $USER && touch /home/$USER/.zshrc && \
    cat /usr/share/zoneinfo/$ZONE/$SUBZONE > /etc/localtime && \
    if [ ! -d "/lib64" ]; then \
        mkdir /tmp/glibc && \
        curl -fsSL https://archlinux.org/packages/core/x86_64/glibc/download | bsdtar -C /tmp/glibc -xvf - && \
        mv /tmp/glibc/usr/lib /lib64; \
    fi && \
    curl -fsSL https://archlinux.org/packages/core/x86_64/lib32-glibc/download | bsdtar -C / -xvf -

USER $USER
WORKDIR /home/$USER
COPY --chown=$USER:users ./config/neovim /home/$USER/.config/nvim
COPY --chown=$USER:users ./config/zsh /home/$USER
COPY --chown=$USER:users ./config/tmux /home/$USER

RUN sudo pacman -S --noconfirm neovim exa wget bat fzf ripgrep tmux strace net-tools npm \
    iputils wget ltrace mlocate ufw python-pip python-virtualenv unzip unrar pigz p7zip nodejs \
    yarn openssh openvpn afl r2ghidra ropper shellnoob binwalk foremost gnu-netcat \
    python-gmpy2 xortool gobuster exploitdb hexedit pwndbg sqlmap z3 jadx nmap \
    perl-image-exiftool mitmproxy python-pwntools python-pycryptodome python-r2pipe yay && \
    yay -S --noconfirm metasploit-git autojump && \
    git clone --depth=1 https://github.com/niklasb/libc-database.git /home/$USER/.local/share/libc-database && \
    git clone --depth=1 https://github.com/Ganapati/RsaCtfTool.git /home/$USER/.local/share/rsactftool && \
    sudo pip install --upgrade pwncat-cs git+https://github.com/Tib3rius/AutoRecon.git && \
    sudo npm install -g ngrok && \
    echo "source /usr/share/pwndbg/gdbinit.py" >> /home/$USER/.gdbinit && \
    mkdir -p /home/$USER/.local/bin && ln -sf /home/$USER/.local/share/rsactftool/attacks/single_key/yafu /home/$USER/.local/bin/yafu && \
    ln -s /usr/bin/vendor_perl/exiftool /home/$USER/.local/bin && \
    sudo setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip /usr/sbin/nmap && \
    sudo mkdir -p /mnt/shared && ln -s /mnt/shared /home/$USER/shared && \
    pip install neovim && nvim --headless -c "autocmd User PackerComplete quitall" -c "PackerSync" && \
    cd /home/$USER/.local/share/nvim/site/pack/packer/start/coq_nvim && python3 -m coq deps && \
    nvim --headless -c "sleep 10" -c "qall" && \
    git clone https://github.com/jandamm/zgenom.git "${HOME}/.zgenom" && \
    touch /home/$USER/.hushlogin && \
    zsh -c "source /home/$USER/.zshrc && /home/$USER/.zgenom/sources/romkatv/powerlevel10k/___/gitstatus/install" && \
    yay -Scc --noconfirm && yay -Rsc --noconfirm npm && \
    sudo rm -rf /home/$USER/.zshrc.pre-oh-my-zsh /home/$USER/.zsh_history /home/$USER/.bash_profile \
    /home/$USER/.bash_logout /home/$USER/.bundle /tmp/* /var/cache /home/$USER/.cache/pip /home/$USER/.cache/yay && \
    sudo updatedb

USER root
COPY ./config/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
