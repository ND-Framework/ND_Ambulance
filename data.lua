Data = {}
Data.deathAnims = {
    {
        down = {"random@dealgonewrong", "idle_a"},
        dead = {"random@crash_rescue@dead_ped", "dead_ped"},
        vehicle = {"random@crash_rescue@car_death@van", "loop"}
    },
    {
        down = {"anim@scripted@data_leak@fix_bil_ig2_chopper_crawl@prototype@", "injured_idle_ped"},
        dead = {"missfinale_c1@", "lying_dead_player0"},
        vehicle = {"random@crash_rescue@car_death@van", "loop"}
    },
    {
        down = {"anim@scripted@data_leak@fix_bil_ig2_chopper_crawl@prototype@", "injured_idle_ped"},
        dead = {"misssolomon_5@end", "dead_black_ops"},
        vehicle = {"random@crash_rescue@car_death@van", "loop"}
    }
}

Data.boneParts = {
    [0] = "NONE",
    [31085] = "HEAD",
    [31086] = "HEAD",
    [39317] = "NECK",
    [57597] = "SPINE",
    [23553] = "SPINE",
    [24816] = "SPINE",
    [24817] = "SPINE",
    [24818] = "SPINE",
    [10706] = "UPPER_BODY",
    [64729] = "UPPER_BODY",
    [11816] = "LOWER_BODY",
    [45509] = "LARM",
    [61163] = "LARM",
    [18905] = "LHAND",
    [4089] = "LFINGER",
    [4090] = "LFINGER",
    [4137] = "LFINGER",
    [4138] = "LFINGER",
    [4153] = "LFINGER",
    [4154] = "LFINGER",
    [4169] = "LFINGER",
    [4170] = "LFINGER",
    [4185] = "LFINGER",
    [4186] = "LFINGER",
    [26610] = "LFINGER",
    [26611] = "LFINGER",
    [26612] = "LFINGER",
    [26613] = "LFINGER",
    [26614] = "LFINGER",
    [58271] = "LLEG",
    [63931] = "LLEG",
    [2108] = "LFOOT",
    [14201] = "LFOOT",
    [40269] = "RARM",
    [28252] = "RARM",
    [57005] = "RHAND",
    [58866] = "RFINGER",
    [58867] = "RFINGER",
    [58868] = "RFINGER",
    [58869] = "RFINGER",
    [58870] = "RFINGER",
    [64016] = "RFINGER",
    [64017] = "RFINGER",
    [64064] = "RFINGER",
    [64065] = "RFINGER",
    [64080] = "RFINGER",
    [64081] = "RFINGER",
    [64096] = "RFINGER",
    [64097] = "RFINGER",
    [64112] = "RFINGER",
    [64113] = "RFINGER",
    [36864] = "RLEG",
    [51826] = "RLEG",
    [20781] = "RFOOT",
    [52301] = "RFOOT"
}

Data.boneSettings = {
    ["HEAD"] = {
        label = "Head",
        severity = 0
    },
    ["NECK"] = {
        label = "Neck",
        severity = 0
    },
    ["SPINE"] = {
        label = "Spine",
        severity = 0,
        causeLimp = true
    },
    ["UPPER_BODY"] = {
        label = "Upper Body",
        severity = 0
    },
    ["LOWER_BODY"] = {
        label = "Lower Body",
        severity = 0,
        causeLimp = true
    },
    ["LARM"] = {
        label = "Left Arm",
        severity = 0,
        canUseTourniquet = true,
    },
    ["LHAND"] = {
        label = "Left Hand",
        severity = 0
    },
    ["LFINGER"] = {
        label = "Left Hand Fingers",
        severity = 0
    },
    ["LLEG"] = {
        label = "Left Leg",
        severity = 0,
        causeLimp = true,
        canUseTourniquet = true,
    },
    ["LFOOT"] = {
        label = "Left Foot",
        severity = 0,
        causeLimp = true
    },
    ["RARM"] = {
        label = "Right Arm",
        severity = 0,
        canUseTourniquet = true,
    },
    ["RHAND"] = {
        label = "Right Hand",
        severity = 0
    },
    ["RFINGER"] = {
        label = "Right Hand Fingers",
        severity = 0
    },
    ["RLEG"] = {
        label = "Right Leg",
        severity = 0,
        causeLimp = true,
        canUseTourniquet = true,
    },
    ["RFOOT"] = {
        label = "Right Foot",
        severity = 0,
        causeLimp = true
    }
}

Data.weapons = {
    -- Mele
    [`WEAPON_DAGGER`] = {
        bleeding = true,
        severity = 2.3,
        injury = "Stabbing"
    },
    [`WEAPON_BAT`] = {
        fracture = true,
        severity = 2.5,
        injury = "Heavy impact"
    },
    [`WEAPON_BOTTLE`] = {
        bleeding = true,
        severity = 0.4,
        injury = "Stabbing"
    },
    [`WEAPON_CROWBAR`] = {
        fracture = true,
        severity = 2.0,
        injury = "Fracture"
    },
    [`WEAPON_UNARMED`] = {
        severity = 1.0,
        injury = "Light impact"
    },
    [`WEAPON_FLASHLIGHT`] = {
        severity = 1.2,
        injury = "Light impact"
    },
    [`WEAPON_GOLFCLUB`] = {
        fracture = true,
        severity = 1.0,
        injury = "Heavy impact"
    },
    [`WEAPON_HAMMER`] = {
        fracture = true,
        severity = 1.0,
        injury = "Heavy impact"
    },
    [`WEAPON_HATCHET`] = {
        fracture = true,
        bleeding = true,
        severity = 2.5,
        injury = "Heavy impact"
    },
    [`WEAPON_KNUCKLE`] = {
        severity = 1.5,
        injury = "Heavy impact"
    },
    [`WEAPON_KNIFE`] = {
        bleeding = true,
        severity = 1.5,
        injury = "Stabbing"
    },
    [`WEAPON_MACHETE`] = {
        bleeding = true,
        severity = 2.5,
        injury = "Stabbing"
    },
    [`WEAPON_SWITCHBLADE`] = {
        bleeding = true,
        severity = 1.0,
        injury = "Stabbing"
    },
    [`WEAPON_NIGHTSTICK`] = {
        severity = 1.5,
        injury = "Heavy impact"
    },
    [`WEAPON_WRENCH`] = {
        fracture = true,
        severity = 1.5,
        injury = "Heavy impact"
    },
    [`WEAPON_BATTLEAXE`] = {
        fracture = true,
        bleeding = true,
        severity = 2.8,
        injury = "Heavy impact"
    },
    [`WEAPON_POOLCUE`] = {
        severity = 1.5,
        injury = "Heavy impact"
    },
    [`WEAPON_STONE_HATCHET`] = {
        fracture = true,
        bleeding = true,
        severity = 2.5,
        injury = "Heavy impact"
    },
    [`WEAPON_CANDYCANE`] = {
        severity = 1.0,
        injury = "Light impact"
    },

    -- Handguns
    [`WEAPON_PISTOL`] = {
        bleeding = true,
        severity = 1.0,
        injury = "Small caliber"
    },
    [`WEAPON_PISTOL_MK2`] = {
        bleeding = true,
        severity = 1.0,
        injury = "Small caliber"
    },
    [`WEAPON_COMBATPISTOL`] = {
        bleeding = true,
        severity = 1.0,
        injury = "Small caliber"
    },
    [`WEAPON_APPISTOL`] = {
        bleeding = true,
        severity = 1.3,
        injury = "Small caliber"
    },
    [`WEAPON_STUNGUN`] = {
        bleeding = true,
        severity = 0.1,
        injury = "Stun gun prongs"
    },
    [`WEAPON_PISTOL50`] = {
        bleeding = true,
        severity = 2.0,
        injury = "Medium caliber"
    },
    [`WEAPON_SNSPISTOL`] = {
        bleeding = true,
        severity = 1.0,
        injury = "Small caliber"
    },
    [`WEAPON_SNSPISTOL_MK2`] = {
        bleeding = true,
        severity = 1.0,
        injury = "Small caliber"
    },
    [`WEAPON_HEAVYPISTOL`] = {
        bleeding = true,
        severity = 1.8,
        injury = "Medium caliber"
    },
    [`WEAPON_VINTAGEPISTOL`] = {
        bleeding = true,
        severity = 1.0,
        injury = "Small caliber"
    },
    [`WEAPON_FLAREGUN`] = {
        burn = true,
        severity = 2.0,
        injury = "Second degree burns"
    },
    [`WEAPON_MARKSMANPISTOL`] = {
        bleeding = true,
        severity = 1.0,
        injury = "Small caliber"
    },
    [`WEAPON_REVOLVER`] = {
        bleeding = true,
        severity = 2.0,
        injury = "Medium caliber"
    },
    [`WEAPON_REVOLVER_MK2`] = {
        bleeding = true,
        severity = 2.0,
        injury = "Medium caliber"
    },
    [`WEAPON_DOUBLEACTION`] = {
        bleeding = true,
        severity = 1.9,
        injury = "Medium caliber"
    },
    [`WEAPON_RAYPISTOL`] = {
        severity = 1.0,
        injury = "Electric shock"
    },
    [`WEAPON_CERAMICPISTOL`] = {
        bleeding = true,
        severity = 0.8,
        injury = "Small caliber"
    },
    [`WEAPON_NAVYREVOLVER`] = {
        bleeding = true,
        severity = 1.7,
        injury = "Medium caliber"
    },
    [`WEAPON_GADGETPISTOL`] = {
        bleeding = true,
        severity = 0.8,
        injury = "Small caliber"
    },
    [`WEAPON_STUNGUN_MP`] = {
        bleeding = true,
        severity = 0.1,
        injury = "Stun gun prongs"
    },
    [`WEAPON_PISTOLXM3`] = {
        bleeding = true,
        severity = 0.8,
        injury = "Small caliber"
    },

    -- Submachine guns
    [`WEAPON_MICROSMG`] = {
        bleeding = true,
        severity = 1.7,
        injury = "Small caliber"
    },
    [`WEAPON_SMG`] = {
        bleeding = true,
        severity = 1.7,
        injury = "Small caliber"
    },
    [`WEAPON_SMG_MK2`] = {
        bleeding = true,
        severity = 1.7,
        injury = "Small caliber"
    },
    [`WEAPON_ASSAULTSMG`] = {
        bleeding = true,
        severity = 2.0,
        injury = "Medium caliber"
    },
    [`WEAPON_COMBATPDW`] = {
        bleeding = true,
        severity = 2.0,
        injury = "Medium caliber"
    },
    [`WEAPON_MACHINEPISTOL`] = {
        bleeding = true,
        severity = 1.7,
        injury = "Small caliber"
    },
    [`WEAPON_MINISMG`] = {
        bleeding = true,
        severity = 1.7,
        injury = "Small caliber"
    },
    [`WEAPON_RAYCARBINE`] = {
        severity = 2.0,
        injury = "Electric shock"
    },
    [`WEAPON_TECPISTOL`] = {
        bleeding = true,
        severity = 1.7,
        injury = "Small caliber"
    },

    -- shotguns
    [`WEAPON_PUMPSHOTGUN`] = {
        bleeding = true,
        severity = 2.5,
        injury = "Shotgun"
    },
    [`WEAPON_PUMPSHOTGUN_MK2`] = {
        bleeding = true,
        severity = 2.5,
        injury = "Shotgun"
    },
    [`WEAPON_SAWNOFFSHOTGUN`] = {
        bleeding = true,
        severity = 2.2,
        injury = "Shotgun"
    },
    [`WEAPON_ASSAULTSHOTGUN`] = {
        bleeding = true,
        severity = 2.5,
        injury = "Shotgun"
    },
    [`WEAPON_BULLPUPSHOTGUN`] = {
        bleeding = true,
        severity = 2.5,
        injury = "Shotgun"
    },
    [`WEAPON_MUSKET`] = {
        bleeding = true,
        severity = 1.8,
        injury = "Minié ball"
    },
    [`WEAPON_HEAVYSHOTGUN`] = {
        bleeding = true,
        severity = 2.5,
        injury = "Shotgun"
    },
    [`WEAPON_DBSHOTGUN`] = {
        bleeding = true,
        severity = 2.5,
        injury = "Shotgun"
    },
    [`WEAPON_AUTOSHOTGUN`] = {
        bleeding = true,
        severity = 2.5,
        injury = "Shotgun"
    },
    [`WEAPON_COMBATSHOTGUN`] = {
        bleeding = true,
        severity = 2.5,
        injury = "Shotgun"
    },

    -- Assault rifles
    [`WEAPON_ASSAULTRIFLE`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },
    [`WEAPON_ASSAULTRIFLE_MK2`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },
    [`WEAPON_CARBINERIFLE`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },
    [`WEAPON_CARBINERIFLE_MK2`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },
    [`WEAPON_ADVANCEDRIFLE`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },
    [`WEAPON_SPECIALCARBINE`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },
    [`WEAPON_SPECIALCARBINE_MK2`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },
    [`WEAPON_BULLPUPRIFLE`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },
    [`WEAPON_BULLPUPRIFLE_MK2`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },
    [`WEAPON_BULLPUPRIFLE_MK2`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },
    [`WEAPON_COMPACTRIFLE`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },
    [`WEAPON_MILITARYRIFLE`] = {
        bleeding = true,
        severity = 2.3,
        injury = "High caliber"
    },
    [`WEAPON_HEAVYRIFLE`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },
    [`WEAPON_TACTICALRIFLE`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },

    -- Light machine guns
    [`WEAPON_MG`] = {
        bleeding = true,
        severity = 2.8,
        injury = "High caliber"
    },
    [`WEAPON_COMBATMG`] = {
        bleeding = true,
        severity = 2.8,
        injury = "High caliber"
    },
    [`WEAPON_COMBATMG_MK2`] = {
        bleeding = true,
        severity = 2.8,
        injury = "High caliber"
    },
    [`WEAPON_GUSENBERG`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },

    -- Sniper rifles
    [`WEAPON_SNIPERRIFLE`] = {
        bleeding = true,
        severity = 3.0,
        injury = "High caliber"
    },
    [`WEAPON_HEAVYSNIPER`] = {
        bleeding = true,
        severity = 3.25,
        injury = "High caliber"
    },
    [`WEAPON_HEAVYSNIPER_MK2`] = {
        bleeding = true,
        severity = 3.5,
        injury = "High caliber"
    },
    [`WEAPON_MARKSMANRIFLE`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },
    [`WEAPON_MARKSMANRIFLE_MK2`] = {
        bleeding = true,
        severity = 2.5,
        injury = "High caliber"
    },
    [`WEAPON_PRECISIONRIFLE`] = {
        bleeding = true,
        severity = 2.8,
        injury = "High caliber"
    },

    -- Heavy weapons
    [`WEAPON_RPG`] = {
        fracture = true,
        bleeding = true,
        severity = 6.0,
        injury = "Explosion burns"
    },
    [`WEAPON_GRENADELAUNCHER`] = {
        fracture = true,
        bleeding = true,
        severity = 5.0,
        injury = "Explosion burns"
    },
    [`WEAPON_GRENADELAUNCHER_SMOKE`] = {
        suffocating = true,
        severity = 1.0,
        injury = "Smoke suffocation"
    },
    [`WEAPON_MINIGUN`] = {
        bleeding = true,
        severity = 3.5,
        injury = "High caliber"
    },
    [`WEAPON_RAILGUN`] = {
        fracture = true,
        bleeding = true,
        severity = 6.0,
        injury = "Explosion burns"
    },
    [`WEAPON_HOMINGLAUNCHER`] = {
        fracture = true,
        bleeding = true,
        severity = 6.0,
        injury = "Explosion burns"
    },
    [`WEAPON_COMPACTLAUNCHER`] = {
        fracture = true,
        bleeding = true,
        severity = 5.0,
        injury = "Explosion burns"
    },
    [`WEAPON_RAYMINIGUN`] = {
        severity = 3.5,
        injury = "Electric shock"
    },
    [`WEAPON_EMPLAUNCHER`] = {
        severity = 2.0,
        injury = "Electric shock"
    },
    [`WEAPON_RAILGUNXM3`] = {
        fracture = true,
        bleeding = true,
        severity = 6.0,
        injury = "Explosion burns"
    },

    -- Throwables
    [`WEAPON_GRENADE`] = {
        fracture = true,
        bleeding = true,
        severity = 4.0,
        injury = "Explosion burns"
    },
    [`WEAPON_BZGAS`] = {
        suffocating = true,
        severity = 1.0,
        injury = "Smoke suffocation"
    },
    [`WEAPON_MOLOTOV`] = {
        burn = true,
        severity = 3.0,
        injury = "Third degree burns"
    },
    [`WEAPON_STICKYBOMB`] = {
        fracture = true,
        bleeding = true,
        severity = 4.0,
        injury = "Explosion burns"
    },
    [`WEAPON_PROXMINE`] = {
        fracture = true,
        bleeding = true,
        severity = 3.0,
        injury = "Explosion burns"
    },
    [`WEAPON_SNOWBALL`] = {
        severity = 0.5,
        injury = "Light impact"
    },
    [`WEAPON_PIPEBOMB`] = {
        fracture = true,
        bleeding = true,
        severity = 4.0,
        injury = "Explosion burns"
    },
    [`WEAPON_BALL`] = {
        severity = 0.3,
        injury = "Light impact"
    },
    [`WEAPON_SMOKEGRENADE`] = {
        suffocating = true,
        severity = 1.0,
        injury = "Smoke suffocation"
    },
    [`WEAPON_FLARE`] = {
        burn = true,
        severity = 2.0,
        injury = "Second degree burns"
    },
    [`WEAPON_ACIDPACKAGE`] = {
        burn = true,
        severity = 2.0,
        injury = "Second degree burns"
    },

    -- Miscellaneous
    [`WEAPON_PETROLCAN`] = {
        burn = true,
        severity = 1.0,
        injury = "Heavy impact & burns"
    },
    [`WEAPON_PARACHUTE`] = {
        fracture = true,
        severity = 1.0,
        injury = "Heavy impact & fracture"
    },
    [`WEAPON_FIREEXTINGUISHER`] = {
        suffocating = true,
        severity = 0.3,
        injury = "Suffocation"
    },
    [`WEAPON_HAZARDCAN`] = {
        burn = true,
        severity = 1.0,
        injury = "Heavy impact & burns"
    },
    [`WEAPON_FERTILIZERCAN`] = {
        burn = true,
        severity = 1.0,
        injury = "Heavy impact & burns"
    },
    [`WEAPON_ANIMAL`] = {
        bleeding = true,
        severity = 0.5,
        injury = "Animal attack"
    },
    [`WEAPON_COUGAR`] = {
        bleeding = true,
        severity = 0.8,
        injury = "Cougar attack"
    },
    [`WEAPON_BARBED_WIRE`] = {
        bleeding = true,
        severity = 0.3,
        injury = "Barbed wire"
    },
    [`WEAPON_GARBAGEBAG`] = {
        severity = 0.3,
        injury = "Light impact"
    },
    [`WEAPON_BRIEFCASE`] = {
        severity = 0.3,
        injury = "Light impact"
    },
    [`WEAPON_BRIEFCASE_02`] = {
        severity = 0.3,
        injury = "Light impact"
    },
    [`WEAPON_NIGHTVISION`] = {
        severity = 0.3,
        injury = "Light impact"
    },
    [`WEAPON_EXPLOSION`] = {
        fracture = true,
        bleeding = true,
        severity = 6.0,
        injury = "Explosion burns"
    },
    [`WEAPON_FALL`] = {
        fracture = true,
        bleeding = true,
        severity = 5.0,
        injury = "High fall"
    },
    [`WEAPON_HIT_BY_WATER_CANNON`] = {
        severity = 1.0,
        injury = "High impact"
    },
    [`WEAPON_RAMMED_BY_CAR`] = {
        fracture = true,
        bleeding = true,
        severity = 0.3,
        injury = "High impact"
    },
    [`WEAPON_RUN_OVER_BY_CAR`] = {
        fracture = true,
        bleeding = true,
        severity = 2.0,
        injury = "High impact"
    },
    [`WEAPON_HELI_CRASH`] = {
        burn = true,
        fracture = true,
        bleeding = true,
        severity = 2.0,
        injury = "High impact"
    },
    [`WEAPON_ELECTRIC_FENCE`] = {
        burn = true,
        bleeding = true,
        severity = 0.5,
        injury = "Electric shock"
    },
    [`WEAPON_FIRE`] = {
        burn = true,
        bleeding = true,
        severity = 0.5,
        injury = "Third degree burns"
    },
    [`WEAPON_DROWNING`] = {
        suffocating = true,
        severity = 1.0,
        injury = "Drowning suffocation"
    },
    [`WEAPON_DROWNING_IN_VEHICLE`] = {
        suffocating = true,
        severity = 1.0,
        injury = "Drowning suffocation"
    },
    [`WEAPON_EXHAUSTION`] = {
        suffocating = true,
        severity = 0.2,
        injury = "Exhaustion"
    },
}