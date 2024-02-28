# ND_Ambulance
Ambulance job for ND Framework.

# Credits
* Tiddy's Factory for providing the stretchers and defibrillator from their [medical prop pack](https://gta5-mods.com/tools/medical-prop-pack)
* This resource is configured with the two Ambulance vehicles from [MRSA Pack](https://www.gta5-mods.com/vehicles/medical-response-san-andreas-mrsa-pack/) (can be changed in data/vehicles)

# Features
* stretcher system
* injury system
* defibrillator & cpr
* medbag
* treatment items (gauze, burndresing, splint, tourniquet)
* carry players
* hospital system
* death screens

## Items
```lua
["stretcher"] = {
    label = "Stretcher",
    weight = 15000,
    stack = false,
    consume = 1,
    server = {
        export = "ND_Ambulance.createStretcher"
    }
},
["defib"] = {
    label = "Monitor/defibrillator",
    weight = 8000,
    stack = false,
    consume = 1,
    client = {
        export = "ND_Ambulance.useDefib",
        add = function(total)
            if total > 0 then
                pcall(function()
                    return exports["ND_Ambulance"]:hasDefib(true)
                end)
            end
        end,
        remove = function(total)
            if total < 1 then
                pcall(function()
                    return exports["ND_Ambulance"]:hasDefib(false)
                end)
            end
        end
    }
},
["medbag"] = {
    label = "Trauma bag",
    weight = 1000,
    stack = false,
    consume = 1,
    server = {
        export = "ND_Ambulance.useBag"
    },
    client = {
        export = "ND_Ambulance.useBag",
        add = function(total)
            if total > 0 then
                pcall(function()
                    return exports["ND_Ambulance"]:bag(true)
                end)
            end
        end,
        remove = function(total)
            if total < 1 then
                pcall(function()
                    return exports["ND_Ambulance"]:bag(false)
                end)
            end
        end
    }
},
["burndressing"] = {
    label = "Burn Dressing",
    weight = 50,
    server = {
        export = "ND_Ambulance.treatment"
    },
    client = {
        anim = { dict = "missheistdockssetup1clipboard@idle_a", clip = "idle_a", flag = 49 },
        prop = { model = `prop_toilet_roll_01`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
        disable = { move = true, car = true, combat = true },
        usetime = 2500
    }
},
["splint"] = {
    label = "Splint",
    weight = 500,
    server = {
        export = "ND_Ambulance.treatment"
    },
    client = {
        anim = { dict = "missheistdockssetup1clipboard@idle_a", clip = "idle_a", flag = 49 },
        prop = { model = `prop_toilet_roll_01`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
        disable = { move = true, car = true, combat = true },
        usetime = 2500
    }
},
["gauze"] = {
    label = "Gauze",
    weight = 80,
    server = {
        export = "ND_Ambulance.treatment"
    },
    client = {
        anim = { dict = "missheistdockssetup1clipboard@idle_a", clip = "idle_a", flag = 49 },
        prop = { model = `prop_toilet_roll_01`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
        disable = { move = true, car = true, combat = true },
        usetime = 2500
    }
},
["tourniquet"] = {
    label = "Tourniquet",
    weight = 85,
    server = {
        export = "ND_Ambulance.treatment"
    },
    client = {
        anim = { dict = "missheistdockssetup1clipboard@idle_a", clip = "idle_a", flag = 49 },
        prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
        disable = { move = true, car = true, combat = true },
        usetime = 2500
    }
},
```
