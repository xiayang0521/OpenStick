# OpenStick
msm8916 4g网卡的逆向工程和主线移植

### 完全开源，但是禁止商用！

### 整个项目还处在很早期的阶段，我不会对刷砖等情况负责！

目前的进度

* 完成了msm8916-mainline部分特性向5.10稳定内核的移植，初步完成了HandsomeMod（openwrt）的移植（但是luci里modem还用不了），目前还在对代码进行清理，Openstick的支持将会在年前加入。
* 完成了所有功能在主线中的驱动，并运行postmarketOS。



## 体验包

* 这是很早期的版本，只是证明这个4g网卡跑主线linux是可行的，请不要在你正在使用的设备上刷入。
* 完美的版本大概要等到年后，届时将会提供postmarketOS、HandsomeMod的完整刷机包。
* 这个体验包会覆盖原机的分区表（删除了没用的分区，大概会给rootfs腾出3G多的空间）和引导程序，不再兼容安卓系统，请使用时做好备份。我也不会提供回去的办法（没研究过：p）
* 包在release里面。

### 主要特性

* postmarketOS缺少modem固件用不了modem，其他正常。Openwrt只是能启动而已，wifi没问题，其余未测试。
* Openwrt目前没有办法用到所有的储存空间。
* 重建了整个分区表和替换了引导程序，开机时按下唯一的实体按键，绿灯与蓝灯同时亮证明进入了fastboot模式。
* 开启了虚拟化，可以使用kvm。
* 能够自动提取modem和wifi校准数据，不用担心分区表变了会盖掉校准数据。
* 开启了64位内核启动的支持。

# 刷机

### 准备工作

* Linux电脑一个
* fastboot & adb

### 开始！~

* 想个办法使网卡处于fastboot模式。
* 执行base包中的flash.sh。
* 完成选择你想要的系统，执行其中的flash.sh。
* enjoy！



