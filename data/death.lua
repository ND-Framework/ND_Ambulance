return {
    timer = 300, -- time in seconds.
    keybind = "R", -- respawn keybind.
    dropInventory = true, -- drop player items when respawn.
    damage = 2, -- amount of damage that will be taken every damageInterval when knocked down injured (Must be a whole number).
    damageInterval = 4, -- interavall in seconds player will take damage when knocked down injured.
    
    -- respawn locations
    locations = {
        vec4(-246.74, 6330.42, 32.43, 222.39), -- paleto
        vec4(1832.07, 3668.50, 34.28, 292.36), -- sandy
        vec4(240.96, -1379.14, 33.74, 142.49) -- LS
    }
}
