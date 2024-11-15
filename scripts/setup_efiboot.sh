
DRIVE=/dev/nvme0n1
PARTITION=/dev/nvme0n1p1

efibootmgr -c -d /dev/nvme0n1 -p 1 -l \EFI\archiso\vmlinuz-linux -L "Archiso Boot" -u 'img_dev=/dev/nvme0n1p1 img_loop=/EFI/archiso/archlinux-x86_64.iso initrd=\EFI\archiso\initramfs-linux.img' -v
