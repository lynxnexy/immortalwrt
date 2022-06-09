#!/bin/bash
#
# Copyright 2022 by lynxnexy <https://github.com/lynxnexy/immortalwrt>
# 
cat << EOF > files/usr/lib/lua/luci/view/openclash/editor.htm
<%+header%>
<div class="cbi-map">
<iframe id="editor" style="width: 100%; min-height: 100vh; border: none; border-radius: 2px;"></iframe>
</div>
<script type="text/javascript">
document.getElementById("editor").src = "http://" + window.location.hostname + "/tinyfilemanager/index.php?p=etc/openclash";
</script>
<%+footer%>
EOF

sed -i '87 i\	entry({"admin", "services", "openclash", "editor"}, template("openclash/editor"),_("Config Editor"), 90).leaf = true' files/usr/lib/lua/luci/controller/openclash.lua
