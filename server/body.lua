lib.callback.register("ND_Ambulance:syncDragBody", function(src, target)
    local targetPlayer = NDCore.getPlayer(target)
    if not targetPlayer then return end

    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(target))

    if not playerCoords or not targetCoords or #(playerCoords-targetCoords) > 10.0 then return end
    targetPlayer.triggerEvent("ND_Ambulance:syncDragBody", src)
    return true
end)

RegisterNetEvent("ND_Ambulance:syncDragBody", function(target)
    local src = source
    local targetPlayer = NDCore.getPlayer(target)
    if not targetPlayer then return end

    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(target))

    if not playerCoords or not targetCoords or #(playerCoords-targetCoords) > 10.0 then return end
    targetPlayer.triggerEvent("ND_Ambulance:syncDragBody", target, true)
end)
