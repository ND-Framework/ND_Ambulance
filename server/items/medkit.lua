local function check(injuries)
    for bone, limb in pairs(injuries) do
        if limb.bleeding and limb.severity and limb.severity > 0 then
            return true
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

    local player = NDCore.getPlayer(target)
    local ped = GetPlayerPed(target)
    local maxHealth = GetEntityMaxHealth(ped)
    local health = GetEntityHealth(ped)

    if health < maxHealth then
        return true, {
            title = "Success",
            description = "Medkit used successfully",
            type = "success"
        }
    end

    local state = Player(target).state
    local injuries = state.injuries
    if not injuries or not check(injuries) then
        return false, {
            title = "Error",
            description = "No injuries found.",
            type = "error"
        }
    end

    return true, {
        title = "Success",
        description = "Medkit used successfully",
        type = "success"
    }
end

function UseNearbyItems.medkit(src)
    local target = GetNearestPlayer(src)
    local result, info = use(target)
    if result then
        local player = NDCore.getPlayer(target)
        if player and player.metadata.dead then
            player.revive()
        else
            TriggerClientEvent("ND_Ambulance:useMedkit", target)
        end
    end
    return result, info, target
end

exports("medkit", function(event, item, inventory, slot, data)
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
        local player = NDCore.getPlayer(inventory.id)
        player.notify(info)
    
        if result then
            if player and player.metadata.dead then
                player.revive()
            else
                TriggerClientEvent("ND_Ambulance:useMedkit", inventory.id)
            end
        end
    end
end)
