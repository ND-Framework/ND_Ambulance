local function check(injuries)
    for _, limb in pairs(injuries) do
        if not limb.usedGauze and limb.bleeding and not limb.usedBandage and limb.severity then
            limb.usedGauze = true
            return limb.label
        end
    end
end

local function use(target)
    if not target then
        return false, {
            title = "Error",
            description = "No player found.",
            type = "error"
        }
    end

    local state = Player(target).state
    local injuries = state.injuries
    if not injuries then
        return false, {
            title = "Error",
            description = "No injuries found.",
            type = "error"
        }
    end

    local limbName = check(injuries)
    if not limbName then
        return false, {
            title = "Error",
            description = "No wounds found.",
            type = "error"
        }
    end

    return injuries, {
        title = "Success",
        description = ("Used gauze on wounds on %s."):format(limbName),
        type = "success"
    }
end

function UseNearbyItems.gauze(src)
    local target = GetNearestPlayer(src)
    local result, info = use(target)
    if result then
        local state = Player(target).state
        state:set("injuries", result, true)
    end
    return result, info, target
end

exports("gauze", function(event, item, inventory, slot, data)
    if event == "usingItem" then
        local result, info = use(inventory.id)
        if not result then            
            local player = NDCore.getPlayer(inventory.id)
            player.notify(info)
        end
        return result
    end
    
    if event == "usedItem" then        
        local result, info = use(inventory.id)
        if result then
            local state = Player(inventory.id).state
            state:set("injuries", result, true)
        end
        local player = NDCore.getPlayer(inventory.id)
        player.notify(info)
    end
end)
