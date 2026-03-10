return {
    timer = 300, -- time in seconds before allowed to respawn.
    spawnAsDeadTime = 15, -- time in minutes where if you rejoin it will go back and see if you're dead.
    keybind = "R", -- respawn keybind.
    dropInventory = false, -- drop player items when respawn.
    damage = 1, -- amount of damage that will be taken every damageInterval when knocked down injured (Must be a whole number).
    damageInterval = 6, -- interavall in seconds player will take damage when knocked down injured.
    
    -- locations player will respawn if they get respawned at mourge.
    mourgeRespawn = {
        vec4(-679.6865, 322.1247, 78.1230, 352.1852),
        vec4(1825.46, 3669.99, 34.27, 21.85),
        vec4(-250.71, 6314.48, 32.43, 350.09)
    },

    -- doctor peds for hospitals.
    hospitalPeds = {
        { coords = vec4(1826.55, 3686.09, 34.27, 243.54), blip = true, selfHeal = 500, otherHeal = 1000, disableHealingOnAmbulanceCount = 7 }, -- paleto
        { coords = vec4(-255.46, 6330.33, 32.43, 281.19), blip = true, selfHeal = 500, otherHeal = 1000, disableHealingOnAmbulanceCount = 7 }, -- sandy
        { coords = vec4(-681.2762, 343.2137, 83.0831, 116.3607), blip = false, selfHeal = 650, otherHeal = 1300, disableHealingOnAmbulanceCount = 5 }, -- city akuten
        { coords = vec4(-675.9603, 328.0188, 83.0831, 226.9012), blip = true, selfHeal = 650, otherHeal = 1300, disableHealingOnAmbulanceCount = 5 }, -- city front
        { coords = vec4(-672.5808, 325.7582, 88.0167, 93.8945), blip = false, selfHeal = 650, otherHeal = 1300, disableHealingOnAmbulanceCount = 5 }, -- city floor 2
        { coords = vec4(-606.9176, -1762.3915, 23.2193, 277.2643), blip = false, selfHeal = 5000, otherHeal = 25000, disableHealingOnAmbulanceCount = 1000 }, -- illegal clinic
    },

    hospitalRespawns = {
        vec4(-679.6865, 322.1247, 78.1230, 352.1852),
        vec4(1825.46, 3669.99, 34.27, 21.85),
        vec4(-250.71, 6314.48, 32.43, 350.09),
        vec4(-604.1700, -1757.8710, 23.2193, 146.3301)
    }
}
