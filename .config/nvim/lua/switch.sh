#!/bin/bash

# if the file ./lsp.lua.disabled exists set STATE to 'on' else set STATE to 'off'
if [ -f ./lsp.lua.disabled ]; then
    echo "Turning on"
    mv ./lsp.lua.disabled ./lsp.lua
    mv ./plugins/cmp.lua.disabled ./plugins/cmp.lua
    mv ./plugins/mason.lua.disabled ./plugins/mason.lua
    sed -i 's/-- require("lsp").setup()/require("lsp").setup()/' ./normal-init.lua
else
    mv ./lsp.lua ./lsp.lua.disabled
    mv ./plugins/cmp.lua ./plugins/cmp.lua.disabled
    mv ./plugins/mason.lua ./plugins/mason.lua.disabled
    sed -i 's/require("lsp").setup/-- require("lsp").setup/' ./normal-init.lua
fi
