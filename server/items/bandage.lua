local function check(injuries)
    for bone, limb in pairs(injuries) do
        if limb.usedGauze and limb.bleeding and limb.severity and limb.severity > 0 then
            if limb.bleeding > 0 and limb.bleeding < 1.0 then
                if limb.severity then
                    limb.severity -= limb.bleeding
                end
                limb.bleeding = nil
            elseif limb.bleeding > 0 then
                limb.bleeding -= 1.0
                limb.severity -= 1.0
            end
            limb.usedBandage = true
            SetTimeout(500, function()
                if limb.severity == 0 then
                    injuries[bone] = nil
                end
            end)
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
            description = "You need to use gauze before bandage.",
            type = "error"
        }
    end

    return true, {
        title = "Success",
        description = ("Used bandage to hold together gauze on %s."):format(limbName),
        type = "success"
    }
end

function UseNearbyItems.bandage2(src)
    local target = GetNearestPlayer(src)
    local result, info = use(target)
    TriggerClientEvent("ND_Ambulance:updateInfo", target, InjuredPlayers[target])
    return result, info, target
end

exports("bandage2", function(event, item, inventory, slot, data)
    if event ~= "usingItem" then return end
    
    local result, info = use(inventory.id)
    local player = NDCore.getPlayer(inventory.id)
    player.notify(info)

    if result then
        TriggerClientEvent("ND_Ambulance:updateInfo", inventory.id, InjuredPlayers[inventory.id])
    end
    return result
end)
