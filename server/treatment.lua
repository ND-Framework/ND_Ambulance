Treatment = {}

local injuryTreatment = {
    fracture = {"splint"},
    burn = {"burndressing"},
    bleeding = {"tourniquet", "gauze"}
}

exports("treatment", function(event, item, inventory, slot, data)
    local treatment = Treatment[item.name]
    if not treatment then return false end

    if event == "usingItem" then
        local result, info = treatment(inventory.id)
        if not result then
            local player = NDCore.getPlayer(inventory.id)
            player.notify(info)
        end
        return result
    end
    
    if event == "usedItem" then
        local result, info = treatment(inventory.id)
        if result then
            local state = Player(inventory.id).state
            state:set("injuries", result, true)
        end
        local player = NDCore.getPlayer(inventory.id)
        player.notify(info)
    end
end)

local function useItem(src, target, item)
    local result, info = Treatment[item](target)
    if result then
        local state = Player(target).state
        state:set("injuries", result, true)
    end
    return result, info, target
end

local function tryTreatment(src, targetPlayerSrc, item)
    if not Treatment[item] or exports.ox_inventory:GetItemCount(src, item) == 0 then return end

    local success, info, target = useItem(src, targetPlayerSrc, item)
    if target then
        local player = NDCore.getPlayer(target)
        player.notify(info)
    end

    if not success then return end
    exports.ox_inventory:RemoveItem(src, item, 1)
    return true
end

RegisterNetEvent("ND_Ambulance:useOnNearby", function(targetPlayerSrc, injury)
    local src = source
    targetPlayerSrc = tonumber(targetPlayerSrc)
    if not targetPlayerSrc then return end

    local treatment = injuryTreatment[injury]
    if not treatment then return end

    for i=1, #treatment do
        local item = treatment[i]
        if tryTreatment(src, targetPlayerSrc, item) then
            break
        end
    end
end)
