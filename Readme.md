# MnhExtractoriOS / Reader(Sony)Dumper

[简体中文](Readme.zh_CN.md) | English

Inject Reader(Sony) iOS to dump MNH eBooks

> [!CAUTION]
> All resources contained within this folder and its sub-directories are strictly for study and research purposes. They are intended to provide reference and materials for academic and research personnel. No other purposes are sanctioned.
> 
> The utilization of this folder and its contents for any commercial or illegal purposes is strictly prohibited. Users will bear full responsibility for any legal consequences arising from violations of this provision.

## Requirements
* Decrypted Reader(Sony) IPA
* LiveContainer/Sideloadly for jailed iOS

## Tested
| Device | System | AppVer | Environment |
| :-: | :-: | :-: | --- |
| iPhone SE 3rd | iOS 17.7.2 | 2.22.1 | LiveContainer Stable 3.7.2  |

## Decrypt IPA
* **Method 1**: Download from trusted website like [decrypt.day](decrypt.day), [armconverter.com](https://armconverter.com/decryptedappstore)
* **Method 2**: Decrypt yourself with a jailbroken/trollstore/darksword device.
    - **Jailbroken**: DumpDecrypter, frida-ios-dump and so on
    - **TrollStore**: [TrollDecrypt](https://github.com/donato-fiore/TrollDecrypt)
    - **DarkSword**: [lara Nightly](https://github.com/rooootdev/lara) (Download IPA from *GitHub Actions*, filter `Status` -> `success`)

## Inject
### Jailed
* [LiveContainer](https://github.com/LiveContainer/LiveContainer)  (Recommanded)
  * Install decrypted Reader(Sony) IPA
  * Create a folder in `Tweak` Tab
  * Import the `dylib`
  * Select the tweak folder we create in Reader(Sony)'s setting
  * Start Reader(Sony)
* [Sideloadly](https://sideloadly.io/)
  * Open decrypted Reader(Sony) IPA
  * Open `Advanced Options`
  * Check `Inject dylibs/framework`
  * Add this dylib
  * Export IPA to install with iloader or other software, or directly install it to your device

### TrollStore
* TrollFools
### Jailbroken
Just install the deb, and restart Reader(Sony)

## Usage
* Enter a Collection (like `書籍`)
* Press `編集`
* Select the downloaded books you want to extract
* Press `N個選択中` in the upper-left, then press `Decrypt Selected`

## Limitation
* The books must be downloaded to local before extract

## License
MIT
