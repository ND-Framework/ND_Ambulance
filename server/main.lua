UseNearbyItems = {}

function GetNearestPlayer(src)
    local pedCoords = GetEntityCoords(GetPlayerPed(src))
    for _, player in ipairs(GetPlayers()) do
        local target = tonumber(player)
        local targetPed = GetPlayerPed(target)
        local targetCoords = GetEntityCoords(targetPed)
        if #(pedCoords - targetCoords) <= 2.0 and target ~= src then
            return target, targetPed, targetCoords
        end
    end
end

RegisterNetEvent("ND_Ambulance:useOnNearby", function(item, slot)
    local src = source
    local func = UseNearbyItems[item]
    if not func then return end

    local success, info, target = func(src)
    if target then
        local player = NDCore.getPlayer(target)
        player.notify(info)
    end

    if not success then return end
    exports.ox_inventory:RemoveItem(src, item, 1, nil, slot)
end)
