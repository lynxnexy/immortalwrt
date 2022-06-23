#!/bin/bash
# Openclash Config Editor by Tiny File Manager
# Copyright 2022 by lynxnexy <https://github.com/lynxnexy/immortalwrt>
# 

cat << EOF > feeds/luci/applications/luci-app-openclash/luasrc/view/openclash/editor.htm
<%+header%>
<div class="cbi-map">
<iframe id="editor" style="width: 100%; min-height: 100vh; border: none; border-radius: 2px;"></iframe>
</div>
<script type="text/javascript">
document.getElementById("editor").src = "http://" + window.location.hostname + "/tinyfilemanager/index.php?p=etc/openclash";
</script>
<%+footer%>
EOF

sed -i '86s/80/90/g' feeds/luci/applications/luci-app-openclash/luasrc/controller/openclash.lua
sed -i '86 i\	entry({"admin", "services", "openclash", "editor"}, template("openclash/editor"),_("Config Editor"), 80).leaf = true' feeds/luci/applications/luci-app-openclash/luasrc/controller/openclash.lua
