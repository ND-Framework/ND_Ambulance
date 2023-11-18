# ND_Ambulance
Ambulance job for ND Framework

```lua
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
["bandage2"] = {
    label = "Bandage",
    weight = 115,
    description = "Wrap gauze with this",
    server = {
        export = "ND_Ambulance.bandage2"
    },
    client = {
        anim = { dict = "missheistdockssetup1clipboard@idle_a", clip = "idle_a", flag = 49 },
        prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
        disable = { move = true, car = true, combat = true },
        usetime = 2500
    },
    buttons = {
        {
            label = "Use on nearby player",
            action = function(slot)
                TriggerServerEvent("ND_Ambulance:useOnNearby", "bandage2", slot)
            end
        }
    }
},
["gauze"] = {
    label = "Gauze",
    weight = 80,
    description = "Cover wounds with this.",
    server = {
        export = "ND_Ambulance.gauze"
    },
    client = {
        anim = { dict = "missheistdockssetup1clipboard@idle_a", clip = "idle_a", flag = 49 },
        prop = { model = `prop_toilet_roll_01`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
        disable = { move = true, car = true, combat = true },
        usetime = 2500
    },
    buttons = {
        {
            label = "Use on nearby player",
            action = function(slot)
                TriggerServerEvent("ND_Ambulance:useOnNearby", "gauze", slot)
            end
        }
    }
},
["tourniquet"] = {
    label = "Tourniquet",
    weight = 85,
    description = "Slow down bleeding a lot.",
    server = {
        export = "ND_Ambulance.tourniquet"
    },
    client = {
        anim = { dict = "missheistdockssetup1clipboard@idle_a", clip = "idle_a", flag = 49 },
        prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
        disable = { move = true, car = true, combat = true },
        usetime = 2500
    },
    buttons = {
        {
            label = "Use on nearby player",
            action = function(slot)
                TriggerServerEvent("ND_Ambulance:useOnNearby", "tourniquet", slot)
            end
        }
    }
},
["medkit"] = {
    label = "Medkit",
    weight = 600,
    description = "Once all injuries are taken care of you can use this to replenish health.",
    server = {
        export = "ND_Ambulance.medkit"
    },
    client = {
        anim = { dict = "missheistdockssetup1clipboard@idle_a", clip = "idle_a", flag = 49 },
        prop = { model = `prop_ld_health_pack`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
        disable = { move = true, car = true, combat = true },
        usetime = 2500
    },
    buttons = {
        {
            label = "Use on nearby player",
            action = function(slot)
                TriggerServerEvent("ND_Ambulance:useOnNearby", "medkit", slot)
            end
        }
    }
},
```
