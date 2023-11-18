-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666"
description "Ambulance job for ND Core"
version "1.0.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

dependencies {
    "ox_lib",
    "ox_inventory",
    "ox_target",
    "ND_Core"
}

shared_scripts {
    "@ox_lib/init.lua",
    "@ND_Core/init.lua",
    "data.lua"
}
server_scripts {
    "server/main.lua",
    "server/body.lua",
    "server/items/**"
}
client_scripts {
    "client/body.lua",
    "client/job.lua",
    "client/items/**"
}