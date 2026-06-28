# MnhExtractoriOS / Reader(Sony)Dumper

简体中文 | [English](Readme.md)

通过注入 Reader(Sony) iOS 实现MHN格式的拆包和重封装

> [!CAUTION]
> 该文件夹及其子目录下的所有资源仅供学习和研究使用。其旨在为学术和研究人员提供参考和资料，任何其他目的均不适用。
> 
> 严禁将此文件夹及其内容用于任何商业或非法用途。对于因违反此规定而产生的任何法律后果，用户需自行承担全部责任。

## 准备工作
* 已砸壳的 Reader(Sony) IPA
* 未越狱iOS需要 LiveContainer/Sideloadly

## 已验证的环境
| Device | System | AppVer | Environment |
| :-: | :-: | :-: | --- |
| iPhone SE 3rd | iOS 17.7.2 | 2.22.1 | LiveContainer Stable 3.7.2  |

## 获取砸壳IPA
* **方法一**: 从可信的砸壳站点下载，如 [decrypt.day](decrypt.day), [armconverter.com](https://armconverter.com/decryptedappstore)
* **方法二**: 利用 已越狱/巨魔商店/darksword漏洞 范围的设备进行砸壳
    - **Jailbroken**: DumpDecrypter, frida-ios-dump等等
    - **TrollStore**: [TrollDecrypt](https://github.com/donato-fiore/TrollDecrypt)
    - **DarkSword**: [lara Nightly](https://github.com/rooootdev/lara) (可以从其*GitHub Actions*下载编译好的IPA, 过滤器`Status` -> `success`)

## 注入
### 未越狱
* [LiveContainer](https://github.com/LiveContainer/LiveContainer)  (推荐)
  * 安装砸壳了的 Reader(Sony) IPA
  * 在`Tweak`页面新建一个文件夹
  * 进入文件夹，右上角选择导入 `dylib`
  * 在LiveContainer的Reader(Sony)设置中选择刚刚创建的文件夹
  * 启动应用
* [Sideloadly](https://sideloadly.io/)
  * 用Sideloadly打开砸壳了的Reader(Sony) IPA
  * 点开`Advanced Options`
  * 勾选`Inject dylibs/framework`
  * 添加这个dylib
  * 导出IPA以便使用SideStore或其他工具安装，也可以直接使用Sideloadly安装

### TrollStore
* TrollFools
### 已越狱
安装deb，然后重启应用

## 用法
* 进入一个合集 (如 `書籍`)
* 点击 `編集`
* 选择你想要导出的已经下载好的书籍
* 点击左上角的`N個選択中`，在弹出菜单中选择`Decrypt Selected`

## 限制
* 导出前你必须先下载好书籍

## 许可证
MIT
