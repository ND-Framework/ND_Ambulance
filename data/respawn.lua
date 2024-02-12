local respawn = {}

respawn.timer = 300 -- time in seconds.
respawn.keybind = "R" -- respawn keybind
respawn.damage = 2 -- amount of damage that will be taken every few seconds when knocked down injured. (Must be a whole number)
respawn.dropInventory = true -- drop player items when respawn

respawn.locations = {
    vec4(-246.74, 6330.42, 32.43, 222.39), -- paleto
    vec4(1832.07, 3668.50, 34.28, 292.36), -- sandy
    vec4(240.96, -1379.14, 33.74, 142.49) -- LS
}


return respawn
