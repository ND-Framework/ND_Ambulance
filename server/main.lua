local data_death = require("data.death")

local function isNearHospitalPed(coords)
    for i=1, #data_death.hospitalPeds do
        local location = data_death.hospitalPeds[i]
        if #(coords-location.xyz) < 5 then
            return true
        end
    end
end

local function getEntityFromNetId(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    local time = os.time()
    while not DoesEntityExist(entity) and os.time()-time < 5 do Wait(100) end
    return entity
end

RegisterNetEvent("ND_Ambulance:respawnPlayer", function()
    local src = source
    local state = Player(src).state
    local time = os.time()
    if not state or time-state.timeSinceDeath < data_death.timer then return end

    local player = NDCore.getPlayer(src)
    if not player then return end
    player.revive()

    if not data_death.dropInventory then return end
    exports.ox_inventory:CreateDropFromPlayer(src)
end)

RegisterNetEvent("ND_Ambulance:treatSelf", function()
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local player = NDCore.getPlayer(src)
    if not player or not isNearHospitalPed(coords) then return end

    local price = data_death.prices.selfHeal
    if player.bank < price and player.cash < price then
        return player.notify("Not enough money")
    end

    if player.bank >= price then
        player.deductMoney("bank", price, "Hospital bill")
    elseif player.cash >= price then
        player.deductMoney("cash", price, "Hospital bill")
    end

    player.revive()
    player.notify("Succesfully healed!")
end)

RegisterNetEvent("ND_Ambulance:treatPatient", function(targetSrc, stretcherNetId)
    local src = source
    targetSrc = tonumber(targetSrc)
    if not targetSrc then return end
    
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local player = NDCore.getPlayer(src)

    local targetPed = GetPlayerPed(targetSrc)
    local targetCoords = GetEntityCoords(targetPed)
    local targetPlayer = NDCore.getPlayer(targetSrc)
    local entity = getEntityFromNetId(stretcherNetId)

    if not player or not targetPlayer or not isNearHospitalPed(coords) or not isNearHospitalPed(targetCoords) or not DoesEntityExist(entity) then return end

    local state = Entity(entity).state
    state:set("ambulanceStretcherPlayer", false, true)
    player.notify("Succesfully treated patient!")

    local price = data_death.prices.selfHeal
    if targetPlayer.bank >= price then
        targetPlayer.deductMoney("bank", price, "Hospital bill")
    elseif player.cash >= price then
        targetPlayer.deductMoney("cash", price, "Hospital bill")
    end

    TriggerClientEvent("ND_Ambulance:respawnHospital", targetSrc)
    Wait(700)

    targetPlayer.revive()
    targetPlayer.notify("Succesfully healed!")
end)

RegisterNetEvent("ND_Ambulance:successDefib", function(targetPlayerSrc)
    local src = source
    targetPlayerSrc = tonumber(targetPlayerSrc)
    if not targetPlayerSrc then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local targetPed = GetPlayerPed(targetPlayerSrc)
    local targetCoords = GetEntityCoords(targetPed)
    local state = Player(targetPlayerSrc).state
    if src == targetPlayerSrc or #(coords-targetCoords) > 10 or state.isDead ~= "eliminated" or os.time()-state.timeSinceDeath > 30 then return end
    TriggerClientEvent("ND_Ambulance:successDefib", targetPlayerSrc)
end)

RegisterNetEvent("ND_Ambulance:pickupDefib", function()
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local objects = lib.getNearbyObjects(coords, 2.0)
    for i=1, #objects do
        local entity = objects[i].object
        if DoesEntityExist(entity) and GetEntityModel(entity) == `lifepak15` then
            DeleteEntity(entity)
            return exports.ox_inventory:AddItem(src, "defib", 1)
        end
    end
end)

exports.ox_inventory:registerHook("swapItems", function(payload)
    if payload.toType ~= "player" or payload.fromInventory == payload.toInventory then return end
    return exports.ox_inventory:GetItemCount(payload.toInventory, "defib") == 0
end, {
    itemFilter = {
        defib = true
    }
})
