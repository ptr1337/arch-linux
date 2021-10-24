#!/bin/bash

# Detect username
username=$(whoami)



#echo "Adding multilib support"
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

wget https://mirror.cachyos.org/cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz
sudo ./cachyos-repo.sh
echo "Syncing repos and updating packages"
sudo pacman -Syu --noconfirm

echo "Installing and configuring UFW"
sudo pacman -S --noconfirm ufw
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "Installing GPU drivers"
sudo pacman -S --noconfirm mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader

echo "Improving hardware video accelaration"
sudo pacman -S --noconfirm ffmpeg libva-utils libva-vdpau-driver vdpauinfo

echo "Installing common applications"
sudo pacman -S --noconfirm vi vim git openssh links upower htop powertop p7zip ripgrep unzip fwupd unrar atom micro

echo "Creating user's folders"
sudo pacman -S --noconfirm xdg-user-dirs

echo "Installing fonts"
sudo pacman -S --noconfirm ttf-roboto ttf-roboto-mono ttf-droid ttf-opensans ttf-dejavu ttf-liberation ttf-hack noto-fonts ttf-fira-code ttf-fira-mono ttf-font-awesome noto-fonts-emoji ttf-hanazono adobe-source-code-pro-fonts ttf-cascadia-code inter-font

echo "Set environment variables and alias"
touch ~/.bashrc
tee -a ~/.bashrc << EOF
alias upa="sudo rm -f /var/lib/pacman/db.lck && sudo pacman -Syu && paru -Syu --aur"
export TERM=xterm
EOF

echo "Installing paru"
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si --noconfirm
cd ..
rm -rf paru-bin

sudo pacman -S --noconfirm nvidia nvidia-utils nvid-dkms
#echo "Installing nvidia"
#git clone https://aur.archlinux.org/nvidia-dkms-performance.git
#cd nvidia-dkms-performance
#makepkg -si --noconfirm
#cd ..
#rm -rf nvidia-dkms-performance

echo "Installing and configuring Plymouth"
paru -S --noconfirm plymouth
sudo sed -i 's/base systemd autodetect/base systemd sd-plymouth autodetect/g' /etc/mkinitcpio.conf
sudo sed -i 's/quiet rw/quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0 rw/g' /boot/loader/entries/arch.conf
sudo sed -i 's/quiet rw/quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0 rw/g' /boot/loader/entries/arch-lts.conf
sudo mkinitcpio -p linux
sudo mkinitcpio -p linux-lts
sudo plymouth-set-default-theme -R bgrt



echo "Reducing VM writeback time"
sudo touch /etc/sysctl.d/dirty.conf
sudo tee -a /etc/sysctl.d/dirty.conf << EOF
vm.dirty_writeback_centisecs = 1500
EOF
fi


echo "Disabling root (still allows sudo)"
passwd --lock root

echo "Adding NTFS support"
sudo pacman -S --noconfirm ntfs-3g

echo "Installing pipewire multimedia framework"
sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-pulse pipewire-jack lib32-pipewire lib32-pipewire-jack
