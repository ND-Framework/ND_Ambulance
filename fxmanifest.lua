-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666"
description "Ambulance job for ND Core"
version "1.0.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

dependencies {
    "ox_lib",
    "ox_target",
    "ND_Core"
}

files {
    "data/**"
}

shared_scripts {
    "@ox_lib/init.lua",
    "@ND_Core/init.lua"
}

client_scripts {
    "client/**"
}
