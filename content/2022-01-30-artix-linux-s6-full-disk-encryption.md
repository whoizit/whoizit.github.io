+++
title = "Artix Linux s6 Full Disk Encryption"
date = 2022-01-30
+++
*(черновик)*

s6 [самый быстрый получается](https://www.youtube.com/watch?v=mkkU1CHI3TY)

системы инициализации Linux можно условно разделить на три вида:
- System 5, **SysV**-подобные (Upstart, OpenRC)
- **daemontools**-подобные (daemontools-encore, runit, s6)
- **launchd**-подобные (Systemd, Suite66, nosh, Dinit)

Характерные отличия:
- SysV - скрипты запуска обычно имеют 3 SHELL функции - start(), stop(), reload()
- daemontools - примитивизм, простота, однострочники на SHELL, автоматический перезапуск
- launchd - конфигурационный файл в стиле ini (key=value)

Что касается SystemD - многословность, неадекватно длинные команды, комбаин-всё в себе, более 1.3 млн строк кода (высокая vulnerability)

s6 это ремейк runit; runit это ремейк daemontools от великого DJB

s6 (s6-db-reload) в отличии от всех выше-названных компилирует списки сервисов в базу данных (compiled service database). Те секунды которые он экономит при загрузке могут быть неоспоримым преимуществом при активном использовании ноутбуков

Links:
1. [ArtixWiki: Installation With Full Disk Encryption](https://wiki.artixlinux.org/Main/InstallationWithFullDiskEncryption)
2. [ArchWiki: Partitioning#BIOS/GPT_layout_example](https://wiki.archlinux.org/title/Partitioning#BIOS/GPT_layout_example)
3. [ArchWiki: GRUB#Encrypted_/boot](https://wiki.archlinux.org/title/GRUB#Encrypted_/boot)
4. [ArchWiki: Device_encryption#With_a_keyfile_embedded_in_the_initramfs](https://wiki.archlinux.org/title/Dm-crypt/Device_encryption#With_a_keyfile_embedded_in_the_initramfs)

```sh
cryptsetup benchmark
```
Имейте ввиду что у меня benchmark показывает в 3 раза меньшие результаты в live ISO, чем в установленой системе с ядром linux-zen.

Считаю значения по умолчанию оптимальными (aes-xts-plain64:sha256:512b) и достаточно быстрыми (на моем древнем процессоре AMD FX-4300 это:
```
~ > cryptsetup benchmark
# Tests are approximate using memory only (no storage IO).
PBKDF2-sha1      1190211 iterations per second for 256-bit key
PBKDF2-sha256    1424695 iterations per second for 256-bit key
PBKDF2-sha512    1227840 iterations per second for 256-bit key
PBKDF2-ripemd160  691672 iterations per second for 256-bit key
PBKDF2-whirlpool  382134 iterations per second for 256-bit key
argon2i       4 iterations, 866287 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
argon2id      4 iterations, 858144 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
#     Algorithm |       Key |      Encryption |      Decryption
        aes-cbc        128b       534.3 MiB/s      1795.6 MiB/s
    serpent-cbc        128b        83.2 MiB/s       312.4 MiB/s
    twofish-cbc        128b       179.4 MiB/s       241.3 MiB/s
        aes-cbc        256b       406.3 MiB/s      1450.6 MiB/s
    serpent-cbc        256b        87.4 MiB/s       313.5 MiB/s
    twofish-cbc        256b       188.2 MiB/s       237.3 MiB/s
        aes-xts        256b      1546.1 MiB/s      1543.9 MiB/s
    serpent-xts        256b       277.3 MiB/s       291.6 MiB/s
    twofish-xts        256b       223.9 MiB/s       227.5 MiB/s
        aes-xts        512b      1306.2 MiB/s      1289.4 MiB/s
    serpent-xts        512b       285.5 MiB/s       293.9 MiB/s
    twofish-xts        512b       223.1 MiB/s       223.3 MiB/s
```

Если вы используете очень быстрый NVMe возможно это не для вас. Если используете SATA интерфейс, вы можете поставить более тяжелую крипту, например serpent-xts:argon2id:512b

```sh
fdisk -l /dev/sdX
# BIOS/GPT
# sda1 = BIOS boot, 1M
fdisk /dev/sdX

cryptsetup luksFormat --type luks1 /dev/sda2
cryptsetup open /dev/sda2 root
mkfs.f2fs -lROOT /dev/mapper/root

mount /dev/mapper/root /mnt

basestrap /mnt base base-devel s6-base elogind-s6 f2fs-tools \
	linux-zen linux-zen-headers linux-firmware \
	cryptsetup-s6 device-mapper-s6 lvm2-s6 vim  

fstabgen -U /mnt >> /mnt/etc/fstab
blkid -s UUID -o value /dev/sdX2
artix-chroot /mnt bash
```
Имя и путь к файлу `/crypto_keyfile.bin` важны подробности в `4`
```sh
dd bs=512 count=4 if=/dev/random of=/crypto_keyfile.bin iflag=fullblock
chmod 600 /crypto_keyfile.bin
chmod 600 /boot/initramfs-linux*
cryptsetup luksAddKey /dev/sdX# /crypto_keyfile.bin
```
```sh
# /etc/mkinitcpio.conf
FILES=(/crypto_keyfile.bin)
# Добавить encrypt, resume и возможно lvm2 перед filesystems
HOOKS=(base udev autodetect modconf block encrypt lvm2 resume filesystems keyboard fsck)
```
```sh
# /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet \
	cryptdevice=UUID=uuid-of-luks-partition:root \
	resume=UUID=uuid-of-swap-partition"
GRUB_ENABLE_CRYPTODISK=y
```
```sh
grub-install --target=i386-pc /dev/sdX
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -P

# REBOOT
pacman -Syu
pacman -S opendoas artix-archlinux-support 
vim /etc/pacman.conf

pacman -S git cargo rust atool \
	sway swaylock seatd-s6 i3status-rust mako wl-clipboard \
	firefox thunderbird keepassxc mpv yt-dlp

cargo install paru
```
