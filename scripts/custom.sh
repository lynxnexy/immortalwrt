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
sed -i "s/OpenWrt/LYNX/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh

# Set default password
sed -i '18s/^/# /' package/emortal/default-settings/files/99-default-settings

# Set timezone
sed -i -e "s/CST-8/WIB-7/g" -e "s/Shanghai/Jakarta/g" package/emortal/default-settings/files/99-default-settings-chinese

# Set hostname
sed -i "s/ImmortalWrt/LYNX/g" package/base-files/files/bin/config_generate

# Set passwd
sed -i "s/root::0:0:99999:7:::/root:"'$'"1"'$'"pSFNodTy"'$'"ej92Jju6QPD9AIAuelgnr.:18993:0:99999:7:::/g" package/base-files/files/etc/shadow

# Set Interface
sed -i "9 i\uci set network.hilink=interface\nuci set network.hilink.ifname=eth1\nuci set network.hilink.proto=dhcp\nuci commit network\nuci add_list firewall.@zone[1].network='hilink'\nuci commit firewall\n" package/emortal/default-settings/files/99-default-settings
sed -i "16 i\uci set network.tethering=interface\nuci set network.tethering.ifname=usb0\nuci set network.tethering.proto=dhcp\nuci commit network\nuci add_list firewall.@zone[1].network='tethering'\nuci commit firewall\n" package/emortal/default-settings/files/99-default-settings

# Add luci-theme-tano (Default)
svn co https://github.com/lynxnexy/luci-theme-tano/trunk package/luci-theme-tano
sed -i "s/+luci-theme-bootstrap //" feeds/luci/collections/luci/Makefile

# Set banner
rm -rf ./package/emortal/default-settings/files/openwrt_banner
svn export https://github.com/lynxnexy/immortalwrt/trunk/amlogic/common/rootfs/etc/banner package/emortal/default-settings/files/openwrt_banner

# Set shell zsh
sed -i "s/\/bin\/ash/\/usr\/bin\/zsh/g" package/base-files/files/etc/passwd

# Set php7 max_size
sed -i -e "s/upload_max_filesize = 2M/upload_max_filesize = 1024M/g" -e "s/post_max_size = 8M/post_max_size = 1024M/g" feeds/packages/lang/php7/files/php.ini

# Add luci-app-3ginfo
svn co https://github.com/4IceG/luci-app-3ginfo/trunk package/luci-app-3ginfo
sed -i "s|, \"<p>\&nbsp;<\/p>\"||g" package/luci-app-3ginfo/luci-app-3ginfo/luasrc/model/cbi/modem/3gconfig.lua
sed -i -e "s|option 'device' ''|option 'device' '192.168.8.1'|g" -e "s|option 'network' 'wan'|option 'network' 'hilink'|g" package/luci-app-3ginfo/3ginfo/files-text/etc/config/3ginfo

# Add luci-app-modemband
svn co https://github.com/4IceG/luci-app-modemband/trunk package/luci-app-modemband
sed -i -e "s/10/20/g" -e "s/20/30/g" package/luci-app-modemband/luci-app-modemband/root/usr/share/luci/menu.d/luci-app-modemband.json

# Add luci-app-atinout-mod
svn co https://github.com/4IceG/luci-app-atinout-mod/trunk package/luci-app-atinout-mod

# Add luci-app-sms-tool
svn co https://github.com/4IceG/luci-app-sms-tool/trunk package/luci-app-sms-tool

# Add luci-app-modeminfo
# svn co https://github.com/koshev-msk/luci-app-modeminfo/trunk package/luci-app-modeminfo

# Add xmm-modem
svn co https://github.com/koshev-msk/xmm-modem/trunk package/xmm-modem

# Add luci-app-amlogic
svn co https://github.com/lynxnexy/luci-app-amlogic/trunk package/luci-app-amlogic

# Add p7zip
svn co https://github.com/hubutui/p7zip-lede/trunk package/p7zip

# Add luci-app-tinyfilemanager
svn co https://github.com/lynxnexy/luci-app-tinyfilemanager/trunk package/luci-app-tinyfilemanager

# Set preset-clash-core
mkdir -p files/etc/openclash/core
OPENCLASH_MAIN_URL=$(curl -sL https://api.github.com/repos/vernesong/OpenClash/releases/tags/Clash | grep /clash-linux-armv8 | awk -F '"' '{print $4}')
CLASH_TUN_URL=$(curl -sL https://api.github.com/repos/vernesong/OpenClash/releases/tags/TUN-Premium | grep /clash-linux-armv8 | awk -F '"' '{print $4}')
CLASH_GAME_URL=$(curl -sL https://api.github.com/repos/vernesong/OpenClash/releases/tags/TUN | grep /clash-linux-armv8 | awk -F '"' '{print $4}')
CLASH_META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/master/core-lateset/meta/clash-linux-armv8.tar.gz"
wget -qO- $OPENCLASH_MAIN_URL | tar xOvz > files/etc/openclash/core/clash
wget -qO- $CLASH_TUN_URL | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- $CLASH_GAME_URL | tar xOvz > files/etc/openclash/core/clash_game
wget -qO- $CLASH_META_URL | tar xOvz > files/etc/openclash/core/clash_meta
chmod +x files/etc/openclash/core/clash*

# Set v2ray-rules-dat
mkdir -p files/etc/openclash
curl -sL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -o files/etc/openclash/GeoSite.dat
curl -sL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -o files/etc/openclash/GeoIP.dat

# Set yt-dlp
mkdir -p files/bin
curl -sL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o files/bin/yt-dlp
chmod +x files/bin/yt-dlp

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
