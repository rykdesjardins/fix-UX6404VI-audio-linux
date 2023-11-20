# fix-UX6404VI-audio-linux
Fixes the audio problem on Linux for the ASUS Zenbook Pro 14 OLED (UX6404) laptop. 

## Steps
If you've never built the Linux kernel before, it can sound pretty scary but it's actually pretty simple. That being said, you will need to download the kernel source code, update one line, and build it.

You'll need to install a few things before getting started. Most of these are necessary to build the kernel and the driver patch.

On Ubuntu, here are the packages I installed using `apt` : 
```
sudo apt-get install git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc libncurses-dev bison flex libssl-dev libelf-dev libelf++0
```

0. Select a Linux kernel version. On my end, I went with 6.6.1. You can check which version you're currently running using the `uname -a` command. 
1. Download the source code from the [https://kernel.org/](https://kernel.org/) website. Feel free to verify your download before untar-ing.
2. Untar the source code and `cd` to the `linux-x.x.x` directory.
3. Edit the `sound/pci/hda/patch_realtek.c` file with your text editor. 
4. Look for the `static const struct snd_pci_quirk alc269_fixup_tbl[]`. Mine was around line 9476.
5. Add the following line along with all the other `SND_PCI_QUIRK` :

```
SND_PCI_QUIRK(0x1043, 0x1863, "ASUS UX6404V1", ALC245_FIXUP_CS35L41_SPI_2),
```

6. Save and close the file
7. Build the kernel. There are many tutorials online on how to do this. Here's a summary : 
    1. Copy current configuration : `cp -v /boot/config-$(uname -r) .config`
    2. Run `make menuconfig`, simply save and exit
    3. Make : `make`. This will take a while. You can build faster by using the `-j` argument along with a number to use multiple cores. i.e.: `make -j 4`. To use all of them, run `make -j $(nproc)`. 
    4. Build modules : `sudo make modules_install`
    5. Install kernel : `sudo make install`
9. Depending on what you use to boot, you might have to edit certain files. For me, it automatically updated grub using `update-initramfs`. 
10. Reboot. The newly built kernel should load by default. You can validate it by running `uname -a` and checking the kernel version.
11. We're going to patch a driver. Good news, it's already in the repo. Simply run : 
```
iasl -tc ux6404vi_cirrus_patch.dsl
mkdir -p kernel/firmware/acpi
cp ux6404vi_cirrus_patch.aml kernel/firmware/acpi
find kernel | cpio -H newc --create > ux6404vi_cirrus_patch.cpio
sudo cp ux6404vi_cirrus_patch.cpio /boot/ux6404vi_cirrus_patch.cpio
```
11. Edit your boot loader to load the patch. For grub, I edited `/etc/default/grub` and added the following line : 
```
GRUB_EARLY_INITRD_LINUX_CUSTOM="ux6404vi_cirrus_patch.cpio"
```
12. Reboot.

## Expected outcome
The obvious way to test if it works it to try and play sound. 

The output of `sudo dmesg | grep CSC3551` should also look like this. 
```
[    0.013918] ACPI: Table Upgrade: install [SSDT-CUSTOM- CSC3551]
[    0.013920] ACPI: SSDT 0x000000005C88A000 0001A0 (v03 CUSTOM CSC3551  01072009 INTL 20200925)
[    4.889146] Serial bus multi instantiate pseudo device driver CSC3551:00: Instantiated 2 SPI devices.
[    4.998612] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.0: Cirrus Logic CS35L41 (35a40), Revision: B2
[    4.999505] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.1: Reset line busy, assuming shared reset
[    5.082898] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.1: Cirrus Logic CS35L41 (35a40), Revision: B2
[    8.000889] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.0: Falling back to default firmware.
[    8.001549] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.0: DSP1: Firmware version: 3
[    8.001553] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.0: DSP1: cirrus/cs35l41-dsp1-spk-prot.wmfw: Fri 24 Jun 2022 14:55:56 GMT Daylight Time
[    8.074335] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.0: DSP1: Firmware: 400a4 vendor: 0x2 v0.58.0, 2 algorithms
[    8.075216] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.0: DSP1: cirrus/cs35l41-dsp1-spk-prot.bin: v0.58.0
[    8.075227] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.0: DSP1: spk-prot: e:\workspace\workspace\tibranch_release_playback_6.76_2\ormis\staging\default_tunings\internal\CS35L53\Fixed_Attenuation_Mono_48000_29.78.0\full\Fixed_Attenuation_Mono_48000_29.78.0_full.bin
[    8.092230] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.0: CS35L41 Bound - SSID: 10431863, BST: 1, VSPK: 1, CH: L, FW EN: 1, SPKID: 0
[    8.092240] snd_hda_codec_realtek ehdaudio0D0: bound spi1-CSC3551:00-cs35l41-hda.0 (ops cs35l41_hda_comp_ops [snd_hda_scodec_cs35l41])
[    8.093607] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.1: Falling back to default firmware.
[    8.094054] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.1: DSP1: Firmware version: 3
[    8.094058] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.1: DSP1: cirrus/cs35l41-dsp1-spk-prot.wmfw: Fri 24 Jun 2022 14:55:56 GMT Daylight Time
[    8.155901] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.1: DSP1: Firmware: 400a4 vendor: 0x2 v0.58.0, 2 algorithms
[    8.157226] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.1: DSP1: cirrus/cs35l41-dsp1-spk-prot.bin: v0.58.0
[    8.157244] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.1: DSP1: spk-prot: e:\workspace\workspace\tibranch_release_playback_6.76_2\ormis\staging\default_tunings\internal\CS35L53\Fixed_Attenuation_Mono_48000_29.78.0\full\Fixed_Attenuation_Mono_48000_29.78.0_full.bin
[    8.179029] cs35l41-hda spi1-CSC3551:00-cs35l41-hda.1: CS35L41 Bound - SSID: 10431863, BST: 1, VSPK: 1, CH: R, FW EN: 1, SPKID: 0
[    8.179042] snd_hda_codec_realtek ehdaudio0D0: bound spi1-CSC3551:00-cs35l41-hda.1 (ops cs35l41_hda_comp_ops [snd_hda_scodec_cs35l41])
```

Good luck

## Troubleshoot
If you run into an issue during kernel compilation regarding signing, open the `.config` that was generated during step 7.2, and remove the lines under `# Certificates for signature checking`. Redo step 7.2.

