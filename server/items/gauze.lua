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
    
    local injuries = InjuredPlayers[target]
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

    return true, {
        title = "Success",
        description = ("Used gauze on wounds on %s."):format(limbName),
        type = "success"
    }
end

function UseNearbyItems.gauze(src)
    local target = GetNearestPlayer(src)
    local result, info = use(target)
    TriggerClientEvent("ND_Ambulance:updateInfo", target, InjuredPlayers[target])
    return result, info, target
end

exports("gauze", function(event, item, inventory, slot, data)
    if event ~= "usingItem" then return end
    
    local result, info = use(inventory.id)
    local player = NDCore.getPlayer(inventory.id)
    player.notify(info)
    
    if result then
        TriggerClientEvent("ND_Ambulance:updateInfo", inventory.id, InjuredPlayers[inventory.id])
    end
    return result
end)
