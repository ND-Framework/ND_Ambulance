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

local function allowCheck(src, targetPlayerSrc)
    targetPlayerSrc = tonumber(targetPlayerSrc)
    if not targetPlayerSrc then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local targetPed = GetPlayerPed(targetPlayerSrc)
    local targetCoords = GetEntityCoords(targetPed)
    local state = Player(targetPlayerSrc).state
    if src == targetPlayerSrc or #(coords-targetCoords) > 10 or state.isDead ~= "eliminated" then return end

    return true
end

RegisterNetEvent("ND_Ambulance:sendSignal", function(location, coords)
    local src = source
    print("Distress signal sent by", src, GetPlayerName(src))

    if not location or not coords or type(location) ~= "string" or type(coords) ~= "vector3" then
        return
    end

    if GetResourceState("ND_MDT") ~= "started" then return end

    exports["ND_MDT"]:createDispatch({
        callDescription = "Distress signal EMS needed!",
        location = location,
        coords = coords
    })
end)

RegisterNetEvent("ND_Ambulance:respawnPlayer", function()
    local src = source
    local state = Player(src).state
    local time = os.time()
    if not state?.timeSinceDeath or time-state.timeSinceDeath < data_death.timer then return end

    Bridge.revivePlayer(src)

    if not data_death.dropInventory then return end
    exports.ox_inventory:CreateDropFromPlayer(src)
end)

RegisterNetEvent("ND_Ambulance:treatSelf", function()
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local player = Bridge.getPlayer(src)
    if not player or not isNearHospitalPed(coords) then return end

    local price = data_death.prices.selfHeal

    if not Bridge.hasMoney(src, price) then
        return Bridge.notify(src, {
            title = "Not enough money",
            type = "error"
        })
    end

    Bridge.deductMoney(src, price)

    TriggerClientEvent("ND_Ambulance:respawnHospital", src)
    Wait(1000)

    Bridge.revivePlayer(src)
    Bridge.notify(src, {
        title = "Succesfully healed!",
        type = "success"
    })
end)

RegisterNetEvent("ND_Ambulance:treatPatient", function(targetSrc, stretcherNetId)
    local src = source
    targetSrc = tonumber(targetSrc)
    if not targetSrc then return end
    
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local player = Bridge.getPlayer(src)

    local targetPed = GetPlayerPed(targetSrc)
    local targetCoords = GetEntityCoords(targetPed)
    local targetPlayer = Bridge.getPlayer(targetSrc)

    if stretcherNetId then
        local entity = getEntityFromNetId(stretcherNetId)
        if not DoesEntityExist(entity) then return end
        local state = Entity(entity).state
        state:set("ambulanceStretcherPlayer", false, true)
    end

    if not player or not targetPlayer or not isNearHospitalPed(coords) or not isNearHospitalPed(targetCoords) then return end
    
    Bridge.notify(src, {
        title = "Succesfully treated patient!",
        type = "success"
    })

    local price = data_death.prices.selfHeal

    Bridge.deductMoney(targetSrc, price)

    TriggerClientEvent("ND_Ambulance:respawnHospital", targetSrc)
    Wait(700)

    Bridge.revivePlayer(targetSrc)
    Bridge.notify(targetSrc, {
        title = "Succesfully healed!",
        type = "success"
    })
end)

RegisterNetEvent("ND_Ambulance:startCpr", function(targetPlayerSrc)
    local src = source
    if not allowCheck(src, targetPlayerSrc) then return end
    
    local playerState = Player(src).state
    playerState:set("performingCpr", targetPlayerSrc, false)

    local state = Player(targetPlayerSrc).state
    local cprData = state.cprData or {}
    state:set("cprData", {
        ongoing = true,
        started = cprData.started or os.time(),
        stopped = false
    }, true)
    
    local changed = false
    local injuries = state.injuries
    for bone, limb in pairs(injuries) do
        if limb and limb.suffocating and limb.severity and limb.severity > 0 then
            limb.severity -= limb.suffocating
            limb.suffocating = nil
            changed = true
        end
    end

    if changed then
        state:set("injuries", injuries, true)
    end
end)

RegisterNetEvent("ND_Ambulance:stopCpr", function(targetPlayerSrc)
    local src = source
    if not allowCheck(src, targetPlayerSrc) then return end
    
    local playerState = Player(src).state
    playerState:set("performingCpr", nil, false)

    local state = Player(targetPlayerSrc).state
    local cprData = state.cprData or {}
    local time = os.time()
    state:set("cprData", {
        ongoing = false,
        started = cprData.started or time,
        stopped = time
    }, true)
end)

RegisterNetEvent("ND:characterUnloaded", function(src, character)
    local playerState = Player(src).state
    if not playerState.performingCpr then return end

    local state = Player(playerState.performingCpr).state
    if state.cprData then        
        local cprData = state.cprData or {}
        local time = os.time()
        state:set("cprData", {
            ongoing = false,
            started = cprData.started or time,
            stopped = time
        }, true)
    end

    playerState:set("performingCpr", nil, false)
end)

RegisterNetEvent("ND_Ambulance:successDefib", function(targetPlayerSrc)
    local src = source
    local state = Player(targetPlayerSrc).state
    if not allowCheck(src, targetPlayerSrc) then return end
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

if Bridge.setDeadMetadata then
    RegisterNetEvent("ND_Ambulance:playerEliminated", function(info)
        local src = source
        Bridge.setDeadMetadata(src, info)
    end)    
end
