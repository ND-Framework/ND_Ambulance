local function check(injuries)
    for bone, limb in pairs(injuries) do
        if limb.canUseTourniquet and not limb.usedTourniquet and limb.severity and limb.bleeding and limb.bleeding > 0 then
            limb.bleeding = limb.bleeding/2
            limb.severity -= limb.bleeding
            limb.usedTourniquet = true
            return limb.label
        end
    end
end

local function use(target)
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
            description = "No injuries found that can use a tourniquet.",
            type = "error"
        }
    end

    return true, {
        title = "Success",
        description = ("Used tourniquet to slow down bleeding on %s."):format(limbName),
        type = "success"
    }
end

function UseNearbyItems.tourniquet(src)
    local target = GetNearestPlayer(src)
    local result, info = use(target)
    TriggerClientEvent("ND_Ambulance:updateInfo", target, InjuredPlayers[target])
    return result, info, target
end

exports("tourniquet", function(event, item, inventory, slot, data)
    if event ~= "usingItem" then return end
    
    local result, info = use(inventory.id)
    local player = NDCore.getPlayer(inventory.id)
    player.notify(info)
    
    if result then
        TriggerClientEvent("ND_Ambulance:updateInfo", inventory.id, InjuredPlayers[inventory.id])
    end
    return result
end)
