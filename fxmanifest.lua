-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666"
description "Ambulance job for ND Core"
version "2.3.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

dependencies {
    "ox_lib",
    "ox_target",
    "ND_Core"
}

files {
    "stream/*.ytyp",
    "data/**",
    "ui/**"
}

data_file "DLC_ITYP_REQUEST" "stream/*.ytyp"
ui_page "ui/index.html"

shared_scripts {
    "@ox_lib/init.lua",
    "@ND_Core/init.lua"
}

client_scripts {
    "client/**"
}

server_scripts {
    "server/*.lua",
    "server/items/*.lua"
}
