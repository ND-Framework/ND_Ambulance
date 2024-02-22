return {
    timer = 300, -- time in seconds.
    keybind = "R", -- respawn keybind.
    dropInventory = true, -- drop player items when respawn.
    damage = 2, -- amount of damage that will be taken every damageInterval when knocked down injured (Must be a whole number).
    damageInterval = 4, -- interavall in seconds player will take damage when knocked down injured.
    prices = {
        selfHeal = 200,
        otherHeal = 300
    },
    
    -- locations player will respawn if they get respawned at mourge.
    mourgeRespawn = {
        vec4(-246.74, 6330.42, 32.43, 222.39),
        vec4(1832.07, 3668.50, 34.28, 292.36),
        vec4(240.96, -1379.14, 33.74, 142.49)
    },

    -- doctor peds for hospitals.
    hospitalPeds = {
        vec4(1826.55, 3686.09, 34.27, 243.54),
        vec4(-255.46, 6330.33, 32.43, 281.19),
        vec4(338.72, -585.92, 28.79, 247.69)
    },

    hospitalRespawns = {
        vec4(355.09, -565.22, 28.79, 108.68),
        vec4(1825.46, 3669.99, 34.27, 21.85),
        vec4(-250.71, 6314.48, 32.43, 350.09)
    }
}
