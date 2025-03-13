-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy"
description "Most advanced Ambulance job in history"
version "2.5.3"

fx_version "cerulean"
game "gta5"
lua54 "yes"

dependencies {
    "ox_lib",
    "ox_target"
}

files {
    "stream/*.ytyp",
    "data/**",
    "ui/**",
    "client/modules/**",
    "bridge/framework/**/client.lua"
}

data_file "DLC_ITYP_REQUEST" "stream/*.ytyp"
ui_page "ui/index.html"

shared_scripts {
    "@ox_lib/init.lua",
    "shared/bridge.lua"
}

client_scripts {
    "client/**"
}

server_scripts {
    "server/*.lua",
    "server/items/*.lua"
}
