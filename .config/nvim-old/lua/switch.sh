#!/bin/bash

# if the file ./lsp.lua.disabled exists set STATE to 'on' else set STATE to 'off'
if [ -f ./lsp.lua.disabled ]; then
    echo "Turning ON"
    mv ./lsp.lua.disabled ./lsp.lua
    mv ./plugins/cmp.lua.disabled ./plugins/cmp.lua
    mv ./plugins/mason.lua.disabled ./plugins/mason.lua
    mv ./plugins/lsp.lua ./plugins/lsp.lua.disabled
    sed -i 's/-- require("lsp").setup()/require("lsp").setup()/' ./normal-init.lua
    cd ../../../
    make stow
else
    echo "Turning OFF"
    mv ./lsp.lua ./lsp.lua.disabled
    mv ./plugins/cmp.lua ./plugins/cmp.lua.disabled
    mv ./plugins/mason.lua ./plugins/mason.lua.disabled
    mv ./plugins/lsp.lua.disabled ./plugins/lsp.lua
    sed -i 's/require("lsp").setup/-- require("lsp").setup/' ./normal-init.lua
    cd ../../../
    make stow
fi
