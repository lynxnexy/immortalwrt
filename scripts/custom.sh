#!/bin/bash
#========================================================================================================================
# Description: Automatically Build ImmortalWrt for Amlogic ARMv8
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/immortalwrt/immortalwrt.git / Branch: 21.02
#========================================================================================================================

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='immortalwrt'" >>package/base-files/files/etc/openwrt_release

# Set ssid
sed -i "s/OpenWrt/FyNn/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh

# Set default password
sed -i '18s/^/# /' package/emortal/default-settings/files/99-default-settings

# Set timezone
sed -i -e "s/CST-8/WIB-7/g" -e "s/Shanghai/Jakarta/g" package/emortal/default-settings/files/99-default-settings-chinese

# Set hostname
sed -i "s/ImmortalWrt/FyNn/g" package/base-files/files/bin/config_generate

# Set passwd
sed -i "s/root::0:0:99999:7:::/root:"'$'"1"'$'"pSFNodTy"'$'"ej92Jju6QPD9AIAuelgnr.:18993:0:99999:7:::/g" package/base-files/files/etc/shadow

# Add luci-theme-tano (Default)
svn co https://github.com/lynxnexy/luci-theme-tano/trunk package/luci-theme-tano
sed -i "s/+luci-theme-bootstrap //" feeds/luci/collections/luci/Makefile

# Set banner
rm -rf ./package/emortal/default-settings/files/openwrt_banner
svn export https://github.com/Jbt88/immortalwrt/trunk/amlogic/common/rootfs/etc/banner package/emortal/default-settings/files/openwrt_banner

# Set shell zsh
sed -i "s/\/bin\/ash/\/usr\/bin\/zsh/g" package/base-files/files/etc/passwd

# Add luci-app-3ginfo-lite
svn co https://github.com/4IceG/luci-app-3ginfo-lite/trunk package/luci-app-3ginfo-lite

# Add luci-app-modemband
svn co https://github.com/4IceG/luci-app-modemband/trunk package/luci-app-modemband

# Add luci-app-atinout-mod
svn co https://github.com/4IceG/luci-app-atinout-mod/trunk package/luci-app-atinout-mod

# Add luci-app-sms-tool
svn co https://github.com/4IceG/luci-app-sms-tool/trunk package/luci-app-sms-tool

# Add luci-app-amlogic
svn co https://github.com/ophub/luci-app-amlogic/trunk package/luci-app-amlogic

# Add p7zip
svn co https://github.com/hubutui/p7zip-lede/trunk package/p7zip

# Set preset-clash-core
mkdir -p files/etc/openclash/core
OPENCLASH_MAIN_URL=$(curl -sL https://api.github.com/repos/vernesong/OpenClash/releases/tags/Clash | grep /clash-linux-armv8 | awk -F '"' '{print $4}')
CLASH_TUN_URL=$(curl -sL https://api.github.com/repos/vernesong/OpenClash/releases/tags/TUN-Premium | grep /clash-linux-armv8 | awk -F '"' '{print $4}')
CLASH_GAME_URL=$(curl -sL https://api.github.com/repos/vernesong/OpenClash/releases/tags/TUN | grep /clash-linux-armv8 | awk -F '"' '{print $4}')
wget -qO- $OPENCLASH_MAIN_URL | tar xOvz > files/etc/openclash/core/clash
wget -qO- $CLASH_TUN_URL | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- $CLASH_GAME_URL | tar xOvz > files/etc/openclash/core/clash_game
chmod +x files/etc/openclash/core/clash*

# Set preset-speedtest
mkdir -p files/bin
wget -qO- https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-linux-aarch64.tgz | tar xOvz > files/bin/speedtest
chmod +x files/bin/speedtest

# Set oh-my-zsh
mkdir -p files/root
pushd files/root
git clone https://github.com/robbyrussell/oh-my-zsh ./.oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ./.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ./.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ./.oh-my-zsh/custom/plugins/zsh-completions
cp $GITHUB_WORKSPACE/amlogic/common/patches/zsh/.zshrc .
cp $GITHUB_WORKSPACE/amlogic/common/patches/zsh/example.zsh ./.oh-my-zsh/custom/example.zsh
popd
